#requires -Version 5.1
<#
.SYNOPSIS
    构建企业门户网站实验部署包 website-package.zip。

.DESCRIPTION
    依次执行：
      1. Maven 打包后端，得到 ruoyi-admin/target/website.jar
      2. npm 构建前端，得到 ruoyi-ui/dist
      3. 组装 dist/website-package/ 并生成 dist/website-package.zip

    产物结构严格对应《课题4-大型网站》实验手册：
      website-package/website.jar
      website-package/website-frontend.zip
      website-package/config/connection.conf
      website-package/config/application.yml
      website-package/config/application-druid.yml
      website-package/sql/*.sql
      website-package/systemd/website.service
      website-package/start.sh / stop.sh / check.sh

.PARAMETER Maven
    Maven 可执行文件。默认使用 PATH 中的 mvn，也可以传完整路径。

.PARAMETER RunTests
    运行后端单元测试。默认跳过测试，与实验手册的 mvn package -DskipTests 一致。

.PARAMETER SkipFrontend
    跳过 npm 构建，直接使用已有的 ruoyi-ui/dist。

.PARAMETER SkipNpmInstall
    跳过 npm install，直接使用已有的 node_modules。

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\deploy\build-package.ps1

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\deploy\build-package.ps1 `
      -Maven "C:\apache-maven-3.9.9\bin\mvn.cmd"
#>
[CmdletBinding()]
param(
    [string]$Maven = "mvn",
    [switch]$RunTests,
    [switch]$SkipFrontend,
    [switch]$SkipNpmInstall
)

$ErrorActionPreference = "Stop"

$DeployDir    = $PSScriptRoot
$RepoRoot     = Split-Path -Parent $DeployDir
$TemplateDir  = Join-Path $DeployDir "package"
$OutputDir    = Join-Path $RepoRoot "dist"
$PackageDir   = Join-Path $OutputDir "website-package"
$PackageZip   = Join-Path $OutputDir "website-package.zip"
$FrontendDist = Join-Path $RepoRoot "ruoyi-ui\dist"
$FrontendZip  = Join-Path $PackageDir "website-frontend.zip"
$JarPath      = Join-Path $RepoRoot "ruoyi-admin\target\website.jar"

function Write-Step([string]$Message) {
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Fail([string]$Message) {
    throw "[FAIL] $Message"
}

function Resolve-Executable([string]$Name) {
    if (Test-Path $Name) {
        return (Resolve-Path $Name).Path
    }
    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }
    return $null
}

function Convert-ToLf([string]$Path) {
    if (-not (Test-Path $Path)) { return }
    $text = [System.IO.File]::ReadAllText($Path)
    $text = $text.Replace("`r`n", "`n").Replace("`r", "`n")
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $text, $utf8NoBom)
}

# 生成 zip。CreateFromDirectory 在 Windows 上会把条目名写成反斜杠，
# 这里改用 ZipArchive 逐文件写入，确保压缩包内统一使用正斜杠，
# 与实验手册提供的 website-package.zip 结构一致。
function New-ZipFromDirectory {
    param(
        [Parameter(Mandatory = $true)][string]$SourceDirectory,
        [Parameter(Mandatory = $true)][string]$DestinationArchive,
        [switch]$IncludeBaseDirectory
    )

    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $SourceFull = (Resolve-Path $SourceDirectory).Path.TrimEnd('\', '/')
    $BaseName = Split-Path -Leaf $SourceFull
    $Files = @(Get-ChildItem -Path $SourceFull -Recurse -File | Sort-Object FullName)

    if (Test-Path $DestinationArchive) {
        Remove-Item -Path $DestinationArchive -Force
    }

    $Stream = [System.IO.File]::Open(
        $DestinationArchive,
        [System.IO.FileMode]::CreateNew,
        [System.IO.FileAccess]::ReadWrite
    )
    try {
        $Archive = New-Object System.IO.Compression.ZipArchive(
            $Stream,
            [System.IO.Compression.ZipArchiveMode]::Create,
            $false
        )
        try {
            foreach ($File in $Files) {
                $Relative = $File.FullName.Substring($SourceFull.Length).TrimStart('\', '/').Replace('\', '/')
                if ($IncludeBaseDirectory) {
                    $Relative = "$BaseName/$Relative"
                }
                $Entry = $Archive.CreateEntry($Relative, [System.IO.Compression.CompressionLevel]::Optimal)
                $Entry.LastWriteTime = $File.LastWriteTime
                $EntryStream = $Entry.Open()
                try {
                    $FileStream = [System.IO.File]::OpenRead($File.FullName)
                    try {
                        $FileStream.CopyTo($EntryStream)
                    } finally {
                        $FileStream.Dispose()
                    }
                } finally {
                    $EntryStream.Dispose()
                }
            }
        } finally {
            $Archive.Dispose()
        }
    } finally {
        $Stream.Dispose()
    }
}

Write-Host "============================================================"
Write-Host "  企业门户网站部署包构建"
Write-Host "  仓库：$RepoRoot"
Write-Host "============================================================"

Write-Step "检查构建环境"

$JavaExe = Resolve-Executable "java"
if (-not $JavaExe) { Fail "找不到 java，请安装 JDK 17 并加入 PATH。" }

$OldErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$JavaVersionText = (& $JavaExe -version 2>&1 | Out-String)
$ErrorActionPreference = $OldErrorActionPreference
if ($JavaVersionText -match 'version "(\d+)') {
    $JavaMajor = [int]$Matches[1]
    if ($JavaMajor -lt 17) {
        Fail "当前 Java 主版本为 $JavaMajor，需要 JDK 17 或更高版本。"
    }
    Write-Host "Java：$JavaMajor"
} else {
    Write-Warning "无法识别 Java 版本，继续构建：$JavaVersionText"
}

$MavenExe = Resolve-Executable $Maven
if (-not $MavenExe) {
    Fail "找不到 Maven（$Maven）。请安装 Maven 3.8+，或用 -Maven 指定 mvn.cmd 的完整路径。"
}
Write-Host "Maven：$MavenExe"

if (-not $SkipFrontend) {
    $NpmExe = Resolve-Executable "npm"
    if (-not $NpmExe) { Fail "找不到 npm，请安装 Node.js 20 LTS+。" }
    Write-Host "npm：$NpmExe"
}

Write-Step "1/4 Maven 打包后端"

Push-Location $RepoRoot
try {
    $MavenArgs = @("clean", "package")
    if (-not $RunTests) {
        $MavenArgs += "-DskipTests"
    }
    & $MavenExe @MavenArgs
    if ($LASTEXITCODE -ne 0) {
        Fail "Maven 构建失败，退出码 $LASTEXITCODE。"
    }
} finally {
    Pop-Location
}

if (-not (Test-Path $JarPath)) {
    Fail "Maven 构建结束，但找不到 $JarPath。请确认 ruoyi-admin/pom.xml 的 finalName 为 website。"
}
$JarSize = (Get-Item $JarPath).Length
if ($JarSize -lt 1MB) {
    Fail "website.jar 大小异常（$JarSize 字节），构建可能不完整。"
}
Write-Host ("website.jar：{0:N1} MB" -f ($JarSize / 1MB))

Write-Step "2/4 构建前端"

if (-not $SkipFrontend) {
    Push-Location (Join-Path $RepoRoot "ruoyi-ui")
    try {
        if (-not $SkipNpmInstall) {
            & $NpmExe install --no-audit --no-fund
            if ($LASTEXITCODE -ne 0) {
                Fail "npm install 失败，退出码 $LASTEXITCODE。"
            }
        }
        & $NpmExe run build:prod
        if ($LASTEXITCODE -ne 0) {
            Fail "npm run build:prod 失败，退出码 $LASTEXITCODE。"
        }
    } finally {
        Pop-Location
    }
} else {
    Write-Host "已跳过前端构建（-SkipFrontend）。"
}

if (-not (Test-Path (Join-Path $FrontendDist "index.html"))) {
    Fail "找不到 $FrontendDist\index.html，前端构建没有完成。"
}

Write-Step "3/4 组装 website-package 目录"

if (Test-Path $PackageDir) {
    Remove-Item -Path $PackageDir -Recurse -Force
}
New-Item -ItemType Directory -Path $PackageDir -Force | Out-Null

if (-not (Test-Path $TemplateDir)) {
    Fail "找不到部署包模板目录 $TemplateDir。"
}
Copy-Item -Path (Join-Path $TemplateDir "*") -Destination $PackageDir -Recurse -Force

Copy-Item -Path $JarPath -Destination (Join-Path $PackageDir "website.jar") -Force

$SqlDir = Join-Path $PackageDir "sql"
New-Item -ItemType Directory -Path $SqlDir -Force | Out-Null
Copy-Item -Path (Join-Path $RepoRoot "sql\ry_20260417.sql") -Destination $SqlDir -Force
Copy-Item -Path (Join-Path $RepoRoot "sql\quartz.sql") -Destination $SqlDir -Force

# 确保 Linux 脚本和配置是 LF，避免在 openEuler 上出现 \r 错误
Convert-ToLf (Join-Path $PackageDir "start.sh")
Convert-ToLf (Join-Path $PackageDir "stop.sh")
Convert-ToLf (Join-Path $PackageDir "check.sh")
Convert-ToLf (Join-Path $PackageDir "config\connection.conf")
Convert-ToLf (Join-Path $PackageDir "config\application.yml")
Convert-ToLf (Join-Path $PackageDir "config\application-druid.yml")
Convert-ToLf (Join-Path $PackageDir "systemd\website.service")
Convert-ToLf (Join-Path $PackageDir "README-部署说明.md")

Write-Step "4/4 生成前端包和部署包"

Add-Type -AssemblyName System.IO.Compression.FileSystem

New-ZipFromDirectory -SourceDirectory $FrontendDist -DestinationArchive $FrontendZip
New-ZipFromDirectory -SourceDirectory $PackageDir -DestinationArchive $PackageZip -IncludeBaseDirectory

# 校验压缩包内的关键路径，防止顶层目录或文件名不符合实验手册
$RequiredEntries = @(
    "website-package/website.jar",
    "website-package/website-frontend.zip",
    "website-package/start.sh",
    "website-package/stop.sh",
    "website-package/check.sh",
    "website-package/config/connection.conf",
    "website-package/config/application.yml",
    "website-package/config/application-druid.yml",
    "website-package/sql/ry_20260417.sql",
    "website-package/sql/quartz.sql",
    "website-package/systemd/website.service"
)
$Zip = [System.IO.Compression.ZipFile]::OpenRead($PackageZip)
try {
    $RawEntries = @($Zip.Entries | ForEach-Object { $_.FullName })
} finally {
    $Zip.Dispose()
}
$BackslashEntries = @($RawEntries | Where-Object { $_.Contains('\') })
if ($BackslashEntries.Count -gt 0) {
    Fail "部署包内存在反斜杠路径，Linux 解压可能出错：`n$($BackslashEntries -join "`n")"
}
$Entries = @($RawEntries | ForEach-Object { $_.Replace('\', '/') })
foreach ($Required in $RequiredEntries) {
    if ($Entries -notcontains $Required) {
        Fail "部署包缺少 $Required。当前包内文件：`n$($Entries -join "`n")"
    }
}

$Hash = Get-FileHash -Path $PackageZip -Algorithm SHA256
Write-Host ""
Write-Host "============================================================"
Write-Host "  打包完成"
Write-Host "  部署包：$PackageZip"
Write-Host "  前端包：$FrontendZip"
Write-Host "  SHA256：$($Hash.Hash)"
Write-Host ""
Write-Host "  上传到实验机：/opt/packages/website-package.zip"
Write-Host "  后端安装脚本：deploy\03-backend\01-website-install.sh"
Write-Host "  数据库脚本：  deploy\01-database\05-mysql-init-website-db.sh"
Write-Host "  Nginx 配置：  deploy\nginx\00-upstream.conf、deploy\nginx\portal.conf"
Write-Host "============================================================"

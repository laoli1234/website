<template>
  <div class="app-container portal-home">
    <!-- 欢迎区 -->
    <section class="welcome">
      <div class="welcome-grid"></div>
      <div class="welcome-glow"></div>

      <div class="welcome-copy">
        <p class="eyebrow">WELCOME BACK · {{ todayText }}</p>
        <h1>你好，{{ displayName }}</h1>
        <p class="slogan">追求<span>卓越</span>，奋勇<span>争先</span></p>
        <p class="desc">
          欢迎回到联想科技企业门户。这里聚合了组织协同、系统管理与业务洞察的入口，
          愿你今天也能把复杂的事情，做得简单而可靠。
        </p>
        <div class="actions">
          <button class="btn primary" @click="openPortal">访问企业官网</button>
          <button class="btn ghost" @click="router.push('/user/profile')">个人中心</button>
        </div>
      </div>

      <div class="welcome-orbit">
        <svg viewBox="0 0 360 360" aria-hidden="true">
          <g stroke="rgba(140,190,230,.2)" fill="none">
            <circle cx="180" cy="180" r="160" />
            <circle cx="180" cy="180" r="120" stroke-dasharray="2 8" />
            <circle cx="180" cy="180" r="78" />
            <line x1="20" y1="180" x2="340" y2="180" />
            <line x1="180" y1="20" x2="180" y2="340" />
          </g>
          <g class="ring" stroke="#35e3c8" fill="none" stroke-width="1.5">
            <circle cx="180" cy="180" r="120" stroke-dasharray="78 300" stroke-linecap="round" />
          </g>
          <g fill="#35e3c8">
            <circle cx="180" cy="60" r="3" />
            <circle cx="290" cy="240" r="3" />
            <circle cx="86" cy="262" r="3" />
          </g>
          <circle cx="180" cy="180" r="40" fill="rgba(8,18,32,.85)" stroke="rgba(53,227,200,.45)" />
          <text x="180" y="190" text-anchor="middle" font-size="26" fill="#e9f4ff" font-family="Songti SC, STSong, serif">联</text>
        </svg>
      </div>
    </section>

    <!-- 概览数据 -->
    <div class="stat-row">
      <div v-for="s in stats" :key="s.label" class="stat">
        <el-icon class="stat-icon"><component :is="s.icon" /></el-icon>
        <div>
          <strong :class="{ small: s.small }">{{ s.value }}</strong>
          <span>{{ s.label }}</span>
        </div>
      </div>
    </div>

    <div class="main-grid">
      <!-- 快捷入口 -->
      <section class="panel">
        <header class="panel-head">
          <h2>快捷入口</h2>
          <span>QUICK ACCESS</span>
        </header>
        <div class="quick-grid">
          <div v-for="q in quickLinks" :key="q.path" class="quick-item" @click="router.push(q.path)">
            <el-icon><component :is="q.icon" /></el-icon>
            <div>
              <strong>{{ q.name }}</strong>
              <em>{{ q.en }}</em>
            </div>
            <span class="quick-arrow">→</span>
          </div>
        </div>
      </section>

      <!-- 企业动态 -->
      <section class="panel">
        <header class="panel-head">
          <h2>企业动态</h2>
          <span>NEWS</span>
        </header>
        <ul class="news-list">
          <li v-for="n in news" :key="n.title">
            <div class="news-date">
              <strong>{{ n.day }}</strong>
              <span>{{ n.month }}</span>
            </div>
            <div class="news-body">
              <span class="news-cat">{{ n.category }}</span>
              <p>{{ n.title }}</p>
            </div>
          </li>
        </ul>
      </section>
    </div>

    <!-- 关于联想 -->
    <section class="about">
      <div class="about-main">
        <p class="eyebrow">ABOUT LENOVO</p>
        <h2>以技术驱动产业升级，让每一次连接都更有价值</h2>
        <p>
          联想科技专注企业级数字化，以云原生、数据智能与安全能力为底座，
          为制造、能源与政企客户提供可持续演进的产品与服务。
        </p>
      </div>
      <div class="about-facts">
        <div v-for="f in facts" :key="f.label">
          <strong>{{ f.value }}</strong>
          <span>{{ f.label }}</span>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup name="Index">
import { computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import useUserStore from '@/store/modules/user'

const router = useRouter()
const userStore = useUserStore()

const displayName = computed(() => userStore.nickName || userStore.name || '管理员')

const todayText = computed(() => {
  const now = new Date()
  const week = ['日', '一', '二', '三', '四', '五', '六'][now.getDay()]
  return `${now.getFullYear()}.${String(now.getMonth() + 1).padStart(2, '0')}.${String(now.getDate()).padStart(2, '0')} 星期${week}`
})

const stats = computed(() => [
  { value: 'v3.9.2', label: '系统版本', icon: 'Cpu' },
  { value: '运行中', label: '服务状态', icon: 'CircleCheck' },
  { value: '6', label: '核心模块', icon: 'Grid' },
  {
    value: userStore.roles.length ? userStore.roles.join(' / ') : '未分配',
    label: '当前角色',
    icon: 'UserFilled',
    small: true
  }
])

const quickLinks = [
  { name: '用户管理', en: 'USERS', path: '/system/user', icon: 'User' },
  { name: '角色管理', en: 'ROLES', path: '/system/role', icon: 'Avatar' },
  { name: '菜单管理', en: 'MENUS', path: '/system/menu', icon: 'Menu' },
  { name: '部门管理', en: 'DEPTS', path: '/system/dept', icon: 'OfficeBuilding' },
  { name: '在线用户', en: 'ONLINE', path: '/monitor/online', icon: 'Monitor' },
  { name: '服务监控', en: 'SERVER', path: '/monitor/server', icon: 'DataLine' },
  { name: '定时任务', en: 'JOBS', path: '/monitor/job', icon: 'Timer' },
  { name: '代码生成', en: 'GENERATOR', path: '/tool/gen', icon: 'MagicStick' }
]

const news = [
  { day: '18', month: '2026.10', category: '公司动态', title: '联想科技发布新一代数据中台产品，指标治理能力全面升级' },
  { day: '06', month: '2026.09', category: '行业洞察', title: '从数据孤岛到指标统一：企业数据治理的三条实践路径' },
  { day: '22', month: '2026.08', category: '客户案例', title: '某大型制造集团数字化门户上线，协同效率提升 40%' }
]

const facts = [
  { value: '18', label: '年行业深耕' },
  { value: '320+', label: '服务客户' },
  { value: '46', label: '技术专利' }
]

function openPortal() {
  window.open(router.resolve('/portal').href, '_blank')
}

onMounted(() => {
  document.title = '企业门户 · 联想科技'
})
</script>

<style lang="scss" scoped>
.portal-home {
  --serif: 'Songti SC', 'STSong', 'Noto Serif SC', 'Source Han Serif SC', 'SimSun', serif;
  --mono: 'JetBrains Mono', 'Cascadia Mono', Consolas, monospace;
  --accent: #16b8a6;
}

/* ---------- 欢迎区 ---------- */
.welcome {
  position: relative;
  overflow: hidden;
  border-radius: 10px;
  padding: 52px 48px;
  background: #060b14;
  color: #e8f0f9;
  display: grid;
  grid-template-columns: 1.15fr 0.85fr;
  align-items: center;
  gap: 32px;
}

.welcome-grid {
  position: absolute;
  inset: 0;
  background-image: linear-gradient(rgba(146, 191, 232, 0.06) 1px, transparent 1px),
    linear-gradient(90deg, rgba(146, 191, 232, 0.06) 1px, transparent 1px);
  background-size: 56px 56px;
  mask-image: radial-gradient(ellipse 80% 90% at 30% 40%, #000 20%, transparent 80%);
  pointer-events: none;
}

.welcome-glow {
  position: absolute;
  right: -120px;
  top: -120px;
  width: 520px;
  height: 520px;
  background: radial-gradient(circle, rgba(53, 227, 200, 0.18), transparent 62%);
  pointer-events: none;
}

.welcome-copy {
  position: relative;
  z-index: 2;
}

.eyebrow {
  margin: 0 0 20px;
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.22em;
  color: #35e3c8;
}

.welcome h1 {
  margin: 0;
  font-family: var(--serif);
  font-size: 30px;
  font-weight: 600;
  letter-spacing: 0.04em;
}

.slogan {
  margin: 16px 0 18px;
  font-family: var(--serif);
  font-size: clamp(30px, 3.4vw, 46px);
  font-weight: 700;
  letter-spacing: 0.05em;
  line-height: 1.2;

  span {
    color: #35e3c8;
  }
}

.desc {
  max-width: 520px;
  margin: 0 0 30px;
  font-size: 13px;
  line-height: 1.95;
  color: rgba(206, 222, 238, 0.66);
}

.actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.btn {
  padding: 11px 24px;
  font-size: 13px;
  letter-spacing: 0.08em;
  cursor: pointer;
  border: 1px solid transparent;
  transition: transform 0.25s ease, background 0.25s ease, color 0.25s ease, border-color 0.25s ease;

  &:hover {
    transform: translateY(-2px);
  }
}

.btn.primary {
  background: #35e3c8;
  color: #04121a;
  font-weight: 600;

  &:hover {
    background: #5df0da;
  }
}

.btn.ghost {
  background: transparent;
  border-color: rgba(232, 240, 249, 0.22);
  color: rgba(232, 240, 249, 0.86);

  &:hover {
    border-color: #35e3c8;
    color: #35e3c8;
  }
}

.welcome-orbit {
  position: relative;
  z-index: 2;
  display: flex;
  justify-content: center;

  svg {
    width: min(100%, 330px);
    height: auto;
  }

  .ring {
    transform-origin: 180px 180px;
    animation: spin 30s linear infinite;
  }
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

/* ---------- 概览数据 ---------- */
.stat-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-top: 16px;
}

.stat {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 20px 22px;
  border-radius: 8px;
  background: var(--el-bg-color-overlay);
  border: 1px solid var(--el-border-color-lighter);

  .stat-icon {
    font-size: 22px;
    color: var(--el-color-primary);
  }

  strong {
    display: block;
    font-size: 22px;
    font-weight: 600;
    line-height: 1.2;
    color: var(--el-text-color-primary);

    &.small {
      font-size: 15px;
      line-height: 1.5;
    }
  }

  span {
    display: block;
    margin-top: 4px;
    font-size: 12px;
    letter-spacing: 0.08em;
    color: var(--el-text-color-secondary);
  }
}

/* ---------- 主区域 ---------- */
.main-grid {
  display: grid;
  grid-template-columns: 1.4fr 1fr;
  gap: 16px;
  margin-top: 16px;
}

.panel {
  padding: 24px 26px;
  border-radius: 8px;
  background: var(--el-bg-color-overlay);
  border: 1px solid var(--el-border-color-lighter);
}

.panel-head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  padding-bottom: 16px;
  margin-bottom: 6px;
  border-bottom: 1px solid var(--el-border-color-lighter);

  h2 {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
    letter-spacing: 0.04em;
    color: var(--el-text-color-primary);
  }

  span {
    font-family: var(--mono);
    font-size: 10px;
    letter-spacing: 0.16em;
    color: var(--el-text-color-placeholder);
  }
}

.quick-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1px;
  background: var(--el-border-color-lighter);
  margin-top: 16px;
}

.quick-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 14px;
  background: var(--el-bg-color-overlay);
  cursor: pointer;
  transition: background 0.25s ease;

  &:hover {
    background: var(--el-fill-color-light);

    .quick-arrow {
      transform: translateX(4px);
      color: var(--el-color-primary);
    }
  }

  .el-icon {
    font-size: 18px;
    color: var(--el-color-primary);
  }

  strong {
    display: block;
    font-size: 13px;
    font-weight: 500;
    color: var(--el-text-color-primary);
  }

  em {
    display: block;
    margin-top: 2px;
    font-style: normal;
    font-family: var(--mono);
    font-size: 9px;
    letter-spacing: 0.12em;
    color: var(--el-text-color-placeholder);
  }

  .quick-arrow {
    margin-left: auto;
    font-size: 14px;
    color: var(--el-text-color-placeholder);
    transition: transform 0.25s ease, color 0.25s ease;
  }
}

.news-list {
  list-style: none;
  margin: 6px 0 0;
  padding: 0;

  li {
    display: flex;
    gap: 14px;
    padding: 16px 0;
    border-bottom: 1px dashed var(--el-border-color-lighter);

    &:last-child {
      border-bottom: none;
      padding-bottom: 4px;
    }
  }

  .news-date {
    flex: none;
    text-align: center;
    width: 46px;

    strong {
      display: block;
      font-family: var(--serif);
      font-size: 24px;
      font-weight: 600;
      line-height: 1;
      color: var(--el-text-color-primary);
    }

    span {
      display: block;
      margin-top: 4px;
      font-family: var(--mono);
      font-size: 9px;
      color: var(--el-text-color-placeholder);
    }
  }

  .news-cat {
    font-size: 10px;
    letter-spacing: 0.1em;
    color: var(--el-color-primary);
  }

  p {
    margin: 5px 0 0;
    font-size: 13px;
    line-height: 1.7;
    color: var(--el-text-color-regular);
  }
}

/* ---------- 关于 ---------- */
.about {
  display: grid;
  grid-template-columns: 1.3fr 1fr;
  gap: 32px;
  align-items: center;
  margin-top: 16px;
  padding: 32px 36px;
  border-radius: 8px;
  background: var(--el-bg-color-overlay);
  border: 1px solid var(--el-border-color-lighter);

  .eyebrow {
    color: var(--el-color-primary);
    margin-bottom: 14px;
  }

  h2 {
    margin: 0 0 12px;
    font-family: var(--serif);
    font-size: 24px;
    font-weight: 600;
    letter-spacing: 0.03em;
    color: var(--el-text-color-primary);
  }

  p {
    margin: 0;
    max-width: 620px;
    font-size: 13px;
    line-height: 1.9;
    color: var(--el-text-color-secondary);
  }
}

.about-facts {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;

  div {
    padding-left: 16px;
    border-left: 1px solid var(--el-border-color-lighter);
  }

  strong {
    display: block;
    font-family: var(--serif);
    font-size: 28px;
    font-weight: 600;
    color: var(--el-text-color-primary);
    line-height: 1.1;
  }

  span {
    display: block;
    margin-top: 6px;
    font-size: 11px;
    letter-spacing: 0.08em;
    color: var(--el-text-color-secondary);
  }
}

/* ---------- 响应式 ---------- */
@media (max-width: 1200px) {
  .welcome {
    grid-template-columns: 1fr;
  }

  .welcome-orbit {
    display: none;
  }

  .main-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .welcome {
    padding: 32px 24px;
  }

  .stat-row {
    grid-template-columns: repeat(2, 1fr);
  }

  .quick-grid {
    grid-template-columns: 1fr;
  }

  .about {
    grid-template-columns: 1fr;
    padding: 24px;
  }

  .about-facts {
    grid-template-columns: repeat(3, 1fr);
    gap: 10px;
  }
}

@media (prefers-reduced-motion: reduce) {
  .welcome-orbit .ring {
    animation: none;
  }
}
</style>

# 企业门户网站前端

基于 **RuoYi-Vue3** 的 Vue 3 + Vite + Element Plus 前端工程。

> 本项目基于开源项目 RuoYi 改编：
> - GitHub：<https://github.com/yangzongzhuan/RuoYi-Vue>
> - Gitee：<https://gitee.com/y_project/RuoYi-Vue>
>
> 后端启动、数据库初始化和环境变量配置请阅读 [根目录 README](../README.md)。

## 开发

```bash
npm install
npm run dev
```

开发服务器默认端口为 `80`，后端接口默认代理到 `http://localhost:8080`。

## 构建

```bash
# 生产环境
npm run build:prod

# 预发布环境
npm run build:stage
```

构建产物位于 `dist/`。

## 目录说明

```text
src/
├── api/          # 接口定义
├── assets/       # 静态资源
├── components/   # 通用组件
├── layout/       # 后台布局
├── router/       # 路由
├── store/        # Pinia 状态管理
├── utils/        # 工具函数
└── views/        # 页面
    ├── portal/   # 企业门户前台
    ├── system/   # 系统管理
    └── ...
public/
├── lb-lab.html       # 负载均衡测试页
└── rewrite-lab.html  # Nginx rewrite 演示页
```

## 说明

- 页面标题通过 `.env.*` 中的 `VITE_APP_TITLE` 配置。
- 门户中的企业名称、新闻、联系方式等均为演示数据，正式使用前请替换。

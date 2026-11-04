<template>
  <div class="portal" ref="rootRef">
    <!-- 顶部导航 -->
    <header class="nav" :class="{ 'is-solid': scrolled }">
      <div class="nav-inner">
        <a class="brand" href="#top">
          <span class="brand-mark">联</span>
          <span class="brand-text">
            <strong>联想科技</strong>
            <em>LENOVO TECH</em>
          </span>
        </a>
        <nav class="nav-links">
          <a v-for="item in navList" :key="item.id" :href="'#' + item.id">{{ item.label }}</a>
        </nav>
        <button class="nav-toggle" type="button" :aria-expanded="menuOpen" @click="menuOpen = !menuOpen">
          <span></span>
          <span></span>
        </button>
        <router-link class="nav-login" to="/login">
          登录系统
          <span class="arrow">→</span>
        </router-link>
      </div>

      <div class="nav-mobile" :class="{ open: menuOpen }">
        <a v-for="item in navList" :key="item.id" :href="'#' + item.id" @click="menuOpen = false">{{ item.label }}</a>
        <router-link to="/login" @click="menuOpen = false">登录系统</router-link>
      </div>
    </header>

    <!-- 首屏 -->
    <section class="hero" id="top">
      <div class="hero-grid"></div>
      <div class="hero-glow"></div>

      <div class="hero-inner">
        <div class="hero-copy">
          <p class="eyebrow anim" style="--d: .05s">SINCE 2008 · 数字基础设施服务商</p>
          <h1 class="slogan">
            <span class="line anim" style="--d: .15s">追求<span class="accent">卓越</span></span>
            <span class="line anim" style="--d: .28s">奋勇<span class="accent">争先</span></span>
          </h1>
          <p class="lede anim" style="--d: .42s">
            以云原生、数据智能与安全能力为底座，为制造、能源与政企客户，
            构建可持续演进的数字化平台。
          </p>
          <div class="hero-actions anim" style="--d: .55s">
            <a class="btn btn-primary" href="#business">了解我们的能力</a>
            <a class="btn btn-ghost" href="#contact">获取解决方案</a>
          </div>
          <p class="hero-meta anim" style="--d: .68s">北京 · 上海 · 深圳 · 成都</p>
        </div>

        <div class="hero-visual anim" style="--d: .35s">
          <div class="radar">
            <svg viewBox="0 0 520 520" aria-hidden="true">
              <defs>
                <linearGradient id="ringGrad" x1="0" y1="0" x2="1" y2="1">
                  <stop offset="0%" stop-color="#35e3c8" stop-opacity=".85" />
                  <stop offset="100%" stop-color="#35e3c8" stop-opacity="0" />
                </linearGradient>
              </defs>
              <g stroke="rgba(140,190,230,.18)" fill="none">
                <circle cx="260" cy="260" r="238" />
                <circle cx="260" cy="260" r="196" />
                <circle cx="260" cy="260" r="150" />
                <circle cx="260" cy="260" r="104" stroke-dasharray="2 8" />
                <line x1="22" y1="260" x2="498" y2="260" />
                <line x1="260" y1="22" x2="260" y2="498" />
              </g>
              <g class="spin-slow" stroke="url(#ringGrad)" fill="none" stroke-width="1.5">
                <circle cx="260" cy="260" r="196" stroke-dasharray="120 400" stroke-linecap="round" />
              </g>
              <g class="spin-reverse" stroke="#35e3c8" fill="none" stroke-width="1.5" opacity=".7">
                <circle cx="260" cy="260" r="150" stroke-dasharray="60 300" stroke-linecap="round" />
              </g>
              <g fill="#35e3c8">
                <circle cx="260" cy="64" r="3.5" />
                <circle cx="430" cy="300" r="3.5" />
                <circle cx="176" cy="418" r="3.5" />
                <circle cx="64" cy="182" r="3.5" />
                <circle cx="392" cy="118" r="3.5" opacity=".6" />
              </g>
              <g fill="rgba(214,230,244,.72)" font-size="11" font-family="Consolas, monospace" letter-spacing="2">
                <text x="248" y="50">AI</text>
                <text x="440" y="304">CLOUD</text>
                <text x="126" y="448">DATA</text>
                <text x="22" y="186">IOT</text>
                <text x="404" y="108">SEC</text>
              </g>
              <circle cx="260" cy="260" r="52" fill="rgba(8,18,32,.85)" stroke="rgba(53,227,200,.45)" />
              <text x="260" y="272" text-anchor="middle" font-size="34" fill="#e9f4ff" font-family="Songti SC, STSong, serif">联</text>
            </svg>
            <span class="corner tl"></span>
            <span class="corner tr"></span>
            <span class="corner bl"></span>
            <span class="corner br"></span>
          </div>
        </div>
      </div>

      <div class="stats">
        <div v-for="(s, i) in stats" :key="s.label" class="stat anim" :style="{ '--d': .7 + i * .08 + 's' }">
          <strong>{{ s.value }}</strong>
          <span>{{ s.label }}</span>
        </div>
      </div>
    </section>

    <!-- 关于我们 -->
    <section class="section section-light" id="about">
      <div class="section-inner">
        <div class="section-head reveal">
          <p class="eyebrow dark">01 / ABOUT</p>
          <h2>把复杂的技术<br />做成可靠的基础设施</h2>
        </div>

        <div class="about-grid">
          <div class="about-copy reveal">
            <p>
              联想科技成立于 2008 年，是一家专注企业级数字化的科技公司。我们把咨询、产品与工程交付放在同一张桌子上，
              用可落地的方案，解决真实业务里的复杂问题。
            </p>
            <p>
              十余年来，我们服务制造、能源、政企等行业客户，从统一门户到数据中台，从云原生底座到智能应用，
              陪伴组织完成一次次安静的升级。
            </p>
            <ul class="values">
              <li v-for="v in values" :key="v.title">
                <span class="dot"></span>
                <div>
                  <h4>{{ v.title }}</h4>
                  <p>{{ v.desc }}</p>
                </div>
              </li>
            </ul>
          </div>

          <div class="layers reveal">
            <p class="layers-title">能力架构 / CAPABILITY STACK</p>
            <div class="layer" v-for="l in layers" :key="l.name">
              <span class="layer-index">{{ l.index }}</span>
              <div class="layer-body">
                <h4>{{ l.name }}</h4>
                <p>{{ l.desc }}</p>
              </div>
              <span class="layer-tag">{{ l.tag }}</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 业务领域 -->
    <section class="section section-dark" id="business">
      <div class="section-inner">
        <div class="section-head reveal">
          <p class="eyebrow">02 / BUSINESS</p>
          <h2>四条主线，<br />覆盖企业数字化的关键环节</h2>
        </div>

        <div class="cards">
          <article v-for="b in business" :key="b.no" class="card reveal">
            <span class="card-no">{{ b.no }}</span>
            <h3>{{ b.title }}</h3>
            <p>{{ b.desc }}</p>
            <div class="tags">
              <span v-for="t in b.tags" :key="t">{{ t }}</span>
            </div>
            <span class="card-arrow">↗</span>
          </article>
        </div>
      </div>
    </section>

    <!-- 新闻动态 -->
    <section class="section section-light" id="news">
      <div class="section-inner">
        <div class="section-head reveal">
          <p class="eyebrow dark">03 / NEWS</p>
          <h2>新闻与洞察</h2>
          <p v-if="rewriteDate" class="rewrite-note">
            由 Nginx rewrite 跳转进入 · 参数 date={{ rewriteDate }}
          </p>
        </div>

        <div class="news">
          <article v-for="n in news" :key="n.title" class="news-item reveal">
            <div class="news-date">
              <strong>{{ n.day }}</strong>
              <span>{{ n.month }}</span>
            </div>
            <div class="news-body">
              <span class="news-cat">{{ n.category }}</span>
              <h3>{{ n.title }}</h3>
            </div>
            <span class="news-arrow">→</span>
          </article>
        </div>
      </div>
    </section>

    <!-- 联系我们 -->
    <section class="section section-contact" id="contact">
      <div class="contact-inner">
        <p class="eyebrow reveal">04 / CONTACT</p>
        <h2 class="reveal">让我们一起，<br />做点不一样的事</h2>
        <div class="contact-grid reveal">
          <div>
            <span class="contact-label">商务咨询</span>
            <strong>400-888-6666</strong>
          </div>
          <div>
            <span class="contact-label">合作邮箱</span>
            <strong>hello@lenovo-tech.com</strong>
          </div>
          <div>
            <span class="contact-label">总部地址</span>
            <strong>北京市海淀区中关村软件园 · 联想科技大厦</strong>
          </div>
        </div>
        <a class="btn btn-primary reveal" href="mailto:hello@lenovo-tech.com">发送合作意向</a>
      </div>

      <footer class="footer">
        <span>© 2026 联想科技 LENOVO TECH</span>
        <span>京ICP备00000000号</span>
      </footer>
    </section>
  </div>
</template>

<script setup name="Portal">
import { onBeforeUnmount, onMounted, ref } from 'vue'

const rootRef = ref(null)
const route = useRoute()
const scrolled = ref(false)
const menuOpen = ref(false)
const rewriteDate = ref('')
const originalTitle = document.title

const navList = [
  { id: 'about', label: '关于我们' },
  { id: 'business', label: '业务领域' },
  { id: 'news', label: '新闻动态' },
  { id: 'contact', label: '联系我们' }
]

const stats = [
  { value: '18', label: '年行业深耕' },
  { value: '320+', label: '服务客户' },
  { value: '46', label: '核心技术专利' },
  { value: '99.99%', label: '平台可用性' }
]

const values = [
  { title: '长期主义', desc: '不做一次性的项目，只做能持续演进的产品。' },
  { title: '工程信仰', desc: '把每一行代码、每一次交付都当作作品。' },
  { title: '客户成功', desc: '指标对齐业务结果，而不是功能清单。' }
]

const layers = [
  { index: 'L4', name: '智能应用层', desc: '门户、协同、数据看板与行业应用', tag: 'APPLICATION' },
  { index: 'L3', name: '数据智能层', desc: '数据治理、指标体系与智能分析', tag: 'DATA & AI' },
  { index: 'L2', name: '云原生平台层', desc: '容器、微服务、DevOps 与可观测性', tag: 'PLATFORM' },
  { index: 'L1', name: '基础设施层', desc: '混合云、网络与安全合规底座', tag: 'INFRA' }
]

const business = [
  {
    no: '01',
    title: '企业数字化平台',
    desc: '统一门户、流程协同与低代码构建，让组织运转更高效。',
    tags: ['统一门户', '流程协同', '低代码']
  },
  {
    no: '02',
    title: '智能数据中台',
    desc: '打通采集、治理、指标与分析，让每一个决策都有据可依。',
    tags: ['数据治理', '指标体系', 'BI']
  },
  {
    no: '03',
    title: '云原生基础设施',
    desc: '容器、微服务与可观测性体系，构建弹性稳定的技术底座。',
    tags: ['Kubernetes', 'DevOps', '可观测']
  },
  {
    no: '04',
    title: '行业解决方案',
    desc: '面向制造、能源与政企的场景化交付，以及长期运营陪伴。',
    tags: ['智能制造', '能源', '政企']
  }
]

const news = [
  { day: '18', month: '2026.10', category: '公司动态', title: '联想科技发布新一代数据中台产品，指标治理能力全面升级' },
  { day: '06', month: '2026.09', category: '行业洞察', title: '从数据孤岛到指标统一：企业数据治理的三条实践路径' },
  { day: '22', month: '2026.08', category: '客户案例', title: '某大型制造集团数字化门户上线，协同效率提升 40%' }
]

let observer = null

function onScroll() {
  scrolled.value = window.scrollY > 40
}

onMounted(() => {
  document.title = '联想科技 · 追求卓越，奋勇争先'

  // Nginx rewrite 演示：捕获组拼出的 ?date= 参数
  if (route.query.date) {
    rewriteDate.value = String(route.query.date)
  }

  // 通过 rewrite 跳转到 /portal#news 时，等待内容渲染后再定位锚点
  const hash = window.location.hash
  if (/^#[\w-]+$/.test(hash)) {
    setTimeout(() => {
      document.querySelector(hash)?.scrollIntoView({ behavior: 'smooth' })
    }, 120)
  }

  onScroll()
  window.addEventListener('scroll', onScroll, { passive: true })

  observer = new IntersectionObserver(
    entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible')
          observer.unobserve(entry.target)
        }
      })
    },
    { threshold: 0.15 }
  )
  rootRef.value?.querySelectorAll('.reveal').forEach(el => observer.observe(el))
})

onBeforeUnmount(() => {
  document.title = originalTitle
  window.removeEventListener('scroll', onScroll)
  observer?.disconnect()
})
</script>

<style lang="scss" scoped>
.portal {
  --bg: #060b14;
  --bg-soft: #0a1322;
  --paper: #f3f5f4;
  --ink: #0a1220;
  --text: #e8f0f9;
  --muted: #8ca0b8;
  --line: rgba(146, 191, 232, 0.16);
  --accent: #35e3c8;
  --serif: 'Songti SC', 'STSong', 'Noto Serif SC', 'Source Han Serif SC', 'SimSun', serif;
  --mono: 'JetBrains Mono', 'Cascadia Mono', Consolas, monospace;

  min-height: 100vh;
  background: var(--bg);
  color: var(--text);
  font-family: 'PingFang SC', 'HarmonyOS Sans SC', 'Microsoft YaHei', sans-serif;
  overflow-x: hidden;

  a {
    color: inherit;
    text-decoration: none;
  }
}

/* ---------- 导航 ---------- */
.nav {
  position: fixed;
  inset: 0 0 auto;
  z-index: 30;
  transition: background 0.35s ease, border-color 0.35s ease, backdrop-filter 0.35s ease;
  border-bottom: 1px solid transparent;

  &.is-solid {
    background: rgba(6, 11, 20, 0.82);
    border-bottom-color: var(--line);
    backdrop-filter: blur(14px);
  }
}

.nav-inner {
  max-width: 1240px;
  margin: 0 auto;
  padding: 20px 40px;
  display: flex;
  align-items: center;
  gap: 48px;
}

.brand {
  display: flex;
  align-items: center;
  gap: 12px;

  .brand-mark {
    width: 38px;
    height: 38px;
    display: grid;
    place-items: center;
    border: 1px solid rgba(53, 227, 200, 0.55);
    color: var(--accent);
    font-family: var(--serif);
    font-size: 19px;
  }

  .brand-text {
    display: flex;
    flex-direction: column;
    line-height: 1.2;

    strong {
      font-size: 15px;
      letter-spacing: 0.16em;
      font-weight: 600;
    }

    em {
      font-style: normal;
      font-family: var(--mono);
      font-size: 9px;
      letter-spacing: 0.22em;
      color: var(--muted);
    }
  }
}

.nav-links {
  display: flex;
  gap: 36px;
  margin-left: auto;

  a {
    font-size: 13px;
    letter-spacing: 0.08em;
    color: rgba(232, 240, 249, 0.72);
    position: relative;
    padding: 4px 0;
    transition: color 0.25s ease;

    &::after {
      content: '';
      position: absolute;
      left: 0;
      bottom: 0;
      width: 0;
      height: 1px;
      background: var(--accent);
      transition: width 0.3s ease;
    }

    &:hover {
      color: #fff;

      &::after {
        width: 100%;
      }
    }
  }
}

.nav-toggle {
  display: none;
  width: 38px;
  height: 38px;
  padding: 0;
  border: 1px solid var(--line);
  background: transparent;
  cursor: pointer;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 5px;

  span {
    display: block;
    width: 16px;
    height: 1px;
    background: rgba(232, 240, 249, 0.8);
  }
}

.nav-mobile {
  display: none;
  flex-direction: column;
  padding: 0 24px;
  background: rgba(6, 11, 20, 0.96);
  border-bottom: 1px solid var(--line);
  backdrop-filter: blur(14px);

  &.open {
    display: flex;
  }

  a {
    padding: 15px 0;
    font-size: 14px;
    letter-spacing: 0.08em;
    color: rgba(232, 240, 249, 0.82);
    border-bottom: 1px solid rgba(146, 191, 232, 0.1);

    &:last-child {
      border-bottom: none;
    }
  }
}

.nav-login {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 9px 18px;
  border: 1px solid rgba(53, 227, 200, 0.42);
  font-size: 13px;
  letter-spacing: 0.08em;
  color: var(--accent);
  transition: background 0.25s ease, color 0.25s ease;

  .arrow {
    transition: transform 0.25s ease;
  }

  &:hover {
    background: var(--accent);
    color: #04121a;

    .arrow {
      transform: translateX(3px);
    }
  }
}

/* ---------- 首屏 ---------- */
.hero {
  position: relative;
  min-height: 100vh;
  padding: 132px 40px 0;
  display: flex;
  flex-direction: column;
  justify-content: center;
  overflow: hidden;
}

.hero-grid {
  position: absolute;
  inset: 0;
  background-image: linear-gradient(rgba(146, 191, 232, 0.055) 1px, transparent 1px),
    linear-gradient(90deg, rgba(146, 191, 232, 0.055) 1px, transparent 1px);
  background-size: 64px 64px;
  mask-image: radial-gradient(ellipse 90% 70% at 50% 40%, #000 30%, transparent 78%);
  pointer-events: none;
}

.hero-glow {
  position: absolute;
  width: 760px;
  height: 760px;
  right: -180px;
  top: 6%;
  background: radial-gradient(circle, rgba(53, 227, 200, 0.16) 0%, rgba(53, 227, 200, 0) 62%);
  pointer-events: none;
}

.hero-inner {
  position: relative;
  width: 100%;
  max-width: 1240px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: 1.12fr 0.88fr;
  align-items: center;
  gap: 64px;
  z-index: 2;
}

.eyebrow {
  font-family: var(--mono);
  font-size: 11px;
  letter-spacing: 0.24em;
  color: var(--accent);
  margin: 0 0 26px;

  &.dark {
    color: #0f766e;
  }
}

.slogan {
  margin: 0;
  font-family: var(--serif);
  font-weight: 700;
  font-size: clamp(54px, 7.4vw, 104px);
  line-height: 1.06;
  letter-spacing: 0.04em;

  .line {
    display: block;
  }

  .accent {
    color: var(--accent);
    position: relative;

    &::after {
      content: '';
      position: absolute;
      left: 0.06em;
      right: 0.06em;
      bottom: 0.1em;
      height: 1px;
      background: linear-gradient(90deg, rgba(53, 227, 200, 0.9), rgba(53, 227, 200, 0));
    }
  }
}

.lede {
  max-width: 480px;
  margin: 30px 0 38px;
  font-size: 15px;
  line-height: 2;
  color: rgba(214, 229, 243, 0.72);
}

.hero-actions {
  display: flex;
  gap: 14px;
  flex-wrap: wrap;
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 14px 30px;
  font-size: 14px;
  letter-spacing: 0.1em;
  border: 1px solid transparent;
  transition: transform 0.25s ease, background 0.25s ease, color 0.25s ease, border-color 0.25s ease;
  cursor: pointer;

  &:hover {
    transform: translateY(-2px);
  }
}

.btn-primary {
  background: var(--accent);
  color: #04121a;
  font-weight: 600;

  &:hover {
    background: #5df0da;
  }
}

.btn-ghost {
  border-color: rgba(232, 240, 249, 0.24);
  color: rgba(232, 240, 249, 0.86);

  &:hover {
    border-color: var(--accent);
    color: var(--accent);
  }
}

.hero-meta {
  margin: 40px 0 0;
  font-family: var(--mono);
  font-size: 11px;
  letter-spacing: 0.2em;
  color: rgba(140, 160, 184, 0.75);
}

.hero-visual {
  display: flex;
  justify-content: center;
}

.radar {
  position: relative;
  width: min(100%, 520px);

  svg {
    width: 100%;
    height: auto;
    display: block;
  }

  .corner {
    position: absolute;
    width: 18px;
    height: 18px;
    border-color: rgba(53, 227, 200, 0.55);
    border-style: solid;
    border-width: 0;

    &.tl {
      top: 0;
      left: 0;
      border-top-width: 1px;
      border-left-width: 1px;
    }

    &.tr {
      top: 0;
      right: 0;
      border-top-width: 1px;
      border-right-width: 1px;
    }

    &.bl {
      bottom: 0;
      left: 0;
      border-bottom-width: 1px;
      border-left-width: 1px;
    }

    &.br {
      bottom: 0;
      right: 0;
      border-bottom-width: 1px;
      border-right-width: 1px;
    }
  }
}

.spin-slow {
  transform-origin: 260px 260px;
  animation: spin 36s linear infinite;
}

.spin-reverse {
  transform-origin: 260px 260px;
  animation: spin 24s linear infinite reverse;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.stats {
  position: relative;
  z-index: 2;
  width: 100%;
  max-width: 1240px;
  margin: 64px auto 0;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  border-top: 1px solid var(--line);

  .stat {
    padding: 26px 0 30px;
    display: flex;
    flex-direction: column;
    gap: 8px;

    & + .stat {
      padding-left: 32px;
      border-left: 1px solid var(--line);
    }

    strong {
      font-family: var(--serif);
      font-size: 40px;
      font-weight: 600;
      color: #fff;
      line-height: 1;
    }

    span {
      font-size: 12px;
      letter-spacing: 0.14em;
      color: var(--muted);
    }
  }
}

/* ---------- 通用区块 ---------- */
.section {
  position: relative;
  padding: 130px 40px;
}

.section-inner {
  max-width: 1240px;
  margin: 0 auto;
}

.section-head {
  margin-bottom: 64px;

  h2 {
    margin: 0;
    font-family: var(--serif);
    font-weight: 700;
    font-size: clamp(32px, 4vw, 54px);
    line-height: 1.28;
    letter-spacing: 0.03em;
  }
}

.section-light {
  background: var(--paper);
  color: var(--ink);

  .eyebrow {
    margin-bottom: 20px;
  }

  .section-head h2 {
    color: var(--ink);
  }
}

.section-dark {
  background: var(--bg);
  border-top: 1px solid var(--line);
  border-bottom: 1px solid var(--line);
}

.rewrite-note {
  display: inline-block;
  margin: 16px 0 0;
  padding: 5px 12px;
  border: 1px solid rgba(15, 118, 110, 0.35);
  background: rgba(15, 118, 110, 0.06);
  font-family: var(--mono);
  font-size: 11px;
  letter-spacing: 0.06em;
  color: #0f766e;
}

/* ---------- 关于 ---------- */
.about-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 80px;
}

.about-copy {
  p {
    margin: 0 0 22px;
    font-size: 15px;
    line-height: 2.1;
    color: #45525f;
  }
}

.values {
  list-style: none;
  margin: 40px 0 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 22px;

  li {
    display: flex;
    gap: 16px;
    padding-top: 22px;
    border-top: 1px solid rgba(10, 18, 32, 0.1);
  }

  .dot {
    width: 7px;
    height: 7px;
    margin-top: 8px;
    background: #0f766e;
    flex: none;
  }

  h4 {
    margin: 0 0 6px;
    font-size: 15px;
    letter-spacing: 0.06em;
    color: var(--ink);
  }

  p {
    margin: 0;
    font-size: 13px;
    color: #6b7885;
    line-height: 1.8;
  }
}

.layers {
  padding: 30px;
  background: #fff;
  border: 1px solid rgba(10, 18, 32, 0.08);
}

.layers-title {
  margin: 0 0 22px;
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.2em;
  color: #7a8794;
}

.layer {
  display: grid;
  grid-template-columns: 34px 1fr auto;
  align-items: center;
  gap: 14px;
  padding: 20px 0;
  border-top: 1px solid rgba(10, 18, 32, 0.08);
  transition: padding-left 0.3s ease;

  &:hover {
    padding-left: 8px;
  }

  .layer-index {
    font-family: var(--mono);
    font-size: 11px;
    color: #0f766e;
    letter-spacing: 0.1em;
  }

  h4 {
    margin: 0 0 4px;
    font-size: 15px;
    color: var(--ink);
  }

  p {
    margin: 0;
    font-size: 12px;
    color: #7a8794;
  }

  .layer-tag {
    font-family: var(--mono);
    font-size: 9px;
    letter-spacing: 0.14em;
    color: #a0abb6;
  }
}

/* ---------- 业务 ---------- */
.cards {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1px;
  background: var(--line);
  border: 1px solid var(--line);
}

.card {
  position: relative;
  padding: 44px 38px 40px;
  background: var(--bg);
  transition: background 0.35s ease;

  &:hover {
    background: #0b1524;

    .card-arrow {
      transform: translate(4px, -4px);
      color: var(--accent);
    }

    .card-no {
      color: var(--accent);
    }
  }

  .card-no {
    font-family: var(--mono);
    font-size: 11px;
    letter-spacing: 0.2em;
    color: rgba(140, 160, 184, 0.7);
    transition: color 0.3s ease;
  }

  h3 {
    margin: 22px 0 14px;
    font-family: var(--serif);
    font-size: 26px;
    font-weight: 600;
    color: #fff;
    letter-spacing: 0.04em;
  }

  p {
    margin: 0 0 26px;
    font-size: 13px;
    line-height: 1.9;
    color: rgba(200, 216, 232, 0.66);
    max-width: 380px;
  }

  .tags {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;

    span {
      padding: 4px 10px;
      border: 1px solid var(--line);
      font-size: 11px;
      letter-spacing: 0.08em;
      color: rgba(200, 216, 232, 0.7);
    }
  }

  .card-arrow {
    position: absolute;
    top: 40px;
    right: 38px;
    font-size: 18px;
    color: rgba(200, 216, 232, 0.4);
    transition: transform 0.3s ease, color 0.3s ease;
  }
}

/* ---------- 新闻 ---------- */
.news {
  border-top: 1px solid rgba(10, 18, 32, 0.12);
}

.news-item {
  display: grid;
  grid-template-columns: 128px 1fr auto;
  align-items: center;
  gap: 28px;
  padding: 30px 0;
  border-bottom: 1px solid rgba(10, 18, 32, 0.12);
  transition: padding-left 0.35s ease;

  &:hover {
    padding-left: 12px;

    .news-arrow {
      color: #0f766e;
      transform: translateX(6px);
    }
  }

  .news-date {
    display: flex;
    align-items: baseline;
    gap: 8px;

    strong {
      font-family: var(--serif);
      font-size: 34px;
      font-weight: 600;
      color: var(--ink);
      line-height: 1;
    }

    span {
      font-family: var(--mono);
      font-size: 10px;
      color: #8b98a4;
      letter-spacing: 0.08em;
    }
  }

  .news-cat {
    font-size: 11px;
    letter-spacing: 0.12em;
    color: #0f766e;
  }

  h3 {
    margin: 8px 0 0;
    font-size: 18px;
    font-weight: 500;
    color: var(--ink);
    letter-spacing: 0.02em;
  }

  .news-arrow {
    font-size: 18px;
    color: #a0abb6;
    transition: transform 0.3s ease, color 0.3s ease;
  }
}

/* ---------- 联系 ---------- */
.section-contact {
  background: radial-gradient(circle at 78% 18%, rgba(53, 227, 200, 0.12), transparent 46%), var(--bg);
  padding-bottom: 0;
}

.contact-inner {
  max-width: 1240px;
  margin: 0 auto;
  padding-bottom: 100px;

  h2 {
    margin: 0 0 60px;
    font-family: var(--serif);
    font-size: clamp(34px, 4.4vw, 62px);
    font-weight: 700;
    line-height: 1.24;
    color: #fff;
    letter-spacing: 0.03em;
  }
}

.contact-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 32px;
  padding-top: 34px;
  border-top: 1px solid var(--line);
  margin-bottom: 50px;

  div {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .contact-label {
    font-family: var(--mono);
    font-size: 10px;
    letter-spacing: 0.2em;
    color: rgba(140, 160, 184, 0.75);
  }

  strong {
    font-size: 16px;
    font-weight: 500;
    color: rgba(232, 240, 249, 0.92);
    line-height: 1.7;
  }
}

.footer {
  max-width: 1240px;
  margin: 0 auto;
  padding: 28px 0;
  border-top: 1px solid var(--line);
  display: flex;
  justify-content: space-between;
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.14em;
  color: rgba(140, 160, 184, 0.6);
}

/* ---------- 动效 ---------- */
.anim {
  opacity: 0;
  transform: translateY(26px);
  animation: rise 0.9s cubic-bezier(0.2, 0.7, 0.2, 1) forwards;
  animation-delay: var(--d, 0s);
}

@keyframes rise {
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.reveal {
  opacity: 0;
  transform: translateY(28px);
  transition: opacity 0.8s ease, transform 0.8s cubic-bezier(0.2, 0.7, 0.2, 1);

  &.is-visible {
    opacity: 1;
    transform: none;
  }
}

/* ---------- 响应式 ---------- */
@media (max-width: 1024px) {
  .nav-links {
    display: none;
  }

  .nav-toggle {
    display: flex;
    margin-left: auto;
  }

  .nav-login {
    display: none;
  }

  .hero-inner {
    grid-template-columns: 1fr;
    gap: 48px;
  }

  .hero-visual {
    order: 0;
    justify-content: center;

    .radar {
      width: min(78%, 420px);
    }
  }

  .about-grid {
    grid-template-columns: 1fr;
    gap: 48px;
  }

  .contact-grid {
    grid-template-columns: 1fr;
  }

  .stats {
    grid-template-columns: repeat(2, 1fr);

    .stat:nth-child(3) {
      border-left: none;
      padding-left: 0;
    }
  }
}

@media (max-width: 720px) {
  .nav-inner,
  .hero,
  .section,
  .hero-inner,
  .stats,
  .footer {
    padding-left: 22px;
    padding-right: 22px;
  }

  .hero {
    padding-top: 112px;
  }

  .hero-visual .radar {
    width: 100%;
  }

  .cards {
    grid-template-columns: 1fr;
  }

  .card {
    padding: 34px 24px;
  }

  .news-item {
    grid-template-columns: 84px 1fr;
    gap: 16px;

    .news-arrow {
      display: none;
    }
  }

  .stats .stat {
    padding-left: 0 !important;
    border-left: none !important;
  }

  .footer {
    flex-direction: column;
    gap: 10px;
  }
}

@media (prefers-reduced-motion: reduce) {
  .anim,
  .reveal {
    opacity: 1;
    transform: none;
    animation: none;
    transition: none;
  }

  .spin-slow,
  .spin-reverse {
    animation: none;
  }
}
</style>

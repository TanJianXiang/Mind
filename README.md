# 心迹 APP - AI情感陪伴与情绪艺术生成系统（PWA）

> 第十四届全国大学生数字媒体科技作品及创意竞赛参赛作品
> 在线体验：https://tanjianxiang.github.io/Mind/

「心迹」以"对话—感知—表达—洞察"为主线，构建完整的情感计算闭环：AI 共情对话、消息实时情绪识别、一键情绪艺术生成、真实数据驱动的情绪分析报告。

## 📱 快速开始

由于 PWA 需要 HTTP/HTTPS 环境（Service Worker 要求），请通过本地服务器运行：

**方法1：使用Python（推荐）**
```bash
python -m http.server 8000
```
然后在浏览器访问：`http://localhost:8000`

**方法2：使用VS Code的Live Server插件**
1. 用VS Code打开 `index.html`
2. 右键选择"Open with Live Server"

**方法3：使用Node.js的http-server**
```bash
npx http-server -p 8000
```

### 安装为APP
1. 在Chrome/Edge浏览器中打开应用
2. 浏览器地址栏右侧会出现安装图标
3. 点击安装图标，应用会添加到主屏幕，即可像原生APP一样使用

---

## 🚀 部署到GitHub Pages

使用PowerShell脚本一键部署：

```powershell
.\deploy.ps1 -RepositoryUrl "https://github.com/你的用户名/你的仓库名.git"
```

或在仓库 Settings → Pages → Source 选择 `master` 分支即可。

---

## 📁 项目文件结构

```
├── index.html              # 主应用（单文件前端，约4800行）
├── manifest.json           # PWA配置文件
├── sw.js                   # Service Worker（离线缓存，v4：HTML网络优先/静态资源缓存优先）
├── chart.umd.min.js        # Chart.js 4.4.0 本地化（避免CDN不可用）
├── icons\
│   ├── icon.svg            # 应用图标
│   ├── ai-avatar.png       # 心迹AI头像（AI生成）
│   └── user-avatar.png     # 用户头像（AI生成）
├── backend\                # 可选后端参考实现（Node.js / Python Flask）
├── 作品说明文档.md          # 参赛作品说明书
├── 演示视频分镜脚本.md      # 演示视频拍摄脚本
└── README.md               # 本文档
```

## ✨ 核心功能

- ✅ AI 情感陪伴对话（智谱 GLM-4-Flash 大模型）
- ✅ 聊天消息实时情绪识别标签
- ✅ 「把此刻心情画成画」聊天-艺术一键联动（自动填充+智能风格推荐）
- ✅ 情绪艺术生成（文生图大模型，6种艺术风格，Canvas降级兜底）
- ✅ 情绪分析报告（AI归因真实对话数据：趋势图/分布图/四维报告）
- ✅ 心情日记与心情树
- ✅ 呼吸冥想与打卡
- ✅ 治愈小游戏
- ✅ 历史记录管理
- ✅ 个人中心与主题切换
- ✅ PWA离线支持、可安装、移动端适配

## 🛡️ 可靠性设计

- 三层降级容错：AI对话（大模型→本地共情库）、情绪分析（AI归因→本地关键词分析）、艺术生成（文生图→Canvas程序化艺术）
- Service Worker 不拦截 API POST 请求，HTML 网络优先保证版本及时更新
- 用户数据全部本地存储（LocalStorage），隐私安全

## ⚠️ 注意事项

1. **必须通过服务器访问** - 直接打开index.html无法使用Service Worker
2. **清除缓存** - 如遇旧版本残留，在浏览器开发者工具 Application → Storage 中清除站点数据
3. **API说明** - AI能力依赖前端直连的公开大模型API，网络异常时自动降级，不影响演示

## 🐛 常见问题

**Q: 安装按钮不出现？**
A: 确保通过HTTPS或localhost访问，且manifest.json和sw.js文件可访问。

**Q: 图表不显示？**
A: 确认 chart.umd.min.js 与 index.html 在同一目录。

**Q: 离线功能不工作？**
A: 检查Service Worker是否注册成功（按F12查看Console）。

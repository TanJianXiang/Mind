# 心迹 APP - PWA网页应用

## 📱 快速开始

### 步骤1：生成图标文件
由于浏览器安全限制，无法直接生成PNG图标，请按以下步骤操作：

1. 打开 `icons/icon-generator.html` 文件（在浏览器中）
2. 点击"生成并下载所有图标"按钮
3. 浏览器会自动下载所有尺寸的图标
4. 将下载的图标文件移动到 `icons/` 目录

### 步骤2：运行应用
由于PWA需要HTTPS和Service Worker，需要通过本地服务器运行：

**方法1：使用Python（推荐）**
```bash
cd d:\AIGC
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

### 步骤3：安装为APP
1. 在Chrome/Edge浏览器中打开应用
2. 浏览器地址栏右侧会出现安装图标 📲
3. 点击安装图标，或点击首页的"安装心迹APP"按钮
4. 应用会添加到主屏幕，即可像原生APP一样使用

---

## 🚀 部署到GitHub Pages

### 前置条件
1. 拥有GitHub账号
2. 已安装Git
3. 创建了一个GitHub仓库（可以是公开或私有）

### 自动部署（推荐）

使用PowerShell脚本一键部署：

```powershell
.\deploy.ps1 -RepositoryUrl "https://github.com/你的用户名/你的仓库名.git"
```

**脚本功能：**
- ✅ 自动检查Git环境
- ✅ 配置远程仓库
- ✅ 创建gh-pages分支
- ✅ 推送部署到GitHub
- ✅ 自动清理临时文件

### 手动部署步骤

**步骤1：创建gh-pages分支**
```bash
git checkout --orphan gh-pages
```

**步骤2：添加文件**
```bash
git add index.html manifest.json sw.js icons/ test-api.html
```

**步骤3：提交**
```bash
git commit -m "Initial deploy"
```

**步骤4：推送**
```bash
git push origin gh-pages
```

**步骤5：配置GitHub Pages**
1. 打开GitHub仓库页面
2. 点击 "Settings" → "Pages"
3. 在 "Source" 中选择 `gh-pages` 分支
4. 点击 "Save"

### 访问地址
```
https://你的用户名.github.io/你的仓库名/
```

> ⚠️ 注意：GitHub Pages部署后可能需要几分钟才能生效

---

## 📁 项目文件结构

```
d:\AIGC\
├── index.html              # 主应用文件
├── manifest.json           # PWA配置文件
├── sw.js                   # Service Worker（离线功能）
├── icons\
│   ├── icon.svg            # SVG图标（可直接使用）
│   ├── icon-generator.html # 图标生成工具
│   └── generate-icons.html # 备用图标生成工具
└── README.md              # 本文档
```

## ✨ PWA功能特性

1. **可安装** - 可添加到手机主屏幕或桌面
2. **离线使用** - Service Worker缓存资源，无网也能用
3. **推送通知** - 支持消息推送提醒
4. **响应式设计** - 完美适配手机、平板、电脑
5. **快速加载** - 资源缓存，加速启动

## 🎨 图标尺寸说明

- 72x72 - 小屏幕Android
- 96x96 - Google TV
- 128x128 - Nexus 7
- 144x144 - Android设备
- 152x152 - iPad
- 192x192 - PWA主图标
- 384x384 - 超大屏幕
- 512x512 - 应用商店（必需）

## 🔧 自定义配置

修改 `manifest.json` 可以更改：
- APP名称（name, short_name）
- 主题颜色（theme_color）
- 背景颜色（background_color）
- 显示模式（display: standalone/fullscreen/browser）

## 📋 功能清单

- ✅ 情感陪伴聊天（智谱AI）
- ✅ 情绪艺术生成
- ✅ 情绪分析报告
- ✅ 用户认证系统
- ✅ 历史记录管理
- ✅ 个人中心
- ✅ 多窗口导航
- ✅ 返回/前进功能
- ✅ 键盘快捷键
- ✅ 移动端适配
- ✅ PWA离线支持

## ⚠️ 注意事项

1. **必须通过服务器访问** - 直接打开index.html无法使用Service Worker
2. **图标需要手动生成** - PNG图标需要用icon-generator.html工具生成
3. **首次加载较慢** - Service Worker缓存资源后速度会提升
4. **清除缓存** - 在浏览器设置中清除站点数据可以重置PWA

## 🐛 常见问题

**Q: 安装按钮不出现？**
A: 确保通过HTTPS或localhost访问，且manifest.json和sw.js文件可访问。

**Q: 图标显示不正确？**
A: 请确保生成了所有尺寸的PNG图标并放在icons目录。

**Q: 离线功能不工作？**
A: 检查Service Worker是否注册成功（按F12查看Console）。

## 📞 技术支持

如有问题，请检查浏览器控制台（F12）的错误信息。

# 中信建投研究所晨报及研报看板（GitHub Pages）

把本地生成的看板 HTML 发布为固定链接；你每次覆盖上传后，他人刷新同一链接即可看到最新内容。

## 一次性设置（约 5 分钟）

### 1. 在 GitHub 新建仓库

1. 打开 https://github.com/new  
2. Repository name 建议：`csc-research-board`（可自定）  
3. 选 **Public**（私密性要求不高时最省事；Private 需 GitHub Pro 才免费开 Pages，或改用 Cloudflare）  
4. **不要**勾选 Add README（本地已有文件）  
5. Create repository  

### 2. 把本地目录推上去

在 PowerShell 中执行（把 `YOUR_USER` 和仓库名换成你的）：

```powershell
cd C:\ai\reports\research-board\github-pages
git add -A
git commit -m "Initial publish: research board"
git remote add origin https://github.com/YOUR_USER/csc-research-board.git
git push -u origin main
```

若尚未登录 GitHub，按提示在浏览器完成登录即可。

### 3. 打开 GitHub Pages

1. 仓库页 → **Settings** → **Pages**  
2. Build and deployment → Source 选 **Deploy from a branch**  
3. Branch 选 `main`，文件夹选 `/ (root)` → Save  
4. 约 1 分钟后出现访问地址，形如：

`https://YOUR_USER.github.io/csc-research-board/`

把这个链接发给同事即可（打开的是本目录下的 `index.html`）。

---

## 日常更新（你改完看板之后）

本地照常更新看板并 `build_board.py` 生成  
`C:\ai\reports\research-board\中信建投研究所晨报及研报看板.html`  
然后执行：

```powershell
powershell -File C:\ai\reports\research-board\github-pages\publish.ps1
```

脚本会：复制最新 HTML → `index.html` → 提交 → 推送到 GitHub。  
对方**刷新链接**即可看到新内容（一般 10–60 秒内 Pages 生效）。

---

## 说明

| 项目 | 说明 |
|------|------|
| 链接是否固定 | 是，仓库与 Pages 地址不变 |
| 是否实时推送 | 否；对方刷新或重新打开即可 |
| 是否公开 | Public 仓库下，知道链接的人都能看 |
| 单文件体积 | 看板较大时推送会稍慢，一般仍可用 |

若以后文件太大、推送变慢，可再改成「壳 + `board-data.json`」只上传数据。

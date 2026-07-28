# GitHub 发布步骤

当前本地仓库已经准备好，分支为 `main`。由于本机 GitHub CLI 尚未登录，需要先完成登录。

## 1. 登录 GitHub

```powershell
gh auth login
gh auth status
```

## 2. 创建公开仓库并推送

把 `YOUR_GITHUB_NAME` 替换成你的 GitHub 用户名。

```powershell
cd "C:\Users\18060\Documents\New project\polymarket_ev_mvp"
gh repo create YOUR_GITHUB_NAME/polymarket-ev-desk --public --source . --remote origin --push
```

## 3. 创建 Release 并上传体验包

```powershell
gh release create v0.1.0 `
  "release\polymarket_ev_desk_web_demo.zip" `
  --title "Polymarket EV Desk v0.1.0" `
  --notes-file "docs\release-notes-v0.1.0.md"
```

## 4. 可选：开启 GitHub Pages

如果要用 GitHub Pages 作为公开 Web demo，需要用仓库路径重新构建：

```powershell
flutter build web --release --base-href /polymarket-ev-desk/
git checkout --orphan gh-pages
git rm -rf .
Copy-Item -Recurse build\web\* .
git add -A
git commit -m "Deploy GitHub Pages demo"
git push -u origin gh-pages --force
gh api repos/YOUR_GITHUB_NAME/polymarket-ev-desk/pages `
  -X POST `
  -f source.branch=gh-pages `
  -f source.path=/
```

GitHub Pages 地址通常是：

```text
https://YOUR_GITHUB_NAME.github.io/polymarket-ev-desk/
```

## 5. 推荐投递材料顺序

1. GitHub/Gitee 仓库链接
2. GitHub Release 下载链接
3. Demo 在线地址
4. `docs/user-research.md`
5. `docs/demo-script.md`

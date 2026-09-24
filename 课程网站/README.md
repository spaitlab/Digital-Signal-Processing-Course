# 课程网站

已导入七章 Quarto 讲义、配套代码、交互实验与 13 个微课入口。采样与混叠试点已连接 Google Drive 浅色版视频，其余视频入口标注待发布。

## 本地预览与构建

安装 Quarto 1.10.18 与 Python 3，从仓库根目录运行：

```sh
python -m pip install -r 课程网站/tools/requirements.txt
quarto preview 课程网站
quarto render 课程网站
python scripts/check_site.py 课程网站/_site
```

检查器覆盖站内文件链接、禁止发布的视频音频文件、教师专用目录和本机绝对路径。它不能代替内容审阅或云端视频播放测试。

## GitHub Pages

仓库 Settings → Pages 的 Source 已设为 GitHub Actions。推送 main 后，工作流构建、检查并发布网站；也可在 Actions 手动运行 Build and publish course website。

正式网址：https://spaitlab.github.io/Digital-Signal-Processing-Course/

首次部署与公开网址检查已通过。`_site/` 是构建产物，由 Actions 发布，不提交到源码仓库。

## 微课维护

稳定入口为 `microlectures/<微课编号>/index.html`。更换视频时保留此路径，更新页面中的播放器与网盘链接，并同步 `资源清单/media-manifest.json`。`cloud.json` 保存对应上传记录；当前页面为静态生成，需要与记录一起更新。

Drive 使用 iframe 预览，并提供网盘打开入口。页面时间表用于对照播放器进度；字幕提供单独下载。试点保留采样率实验和先作答后反馈的练习。

在未登录浏览器、手机和目标教学网络检查播放。分享权限可读不代表已完成播放验收，未验证项目应保留待验证状态。

## 内容更新

修改对应章节 `.qmd` 和代码后先本地构建。本学期课堂课件采用 HTML，维护在 `courseware/`；保留原课件布局、交互及配套 MP3 音频。课件目录通过 `courseware/course-home/catalog.js` 登记已完成讲次。新视频成片存入网盘，提交网页所需的封面、字幕、讲稿、代码与 HTML 课件必要的讲解音频。

## 统一页眉与首页

网站名称和四个内容入口统一在 `_quarto.yml` 的 `website.navbar` 维护。Quarto正文使用原生导航；`tools/sync_navigation.py` 在构建前为微课与在线课件写入同版导航，支持本地文件和GitHub Pages子路径。首次构建从仓库根目录安装 `python -m pip install -r 课程网站/tools/requirements.txt`。样式共用 `site-header.css`；移动菜单脚本为 `site-header.js`。

七章索引在 `textbook.qmd`，备课法并入首页 `#teaching-method`；旧 `method.html` 自动跳到首页对应内容。课件保留学校标识与投影控制，同元 MWORKS 标志统一放在网站页眉。

右上角为GitHub、同元MWORKS圆形Logo和深浅主题按钮。主题共用dsp-micro-theme偏好；微课调用原播放器主题切换以保留播放状态。原微课正文中的重复主题按钮隐藏。

课件接入规则：构建时移除内部重复的站级导航和大号MWORKS标志，保留学校标识与教学控制；返回入口统一为“课件目录”。独立原稿无需改动，导入站点副本后运行tools/sync_navigation.py。全屏仍由.deck.requestFullscreen()实现，主站页眉位于课件之外，退出后恢复。

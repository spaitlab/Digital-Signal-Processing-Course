# 课程网站

已导入七章 Quarto 讲义、配套代码、交互实验与 13 个微课入口。采样与混叠试点已连接 Google Drive 浅色版视频，其余视频入口标注待发布。

## 本地预览与构建

安装 Quarto 1.10.18 与 Python 3，从仓库根目录运行：

```sh
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

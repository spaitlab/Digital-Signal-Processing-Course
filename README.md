# 数字信号处理 · 课程资源

Digital Signal Processing Course · SpaitLab

本仓库用于维护《数字信号处理》课程的课件、课程网站、微课资料与实验代码。课程网站作为统一学习入口，视频成片存放于 Google Drive。

> 当前状态：七章讲义网站已上线；本学期采用 HTML 动静课件，目前接入三讲（第1章01、第2章01、第3章01），其余课堂课件陆续补充。首条采样微课已接入 Google Drive 并验证未登录起播。

[访问课程网站](https://spaitlab.github.io/Digital-Signal-Processing-Course/) · [查看部署状态](https://github.com/spaitlab/Digital-Signal-Processing-Course/actions/workflows/pages.yml)

网站已上线：可从首页进入七章讲义、课堂课件和微课目录。

## 资源入口

| 资源 | 入口 | 当前状态 |
| --- | --- | --- |
| 课程网站 | [在线课程网站](https://spaitlab.github.io/Digital-Signal-Processing-Course/) · [维护说明](课程网站/README.md) | 已上线 |
| 课堂课件 | [进入 HTML 课件](https://spaitlab.github.io/Digital-Signal-Processing-Course/courseware/index.html) | 三讲已接入，支持动态演示和同步讲解 |
| 微课与视频 | [媒体管理说明](资源清单/README.md) · [媒体清单](资源清单/media-manifest.json) | 已登记 13 条，首条浅色版已验证未登录起播 |
| 云端课程资源 | [Google Drive · Course](https://drive.google.com/drive/folders/1gHXmujkXIk45643K1fm7i8QP-Eqhe5_5) | 已确定存储目录 |
| 原有配套程序 | [Digital-Signal-Processing](https://github.com/spaitlab/Digital-Signal-Processing) | 独立程序仓库 |

## 课程章节

1. 数字信号处理概述
2. 离散时间信号和系统分析
3. 离散傅里叶变换
4. 快速傅里叶变换
5. 数字滤波器的结构
6. IIR 数字滤波器设计
7. FIR 数字滤波器设计

## 仓库结构

```text
课件/          本学期 HTML 课堂课件入口与说明
课程网站/      Quarto 讲义、交互页面、实验代码及微课页面
资源清单/      视频存储位置、发布状态、版本与校验信息
```

课堂课件位于 `课程网站/courseware/`；微课页面连接 Google Drive 视频。更换视频或存储服务时，保持课程页面地址稳定。

## 维护约定

- Git 管理讲义、课件、代码、封面、讲稿、字幕和时间轴；视频成片、配音制作缓存及离线整站包存放于网盘；HTML 课件必需的 MP3 讲解音频随课件发布。
- 网站生成目录 `_site/`、Quarto 缓存、浏览器测试缓存及 Office 临时文件不提交。
- 花名册、成绩、学生个人作业、教师专用答案和账号配置不进入公开仓库。
- 微课上传完成后，验证分享权限及实际播放，再填写资源清单的链接和验证日期。
- 学期定稿通过版本标签保存，例如 `2026-2027-1-v1.0`；该标签目前尚未创建。

## 使用与反馈

目前处于首轮发布阶段。发现错字、失效链接或实验问题，可通过本仓库 [Issues](https://github.com/spaitlab/Digital-Signal-Processing-Course/issues) 反馈，并注明章节或微课编号。

各资源的作者、来源与许可将在导入时逐项记录；当前尚未指定统一的内容或代码许可证。

# 媒体资源清单

[media-manifest.json](media-manifest.json) 记录本地已有微课的编号、标题、主题版本及待填的云端链接。共登记 13 条微课。`2.1-sampling` 浅色版已上传，分享权限已确认，未登录桌面浏览器短时起播已通过，手机与教学网络待验收；其余条目待上传。

## 云端存储

课程资源根目录：[Google Drive · Course](https://drive.google.com/drive/folders/1gHXmujkXIk45643K1fm7i8QP-Eqhe5_5)。

计划在其下建立 `Digital-Signal-Processing/微课/第01章/` 至 `第07章/`，并另建 `课堂动画/` 与 `离线下载包/`。目前已建立 `Digital-Signal-Processing/微课/第02章/2.1-采样与混叠/`，其余目录按实际上传需要创建。

## 清单字段

| 字段 | 含义 |
| --- | --- |
| `id` | 与现有微课目录一致的稳定编号 |
| `title` | 从本地微课网页标题提取的名称 |
| `status` | `pending_upload`、`uploaded` 或 `verified` |
| `planned_page_path` | 计划保留的网站相对路径，尚不代表页面已发布 |
| `page_url` | 实际发布并验证后的网站地址 |
| `variants` | 浅色、深色等视频版本，包含相对文件路径和云端记录 |
| `file_id` / `share_url` / `embed_url` | 上传并验证后填写的真实 Drive 文件 ID、分享和嵌入地址 |
| `mirror_url` | 已验证的备用播放地址，无镜像时为 `null` |
| `version` / `sha256` | 经确认的版本和上传文件校验值 |
| `verified_at` | 验证日期；尚未验证时为 `null` |

缺失的信息统一使用 `null`，不使用示例 ID 或猜测的播放地址。保存完整的真实分享链接，包括服务返回的必要参数。

## 上线流程

1. 选定成片版本，上传至对应课程子目录。
2. 等待同步和视频处理结束，记录实际文件 ID、分享链接与校验值。
3. 检查查看权限，并用未登录浏览器验证播放、字幕和下载。
4. 配置网站播放入口与备用链接；验证通过后将状态改为 `verified`。
5. 网站发布后填写 `page_url`，课件链接及二维码指向该固定页面。

不要通过文件夹分享地址或本地同步盘路径推算单个视频的播放链接。更新视频后应重新验证实际链接和页面行为。

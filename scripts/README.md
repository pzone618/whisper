# 🚀 新 Mac 快速部署

## 一键部署命令

在新 Mac 上，只需要一行命令即可完成整个部署：

```bash
curl -sSL https://raw.githubusercontent.com/pzone618/whisper/feature/mac/quick_deploy.sh | bash
```

## 分步部署（推荐）

如果你喜欢更可控的部署过程：

```bash
# 1. 克隆项目
git clone https://github.com/pzone618/whisper.git
cd whisper
git checkout feature/mac

# 2. 运行设置脚本
./scripts/setup_new_mac.sh

# 3. 激活环境
source venv/bin/activate

# 4. 开始使用
python subtitle_extractor.py --help
```

## 部署后验证

```bash
# 激活环境
source venv/bin/activate

# 验证 Whisper
python -c "import whisper; print('✅ 成功!')"

# 测试功能
./batch_subtitle.sh --help

# 查看完整文档
cat DOCUMENTATION_INDEX.md
```

## 前提条件

新 Mac 需要安装：
- **Git** (通常系统自带)
- **Python 3.8+** (可通过 Xcode Command Line Tools 或 Homebrew 安装)
- **Homebrew** (可选，用于安装 ffmpeg)

## 包含的功能

部署完成后，您将拥有：

✅ **完整的 Whisper 环境**
- 多语言语音识别（99种语言）
- 批量处理脚本
- Python API 工具
- 容器化部署选项

✅ **完整的目录结构**
- 音频/视频输入输出目录
- 模型缓存目录
- 示例和文档

✅ **详细的文档系统**
- 多语言使用指南
- 容器部署指南
- 故障排除文档

## 预计时间

- **一键部署**: 5-10 分钟
- **分步部署**: 3-5 分钟
- **首次模型下载**: 1-5 分钟（根据模型大小）

## 下一步

部署完成后，建议：

1. 阅读 `MULTILINGUAL_SUBTITLES_GUIDE.md` 了解如何提取字幕
2. 查看 `CONTAINER_DEPLOYMENT.md` 学习容器化部署
3. 尝试 `./batch_subtitle.sh` 进行批量处理

🎉 享受 Whisper 的强大功能！
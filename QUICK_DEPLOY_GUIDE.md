# 🚀 新 Mac 快速部署指南

## 📋 一键部署脚本

### 前提条件检查
在开始之前，确保新 Mac 已安装：
- **Git** - 用于克隆项目
- **Python 3.8+** - 运行 Whisper
- **Homebrew** (推荐) - 安装依赖

## 🎯 5分钟快速部署

### 方法一：全自动部署脚本

创建并运行自动化部署脚本：

```bash
# 下载并运行一键部署脚本
curl -sSL https://raw.githubusercontent.com/pzone618/whisper/feature/mac/quick_deploy.sh | bash
```

### 方法二：手动分步部署

```bash
# 1. 克隆项目
git clone https://github.com/pzone618/whisper.git
cd whisper

# 2. 切换到功能分支
git checkout feature/mac

# 3. 一键环境设置
./scripts/setup_new_mac.sh

# 4. 验证安装
python -c "import whisper; print('✅ Whisper 安装成功!')"
```

## 🛠️ 详细部署步骤

### 1. 环境准备

```bash
# 安装 Homebrew (如果没有)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装必要工具
brew install python git ffmpeg

# 验证 Python 版本
python3 --version  # 应该是 3.8+
```

### 2. 项目克隆与设置

```bash
# 克隆项目
git clone https://github.com/pzone618/whisper.git
cd whisper

# 切换到功能分支
git checkout feature/mac

# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 验证安装
python -c "import whisper; print('安装成功!')"
```

### 3. 目录结构验证

项目克隆后会自动包含：
```
whisper/
├── 📁 audio_input/          # 音频输入目录 (空目录 + .gitkeep)
├── 📁 audio_output/         # 字幕输出目录 (空目录 + .gitkeep)  
├── 📁 video_input/          # 视频输入目录 (空目录 + .gitkeep)
├── 📁 video_output/         # 视频字幕输出目录 (空目录 + .gitkeep)
├── 🛠️ deploy.sh             # 容器部署脚本
├── 🛠️ batch_subtitle.sh     # 批量处理脚本
├── 🐍 subtitle_extractor.py # Python 工具
├── 📚 完整文档系统          # 所有使用指南
└── ⚙️ 所有配置文件          # 容器、部署配置
```

### 4. 快速测试

```bash
# 下载测试模型 (最小的 tiny 模型)
python -c "import whisper; whisper.load_model('tiny')"

# 测试基本功能 (如果有测试音频)
whisper audio_input/test.wav --language Chinese --model tiny

# 或使用我们的 Python 工具
python subtitle_extractor.py --help
```

## 🎉 完成后可用功能

### ✅ 立即可用的功能
1. **命令行转录** - `whisper audio.mp3 --language Chinese`
2. **批量处理** - `./batch_subtitle.sh Chinese medium srt`
3. **Python API** - `python subtitle_extractor.py`
4. **容器部署** - `./deploy.sh build && ./deploy.sh run`

### ✅ 已配置的目录
- 音频输入目录已就绪
- 字幕输出目录已配置
- 模型缓存目录已设置
- 所有脚本已具备执行权限

### ✅ 完整文档
- 多语言使用指南
- 容器部署指南  
- 故障排除文档
- API 使用说明

## 🚀 高级部署选项

### 容器化部署 (推荐生产环境)

```bash
# 构建容器
./deploy.sh build

# 交互式使用
./deploy.sh run

# 批量处理
./deploy.sh transcribe audio.mp3 large
```

### 性能优化

```bash
# 预下载常用模型
python -c "
import whisper
for model in ['tiny', 'base', 'small', 'medium']:
    print(f'下载 {model} 模型...')
    whisper.load_model(model)
print('✅ 所有模型下载完成!')
"
```

## 🔧 故障排除

### 常见问题及解决方案

#### 1. 权限问题
```bash
# 确保脚本有执行权限
chmod +x deploy.sh batch_subtitle.sh subtitle_extractor.py
```

#### 2. Python 版本问题
```bash
# 如果系统 Python 版本过低
brew install python@3.11
python3.11 -m venv venv
```

#### 3. ffmpeg 缺失
```bash
# 安装 ffmpeg
brew install ffmpeg
```

#### 4. 网络问题 (模型下载失败)
```bash
# 设置代理 (如果需要)
export HTTP_PROXY=http://proxy:port
export HTTPS_PROXY=http://proxy:port

# 或手动下载模型到 whisper_models/ 目录
```

## 📊 部署时间估算

| 步骤 | 预计时间 | 说明 |
|------|----------|------|
| Git 克隆 | 1-2 分钟 | 取决于网络速度 |
| 环境设置 | 2-3 分钟 | 虚拟环境 + 依赖安装 |
| 首次模型下载 | 1-5 分钟 | 取决于选择的模型大小 |
| **总计** | **5-10 分钟** | 一杯咖啡的时间 ☕ |

## 🎯 快速验证清单

部署完成后，验证以下功能：

- [ ] ✅ Python 环境激活成功
- [ ] ✅ Whisper 导入无错误  
- [ ] ✅ 目录结构完整
- [ ] ✅ 脚本具有执行权限
- [ ] ✅ 文档可以正常访问
- [ ] ✅ 基本转录功能正常

## 💡 小贴士

1. **建议先用 tiny 模型测试** - 下载快，验证环境
2. **根据需要下载大模型** - medium/large 模型效果更好但需要更多资源
3. **参考完整文档** - `DOCUMENTATION_INDEX.md` 包含所有功能说明
4. **容器化适合生产** - 如果需要稳定的生产环境，使用容器部署

---

🎉 **恭喜！** 您现在已经在新 Mac 上拥有了一个功能完整的 Whisper 多语言字幕提取系统！

下一步可以查看 `MULTILINGUAL_SUBTITLES_GUIDE.md` 开始提取字幕，或查看 `CONTAINER_DEPLOYMENT.md` 进行容器化部署。
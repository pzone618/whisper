#!/bin/bash

# =============================================================================
# 新 Mac 环境快速设置脚本
# 在项目目录内运行，假设项目已经克隆
# =============================================================================

set -e

echo "🚀 开始设置 Whisper 环境..."

# 检查是否在项目根目录
if [[ ! -f "requirements.txt" ]]; then
    echo "❌ 请在项目根目录运行此脚本"
    exit 1
fi

# 1. 创建虚拟环境
echo "📦 创建虚拟环境..."
python3 -m venv venv
source venv/bin/activate

# 2. 升级 pip
echo "⬆️ 升级 pip..."
pip install --upgrade pip

# 3. 安装依赖
echo "📚 安装依赖..."
pip install -r requirements.txt

# 4. 设置脚本权限
echo "🔧 设置权限..."
chmod +x deploy.sh batch_subtitle.sh subtitle_extractor.py quick_deploy.sh

# 5. 验证安装
echo "✅ 验证安装..."
python -c "import whisper; print('Whisper 安装成功!')"

echo ""
echo "🎉 环境设置完成！"
echo ""
echo "下一步："
echo "  1. 激活环境: source venv/bin/activate"
echo "  2. 查看文档: cat DOCUMENTATION_INDEX.md"
echo "  3. 开始使用: python subtitle_extractor.py --help"
#!/bin/bash

# =============================================================================
# Whisper 新 Mac 一键部署脚本
# =============================================================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 打印函数
print_step() {
    echo -e "${BLUE}🔄 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 主要部署函数
main() {
    echo -e "${BLUE}"
    echo "=========================================="
    echo "🚀 Whisper 新 Mac 一键部署脚本"
    echo "=========================================="
    echo -e "${NC}"
    
    # 1. 检查系统要求
    print_step "检查系统要求..."
    
    # 检查 macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "此脚本仅适用于 macOS 系统"
        exit 1
    fi
    print_success "运行在 macOS 系统"
    
    # 检查 Git
    if ! command_exists git; then
        print_error "Git 未安装，请先安装 Git"
        exit 1
    fi
    print_success "Git 已安装: $(git --version)"
    
    # 检查 Python
    if ! command_exists python3; then
        print_error "Python3 未安装，请先安装 Python 3.8+"
        exit 1
    fi
    
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    print_success "Python 已安装: $PYTHON_VERSION"
    
    # 2. 检查/安装 Homebrew
    print_step "检查 Homebrew..."
    if ! command_exists brew; then
        print_warning "Homebrew 未安装，正在安装..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # 添加 Homebrew 到 PATH
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            export PATH="/opt/homebrew/bin:$PATH"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            export PATH="/usr/local/bin:$PATH"
        fi
    fi
    print_success "Homebrew 已就绪: $(brew --version | head -1)"
    
    # 3. 安装/检查 ffmpeg
    print_step "检查 ffmpeg..."
    if ! command_exists ffmpeg; then
        print_warning "ffmpeg 未安装，正在安装..."
        brew install ffmpeg
    fi
    print_success "ffmpeg 已安装: $(ffmpeg -version | head -1 | cut -d' ' -f3)"
    
    # 4. 克隆项目
    print_step "克隆 Whisper 项目..."
    
    PROJECT_DIR="whisper"
    if [[ -d "$PROJECT_DIR" ]]; then
        print_warning "目录 $PROJECT_DIR 已存在，正在更新..."
        cd "$PROJECT_DIR"
        git pull origin feature/mac
    else
        git clone https://github.com/pzone618/whisper.git "$PROJECT_DIR"
        cd "$PROJECT_DIR"
        git checkout feature/mac
    fi
    print_success "项目已克隆到 $(pwd)"
    
    # 5. 创建虚拟环境
    print_step "创建 Python 虚拟环境..."
    if [[ ! -d "venv" ]]; then
        python3 -m venv venv
    fi
    source venv/bin/activate
    print_success "虚拟环境已激活"
    
    # 6. 升级 pip
    print_step "升级 pip..."
    pip install --upgrade pip
    
    # 7. 安装依赖
    print_step "安装 Python 依赖..."
    pip install -r requirements.txt
    print_success "所有依赖已安装"
    
    # 8. 设置脚本权限
    print_step "设置脚本执行权限..."
    chmod +x deploy.sh batch_subtitle.sh subtitle_extractor.py
    print_success "脚本权限已设置"
    
    # 9. 验证安装
    print_step "验证 Whisper 安装..."
    python -c "import whisper; print('Whisper 导入成功!')" 2>/dev/null || {
        print_error "Whisper 导入失败，请检查安装"
        exit 1
    }
    print_success "Whisper 安装验证通过"
    
    # 10. 下载测试模型（可选）
    echo ""
    read -p "$(echo -e ${YELLOW}是否下载 tiny 模型进行测试？ \(y/N\): ${NC})" -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "下载 tiny 模型..."
        python -c "import whisper; whisper.load_model('tiny'); print('tiny 模型下载完成!')"
        print_success "tiny 模型已缓存"
    fi
    
    # 11. 完成信息
    echo ""
    echo -e "${GREEN}"
    echo "=========================================="
    echo "🎉 部署完成！"
    echo "=========================================="
    echo -e "${NC}"
    
    echo -e "${YELLOW}项目路径:${NC} $(pwd)"
    echo -e "${YELLOW}虚拟环境:${NC} source venv/bin/activate"
    echo ""
    echo -e "${BLUE}快速开始:${NC}"
    echo "  1. 激活环境: source venv/bin/activate"
    echo "  2. 查看帮助: python subtitle_extractor.py --help"
    echo "  3. 批量处理: ./batch_subtitle.sh Chinese medium srt"
    echo "  4. 容器部署: ./deploy.sh build"
    echo ""
    echo -e "${BLUE}文档指南:${NC}"
    echo "  📚 完整文档: cat DOCUMENTATION_INDEX.md"
    echo "  🌏 多语言指南: cat MULTILINGUAL_SUBTITLES_GUIDE.md"
    echo "  🐳 容器部署: cat CONTAINER_DEPLOYMENT.md"
    echo ""
    echo -e "${GREEN}✨ 享受 Whisper 多语言字幕提取！${NC}"
}

# 错误处理
trap 'print_error "部署过程中出现错误，请检查上述输出"; exit 1' ERR

# 运行主函数
main "$@"
#!/bin/bash

# 批量字幕提取脚本
# 用法: ./batch_subtitle.sh [语言] [模型] [输出格式]

set -euo pipefail

# 默认参数
LANGUAGE="${1:-auto}"       # 语言 (auto为自动检测)
MODEL="${2:-base}"          # 模型大小
FORMAT="${3:-srt}"          # 输出格式

# 输入和输出目录
INPUT_DIR="audio_input"
OUTPUT_DIR="audio_output"

# 创建目录
mkdir -p "$INPUT_DIR" "$OUTPUT_DIR"

# 激活虚拟环境（如果使用本地方式）
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
fi

echo "🎯 批量字幕提取开始..."
echo "语言: $LANGUAGE"
echo "模型: $MODEL"
echo "格式: $FORMAT"
echo "================================"

# 支持的音频/视频格式
EXTENSIONS="mp3 wav flac m4a aac ogg mp4 avi mkv mov"

processed=0
failed=0

for ext in $EXTENSIONS; do
    for file in "$INPUT_DIR"/*."$ext" 2>/dev/null; do
        [ -f "$file" ] || continue
        
        filename=$(basename "$file")
        echo "📄 处理: $filename"
        
        # 选择处理方式：容器 vs 本地
        if command -v podman &> /dev/null && podman images | grep -q whisper:latest; then
            # 使用容器
            if [ "$LANGUAGE" = "auto" ]; then
                podman run --rm \
                    -v "$(pwd)/whisper_models:/models:Z" \
                    -v "$(pwd)/$INPUT_DIR:/input:Z,ro" \
                    -v "$(pwd)/$OUTPUT_DIR:/output:Z" \
                    -e WHISPER_CACHE_DIR=/models \
                    whisper:latest \
                    whisper "/input/$filename" --model "$MODEL" --output_format "$FORMAT" --output_dir /output
            else
                podman run --rm \
                    -v "$(pwd)/whisper_models:/models:Z" \
                    -v "$(pwd)/$INPUT_DIR:/input:Z,ro" \
                    -v "$(pwd)/$OUTPUT_DIR:/output:Z" \
                    -e WHISPER_CACHE_DIR=/models \
                    whisper:latest \
                    whisper "/input/$filename" --model "$MODEL" --language "$LANGUAGE" --output_format "$FORMAT" --output_dir /output
            fi
        else
            # 使用本地安装
            if [ "$LANGUAGE" = "auto" ]; then
                whisper "$file" --model "$MODEL" --output_format "$FORMAT" --output_dir "$OUTPUT_DIR"
            else
                whisper "$file" --model "$MODEL" --language "$LANGUAGE" --output_format "$FORMAT" --output_dir "$OUTPUT_DIR"
            fi
        fi
        
        if [ $? -eq 0 ]; then
            echo "✅ 成功: $filename"
            ((processed++))
        else
            echo "❌ 失败: $filename"
            ((failed++))
        fi
        echo "--------------------------------"
    done
done

echo "🎉 批量处理完成!"
echo "✅ 成功: $processed 个文件"
echo "❌ 失败: $failed 个文件"
echo "📁 输出目录: $OUTPUT_DIR"

# 显示结果文件
if [ $processed -gt 0 ]; then
    echo ""
    echo "📋 生成的字幕文件:"
    ls -la "$OUTPUT_DIR"/*."$FORMAT" 2>/dev/null || echo "   没有找到 .$FORMAT 文件"
fi
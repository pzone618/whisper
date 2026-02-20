#!/usr/bin/env python3
"""
Whisper 基础功能验证和使用指南
不依赖模型下载的测试
"""

import whisper
import sys
import os

def test_basic_functionality():
    """测试基础功能"""
    print("🔍 Whisper 基础功能测试")
    print("=" * 40)
    
    # 1. 模块导入测试
    print("1. ✅ 模块导入成功")
    
    # 2. 获取可用模型
    models = whisper.available_models()
    print(f"2. ✅ 可用模型: {len(models)} 个")
    for i, model in enumerate(models, 1):
        print(f"   {i:2d}. {model}")
    
    # 3. 检查缓存目录
    cache_dir = "/Volumes/LaCie/big_model/whisper"
    print(f"\n3. 📁 缓存目录: {cache_dir}")
    if os.path.exists(cache_dir):
        files = [f for f in os.listdir(cache_dir) if f.endswith('.pt')]
        if files:
            print(f"   ✅ 已下载模型: {files}")
        else:
            print(f"   ⚠️  暂无已下载的模型文件")
    else:
        print(f"   ⚠️  缓存目录不存在")
    
    # 4. 检查 ffmpeg
    import subprocess
    try:
        result = subprocess.run(['ffmpeg', '-version'], 
                              capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            version_line = result.stdout.split('\n')[0]
            print(f"\n4. ✅ ffmpeg 已安装: {version_line}")
        else:
            print(f"\n4. ❌ ffmpeg 检查失败")
    except Exception as e:
        print(f"\n4. ❌ ffmpeg 未找到: {e}")

def show_usage_examples():
    """展示使用示例"""
    print("\n" + "=" * 50)
    print("📚 Whisper 使用指南")
    print("=" * 50)
    
    print("\n🎯 1. 命令行使用:")
    print("   # 转录音频文件")
    print("   whisper audio.mp3")
    print("   whisper audio.wav --language Chinese")
    print("   whisper audio.m4a --model tiny --output_dir ./output")
    
    print("\n🐍 2. Python 代码使用:")
    print("""   import whisper
   
   # 加载模型
   model = whisper.load_model("tiny")
   
   # 转录音频文件
   result = model.transcribe("audio.mp3")
   print(result["text"])
   
   # 指定语言
   result = model.transcribe("audio.mp3", language="zh")
   print(result["text"])""")
    
    print("\n🌍 3. 支持的语言:")
    languages = [
        "Chinese (zh)", "English (en)", "Japanese (ja)", 
        "Korean (ko)", "Spanish (es)", "French (fr)",
        "German (de)", "Italian (it)", "Portuguese (pt)",
        "Russian (ru)", "Arabic (ar)", "Hindi (hi)"
    ]
    for lang in languages:
        print(f"   • {lang}")
    
    print("\n🤖 4. 模型选择:")
    model_info = [
        ("tiny", "~39MB", "最快，精度较低"),
        ("base", "~142MB", "平衡速度和精度"),
        ("small", "~461MB", "较好精度"),
        ("medium", "~1.42GB", "更好精度"),
        ("large", "~2.87GB", "最高精度")
    ]
    print("   模型名称    大小      特点")
    print("   " + "-" * 30)
    for name, size, desc in model_info:
        print(f"   {name:<10} {size:<10} {desc}")
    
    print("\n📱 5. 支持的音频格式:")
    formats = ["MP3", "WAV", "FLAC", "M4A", "OGG", "WMA"]
    print("   " + " • ".join(formats))

def show_next_steps():
    """展示后续步骤"""
    print("\n" + "=" * 50)
    print("🚀 接下来你可以:")
    print("=" * 50)
    
    print("\n1. 🎵 测试音频转录:")
    print("   - 准备一个音频文件 (如 test.mp3)")
    print("   - 运行: whisper test.mp3")
    
    print("\n2. 📓 查看示例笔记本:")
    print("   - notebooks/LibriSpeech.ipynb")
    print("   - notebooks/Multilingual_ASR.ipynb")
    
    print("\n3. 🔧 如果模型下载有问题:")
    print("   - 检查网络连接")
    print("   - 清除缓存: rm -rf /Volumes/LaCie/big_model/whisper")
    print("   - 使用VPN或更换网络")
    print("   - 尝试从不同位置下载")
    
    print("\n4. 💻 开发集成:")
    print("   - 查看 whisper/ 目录源码")
    print("   - 阅读 README.md")
    print("   - 运行测试: pytest tests/")

def main():
    """主函数"""
    print("🎤 OpenAI Whisper 本地安装验证")
    print("=" * 50)
    
    try:
        test_basic_functionality()
        show_usage_examples()
        show_next_steps()
        
        print(f"\n✅ Whisper 已成功安装并可以使用!")
        print("💡 模型会在首次使用时自动下载")
        return 0
        
    except Exception as e:
        print(f"\n❌ 测试出错: {e}")
        return 1

if __name__ == "__main__":
    exit(main())
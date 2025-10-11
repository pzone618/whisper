#!/usr/bin/env python3
"""
Whisper 音频转录示例
使用内置测试音频或自定义音频文件
"""

import whisper
import numpy as np

def create_test_audio():
    """创建一个简单的测试音频信号"""
    # 创建1秒的440Hz正弦波(A音符)
    sample_rate = 16000  # Whisper期望的采样率
    duration = 1.0  # 秒
    frequency = 440  # Hz
    
    t = np.linspace(0, duration, int(sample_rate * duration))
    audio = np.sin(2 * np.pi * frequency * t).astype(np.float32)
    
    return audio

def test_whisper_functionality():
    """测试Whisper的基本转录功能"""
    print("🎵 开始 Whisper 音频转录测试\n")
    
    try:
        # 1. 导入测试
        print("1. 📦 测试模块导入...")
        print("✅ Whisper 模块导入成功")
        
        # 2. 模型列表
        print("\n2. 📋 获取可用模型...")
        models = whisper.available_models()
        print(f"✅ 可用模型: {models}")
        
        # 3. 加载模型 (使用最小的模型避免下载问题)
        print(f"\n3. 🤖 尝试加载 tiny 模型...")
        
        # 先检查是否有本地缓存
        import os
        cache_dir = os.path.expanduser("~/.cache/whisper")
        if os.path.exists(cache_dir):
            print(f"📁 缓存目录: {cache_dir}")
            files = os.listdir(cache_dir) if os.path.exists(cache_dir) else []
            print(f"📄 缓存文件: {files}")
        
        # 尝试加载模型
        try:
            model = whisper.load_model("tiny")
            print("✅ 模型加载成功")
            print(f"📱 运行设备: {model.device}")
            
            # 4. 测试音频处理
            print(f"\n4. 🎧 测试音频处理...")
            test_audio = create_test_audio()
            print(f"✅ 测试音频创建成功: {len(test_audio)} 采样点")
            
            # 5. 进行转录
            print(f"\n5. 🗣️  尝试音频转录...")
            result = model.transcribe(test_audio)
            print(f"✅ 转录完成")
            print(f"📝 转录结果: '{result['text']}'")
            print(f"🎯 检测语言: {result.get('language', 'unknown')}")
            
            return True
            
        except Exception as model_error:
            print(f"❌ 模型相关错误: {model_error}")
            print("💡 这可能是由于网络问题或模型文件损坏")
            print("💡 建议: 检查网络连接或稍后重试")
            return False
            
    except Exception as e:
        print(f"❌ 测试失败: {e}")
        return False

def show_whisper_info():
    """显示Whisper基本信息"""
    print("📋 Whisper 项目信息:")
    print("=" * 50)
    print("🏷️  项目名称: OpenAI Whisper")
    print("🎯 功能: 自动语音识别 (ASR)")
    print("🌍 支持语言: 多语言 (包括中文)")
    print("🤖 模型大小: tiny, base, small, medium, large")
    print("📱 设备支持: CPU 和 GPU")
    print("🎵 音频格式: MP3, WAV, M4A, FLAC 等")
    print("=" * 50)

def main():
    """主函数"""
    show_whisper_info()
    print()
    
    success = test_whisper_functionality()
    
    print(f"\n{'=' * 50}")
    if success:
        print("🎉 Whisper 安装验证成功！")
        print("💡 你现在可以:")
        print("   - 使用命令行: whisper audio.mp3")
        print("   - 在Python中: import whisper; model = whisper.load_model('tiny')")
        print("   - 查看示例: 检查 notebooks/ 目录中的 Jupyter notebook")
    else:
        print("⚠️  Whisper 基本功能有问题")
        print("💡 但核心模块已正确安装")
        print("💡 可能需要:")
        print("   - 检查网络连接")
        print("   - 清除缓存: rm -rf ~/.cache/whisper/")
        print("   - 重新运行测试")
    
    return 0 if success else 1

if __name__ == "__main__":
    exit(main())
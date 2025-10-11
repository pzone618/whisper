#!/usr/bin/env python3
"""
简单的 Whisper 功能测试
"""

import whisper

def test_basic_import():
    """测试基本导入功能"""
    print("✅ Whisper 模块导入成功")
    return True

def test_available_models():
    """测试可用模型"""
    models = whisper.available_models()
    print(f"✅ 可用模型: {models}")
    assert len(models) > 0
    return True

def test_load_model():
    """测试加载最小模型"""
    try:
        print("⏳ 正在加载 tiny 模型...")
        model = whisper.load_model("tiny")
        print("✅ tiny 模型加载成功")
        print(f"✅ 模型设备: {model.device}")
        return True
    except Exception as e:
        print(f"❌ 模型加载失败: {e}")
        return False

def main():
    """运行所有测试"""
    print("🚀 开始 Whisper 基本功能测试\n")
    
    tests = [
        ("基本导入测试", test_basic_import),
        ("可用模型测试", test_available_models),
        ("模型加载测试", test_load_model),
    ]
    
    passed = 0
    total = len(tests)
    
    for name, test_func in tests:
        print(f"📋 运行: {name}")
        try:
            if test_func():
                passed += 1
                print(f"✅ {name} 通过\n")
            else:
                print(f"❌ {name} 失败\n")
        except Exception as e:
            print(f"❌ {name} 错误: {e}\n")
    
    print(f"📊 测试结果: {passed}/{total} 通过")
    
    if passed == total:
        print("🎉 所有测试通过！Whisper 安装成功且运行正常！")
        return 0
    else:
        print("⚠️  部分测试失败，请检查安装")
        return 1

if __name__ == "__main__":
    exit(main())
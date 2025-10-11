#!/usr/bin/env python3
"""
Whisper多语言字幕提取Python接口示例
支持批量处理、多种输出格式、语言检测等功能
"""

import whisper
import os
import sys
import json
from pathlib import Path
import argparse

class WhisperSubtitleExtractor:
    def __init__(self, model_name="base", device="cpu"):
        """
        初始化Whisper字幕提取器
        
        Args:
            model_name: 模型名称 (tiny, base, small, medium, large, turbo)
            device: 设备 (cpu, cuda)
        """
        print(f"🔄 正在加载 {model_name} 模型...")
        self.model = whisper.load_model(model_name, device=device)
        self.model_name = model_name
        print(f"✅ {model_name} 模型加载完成")
    
    def extract_subtitles(self, audio_path, language=None, task="transcribe", 
                         output_dir="output", output_formats=["srt"]):
        """
        提取字幕
        
        Args:
            audio_path: 音频文件路径
            language: 语言代码 (zh, en, ja, ko等，None为自动检测)
            task: 任务类型 ("transcribe" 或 "translate")
            output_dir: 输出目录
            output_formats: 输出格式列表 ["srt", "vtt", "txt", "json"]
        
        Returns:
            dict: 包含转录结果的字典
        """
        if not os.path.exists(audio_path):
            raise FileNotFoundError(f"音频文件不存在: {audio_path}")
        
        print(f"🎵 正在处理: {audio_path}")
        
        # 设置输出目录
        Path(output_dir).mkdir(parents=True, exist_ok=True)
        
        # 执行转录
        options = {
            "task": task,
            "fp16": False  # 在CPU上使用fp32
        }
        
        if language:
            options["language"] = language
            print(f"🌍 指定语言: {language}")
        else:
            print("🔍 自动检测语言中...")
        
        result = self.model.transcribe(audio_path, **options)
        
        # 显示检测到的语言
        detected_language = result.get("language", "unknown")
        print(f"🎯 检测到的语言: {detected_language}")
        
        # 生成输出文件
        base_name = Path(audio_path).stem
        
        for fmt in output_formats:
            output_path = Path(output_dir) / f"{base_name}.{fmt}"
            self._save_result(result, output_path, fmt)
            print(f"💾 已保存: {output_path}")
        
        return result
    
    def _save_result(self, result, output_path, format_type):
        """保存结果到指定格式"""
        
        if format_type == "txt":
            with open(output_path, "w", encoding="utf-8") as f:
                f.write(result["text"])
        
        elif format_type == "json":
            with open(output_path, "w", encoding="utf-8") as f:
                json.dump(result, f, ensure_ascii=False, indent=2)
        
        elif format_type == "srt":
            self._write_srt(result, output_path)
        
        elif format_type == "vtt":
            self._write_vtt(result, output_path)
    
    def _write_srt(self, result, output_path):
        """写入SRT格式字幕"""
        with open(output_path, "w", encoding="utf-8") as f:
            for i, segment in enumerate(result["segments"], 1):
                start_time = self._format_timestamp(segment["start"])
                end_time = self._format_timestamp(segment["end"])
                text = segment["text"].strip()
                
                f.write(f"{i}\n")
                f.write(f"{start_time} --> {end_time}\n")
                f.write(f"{text}\n\n")
    
    def _write_vtt(self, result, output_path):
        """写入VTT格式字幕"""
        with open(output_path, "w", encoding="utf-8") as f:
            f.write("WEBVTT\n\n")
            
            for segment in result["segments"]:
                start_time = self._format_timestamp(segment["start"], vtt=True)
                end_time = self._format_timestamp(segment["end"], vtt=True)
                text = segment["text"].strip()
                
                f.write(f"{start_time} --> {end_time}\n")
                f.write(f"{text}\n\n")
    
    def _format_timestamp(self, seconds, vtt=False):
        """格式化时间戳"""
        hours = int(seconds // 3600)
        minutes = int((seconds % 3600) // 60)
        seconds = seconds % 60
        
        if vtt:
            return f"{hours:02d}:{minutes:02d}:{seconds:06.3f}"
        else:
            return f"{hours:02d}:{minutes:02d}:{seconds:06.3f}".replace(".", ",")
    
    def batch_process(self, input_dir, language=None, task="transcribe", 
                     output_dir="batch_output", output_formats=["srt"]):
        """
        批量处理目录中的音频文件
        
        Args:
            input_dir: 输入目录
            language: 语言代码
            task: 任务类型
            output_dir: 输出目录
            output_formats: 输出格式列表
        """
        input_path = Path(input_dir)
        if not input_path.exists():
            raise FileNotFoundError(f"输入目录不存在: {input_dir}")
        
        # 支持的音频格式
        audio_extensions = {".mp3", ".wav", ".flac", ".m4a", ".aac", ".ogg", 
                          ".mp4", ".avi", ".mkv", ".mov"}
        
        audio_files = []
        for ext in audio_extensions:
            audio_files.extend(input_path.glob(f"*{ext}"))
            audio_files.extend(input_path.glob(f"*{ext.upper()}"))
        
        if not audio_files:
            print(f"❌ 在 {input_dir} 中没有找到音频文件")
            return
        
        print(f"📁 找到 {len(audio_files)} 个音频文件")
        
        successful = 0
        failed = 0
        
        for audio_file in audio_files:
            try:
                self.extract_subtitles(
                    str(audio_file), 
                    language=language,
                    task=task,
                    output_dir=output_dir,
                    output_formats=output_formats
                )
                successful += 1
            except Exception as e:
                print(f"❌ 处理失败 {audio_file}: {e}")
                failed += 1
        
        print(f"\n🎉 批量处理完成!")
        print(f"✅ 成功: {successful} 个文件")
        print(f"❌ 失败: {failed} 个文件")
    
    def detect_language(self, audio_path):
        """
        检测音频语言
        
        Args:
            audio_path: 音频文件路径
            
        Returns:
            tuple: (语言代码, 置信度字典)
        """
        if not os.path.exists(audio_path):
            raise FileNotFoundError(f"音频文件不存在: {audio_path}")
        
        print(f"🔍 正在检测语言: {audio_path}")
        
        # 加载音频并调整到30秒
        audio = whisper.load_audio(audio_path)
        audio = whisper.pad_or_trim(audio)
        
        # 生成梅尔频谱图
        mel = whisper.log_mel_spectrogram(audio, n_mels=self.model.dims.n_mels).to(self.model.device)
        
        # 检测语言
        _, probs = self.model.detect_language(mel)
        detected_language = max(probs, key=probs.get)
        
        print(f"🎯 检测结果: {detected_language} (置信度: {probs[detected_language]:.2f})")
        
        # 显示前5种可能的语言
        sorted_probs = sorted(probs.items(), key=lambda x: x[1], reverse=True)[:5]
        print("📊 语言概率排序:")
        for lang, prob in sorted_probs:
            print(f"   {lang}: {prob:.3f}")
        
        return detected_language, probs

def main():
    parser = argparse.ArgumentParser(description="Whisper多语言字幕提取工具")
    parser.add_argument("input", help="输入音频文件或目录")
    parser.add_argument("--model", default="base", 
                       choices=["tiny", "base", "small", "medium", "large", "turbo"],
                       help="Whisper模型大小")
    parser.add_argument("--language", help="指定语言 (zh, en, ja, ko等)")
    parser.add_argument("--task", default="transcribe", 
                       choices=["transcribe", "translate"],
                       help="任务类型")
    parser.add_argument("--output-dir", default="output", help="输出目录")
    parser.add_argument("--formats", nargs="+", default=["srt"],
                       choices=["srt", "vtt", "txt", "json"],
                       help="输出格式")
    parser.add_argument("--batch", action="store_true", help="批量处理目录")
    parser.add_argument("--detect-only", action="store_true", help="仅检测语言")
    parser.add_argument("--device", default="cpu", help="设备 (cpu, cuda)")
    
    args = parser.parse_args()
    
    try:
        # 初始化提取器
        extractor = WhisperSubtitleExtractor(args.model, args.device)
        
        if args.detect_only:
            # 仅检测语言
            extractor.detect_language(args.input)
        elif args.batch:
            # 批量处理
            extractor.batch_process(
                args.input,
                language=args.language,
                task=args.task,
                output_dir=args.output_dir,
                output_formats=args.formats
            )
        else:
            # 单个文件处理
            extractor.extract_subtitles(
                args.input,
                language=args.language,
                task=args.task,
                output_dir=args.output_dir,
                output_formats=args.formats
            )
        
    except Exception as e:
        print(f"❌ 错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
# 多语言字幕提取实战指南

## 🎯 常见使用场景

### 1. 中文音视频字幕提取

```bash
# 中文普通话
whisper chinese_speech.mp3 --language Chinese --output_format srt

# 中文粤语
whisper cantonese_speech.mp3 --language Cantonese --output_format srt

# 自动检测中文方言
whisper chinese_mixed.mp3 --output_format srt
```

### 2. 日韩音视频处理

```bash
# 日语
whisper japanese_anime.mp4 --language Japanese --output_format srt
whisper japanese_podcast.mp3 --language ja --output_format vtt

# 韩语
whisper korean_drama.mp4 --language Korean --output_format srt
whisper kpop_song.mp3 --language ko --output_format txt
```

### 3. 欧洲语言

```bash
# 法语
whisper french_movie.mp4 --language French --output_format srt

# 德语
whisper german_lecture.mp3 --language German --output_format vtt

# 西班牙语
whisper spanish_news.mp4 --language Spanish --output_format srt

# 俄语
whisper russian_interview.mp3 --language Russian --output_format srt
```

### 4. 翻译功能

```bash
# 将中文翻译成英文字幕
whisper chinese_speech.mp3 --task translate --language Chinese --model medium

# 将日语翻译成英文字幕
whisper japanese_content.mp4 --task translate --language Japanese --model large

# 将任意语言翻译成英文
whisper foreign_audio.mp3 --task translate --model large
```

## 🔧 高级技巧

### 1. 提高准确率的方法

```bash
# 使用更大的模型
whisper audio.mp3 --model large

# 提供上下文提示
whisper tech_talk.mp3 --initial_prompt "这是一个关于人工智能和机器学习的技术讲座"

# 指定温度参数（0.0-1.0，0为最确定性）
whisper audio.mp3 --temperature 0.2
```

### 2. 时间戳和字幕格式优化

```bash
# 精确的单词级时间戳
whisper audio.mp3 --word_timestamps True --output_format srt

# 高亮显示当前说话的词（VTT格式）
whisper audio.mp3 --word_timestamps True --highlight_words True --output_format vtt

# 控制字幕行宽和行数
whisper audio.mp3 --word_timestamps True --max_line_width 42 --max_line_count 2 --output_format srt
```

### 3. 批量处理不同语言

```bash
# 自动检测语言并批量处理
./batch_subtitle.sh auto medium srt

# 指定中文批量处理
./batch_subtitle.sh Chinese large srt

# 多格式输出
./batch_subtitle.sh Japanese medium all
```

## 📁 输出格式说明

### SRT 格式 (.srt)
```
1
00:00:00,000 --> 00:00:03,000
这是第一段字幕内容

2
00:00:03,000 --> 00:00:06,000
这是第二段字幕内容
```

### VTT 格式 (.vtt)
```
WEBVTT

00:00:00.000 --> 00:00:03.000
这是第一段字幕内容

00:00:03.000 --> 00:00:06.000
这是第二段字幕内容
```

### JSON 格式 (.json)
```json
{
  "text": "完整的转录文本",
  "segments": [
    {
      "id": 0,
      "seek": 0,
      "start": 0.0,
      "end": 3.0,
      "text": "这是第一段内容",
      "tokens": [...],
      "temperature": 0.0,
      "avg_logprob": -0.45,
      "compression_ratio": 1.2,
      "no_speech_prob": 0.01
    }
  ],
  "language": "zh"
}
```

## 🚀 性能优化建议

### 模型选择策略

| 用途 | 推荐模型 | 理由 |
|------|----------|------|
| 快速预览 | tiny, base | 速度最快，适合大量文件预处理 |
| 日常使用 | small, medium | 速度和准确度的平衡 |
| 专业制作 | large | 最高准确度，适合重要内容 |
| 英文专用 | *.en 系列 | 英文准确度更高 |

### 硬件配置建议

- **CPU**: 多核处理器，推荐8核以上
- **内存**: 最少8GB，推荐16GB以上
- **存储**: SSD固态硬盘，提高I/O性能
- **GPU**: 支持CUDA的显卡可显著提升速度

### 容器化部署优势

1. **环境隔离**: 避免依赖冲突
2. **易于部署**: 一键部署到任何支持容器的环境
3. **资源控制**: 可限制CPU和内存使用
4. **批量处理**: 适合服务器端大规模处理

## 🔍 故障排除

### 常见问题及解决方案

1. **模型下载失败或SHA256校验错误**
   ```bash
   # 清除损坏的模型文件
   rm -f ~/.cache/whisper/*.pt
   
   # 重新运行命令，模型会自动重新下载
   whisper audio.mp3 --model tiny --output_format srt
   
   # 或手动创建缓存目录
   mkdir -p ~/.cache/whisper
   ```

2. **音频格式不支持**
   ```bash
   # 使用 ffmpeg 转换格式
   ffmpeg -i input.format output.wav
   ```

3. **内存不足**
   ```bash
   # 使用较小的模型
   whisper audio.mp3 --model tiny
   
   # 或分段处理长音频
   whisper audio.mp3 --clip_timestamps 0,300,300,600
   ```

4. **准确度不理想**
   ```bash
   # 指定正确的语言
   whisper audio.mp3 --language Chinese
   
   # 使用更大的模型
   whisper audio.mp3 --model large
   
   # 提供上下文
   whisper audio.mp3 --initial_prompt "会议记录"
   ```
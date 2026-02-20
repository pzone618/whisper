# Whisper

[[Blog]](https://openai.com/blog/whisper)
[[Paper]](https://arxiv.org/abs/2212.04356)
[[Model card]](https://github.com/openai/whisper/blob/main/model-card.md)
[[Colab example]](https://colab.research.google.com/github/openai/whisper/blob/master/notebooks/LibriSpeech.ipynb)

Whisper is a general-purpose speech recognition model. It is trained on a large dataset of diverse audio and is also a multitasking model that can perform multilingual speech recognition, speech translation, and language identification.

## 🚀 快速开始 (新 Mac 一键部署)

### 一键部署
```bash
curl -sSL https://raw.githubusercontent.com/pzone618/whisper/feature/mac/quick_deploy.sh | bash
```

### 分步部署
```bash
git clone https://github.com/pzone618/whisper.git
cd whisper && git checkout feature/mac
./scripts/setup_new_mac.sh
source venv/bin/activate
```

📚 **完整部署指南**: [QUICK_DEPLOY_GUIDE.md](./QUICK_DEPLOY_GUIDE.md)


## Approach

![Approach](https://raw.githubusercontent.com/openai/whisper/main/approach.png)

A Transformer sequence-to-sequence model is trained on various speech processing tasks, including multilingual speech recognition, speech translation, spoken language identification, and voice activity detection. These tasks are jointly represented as a sequence of tokens to be predicted by the decoder, allowing a single model to replace many stages of a traditional speech-processing pipeline. The multitask training format uses a set of special tokens that serve as task specifiers or classification targets.


## Setup

We used Python 3.9.9 and [PyTorch](https://pytorch.org/) 1.10.1 to train and test our models, but the codebase is expected to be compatible with Python 3.8-3.11 and recent PyTorch versions. The codebase also depends on a few Python packages, most notably [OpenAI's tiktoken](https://github.com/openai/tiktoken) for their fast tokenizer implementation. You can download and install (or update to) the latest release of Whisper with the following command:

    pip install -U openai-whisper

Alternatively, the following command will pull and install the latest commit from this repository, along with its Python dependencies:

    pip install git+https://github.com/openai/whisper.git

To update the package to the latest version of this repository, please run:

    pip install --upgrade --no-deps --force-reinstall git+https://github.com/openai/whisper.git

It also requires the command-line tool [`ffmpeg`](https://ffmpeg.org/) to be installed on your system, which is available from most package managers:

```bash
# on Ubuntu or Debian
sudo apt update && sudo apt install ffmpeg

# on Arch Linux
sudo pacman -S ffmpeg

# on MacOS using Homebrew (https://brew.sh/)
brew install ffmpeg

# on Windows using Chocolatey (https://chocolatey.org/)
choco install ffmpeg

# on Windows using Scoop (https://scoop.sh/)
scoop install ffmpeg
```

You may need [`rust`](http://rust-lang.org) installed as well, in case [tiktoken](https://github.com/openai/tiktoken) does not provide a pre-built wheel for your platform. If you see installation errors during the `pip install` command above, please follow the [Getting started page](https://www.rust-lang.org/learn/get-started) to install Rust development environment. Additionally, you may need to configure the `PATH` environment variable, e.g. `export PATH="$HOME/.cargo/bin:$PATH"`. If the installation fails with `No module named 'setuptools_rust'`, you need to install `setuptools_rust`, e.g. by running:

```bash
pip install setuptools-rust
```


## Available models and languages

There are six model sizes, four with English-only versions, offering speed and accuracy tradeoffs.
Below are the names of the available models and their approximate memory requirements and inference speed relative to the large model.
The relative speeds below are measured by transcribing English speech on a A100, and the real-world speed may vary significantly depending on many factors including the language, the speaking speed, and the available hardware.

|  Size  | Parameters | English-only model | Multilingual model | Required VRAM | Relative speed |
|:------:|:----------:|:------------------:|:------------------:|:-------------:|:--------------:|
|  tiny  |    39 M    |     `tiny.en`      |       `tiny`       |     ~1 GB     |      ~10x      |
|  base  |    74 M    |     `base.en`      |       `base`       |     ~1 GB     |      ~7x       |
| small  |   244 M    |     `small.en`     |      `small`       |     ~2 GB     |      ~4x       |
| medium |   769 M    |    `medium.en`     |      `medium`      |     ~5 GB     |      ~2x       |
| large  |   1550 M   |        N/A         |      `large`       |    ~10 GB     |       1x       |
| turbo  |   809 M    |        N/A         |      `turbo`       |     ~6 GB     |      ~8x       |

The `.en` models for English-only applications tend to perform better, especially for the `tiny.en` and `base.en` models. We observed that the difference becomes less significant for the `small.en` and `medium.en` models.
Additionally, the `turbo` model is an optimized version of `large-v3` that offers faster transcription speed with a minimal degradation in accuracy.

Whisper's performance varies widely depending on the language. The figure below shows a performance breakdown of `large-v3` and `large-v2` models by language, using WERs (word error rates) or CER (character error rates, shown in *Italic*) evaluated on the Common Voice 15 and Fleurs datasets. Additional WER/CER metrics corresponding to the other models and datasets can be found in Appendix D.1, D.2, and D.4 of [the paper](https://arxiv.org/abs/2212.04356), as well as the BLEU (Bilingual Evaluation Understudy) scores for translation in Appendix D.3.

![WER breakdown by language](https://github.com/openai/whisper/assets/266841/f4619d66-1058-4005-8f67-a9d811b77c62)

## Command-line usage

The following command will transcribe speech in audio files, using the `turbo` model:

```bash
whisper audio.flac audio.mp3 audio.wav --model turbo
```

The default setting (which selects the `turbo` model) works well for transcribing English. However, **the `turbo` model is not trained for translation tasks**. If you need to **translate non-English speech into English**, use one of the **multilingual models** (`tiny`, `base`, `small`, `medium`, `large`) instead of `turbo`.

For example, to transcribe an audio file containing non-English speech, you can specify the language:

```bash
whisper japanese.wav --language Japanese
```

To **translate** speech into English, use:

```bash
whisper japanese.wav --model medium --language Japanese --task translate
```

> **Note:** The `turbo` model will return the original language even if `--task translate` is specified. Use `medium` or `large` for the best translation results.

Run the following to view all available options:

```bash
whisper --help
```

See [tokenizer.py](https://github.com/openai/whisper/blob/main/whisper/tokenizer.py) for the list of all available languages.


## Python usage

Transcription can also be performed within Python:

```python
import whisper

model = whisper.load_model("turbo")
result = model.transcribe("audio.mp3")
print(result["text"])
```

Internally, the `transcribe()` method reads the entire file and processes the audio with a sliding 30-second window, performing autoregressive sequence-to-sequence predictions on each window.

Below is an example usage of `whisper.detect_language()` and `whisper.decode()` which provide lower-level access to the model.

```python
import whisper

model = whisper.load_model("turbo")

# load audio and pad/trim it to fit 30 seconds
audio = whisper.load_audio("audio.mp3")
audio = whisper.pad_or_trim(audio)

# make log-Mel spectrogram and move to the same device as the model
mel = whisper.log_mel_spectrogram(audio, n_mels=model.dims.n_mels).to(model.device)

# detect the spoken language
_, probs = model.detect_language(mel)
print(f"Detected language: {max(probs, key=probs.get)}")

# decode the audio
options = whisper.DecodingOptions()
result = whisper.decode(model, mel, options)

# print the recognized text
print(result.text)
```

## More examples

Please use the [🙌 Show and tell](https://github.com/openai/whisper/discussions/categories/show-and-tell) category in Discussions for sharing more example usages of Whisper and third-party extensions such as web demos, integrations with other tools, ports for different platforms, etc.

---

## 🌟 Enhanced Features for Chinese Users

This repository has been enhanced with additional tools and documentation for easier deployment and multilingual subtitle extraction:

### 📚 Complete Documentation

- **[DOCUMENTATION_INDEX.md](./DOCUMENTATION_INDEX.md)** - 完整文档索引和使用指南
- **[MULTILINGUAL_SUBTITLES_GUIDE.md](./MULTILINGUAL_SUBTITLES_GUIDE.md)** - 多语言字幕提取详细指南
- **[CONTAINER_DEPLOYMENT.md](./CONTAINER_DEPLOYMENT.md)** - 容器化部署完整文档

### 🚀 Quick Start Tools

#### 1. Container Deployment (Recommended)
```bash
# Build and deploy with Podman
./deploy.sh build
./deploy.sh transcribe your_audio.mp3 medium

# Interactive container
./deploy.sh run
```

#### 2. Batch Processing
```bash
# Batch subtitle extraction
./batch_subtitle.sh Chinese large srt

# Python batch processing
python subtitle_extractor.py ./audio_files/ --batch --model medium
```

#### 3. Advanced Python Interface
```bash
# Single file with multiple formats
python subtitle_extractor.py audio.mp3 --language Chinese --formats srt vtt json

# Language detection only
python subtitle_extractor.py audio.mp3 --detect-only
```

### 🎯 Key Features

- **99 Languages Supported** - Including Chinese (Mandarin/Cantonese), Japanese, Korean, and more
- **Multiple Output Formats** - SRT, VTT, TXT, JSON with customizable formatting
- **Container Deployment** - Production-ready Podman/Docker containers
- **Batch Processing** - Automated tools for processing multiple files
- **Chinese Documentation** - Complete guides in Chinese for easier adoption

### 📋 Supported Languages

Chinese (中文) | Japanese (日本語) | Korean (한국어) | English | French | German | Spanish | Russian | Arabic | And 90+ more...

For the complete list and usage examples, see [MULTILINGUAL_SUBTITLES_GUIDE.md](./MULTILINGUAL_SUBTITLES_GUIDE.md).

---

## License

Whisper's code and model weights are released under the MIT License. See [LICENSE](https://github.com/openai/whisper/blob/main/LICENSE) for further details.

# Memo:
## 激活虚拟环境
source venv/bin/activate

## 使用tiny模型（快速）
whisper /Users/leonyu/Downloads/You_are_not_responsible.MP4 --model tiny --word_timestamps True --output_format srt

## 使用更准确的模型
whisper /Users/leonyu/Downloads/You_are_not_responsible.MP4 --model base --word_timestamps True --output_format srt

## 指定语言提高准确度
whisper '/Users/leonyu/dev/GitHub/leon-reboot-system/storage/sla/en/ielts/cambridge-ielts-19-academic-listening-1-audio-1.mp3' --language English --model large --word_timestamps True --output_format srt

python subtitle_extractor.py /Users/leonyu/dev/GitHub/listening_training/6ME/mp3o/ \
  --batch \
  --language English \
  --model large \
  --word-timestamps \
  --formats srt \
  --output-dir /Users/leonyu/dev/GitHub/listening_training/6ME/srt/

whisper '/Users/leonyu/leonyu/IELTS/Peppa_Pig/Season_03/Episode 5 - Hide and Seek.mp4' --language Cantonese --model large --word_timestamps True --output_format srt

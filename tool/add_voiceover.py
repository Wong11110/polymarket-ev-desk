from __future__ import annotations

import subprocess
from pathlib import Path

import imageio_ffmpeg


ROOT = Path(__file__).resolve().parents[1]
VIDEO = ROOT / "release" / "polymarket_ev_desk_intro.mp4"
AUDIO = ROOT / "release" / "polymarket_ev_desk_voiceover.wav"
OUT = ROOT / "release" / "polymarket_ev_desk_intro_voiceover.mp4"
SCRIPT = (
    "这是 Polymarket EV Desk，一个用 Vibe Coding 完成的 Flutter Web PWA。"
    "它面向预测市场研究，准实时同步 Polymarket 行情，每六十秒刷新价格，并在本地重算 EV Gap 和 Kelly 仓位。"
    "中文模式会本地化常见市场标题，同时保留英文原题，方便说明真实数据来源。"
    "项目只做分析，不保存私钥，不自动下单。"
    "目前已提供 GitHub 仓库、线上 Demo、Release 体验包和需求分析文档，展示从需求到上线的完整闭环。"
)


def make_voiceover() -> None:
    ps = f"""
Add-Type -AssemblyName System.Speech
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$synth.SelectVoice('Microsoft Huihui Desktop')
$synth.Rate = 2
$synth.Volume = 100
$synth.SetOutputToWaveFile('{AUDIO}')
$synth.Speak('{SCRIPT}')
$synth.Dispose()
"""
    subprocess.run(["powershell", "-NoProfile", "-Command", ps], check=True)


def mux() -> None:
    ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()
    subprocess.run(
        [
            ffmpeg,
            "-y",
            "-i",
            str(VIDEO),
            "-i",
            str(AUDIO),
            "-map",
            "0:v:0",
            "-map",
            "1:a:0",
            "-c:v",
            "copy",
            "-c:a",
            "aac",
            "-b:a",
            "128k",
            "-shortest",
            "-movflags",
            "+faststart",
            str(OUT),
        ],
        check=True,
    )


if __name__ == "__main__":
    make_voiceover()
    mux()
    print(OUT)

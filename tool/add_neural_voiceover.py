from __future__ import annotations

import asyncio
import subprocess
from pathlib import Path

import edge_tts
import imageio_ffmpeg


ROOT = Path(__file__).resolve().parents[1]
VIDEO = ROOT / "release" / "polymarket_ev_desk_intro.mp4"
AUDIO = ROOT / "release" / "polymarket_ev_desk_neural_voiceover.mp3"
OUT = ROOT / "release" / "polymarket_ev_desk_intro_neural_voiceover.mp4"

SCRIPT = """
这是 Polymarket EV Desk，一个用 Vibe Coding 完成的 Flutter Web PWA。
它面向预测市场研究，可以准实时同步 Polymarket 行情，每六十秒刷新价格，并在本地重算 EV Gap 和 Kelly 仓位。
中文模式会本地化常见市场标题，同时保留英文原题，方便说明真实数据来源。
项目只做分析，不保存私钥，也不自动下单。
目前已经提供 GitHub 仓库、线上 Demo、Release 体验包和需求分析文档，展示从需求拆解到上线演示的完整闭环。
""".strip()


async def make_voiceover() -> None:
    last_error: Exception | None = None
    for _ in range(3):
        try:
            if AUDIO.exists():
                AUDIO.unlink()
            communicate = edge_tts.Communicate(
                SCRIPT,
                voice="zh-CN-YunxiNeural",
                rate="+6%",
                volume="+0%",
            )
            await communicate.save(str(AUDIO))
            if AUDIO.stat().st_size > 1024:
                return
        except Exception as exc:  # noqa: BLE001 - command-line retry helper.
            last_error = exc
            await asyncio.sleep(2)
    if last_error is not None:
        raise last_error


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
    asyncio.run(make_voiceover())
    mux()
    print(OUT)

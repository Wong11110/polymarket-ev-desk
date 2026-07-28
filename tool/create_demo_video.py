from __future__ import annotations

import math
from pathlib import Path

import imageio.v2 as imageio
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "release" / "polymarket_ev_desk_intro.mp4"
FPS = 12
W, H = 720, 1280

FONT = Path("C:/Windows/Fonts/msyh.ttc")
BOLD = Path("C:/Windows/Fonts/msyhbd.ttc")


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(BOLD if bold else FONT), size)


F = {
    "hero": font(52, True),
    "h1": font(40, True),
    "h2": font(31, True),
    "body": font(25),
    "small": font(20),
    "mono": font(22),
}
_BG_CACHE: Image.Image | None = None


def ease(t: float) -> float:
    return 3 * t * t - 2 * t * t * t


def wrap_text(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.FreeTypeFont, width: int) -> list[str]:
    lines: list[str] = []
    current = ""
    for char in text:
        candidate = current + char
        if draw.textlength(candidate, font=fnt) <= width:
            current = candidate
        else:
            if current:
                lines.append(current)
            current = char
    if current:
        lines.append(current)
    return lines


def draw_text_block(
    draw: ImageDraw.ImageDraw,
    text: str,
    xy: tuple[int, int],
    fnt: ImageFont.FreeTypeFont,
    width: int,
    fill: str = "#EAF7F4",
    line_gap: int = 10,
) -> int:
    x, y = xy
    for line in wrap_text(draw, text, fnt, width):
        draw.text((x, y), line, font=fnt, fill=fill)
        y += fnt.size + line_gap
    return y


def background() -> Image.Image:
    global _BG_CACHE
    if _BG_CACHE is not None:
        return _BG_CACHE.copy()

    yy, xx = np.mgrid[0:H, 0:W]
    green = 10 + 18 * (yy / H) + 8 * np.sin((xx + yy) / 190)
    arr = np.zeros((H, W, 3), dtype=np.uint8)
    arr[:, :, 0] = 7
    arr[:, :, 1] = np.clip(green, 0, 255).astype(np.uint8)
    arr[:, :, 2] = 20
    img = Image.fromarray(arr, "RGB")
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.ellipse((-120, 130, 300, 560), fill=(0, 194, 168, 32))
    d.ellipse((450, 720, 910, 1210), fill=(82, 224, 255, 24))
    _BG_CACHE = Image.alpha_composite(img.convert("RGBA"), layer)
    return _BG_CACHE.copy()


def rounded_paste(base: Image.Image, src: Image.Image, box: tuple[int, int, int, int], radius: int = 28) -> None:
    x, y, w, h = box
    src = src.resize((w, h), Image.LANCZOS).convert("RGBA")
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, w, h), radius=radius, fill=255)
    shadow = Image.new("RGBA", (w + 38, h + 38), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle((19, 19, w + 19, h + 19), radius=radius, fill=(0, 0, 0, 125))
    shadow = shadow.filter(ImageFilter.GaussianBlur(14))
    base.alpha_composite(shadow, (x - 19, y - 19))
    base.paste(src, (x, y), mask)


def chip(draw: ImageDraw.ImageDraw, xy: tuple[int, int], text: str, color: str = "#78F0DB") -> None:
    x, y = xy
    pad_x, pad_y = 18, 10
    tw = int(draw.textlength(text, font=F["small"]))
    draw.rounded_rectangle((x, y, x + tw + pad_x * 2, y + F["small"].size + pad_y * 2), radius=18, fill="#163630", outline="#2C6B5F")
    draw.text((x + pad_x, y + pad_y - 1), text, font=F["small"], fill=color)


def frame_title(title: str, subtitle: str, t: float) -> Image.Image:
    img = background()
    d = ImageDraw.Draw(img)
    y = 160
    d.text((54, y), "Polymarket", font=F["h1"], fill="#EAF7F4")
    d.text((54, y + 54), "EV Desk", font=F["hero"], fill="#78F0DB")
    y += 150
    draw_text_block(d, title, (54, y), F["h2"], 610, fill="#FFFFFF")
    draw_text_block(d, subtitle, (54, y + 105), F["body"], 590, fill="#BFD0CC")
    chip(d, (54, 800), "Flutter Web / PWA")
    chip(d, (54, 865), "Vibe Coding MVP")
    chip(d, (54, 930), "Analysis only")
    d.rounded_rectangle((54, 1068, 666, 1146), radius=18, fill="#0E211F", outline="#1D5149")
    d.text((82, 1092), "Demo: https://ev.aldacareer.online", font=F["mono"], fill="#D8FFF7")
    return img


def frame_problem(t: float) -> Image.Image:
    img = background()
    d = ImageDraw.Draw(img)
    d.text((54, 120), "需求问题", font=F["h1"], fill="#78F0DB")
    items = [
        ("市场价格", "Polymarket 价格可以看作隐含概率"),
        ("研究判断", "用户需要输入或估计 fair probability"),
        ("EV Gap", "fair probability - implied probability"),
        ("风险约束", "Kelly 仓位必须被最大仓位和日亏损限制截断"),
    ]
    y = 230
    for label, body in items:
        d.rounded_rectangle((54, y, 666, y + 130), radius=20, fill="#101B1F", outline="#263A3C")
        d.text((82, y + 26), label, font=F["h2"], fill="#FFFFFF")
        d.text((82, y + 74), body, font=F["small"], fill="#BFD0CC")
        y += 154
    return img


def frame_screenshot(src: Image.Image, title: str, subtitle: str, t: float, mobile: bool = True) -> Image.Image:
    img = background()
    d = ImageDraw.Draw(img)
    d.text((46, 72), title, font=F["h1"], fill="#FFFFFF")
    draw_text_block(d, subtitle, (46, 128), F["small"], 620, fill="#BFD0CC")
    if mobile:
        scale = 1.0 + 0.035 * ease(t)
        box_w, box_h = int(510 * scale), int(918 * scale)
        x = (W - box_w) // 2
        y = 300 - int(26 * ease(t))
        rounded_paste(img, src, (x, y, box_w, box_h), radius=28)
    else:
        crop_w = int(src.width * (0.82 - 0.05 * ease(t)))
        crop_h = int(src.height * (0.86 - 0.04 * ease(t)))
        crop = src.crop((0, 0, crop_w, crop_h))
        rounded_paste(img, crop, (38, 365, 644, 453), radius=22)
        y = 880
        for label in ["Top Opportunities", "EV Gap", "Fractional Kelly", "Risk limits"]:
            chip(d, (54, y), label)
            y += 58
    return img


def frame_localization(t: float) -> Image.Image:
    img = background()
    d = ImageDraw.Draw(img)
    d.text((54, 108), "中文演示优化", font=F["h1"], fill="#78F0DB")
    draw_text_block(
        d,
        "设置页支持 English / 中文切换。中文模式会本地化常见市场标题，同时保留 Polymarket 英文原题，方便说明数据来源。",
        (54, 180),
        F["body"],
        606,
        fill="#D9E8E4",
    )
    d.rounded_rectangle((54, 420, 666, 610), radius=20, fill="#101B1F", outline="#263A3C")
    d.text((82, 454), "美联储会在下一次 FOMC 会议降息吗？", font=F["h2"], fill="#FFFFFF")
    d.text((82, 520), "原题：Will the Fed cut rates at the next FOMC meeting?", font=F["small"], fill="#8FA19D")
    d.rounded_rectangle((54, 665, 666, 855), radius=20, fill="#101B1F", outline="#263A3C")
    d.text((82, 699), "BTC 会在年底前收于 10 万美元上方吗？", font=F["h2"], fill="#FFFFFF")
    d.text((82, 765), "原题：Will BTC close above $100k before year end?", font=F["small"], fill="#8FA19D")
    chip(d, (54, 970), "面试展示更自然")
    chip(d, (54, 1035), "保留真实市场语义")
    return img


def frame_delivery(t: float) -> Image.Image:
    img = background()
    d = ImageDraw.Draw(img)
    d.text((54, 104), "交付材料", font=F["h1"], fill="#78F0DB")
    rows = [
        ("GitHub 开源仓库", "github.com/Wong11110/polymarket-ev-desk"),
        ("线上 Demo", "ev.aldacareer.online"),
        ("Release 体验包", "v0.1.0 / Web-PWA zip"),
        ("需求分析 Demo", "docs/user-research.md"),
    ]
    y = 230
    for label, value in rows:
        d.rounded_rectangle((54, y, 666, y + 122), radius=18, fill="#101B1F", outline="#263A3C")
        d.text((82, y + 24), label, font=F["h2"], fill="#FFFFFF")
        d.text((82, y + 76), value, font=F["small"], fill="#9DF5E4")
        y += 146
    d.text((54, 1070), "MVP 边界：不保存私钥，不自动下单，不构成投资建议。", font=F["small"], fill="#BFD0CC")
    return img


def build_video() -> None:
    OUT.parent.mkdir(exist_ok=True)
    mobile = Image.open(ROOT / "docs" / "screenshots" / "mobile-dashboard.png").convert("RGB")
    desktop = Image.open(ROOT / "docs" / "screenshots" / "desktop-dashboard.png").convert("RGB")
    scenes = [
        (4.0, lambda t: frame_title("预测市场 EV 分析 PWA", "从产品想法、AI 辅助开发到线上部署的 MVP 闭环。", t)),
        (6.0, frame_problem),
        (7.5, lambda t: frame_screenshot(mobile, "手机端 Demo", "热门市场、Top Opportunities、EV Gap 与 Kelly 仓位建议。", t, True)),
        (7.0, lambda t: frame_screenshot(desktop, "分析仪表盘", "每 60 秒准实时拉取 Polymarket Gamma API，失败时 mock fallback。", t, False)),
        (6.5, frame_localization),
        (6.5, frame_delivery),
        (3.5, lambda t: frame_title("可继续完善", "真实聪明钱数据、AI 后端解释、历史价格图和操作视频会作为下一阶段迭代。", t)),
    ]

    writer = imageio.get_writer(
        OUT,
        fps=FPS,
        codec="libx264",
        quality=7,
        macro_block_size=16,
        ffmpeg_params=["-pix_fmt", "yuv420p", "-movflags", "+faststart"],
    )
    try:
        for duration, maker in scenes:
            total = int(duration * FPS)
            for idx in range(total):
                t = idx / max(1, total - 1)
                frame = maker(t).convert("RGB")
                writer.append_data(np.asarray(frame))
    finally:
        writer.close()


if __name__ == "__main__":
    build_video()
    print(OUT)

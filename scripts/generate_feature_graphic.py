#!/usr/bin/env python3
"""
Generate Google Play Feature Graphic (1024 x 500 px PNG):
- Exact Google Play specification (1024x500 RGB PNG)
- Brand taxi yellow (#FEC506 / #FFC800) with subtle automotive gradient & speed lines
- Left: Executive typography ("BPT 121 Taxi", "Theorieprüfung Schweiz 2026 • ARV 2", ASA 2026 badge, feature chips)
- Right: High-res master taxi artwork emblem with soft ambient shadow
- Margins: All text and critical motifs kept > 60px away from edges (50px safe boundary)
"""

import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

OUTPUT_PATH = "assets/store/feature_graphic.png"

def generate_feature_graphic():
    W, H = 1024, 500

    # 1. Base Canvas with Warm Taxi Gold Gradient
    canvas = Image.new("RGBA", (W, H), (254, 197, 6, 255))
    draw = ImageDraw.Draw(canvas)

    # Create subtle gradient
    top_color = (255, 214, 25)
    bottom_color = (248, 180, 0)
    for y in range(H):
        t = y / H
        r = int(top_color[0] * (1 - t) + bottom_color[0] * t)
        g = int(top_color[1] * (1 - t) + bottom_color[1] * t)
        b = int(top_color[2] * (1 - t) + bottom_color[2] * t)
        draw.line([(0, y), (W, y)], fill=(r, g, b, 255))

    # Subtle automotive diagonal speed lines in background (low opacity)
    accent_overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    acc_draw = ImageDraw.Draw(accent_overlay)
    for x in range(-100, W + 300, 45):
        acc_draw.line([(x, 0), (x - 120, H)], fill=(255, 255, 255, 12), width=8)
        acc_draw.line([(x + 15, 0), (x - 105, H)], fill=(0, 0, 0, 8), width=3)

    canvas = Image.alpha_composite(canvas, accent_overlay)

    # Load fonts
    try:
        font_badge = ImageFont.truetype("/System/Library/Fonts/HelveticaNeue.ttc", 13)
        font_title = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 60)
        font_sub = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 25)
        font_desc = ImageFont.truetype("/System/Library/Fonts/HelveticaNeue.ttc", 18)
        font_chip = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 13)
    except Exception:
        font_badge = font_title = font_sub = font_desc = font_chip = ImageFont.load_default()

    draw = ImageDraw.Draw(canvas)

    # Left column layout
    # Top pill badge: "STAND 2026 • OFFIZIELLER ASA-KATALOG"
    badge_x, badge_y = 65, 62
    badge_text = "STAND 2026 · OFFIZIELLER ASA-FRAGENKATALOG"
    bbox_text = draw.textbbox((0, 0), badge_text, font=font_badge)
    badge_w = (bbox_text[2] - bbox_text[0]) + 48
    badge_h = 32

    # Pill background
    draw.rounded_rectangle([badge_x, badge_y, badge_x + badge_w, badge_y + badge_h], radius=16, fill=(16, 22, 34, 255), outline=(255, 200, 0, 180), width=1)
    # Small red swiss flag dot/square in pill
    flag_sz = 14
    flag_x = badge_x + 12
    flag_y = badge_y + (badge_h - flag_sz) // 2
    draw.rounded_rectangle([flag_x, flag_y, flag_x + flag_sz, flag_y + flag_sz], radius=3, fill=(218, 41, 28, 255))
    # White cross in mini flag
    cw, cl = 2, 8
    cx, cy = flag_x + flag_sz // 2, flag_y + flag_sz // 2
    draw.rectangle([cx - cw//2, cy - cl//2, cx + cw//2, cy + cl//2], fill=(255, 255, 255))
    draw.rectangle([cx - cl//2, cy - cw//2, cx + cl//2, cy + cw//2], fill=(255, 255, 255))

    draw.text((flag_x + flag_sz + 10, badge_y + 8), badge_text, font=font_badge, fill=(255, 204, 0, 255))

    # Main Title: "BPT 121 Taxi"
    draw.text((65, 114), "BPT 121 Taxi", font=font_title, fill=(12, 19, 31, 255))

    # Subtitle: "Theorieprüfung Schweiz 2026"
    draw.text((65, 194), "Theorieprüfung Schweiz 2026", font=font_sub, fill=(20, 28, 44, 255))

    # Subtitle line 2: "ARV 2 • Code 121 • Personentransport (BPT)"
    draw.text((65, 234), "ARV 2 • Code 121 • Personentransport (BPT)", font=font_desc, fill=(50, 60, 75, 255))

    # Feature Chips Row
    chips = [
        ("500 Prüfungsfragen", True),
        ("ARV 2 Richtlinien", False),
        ("100% Offline", False),
    ]

    chip_x = 65
    chip_y = 285
    for label, highlight in chips:
        t_bbox = draw.textbbox((0, 0), label, font=font_chip)
        tw = t_bbox[2] - t_bbox[0]
        cw = tw + 26
        ch = 34
        
        bg_col = (12, 19, 31, 255) if highlight else (255, 255, 255, 190)
        txt_col = (255, 204, 0, 255) if highlight else (16, 22, 34, 255)
        border_col = (255, 204, 0, 200) if highlight else (0, 0, 0, 25)
        
        draw.rounded_rectangle([chip_x, chip_y, chip_x + cw, chip_y + ch], radius=8, fill=bg_col, outline=border_col, width=1)
        draw.text((chip_x + 13, chip_y + 9), label, font=font_chip, fill=txt_col)
        chip_x += cw + 12

    # Trust Seal / Authority Note
    draw.text((65, 342), "Geprüft nach Vorgaben der Vereinigung der Strassenverkehrsämter (asa)", font=font_badge, fill=(70, 80, 95, 255))

    # Right side: High-Res Master Artwork Badge
    logo_src = Image.open("assets/icons/splash_logo.png").convert("RGBA")
    bbox = logo_src.getbbox()
    cropped_logo = logo_src.crop(bbox)

    # Target height for logo: ~370px
    logo_h = 370
    scale = logo_h / cropped_logo.height
    logo_w = int(cropped_logo.width * scale)
    resized_logo = cropped_logo.resize((logo_w, logo_h), Image.Resampling.LANCZOS)

    # Placement
    pos_x = 580 + (400 - logo_w) // 2
    pos_y = (H - logo_h) // 2 + 5

    # Soft drop shadow behind motif
    shadow_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    shadow_mask = Image.new("L", (logo_w, logo_h), 0)
    for y in range(logo_h):
        for x in range(logo_w):
            if resized_logo.getpixel((x, y))[3] > 20:
                shadow_mask.putpixel((x, y), 70)

    shadow_blurred = shadow_mask.filter(ImageFilter.GaussianBlur(16))
    shadow_layer.paste(Image.new("RGBA", (logo_w, logo_h), (12, 19, 31, 255)), (pos_x + 4, pos_y + 12), shadow_blurred)

    canvas = Image.alpha_composite(canvas, shadow_layer)
    canvas.paste(resized_logo, (pos_x, pos_y), resized_logo)

    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    canvas.convert("RGB").save(OUTPUT_PATH, "PNG")
    print(f"Generated Google Play Feature Graphic: {OUTPUT_PATH} (1024x500 PNG)")

if __name__ == "__main__":
    generate_feature_graphic()

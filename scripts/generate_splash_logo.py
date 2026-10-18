#!/usr/bin/env python3
"""
Generate HD Retina-quality assets/icons/splash_logo.png (1024x1024 RGBA):
- Clean soft alpha matting with smooth Hermite interpolation
- Color de-matting to completely eliminate yellow halos/fringing on edges
- Centers motif cleanly onto 1024x1024 canvas with 0 edge artifacts
- Calibrated to 512px motif width for perfect, unclipped fit inside Android 12+ circular splash mask
"""

import os
import math
from PIL import Image

SRC_PATH = "/Users/ryxen_12/.gemini/antigravity/brain/1762b73f-0992-47eb-873d-1d5e4e9a806d/.user_uploaded/media_1792350005799_7d20299e.jpg"
SPLASH_PATH = "assets/icons/splash_logo.png"

def generate_splash_logo():
    src = Image.open(SRC_PATH).convert("RGB")
    w, h = src.size
    bg = (254, 197, 6)

    matted = Image.new("RGBA", (w, h), (0, 0, 0, 0))

    min_x, max_x = 35, 989
    min_y, max_y = 60, 960

    for y in range(h):
        for x in range(w):
            if x < min_x or x > max_x or y < min_y or y > max_y:
                continue
            # Clear top corners outside 2026 and flag
            if (x < 55 and y < 68) or (x > 935 and y < 68):
                continue
            # Clear bottom corners outside rounded banner
            if (x < 75 and y > 945) or (x > 945 and y > 945):
                continue

            r, g, b = src.getpixel((x, y))
            d = math.sqrt((r - bg[0])**2 + (g - bg[1])**2 + (b - bg[2])**2)
            
            d_low = 35.0
            d_high = 95.0
            if d <= d_low:
                alpha = 0.0
            elif d >= d_high:
                alpha = 1.0
            else:
                t = (d - d_low) / (d_high - d_low)
                alpha = t * t * (3 - 2 * t)
                
            if alpha > 0.01:
                rf = max(0, min(255, int((r - (1.0 - alpha) * bg[0]) / alpha)))
                gf = max(0, min(255, int((g - (1.0 - alpha) * bg[1]) / alpha)))
                bf = max(0, min(255, int((b - (1.0 - alpha) * bg[2]) / alpha)))
                a_byte = int(alpha * 255)
                matted.putpixel((x, y), (rf, gf, bf, a_byte))

    bbox = matted.getbbox()
    cropped = matted.crop(bbox)

    # Scale motif cleanly to 512px wide so it fits Android 12 circle safely with 0 clipping
    target_w = 512
    scale = target_w / cropped.width
    target_h = int(cropped.height * scale)

    resized = cropped.resize((target_w, target_h), Image.Resampling.LANCZOS)

    splash = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    px = (1024 - target_w) // 2
    py = (1024 - target_h) // 2
    splash.paste(resized, (px, py), resized)

    os.makedirs("assets/icons", exist_ok=True)
    splash.save(SPLASH_PATH, "PNG")
    print(f"Generated HD splash logo successfully: {SPLASH_PATH} ({splash.size}) Motif: {target_w}x{target_h}")

if __name__ == "__main__":
    generate_splash_logo()

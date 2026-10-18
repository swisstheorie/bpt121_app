#!/usr/bin/env python3
"""
Process the Official Master App Icon directly from the uploaded artwork:
1. Save uploaded image directly as assets/icons/app_icon.png (1024x1024 RGB) and assets/icon/app_icon.png
2. Generate adaptive icon foreground (assets/icons/app_icon_foreground.png) with scale ~0.55
   keeping the entire composition safely inside the Android circular mask zone so nothing is clipped.
"""

import os
from PIL import Image

SRC_PATH = "/Users/ryxen_12/.gemini/antigravity/brain/1762b73f-0992-47eb-873d-1d5e4e9a806d/.user_uploaded/media_1792350005799_7d20299e.jpg"
MASTER_PATH = "assets/icons/app_icon.png"
ICON_COPY_PATH = "assets/icon/app_icon.png"
FG_PATH = "assets/icons/app_icon_foreground.png"

def generate_icons():
    os.makedirs("assets/icons", exist_ok=True)
    os.makedirs("assets/icon", exist_ok=True)

    # 1. Process uploaded artwork: remove white outer corners
    img_rgba = Image.open(SRC_PATH).convert("RGBA")
    datas = img_rgba.getdata()
    new_data = []
    for item in datas:
        r, g, b, a = item
        # Make outer white corners transparent so they don't show
        if r > 245 and g > 245 and b > 245:
            new_data.append((0, 0, 0, 0))
        else:
            new_data.append(item)

    img_no_white = Image.new("RGBA", img_rgba.size)
    img_no_white.putdata(new_data)

    # 2. Scale motif to 0.72 (~737px) to fill canvas edge-to-edge
    scale = 0.72
    nw = int(1024 * scale)
    nh = int(1024 * scale)
    resized = img_no_white.resize((nw, nh), Image.Resampling.LANCZOS)

    fg = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    px = (1024 - nw) // 2
    py = (1024 - nh) // 2
    fg.paste(resized, (px, py), resized)
    fg.save(FG_PATH, "PNG")
    print(f"Saved adaptive icon foreground: {FG_PATH} (scale {scale}, ~{nw}px)")

    # 3. Master full-bleed icon: prominently scaled motif on solid Swiss Taxi Yellow (#FCC604)
    master = Image.new("RGB", (1024, 1024), (252, 198, 4))
    master.paste(fg, (0, 0), fg)
    master.save(MASTER_PATH, "PNG")
    master.save(ICON_COPY_PATH, "PNG")
    print(f"Saved prominent master artwork: {MASTER_PATH} and {ICON_COPY_PATH} (1024x1024 RGB)")

if __name__ == "__main__":
    generate_icons()

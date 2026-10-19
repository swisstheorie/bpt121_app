import subprocess
import os
import time
from http.server import HTTPServer, SimpleHTTPRequestHandler
import threading
from PIL import Image

class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory="build/web", **kwargs)

PORT = 8788
server = HTTPServer(('127.0.0.1', PORT), Handler)
t = threading.Thread(target=server.serve_forever)
t.daemon = True
t.start()
print(f"Web server started on http://127.0.0.1:{PORT}")

chrome_bin = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
output_dir = "assets/store/screenshots"
os.makedirs(output_dir, exist_ok=True)

targets = [
    {
        "name": "iphone_01_home_1320x2868.png",
        "url": f"http://127.0.0.1:{PORT}/?screen=home&device=iphone",
        "width": 1320,
        "height": 2868,
    },
    {
        "name": "ipad_01_home_2064x2752.png",
        "url": f"http://127.0.0.1:{PORT}/?screen=home&device=ipad",
        "width": 2064,
        "height": 2752,
    },
    {
        "name": "iphone_02_quiz_1320x2868.png",
        "url": f"http://127.0.0.1:{PORT}/?screen=quiz&device=iphone",
        "width": 1320,
        "height": 2868,
    },
    {
        "name": "ipad_02_quiz_2064x2752.png",
        "url": f"http://127.0.0.1:{PORT}/?screen=quiz&device=ipad",
        "width": 2064,
        "height": 2752,
    },
]

for target in targets:
    out_path = os.path.join(output_dir, target["name"])
    w = target["width"]
    h = target["height"]
    print(f"Capturing {target['name']} ({w}x{h})...")
    
    cmd = [
        chrome_bin,
        "--headless=new",
        "--disable-gpu",
        "--hide-scrollbars",
        f"--window-size={w},{h}",
        "--virtual-time-budget=6000",
        f"--screenshot={out_path}",
        target["url"]
    ]
    
    res = subprocess.run(cmd, capture_output=True, text=True)
    if os.path.exists(out_path):
        # Open and ensure exact resolution
        img = Image.open(out_path)
        print(f"  Captured: {img.size} ({os.path.getsize(out_path)} bytes)")
        if img.size != (w, h):
            print(f"  Resizing from {img.size} to exact {(w, h)}...")
            img = img.crop((0, 0, w, h)) if img.width >= w and img.height >= h else img.resize((w, h), Image.Resampling.LANCZOS)
            img.save(out_path, format="PNG")
            print(f"  Final verified size: {img.size}")
    else:
        print(f"  Error capturing {target['name']}")

server.shutdown()
print("All captures completed.")

import os
import sys
import subprocess
import shutil

try:
    from PIL import Image
except ImportError:
    print("Pillow not installed.")
    sys.exit(1)

def generate_icns(source_path, output_path):
    iconset_dir = "DevTools.iconset"
    if os.path.exists(iconset_dir):
        shutil.rmtree(iconset_dir)
    os.makedirs(iconset_dir)

    sizes = [
        (16, "icon_16x16.png"),
        (32, "icon_16x16@2x.png"),
        (32, "icon_32x32.png"),
        (64, "icon_32x32@2x.png"),
        (128, "icon_128x128.png"),
        (256, "icon_128x128@2x.png"),
        (256, "icon_256x256.png"),
        (512, "icon_256x256@2x.png"),
        (512, "icon_512x512.png"),
        (1024, "icon_512x512@2x.png")
    ]

    img = Image.open(source_path)
    
    print(f"Processing {source_path}...")

    for size, name in sizes:
        # High-quality resampling
        resized = img.resize((size, size), Image.Resampling.LANCZOS)
        
        # Save with optimization
        out_file = os.path.join(iconset_dir, name)
        # optimize=True enables PNG compression
        resized.save(out_file, "PNG", optimize=True)
        print(f"Saved {name} ({size}x{size})")

    print("Packing into .icns...")
    subprocess.run(["iconutil", "-c", "icns", iconset_dir, "-o", output_path], check=True)
    
    # Cleanup
    shutil.rmtree(iconset_dir)
    print(f"Done! Generated {output_path}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 generate_icns_optimized.py <source_png> <output_icns>")
        sys.exit(1)
        
    generate_icns(sys.argv[1], sys.argv[2])

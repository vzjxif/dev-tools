import os
from PIL import Image

def create_standard_icon(input_path, output_path):
    size = (1024, 1024)
    canvas = Image.new('RGBA', size, (255, 255, 255, 255))
    
    if os.path.exists(input_path):
        source = Image.open(input_path).convert('RGBA')
        
        bbox = source.getbbox()
        if bbox:
            source = source.crop(bbox)
            
        target_icon_size = (820, 820)
        source.thumbnail(target_icon_size, Image.Resampling.LANCZOS)
        
        x = (size[0] - source.width) // 2
        y = (size[1] - source.height) // 2
        
        canvas.paste(source, (x, y), source)
    else:
        print("Source image not found, generating text fallback...")
        from PIL import ImageDraw, ImageFont
        draw = ImageDraw.Draw(canvas)
        draw.ellipse([100, 100, 924, 924], fill=(0, 122, 255))
        
    canvas.save(output_path, "PNG")
    print(f"Created standard macOS icon at {output_path}")

if __name__ == "__main__":
    source = "Resources/dev-tools.png" 
    if not os.path.exists("Resources"):
        os.makedirs("Resources")
        
    files = os.listdir("Resources")
    pngs = [f for f in files if f.endswith(".png") and "AppIcon" not in f]
    
    if pngs:
        source = os.path.join("Resources", pngs[0])
        print(f"Using source: {source}")
    else:
        print("No source png found. Creating default.")
        
    create_standard_icon(source, "Resources/AppIcon_Prepared.png")

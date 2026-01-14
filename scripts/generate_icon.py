import sys
import os

try:
    from PIL import Image, ImageDraw, ImageFont, ImageFilter
except ImportError:
    print("PIL/Pillow not installed. Skipping icon generation. Use 'pip3 install Pillow' if needed.")
    sys.exit(0)

def create_icon(size=1024):
    # 1. Background Gradient (Dark Blue/Gray)
    img = Image.new('RGB', (size, size), color=(30, 30, 40))
    draw = ImageDraw.Draw(img)
    
    # 2. Add some gradient-like effect (Circles)
    draw.ellipse((-200, -200, size, size), fill=(40, 40, 60))
    draw.ellipse((size//2, size//2, size+300, size+300), fill=(20, 20, 30))
    
    # 3. Main Box (Rounded)
    padding = size // 5
    box_rect = [padding, padding, size - padding, size - padding]
    
    # Draw a rounded rectangle for the "Toolbox" look
    # Since simple PIL doesn't have easy rounded rect with gradient, we use a solid color
    draw.rounded_rectangle(box_rect, radius=size//10, fill=(60, 130, 246)) # iOS Blue style
    
    # 4. Add Text "DT"
    try:
        # Try to find a system font
        font_path = "/System/Library/Fonts/SFCompactDisplay-Bold.otf"
        if not os.path.exists(font_path):
             font_path = "/Library/Fonts/Arial.ttf"
        
        font = ImageFont.truetype(font_path, size=size//2)
        text = "DT"
        
        # Calculate text position to center it
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        x = (size - text_width) / 2
        y = (size - text_height) / 2 - (text_height * 0.1) # slight adjust up
        
        draw.text((x, y), text, fill=(255, 255, 255), font=font)
        
    except Exception as e:
        print(f"Could not draw text: {e}")
        # Fallback to simple rectangle
        pass

    return img

if __name__ == "__main__":
    if len(sys.argv) > 1:
        output_path = sys.argv[1]
    else:
        output_path = "icon_1024.png"
        
    img = create_icon()
    img.save(output_path)
    print(f"Icon generated at {output_path}")

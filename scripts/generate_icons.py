#!/usr/bin/env python3
"""
CleanLoop App Icon Generator
Generates app icons for iOS and Android
"""

from PIL import Image, ImageDraw
import os

# Output directory
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'icon')
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Colors
PRIMARY_GREEN = '#4CAF50'
DARK_GREEN = '#2E7D32'
WHITE = '#FFFFFF'
LIGHT_GREEN = '#81C784'

def hex_to_rgb(hex_color):
    """Convert hex color to RGB tuple"""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def draw_house(draw, x, y, size, color):
    """Draw a simple house icon"""
    # House body (rectangle)
    body_top = y + size * 0.35
    body_left = x + size * 0.2
    body_right = x + size * 0.8
    body_bottom = y + size * 0.85
    
    draw.rectangle(
        [body_left, body_top, body_right, body_bottom],
        fill=color
    )
    
    # Roof (triangle)
    roof_points = [
        (x + size * 0.5, y + size * 0.1),   # Top
        (x + size * 0.1, y + size * 0.4),   # Bottom left
        (x + size * 0.9, y + size * 0.4),   # Bottom right
    ]
    draw.polygon(roof_points, fill=color)
    
    # Door
    door_width = size * 0.15
    door_height = size * 0.25
    door_x = x + size * 0.5 - door_width / 2
    door_y = body_bottom - door_height
    
    draw.rectangle(
        [door_x, door_y, door_x + door_width, body_bottom],
        fill=hex_to_rgb(PRIMARY_GREEN)
    )
    
    # Window left
    window_size = size * 0.12
    window_margin = size * 0.08
    window_y = body_top + size * 0.1
    
    draw.rectangle(
        [body_left + window_margin, window_y, 
         body_left + window_margin + window_size, window_y + window_size],
        fill=hex_to_rgb(LIGHT_GREEN)
    )
    
    # Window right
    draw.rectangle(
        [body_right - window_margin - window_size, window_y,
         body_right - window_margin, window_y + window_size],
        fill=hex_to_rgb(LIGHT_GREEN)
    )

def create_app_icon(size, filename, with_padding=False):
    """Create app icon with specified size"""
    # Create image with gradient-like background
    img = Image.new('RGBA', (size, size), hex_to_rgb(PRIMARY_GREEN))
    draw = ImageDraw.Draw(img)
    
    # Add subtle gradient effect (lighter at top)
    for i in range(size // 3):
        alpha = int(255 * (1 - i / (size // 3)) * 0.3)
        draw.rectangle([0, i, size, i + 1], fill=(*hex_to_rgb(WHITE), alpha))
    
    # Draw house
    padding = size * 0.15 if with_padding else size * 0.1
    house_size = size - (padding * 2)
    draw_house(draw, padding, padding, house_size, hex_to_rgb(WHITE))
    
    # Save
    filepath = os.path.join(OUTPUT_DIR, filename)
    img.save(filepath, 'PNG')
    print(f"Created: {filepath} ({size}x{size})")

def create_splash_icon(size, filename):
    """Create splash screen icon (transparent background)"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw house with white color
    padding = size * 0.1
    house_size = size - (padding * 2)
    
    # House body
    body_top = padding + house_size * 0.35
    body_left = padding + house_size * 0.2
    body_right = padding + house_size * 0.8
    body_bottom = padding + house_size * 0.85
    
    draw.rectangle(
        [body_left, body_top, body_right, body_bottom],
        fill=hex_to_rgb(WHITE)
    )
    
    # Roof
    roof_points = [
        (padding + house_size * 0.5, padding + house_size * 0.1),
        (padding + house_size * 0.1, padding + house_size * 0.4),
        (padding + house_size * 0.9, padding + house_size * 0.4),
    ]
    draw.polygon(roof_points, fill=hex_to_rgb(WHITE))
    
    filepath = os.path.join(OUTPUT_DIR, filename)
    img.save(filepath, 'PNG')
    print(f"Created: {filepath} ({size}x{size})")

def create_adaptive_foreground(size, filename):
    """Create adaptive icon foreground for Android"""
    # Adaptive icons need extra padding (safe zone is 66% of total)
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # House in center with proper safe zone
    padding = size * 0.25  # More padding for adaptive icon
    house_size = size - (padding * 2)
    
    # House body
    body_top = padding + house_size * 0.35
    body_left = padding + house_size * 0.2
    body_right = padding + house_size * 0.8
    body_bottom = padding + house_size * 0.85
    
    draw.rectangle(
        [body_left, body_top, body_right, body_bottom],
        fill=hex_to_rgb(WHITE)
    )
    
    # Roof
    roof_points = [
        (padding + house_size * 0.5, padding + house_size * 0.1),
        (padding + house_size * 0.1, padding + house_size * 0.4),
        (padding + house_size * 0.9, padding + house_size * 0.4),
    ]
    draw.polygon(roof_points, fill=hex_to_rgb(WHITE))
    
    # Door (green)
    door_width = house_size * 0.15
    door_height = house_size * 0.25
    door_x = padding + house_size * 0.5 - door_width / 2
    door_y = body_bottom - door_height
    
    draw.rectangle(
        [door_x, door_y, door_x + door_width, body_bottom],
        fill=hex_to_rgb(PRIMARY_GREEN)
    )
    
    # Windows (light green)
    window_size = house_size * 0.12
    window_margin = house_size * 0.08
    window_y = body_top + house_size * 0.1
    
    draw.rectangle(
        [body_left + window_margin, window_y,
         body_left + window_margin + window_size, window_y + window_size],
        fill=hex_to_rgb(LIGHT_GREEN)
    )
    
    draw.rectangle(
        [body_right - window_margin - window_size, window_y,
         body_right - window_margin, window_y + window_size],
        fill=hex_to_rgb(LIGHT_GREEN)
    )
    
    filepath = os.path.join(OUTPUT_DIR, filename)
    img.save(filepath, 'PNG')
    print(f"Created: {filepath} ({size}x{size})")

if __name__ == '__main__':
    print("Generating CleanLoop app icons...")
    print("-" * 40)
    
    # Main app icon (1024x1024 for both iOS and Android)
    create_app_icon(1024, 'app_icon.png')
    
    # Adaptive icon foreground for Android (1024x1024)
    create_adaptive_foreground(1024, 'app_icon_foreground.png')
    
    # Splash screen icon (512x512, white on transparent)
    create_splash_icon(512, 'splash_icon.png')
    
    print("-" * 40)
    print("Done! Icons saved to assets/icon/")
    print("\nNext steps:")
    print("1. Run: flutter pub get")
    print("2. Run: dart run flutter_launcher_icons")
    print("3. Run: dart run flutter_native_splash:create")


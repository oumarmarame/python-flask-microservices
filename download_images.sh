#!/bin/bash

# Script pour télécharger les images de produits depuis Unsplash
# Images gratuites et de haute qualité

TARGET_DIR="frontend/application/static/images"

echo "📸 Téléchargement des images de produits..."
echo ""

# 1. Laptop
echo "1/10 Téléchargement: laptop.jpg"
curl -L "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400&h=400&fit=crop" \
  -o "$TARGET_DIR/laptop.jpg" 2>/dev/null

# 2. Smartphone
echo "2/10 Téléchargement: smartphone.jpg"
curl -L "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&h=400&fit=crop" \
  -o "$TARGET_DIR/smartphone.jpg" 2>/dev/null

# 3. Headphones
echo "3/10 Téléchargement: headphones.jpg"
curl -L "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=400&fit=crop" \
  -o "$TARGET_DIR/headphones.jpg" 2>/dev/null

# 4. Gaming Mouse
echo "4/10 Téléchargement: mouse.jpg"
curl -L "https://images.unsplash.com/photo-1527814050087-3793815479db?w=400&h=400&fit=crop" \
  -o "$TARGET_DIR/mouse.jpg" 2>/dev/null

# 5. Mechanical Keyboard
echo "5/10 Téléchargement: keyboard.jpg"
curl -L "https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=400&h=400&fit=crop" \
  -o "$TARGET_DIR/keyboard.jpg" 2>/dev/null

# 6. 4K Monitor
echo "6/10 Téléchargement: monitor.jpg"
curl -L "https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=400&h=400&fit=crop" \
  -o "$TARGET_DIR/monitor.jpg" 2>/dev/null

# 7. Webcam HD
echo "7/10 Téléchargement: webcam.jpg"
curl -L "https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?w=400&h=400&fit=crop" \
  -o "$TARGET_DIR/webcam.jpg" 2>/dev/null

# 8. USB-C Hub
echo "8/10 Téléchargement: hub.jpg"
curl -L "https://images.unsplash.com/photo-1625948515291-69613efd103f?w=400&h=400&fit=crop" \
  -o "$TARGET_DIR/hub.jpg" 2>/dev/null

# 9. Wireless Charger
echo "9/10 Téléchargement: charger.jpg"
curl -L "https://images.unsplash.com/photo-1591290619762-c588f8d8c30d?w=400&h=400&fit=crop" \
  -o "$TARGET_DIR/charger.jpg" 2>/dev/null

# 10. External SSD
echo "10/10 Téléchargement: ssd.jpg"
curl -L "https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=400&h=400&fit=crop" \
  -o "$TARGET_DIR/ssd.jpg" 2>/dev/null

echo ""
echo "✅ Téléchargement terminé!"
echo ""
echo "Images téléchargées dans: $TARGET_DIR/"
ls -lh "$TARGET_DIR"/*.jpg
echo ""
echo "🔄 Redémarrez les services pour voir les nouvelles images:"
echo "   docker compose restart product-service frontend"

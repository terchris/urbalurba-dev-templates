#!/bin/bash

# Check if cwebp is installed
if ! command -v cwebp &> /dev/null; then
    echo "Error: cwebp is not installed. Please install it first:"
    echo "  macOS: brew install webp"
    echo "  Ubuntu/Debian: sudo apt-get install webp"
    echo "  CentOS/RHEL: sudo yum install libwebp-tools"
    exit 1
fi

# Create optimized directory if it doesn't exist
mkdir -p public/images/optimized

# Optimize each image
for img in public/images/*.png; do
    if [ -f "$img" ]; then
        filename=$(basename "$img")
        name="${filename%.*}"
        
        # Convert to WebP with quality 80
        cwebp -q 80 "$img" -o "public/images/optimized/${name}.webp"
        
        echo "Optimized $filename -> ${name}.webp"
    fi
done

echo "Image optimization complete!" 
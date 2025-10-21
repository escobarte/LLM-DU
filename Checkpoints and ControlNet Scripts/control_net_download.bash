#!/bin/bash

# ===== CONFIGURATION =====
# Add your Civitai API token here
CIVITAI_TOKEN="067a04b7494716260a61a33776136985"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Auto-detect models directory
if [ -d "/workspace/stable-diffusion-webui-forge/models/ControlNet" ]; then
    MODELS_DIR="/workspace/stable-diffusion-webui-forge/models/ControlNet"
elif [ -d "/workspace/stable-diffusion-forge/models/Stable-diffusion" ]; then
    MODELS_DIR="/workspace/stable-diffusion-forge/models/Stable-diffusion"
elif [ -d "/workspace/models/Stable-diffusion" ]; then
    MODELS_DIR="/workspace/models/Stable-diffusion"
else
    echo -e "${RED}✗ Error: Cannot find Stable Diffusion models directory!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Found models directory: ${MODELS_DIR}${NC}"
echo ""

TEMP_DIR="/tmp/sd_downloads"
mkdir -p "$TEMP_DIR"

# Function to download and install model
download_model() {
    local name="$1"
    local url="$2"
    local extension="$3"
    local final_filename="${name}${extension}"
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Downloading: ${name}${NC}"
    echo -e "${YELLOW}Final filename: ${final_filename}${NC}"
    
    # Check if file already exists
    if [ -f "${MODELS_DIR}/${final_filename}" ]; then
        echo -e "${YELLOW}⚠ File already exists, skipping download${NC}"
        echo ""
        return
    fi
    
    # Add API token to URL if it's a Civitai link and token is set
    if [[ "$url" == *"civitai.com"* ]] && [ ! -z "$CIVITAI_TOKEN" ]; then
        if [[ "$url" == *"?"* ]]; then
            url="${url}&token=${CIVITAI_TOKEN}"
        else
            url="${url}?token=${CIVITAI_TOKEN}"
        fi
        echo -e "${GREEN}✓ Using Civitai authentication${NC}"
    fi
    
    # Download to temp directory
    wget -O "${TEMP_DIR}/${final_filename}" "$url" \
        --progress=bar:force \
        --content-disposition \
        2>&1
    
    if [ $? -eq 0 ] && [ -f "${TEMP_DIR}/${final_filename}" ]; then
        echo -e "${GREEN}✓ Download complete${NC}"
        
        # Move to models directory
        if mv "${TEMP_DIR}/${final_filename}" "${MODELS_DIR}/${final_filename}"; then
            echo -e "${GREEN}✓ Saved as: ${final_filename}${NC}"
            echo -e "${GREEN}✓ Location: ${MODELS_DIR}/${NC}"
            
            # Show file size
            local size=$(du -h "${MODELS_DIR}/${final_filename}" | cut -f1)
            echo -e "${GREEN}✓ File size: ${size}${NC}"
        else
            echo -e "${RED}✗ Failed to move file to models directory${NC}"
        fi
    else
        echo -e "${RED}✗ Download failed for ${name}${NC}"
    fi
    echo ""
}

# Start downloads
echo "Starting model downloads..."
echo "================================"

download_model "ControlNet 1.1 Models" \
    "https://civitai.com/api/download/models/44811?type=Model&format=SafeTensor&size=pruned&fp=fp16" \
    ".safetensors"
	
download_model "Instant ID SDXL" \
    "https://civitai.com/api/download/models/338882?type=Model&format=Other" \
    ".safetensors"
	
download_model "IP-Adapter" \
    "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter-plus_sd15.bin" \
    ".bin"
	
download_model "ControlNet_OpenPose_sdx1-1.0" \
    "https://huggingface.co/thibaud/controlnet-openpose-sdxl-1.0/resolve/main/OpenPoseXL2.safetensors" \
    ".safetensors"
	


# Clean up
rm -rf "$TEMP_DIR"

echo "================================"
echo -e "${GREEN}All downloads complete!${NC}"
echo ""
echo -e "${YELLOW}Downloaded models (most recent first):${NC}"
ls -lhS /workspace/stable-diffusion-webui-forge/models/ControlNet/ | head -10
echo ""
echo -e "${YELLOW}⚠ Don't forget to restart Stable Diffusion Forge!${NC}"
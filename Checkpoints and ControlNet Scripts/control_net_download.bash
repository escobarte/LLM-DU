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

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Downloading: ${name}${NC}"

    # Add API token to URL if it's a Civitai link and token is set
    if [[ "$url" == *"civitai.com"* ]] && [ ! -z "$CIVITAI_TOKEN" ]; then
        if [[ "$url" == *"?"* ]]; then
            url="${url}&token=${CIVITAI_TOKEN}"
        else
            url="${url}?token=${CIVITAI_TOKEN}"
        fi
        echo -e "${GREEN}✓ Using Civitai authentication${NC}"
    fi

    # Download to TEMP_DIR using content-disposition (lets server set filename)
    wget --content-disposition \
         --directory-prefix="$TEMP_DIR" \
         "$url" \
         --progress=bar:force

    # Get latest downloaded file
    downloaded_file=$(ls -t "$TEMP_DIR" | head -n1)
    downloaded_path="${TEMP_DIR}/${downloaded_file}"

    if [ -f "$downloaded_path" ]; then
        echo -e "${GREEN}✓ Download complete: $downloaded_file${NC}"

        # Check if already exists in destination
        if [ -f "${MODELS_DIR}/${downloaded_file}" ]; then
            echo -e "${YELLOW}⚠ File already exists in models dir, skipping move${NC}"
        else
            if mv "$downloaded_path" "${MODELS_DIR}/${downloaded_file}"; then
                echo -e "${GREEN}✓ Moved to: ${MODELS_DIR}/${downloaded_file}${NC}"
                local size=$(du -h "${MODELS_DIR}/${downloaded_file}" | cut -f1)
                echo -e "${GREEN}✓ File size: ${size}${NC}"
            else
                echo -e "${RED}✗ Failed to move file to models directory${NC}"
            fi
        fi
    else
        echo -e "${RED}✗ Download failed or file not found for ${name}${NC}"
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

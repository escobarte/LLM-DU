#!/bin/bash
# ======================================
# List Files in Stable Diffusion Folders
# ======================================

# Define folders
EMBEDDINGS="/workspace/stable-diffusion-webui-forge/embeddings"
ESRGAN="/workspace/stable-diffusion-webui-forge/models/ESRGAN"
LORA="/workspace/stable-diffusion-webui-forge/models/LORA"
WILDCARDS="/workspace/stable-diffusion-webui-forge/extensions/wildcards"
CHECKPOINTS="/workspace/stable-diffusion-webui-forge/models/Stable-diffusion"
CONTROLNET="/workspace/stable-diffusion-webui-forge/models/ControlNet"

# Function to list files in a directory
list_files() {
    local dir="$1"
    local name="$2"
    echo -e "\n===== $name ====="
    if [ -d "$dir" ]; then
        ls -lh "$dir"
    else
        echo "Directory not found: $dir"
    fi
}

# List all categories
list_files "$EMBEDDINGS" "Embeddings"
list_files "$ESRGAN" "ESRGAN"
list_files "$LORA" "LORA"
list_files "$WILDCARDS" "Wildcards"
list_files "$CHECKPOINTS" "Checkpoints"
list_files "$CONTROLNET" "ControlNet"

echo -e "\n✅ Done listing all specified folders."

#!/bin/bash
# ===============================
# Move model folders to SD Forge
# ===============================

# --- Variables ---
ESRGAN_SRC="/workspace/LLM-DU/ESRGAN"
ESRGAN_DST="/workspace/stable-diffusion-webui-forge/models/ESRGAN"

EMB_SRC="/workspace/LLM-DU/embeddings"
EMB_DST="/workspace/stable-diffusion-webui-forge/embeddings"

WLD_SRC="/workspace/LLM-DU/wildcards"
WLD_DST="/workspace/stable-diffusion-webui-forge/extensions/wildcards"

# --- Function to safely move folders ---
move_dir() {
    local src="$1"
    local dst="$2"

    if [ ! -d "$src" ]; then
        echo "❌ Source directory not found: $src"
        return 1
    fi

    mkdir -p "$(dirname "$dst")" || {
        echo "❌ Failed to create parent directory for: $dst"
        return 1
    }

    echo "➡️ Moving $src → $dst ..."
    mv "$src" "$dst" && echo "✅ Moved successfully." || echo "⚠️ Failed to move $src"
}

# --- Execute moves ---
move_dir "$ESRGAN_SRC" "$ESRGAN_DST"
move_dir "$EMB_SRC" "$EMB_DST"
move_dir "$WLD_SRC" "$WLD_DST"

echo "🎯 All operations completed."

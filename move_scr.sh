#!/bin/bash
# ===============================
# Copy contents of model folders to SD Forge
# ===============================

# --- Variables ---
ESRGAN_SRC="/workspace/LLM-DU/ESRGAN"
ESRGAN_DST="/workspace/stable-diffusion-webui-forge/models/ESRGAN"

EMB_SRC="/workspace/LLM-DU/embeddings"
EMB_DST="/workspace/stable-diffusion-webui-forge/embeddings"

WLD_SRC="/workspace/LLM-DU/wildcards"
WLD_DST="/workspace/stable-diffusion-webui-forge/extensions/wildcards"

# --- Function to safely copy contents of folders ---
copy_contents() {
    local src="$1"
    local dst="$2"

    if [ ! -d "$src" ]; then
        echo "❌ Source directory not found: $src"
        return 1
    fi

    mkdir -p "$dst" || {
        echo "❌ Failed to create destination directory: $dst"
        return 1
    }

    echo "➡️ Copying contents of $src → $dst ..."
    shopt -s dotglob nullglob  # Include hidden files and handle empty dirs
    cp -r "$src"/* "$dst"/ 2>/dev/null && echo "✅ Copied successfully." || echo "⚠️ No files to copy or copy failed."
    shopt -u dotglob nullglob
}

# --- Execute copies ---
copy_contents "$ESRGAN_SRC" "$ESRGAN_DST"
copy_contents "$EMB_SRC" "$EMB_DST"
copy_contents "$WLD_SRC" "$WLD_DST"

echo "🎯 All operations completed."

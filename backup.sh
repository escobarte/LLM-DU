#!/bin/bash
# Полное резервное копирование настроек Stable Diffusion

BACKUP_DIR="/workspace/SD_Complete_Backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "🔄 Создаю полный бэкап настроек..."

# Основные конфиги
echo "📋 Копирую основные настройки..."
cp /workspace/stable-diffusion-webui-forge/ui-config.json "$BACKUP_DIR/"
cp /workspace/stable-diffusion-webui-forge/config.json "$BACKUP_DIR/"
cp /workspace/stable-diffusion-webui-forge/styles.csv "$BACKUP_DIR/"
cp /workspace/stable-diffusion-webui-forge/extensions.txt "$BACKUP_DIR/" 2>/dev/null

# Настройки расширений
echo "🔌 Копирую настройки расширений..."
mkdir -p "$BACKUP_DIR/extensions"

# ControlNet
if [ -f "/workspace/stable-diffusion-webui-forge/extensions/sd-webui-controlnet/controlnet_settings.json" ]; then
    cp /workspace/stable-diffusion-webui-forge/extensions/sd-webui-controlnet/controlnet_settings.json "$BACKUP_DIR/extensions/"
fi

# ADetailer
if [ -d "/workspace/stable-diffusion-webui-forge/extensions/adetailer" ]; then
    cp -r /workspace/stable-diffusion-webui-forge/extensions/adetailer/*.json "$BACKUP_DIR/extensions/" 2>/dev/null
fi

# Civitai Helper
if [ -f "/workspace/stable-diffusion-webui-forge/extensions/sd-civitai-browser/config.json" ]; then
    cp /workspace/stable-diffusion-webui-forge/extensions/sd-civitai-browser/config.json "$BACKUP_DIR/extensions/civitai_config.json"
fi

# Список моделей (для справки)
echo "📦 Создаю список моделей..."
ls -la /workspace/stable-diffusion-webui-forge/models/Stable-diffusion/ > "$BACKUP_DIR/models_list.txt"
ls -la /workspace/stable-diffusion-webui-forge/models/Lora/ > "$BACKUP_DIR/lora_list.txt"
ls -la /workspace/stable-diffusion-webui-forge/models/VAE/ > "$BACKUP_DIR/vae_list.txt"

# Создаем архив
echo "📦 Создаю архив..."
cd /workspace
tar -czf "${BACKUP_DIR}.tar.gz" "$(basename $BACKUP_DIR)"

echo "✅ Бэкап завершен!"
echo "📁 Папка: $BACKUP_DIR"
echo "📦 Архив: ${BACKUP_DIR}.tar.gz"
echo ""
echo "Скачай файл: ${BACKUP_DIR}.tar.gz"

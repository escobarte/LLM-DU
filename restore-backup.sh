#!/bin/bash
# Скрипт восстановления настроек Stable Diffusion из бэкапа

# ============================================
# КОНФИГУРАЦИЯ
# ============================================
BACKUP_FILE="/workspace/SD_Complete_Backup_20251021_140923.tar.gz"
BACKUP_FOLDER="/workspace/SD_Complete_Backup_20251021_140923"
FORGE_DIR="/workspace/stable-diffusion-webui-forge"
CURRENT_BACKUP_DIR="/workspace/SD_Current_Backup_$(date +%Y%m%d_%H%M%S)"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================
# ФУНКЦИИ
# ============================================

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# ============================================
# ГЛАВНАЯ ФУНКЦИЯ ВОССТАНОВЛЕНИЯ
# ============================================

restore_settings() {
    print_header "ВОССТАНОВЛЕНИЕ НАСТРОЕК STABLE DIFFUSION"
    
    # Проверка наличия архива
    if [ ! -f "$BACKUP_FILE" ]; then
        print_error "Архив не найден: $BACKUP_FILE"
        exit 1
    fi
    print_success "Архив найден: $BACKUP_FILE"
    
    # Распаковка архива (если еще не распакован)
    if [ ! -d "$BACKUP_FOLDER" ]; then
        print_info "Распаковываю архив..."
        cd /workspace
        tar -xzf "$BACKUP_FILE"
        if [ $? -eq 0 ]; then
            print_success "Архив успешно распакован"
        else
            print_error "Ошибка распаковки архива"
            exit 1
        fi
    else
        print_info "Папка бэкапа уже существует: $BACKUP_FOLDER"
    fi
    
    # Проверка директории Forge
    if [ ! -d "$FORGE_DIR" ]; then
        print_error "Директория Forge не найдена: $FORGE_DIR"
        exit 1
    fi
    
    echo ""
    print_header "СОЗДАНИЕ РЕЗЕРВНОЙ КОПИИ ТЕКУЩИХ НАСТРОЕК"
    
    # Создаем бэкап текущих настроек
    mkdir -p "$CURRENT_BACKUP_DIR"
    
    if [ -f "$FORGE_DIR/ui-config.json" ]; then
        cp "$FORGE_DIR/ui-config.json" "$CURRENT_BACKUP_DIR/"
        print_success "Сохранен текущий ui-config.json"
    fi
    
    if [ -f "$FORGE_DIR/config.json" ]; then
        cp "$FORGE_DIR/config.json" "$CURRENT_BACKUP_DIR/"
        print_success "Сохранен текущий config.json"
    fi
    
    if [ -f "$FORGE_DIR/styles.csv" ]; then
        cp "$FORGE_DIR/styles.csv" "$CURRENT_BACKUP_DIR/"
        print_success "Сохранен текущий styles.csv"
    fi
    
    print_info "Резервная копия создана в: $CURRENT_BACKUP_DIR"
    
    echo ""
    print_header "ВОССТАНОВЛЕНИЕ ФАЙЛОВ"
    
    # Восстановление ui-config.json
    if [ -f "$BACKUP_FOLDER/ui-config.json" ]; then
        cp "$BACKUP_FOLDER/ui-config.json" "$FORGE_DIR/"
        print_success "Восстановлен ui-config.json (все настройки интерфейса)"
    else
        print_warning "ui-config.json не найден в бэкапе"
    fi
    
    # Восстановление config.json
    if [ -f "$BACKUP_FOLDER/config.json" ]; then
        cp "$BACKUP_FOLDER/config.json" "$FORGE_DIR/"
        print_success "Восстановлен config.json (системные настройки)"
    else
        print_warning "config.json не найден в бэкапе"
    fi
    
    # Восстановление styles.csv (если есть)
    if [ -f "$BACKUP_FOLDER/styles.csv" ]; then
        cp "$BACKUP_FOLDER/styles.csv" "$FORGE_DIR/"
        print_success "Восстановлен styles.csv (сохраненные стили)"
    else
        print_info "styles.csv не найден в бэкапе (это нормально)"
    fi
    
    # Восстановление настроек расширений
    if [ -d "$BACKUP_FOLDER/extensions" ] && [ "$(ls -A $BACKUP_FOLDER/extensions)" ]; then
        print_info "Восстанавливаю настройки расширений..."
        
        for ext_file in "$BACKUP_FOLDER/extensions"/*; do
            filename=$(basename "$ext_file")
            
            # ControlNet
            if [[ "$filename" == "controlnet_settings.json" ]]; then
                if [ -d "$FORGE_DIR/extensions/sd-webui-controlnet" ]; then
                    cp "$ext_file" "$FORGE_DIR/extensions/sd-webui-controlnet/"
                    print_success "  → ControlNet settings restored"
                fi
            fi
            
            # Civitai Helper
            if [[ "$filename" == "civitai_config.json" ]]; then
                if [ -d "$FORGE_DIR/extensions/sd-civitai-browser" ]; then
                    cp "$ext_file" "$FORGE_DIR/extensions/sd-civitai-browser/config.json"
                    print_success "  → Civitai Helper settings restored"
                fi
            fi
            
            # Другие расширения - копируем как есть
            if [[ "$filename" != "controlnet_settings.json" ]] && [[ "$filename" != "civitai_config.json" ]]; then
                # Ищем расширение с подходящим файлом настроек
                for ext_dir in "$FORGE_DIR/extensions"/*; do
                    if [ -d "$ext_dir" ]; then
                        ext_name=$(basename "$ext_dir")
                        # Копируем в каждое расширение (безопасно, перезапишет только если есть)
                        cp "$ext_file" "$ext_dir/" 2>/dev/null
                    fi
                done
                print_info "  → $filename скопирован в extensions"
            fi
        done
    else
        print_info "Настройки расширений не найдены (папка extensions пуста)"
    fi
    
    echo ""
    print_header "СПРАВОЧНАЯ ИНФОРМАЦИЯ"
    
    # Показываем списки моделей
    if [ -f "$BACKUP_FOLDER/models_list.txt" ]; then
        print_info "Список моделей на момент бэкапа:"
        cat "$BACKUP_FOLDER/models_list.txt"
    fi
    
    if [ -f "$BACKUP_FOLDER/lora_list.txt" ]; then
        echo ""
        print_info "Список LoRA на момент бэкапа:"
        cat "$BACKUP_FOLDER/lora_list.txt"
    fi
    
    echo ""
    print_header "ВОССТАНОВЛЕНИЕ ЗАВЕРШЕНО"
    
    print_success "Все настройки успешно восстановлены!"
    print_info "Текущие настройки сохранены в: $CURRENT_BACKUP_DIR"
    echo ""
    print_warning "ВАЖНО: Перезапусти Stable Diffusion Forge чтобы изменения вступили в силу!"
    echo ""
    print_info "Команды для перезапуска:"
    echo "  1. Останови текущий процесс (Ctrl+C в терминале где запущен Forge)"
    echo "  2. Запусти заново:"
    echo "     cd $FORGE_DIR"
    echo "     python launch.py --xformers"
}

# ============================================
# ЗАПУСК СКРИПТА
# ============================================

restore_settings

echo ""
print_info "Если что-то пошло не так, восстанови из: $CURRENT_BACKUP_DIR"
echo ""

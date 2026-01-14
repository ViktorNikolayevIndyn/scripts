# -*- coding: utf-8 -*-
"""
Утилита для замены эмодзи на ASCII-символы для совместимости с CMD
"""

import os
import re

# Карта замены эмодзи -> ASCII
EMOJI_MAP = {
    '📥': '[>>]',
    '📦': '[PKG]',
    '✅': '[OK]',
    '❌': '[X]',
    '⚠️': '[!]',
    '🔄': '[~]',
    '🕒': '[T]',
    '📁': '[DIR]',
    '⏭️': '[>>]',
    '🗑️': '[DEL]',
    '📊': '[STAT]',
    '📤': '[UP]',
    '💾': '[SAVE]',
    '🔒': '[LOCK]',
    '🎯': '[=>]',
    '📄': '[DOC]',
    '🚀': '[GO]',
    '⏳': '[...]',
}

def remove_emojis_from_file(file_path):
    """Заменяет эмодзи на ASCII в файле"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        for emoji, replacement in EMOJI_MAP.items():
            content = content.replace(emoji, replacement)
        
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"[OK] {file_path}")
            return True
        return False
    except Exception as e:
        print(f"[X] Fehler bei {file_path}: {e}")
        return False

def process_directory(directory):
    """Обрабатывает все .py файлы в директории"""
    count = 0
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.py'):
                file_path = os.path.join(root, file)
                if remove_emojis_from_file(file_path):
                    count += 1
    return count

if __name__ == "__main__":
    base_dir = os.path.dirname(os.path.abspath(__file__))
    modules_dir = os.path.join(base_dir, 'modules')
    
    print("Starte Emoji-Ersetzung...")
    print("=" * 50)
    
    # Verarbeite main.py
    main_py = os.path.join(base_dir, 'main.py')
    if os.path.exists(main_py):
        remove_emojis_from_file(main_py)
    
    # Verarbeite modules/
    count = process_directory(modules_dir)
    
    print("=" * 50)
    print(f"[OK] {count} Dateien aktualisiert!")

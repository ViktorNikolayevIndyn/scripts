#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Company Structure Generator
Автоматическая генерация структуры папок для управления документами компании

Author: Viktor Nikolayev
Company: InsideDynamic GmbH
Version: 1.0
Date: 2024-12-26
"""

import json
import os
import sys
from pathlib import Path
from typing import Dict, Any, List


class CompanyStructureGenerator:
    """Генератор структуры папок для компании из JSON конфигурации"""
    
    VERSION = "1.0"
    
    def __init__(self, config_path: str, base_path: str = "."):
        """
        Инициализация генератора
        
        Args:
            config_path: Путь к JSON файлу конфигурации
            base_path: Базовая директория для создания структуры
        """
        self.config_path = Path(config_path)
        self.base_path = Path(base_path).resolve()
        self.config: Dict[str, Any] = {}
        self.stats = {
            "folders_created": 0,
            "files_created": 0,
            "errors": 0
        }
        
    def load_config(self) -> bool:
        """
        Загрузка JSON конфигурации
        
        Returns:
            True если успешно, False иначе
        """
        try:
            with open(self.config_path, 'r', encoding='utf-8') as f:
                self.config = json.load(f)
            return True
        except FileNotFoundError:
            print(f"❌ Ошибка: Файл {self.config_path} не найден!")
            return False
        except json.JSONDecodeError as e:
            print(f"❌ Ошибка: Некорректный JSON в файле {self.config_path}")
            print(f"   {str(e)}")
            return False
        except Exception as e:
            print(f"❌ Ошибка при загрузке конфигурации: {str(e)}")
            return False
    
    def print_header(self):
        """Печать заголовка"""
        print("=" * 60)
        print("🏢 Company Structure Generator")
        print("=" * 60)
        print()
        
    def print_config_info(self):
        """Печать информации о конфигурации"""
        company_name = self.config.get('company_name', 'Unknown')
        version = self.config.get('version', '?')
        description = self.config.get('description', '')
        
        print(f"✅ Конфигурация загружена из {self.config_path.name}")
        print(f"   Компания: {company_name}")
        print(f"   Версия: {version}")
        if description:
            print(f"   Описание: {description}")
        print()
        
    def get_target_path(self) -> Path:
        """
        Получить целевой путь для создания структуры
        
        Returns:
            Path объект целевого пути
        """
        company_name = self.config.get('company_name', 'Company')
        return self.base_path / company_name
    
    def confirm_creation(self, target_path: Path) -> bool:
        """
        Запрос подтверждения создания структуры
        
        Args:
            target_path: Целевой путь
            
        Returns:
            True если пользователь подтвердил, False иначе
        """
        print(f"📁 Создаю структуру в: {target_path}")
        print()
        
        if target_path.exists():
            print("⚠️  ВНИМАНИЕ: Директория уже существует!")
            print("   Файлы могут быть перезаписаны.")
            print()
        
        response = input("Продолжить? (y/n): ").lower().strip()
        return response in ['y', 'yes', 'да', 'д']
    
    def create_folder(self, path: Path, description: str = ""):
        """
        Создание папки с README.md и .gitkeep
        
        Args:
            path: Путь к папке
            description: Описание папки для README
        """
        try:
            # Создаем папку
            path.mkdir(parents=True, exist_ok=True)
            self.stats["folders_created"] += 1
            print(f"📁 Создаю: {path.relative_to(self.get_target_path())}")
            
            # Создаем README.md
            readme_path = path / "README.md"
            if not readme_path.exists():
                folder_name = path.name
                readme_content = f"# {folder_name}\n\n"
                if description:
                    readme_content += f"{description}\n\n"
                readme_content += "---\n\n"
                readme_content += "*Создано с помощью Company Structure Generator*\n"
                
                with open(readme_path, 'w', encoding='utf-8') as f:
                    f.write(readme_content)
                self.stats["files_created"] += 1
            
            # Создаем .gitkeep
            gitkeep_path = path / ".gitkeep"
            if not gitkeep_path.exists():
                gitkeep_path.touch()
                self.stats["files_created"] += 1
                
        except Exception as e:
            print(f"❌ Ошибка при создании {path}: {str(e)}")
            self.stats["errors"] += 1
    
    def create_example_file(self, path: Path, filename: str):
        """
        Создание примера файла
        
        Args:
            path: Путь к папке
            filename: Имя файла
        """
        try:
            example_filename = f"_EXAMPLE_{filename}"
            file_path = path / example_filename
            
            if not file_path.exists():
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(f"# Пример файла: {filename}\n\n")
                    f.write("Это пример именования файла.\n")
                    f.write("Удалите этот файл и используйте аналогичное именование.\n")
                self.stats["files_created"] += 1
                
        except Exception as e:
            print(f"❌ Ошибка при создании примера {filename}: {str(e)}")
            self.stats["errors"] += 1
    
    def create_template_file(self, path: Path, filename: str):
        """
        Создание файла-шаблона
        
        Args:
            path: Путь к папке
            filename: Имя файла
        """
        try:
            template_filename = f"_TEMPLATE_{filename}"
            file_path = path / template_filename
            
            if not file_path.exists():
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(f"# Шаблон: {filename}\n\n")
                    f.write("Это шаблон файла.\n")
                    f.write("Скопируйте и адаптируйте под свои нужды.\n")
                self.stats["files_created"] += 1
                
        except Exception as e:
            print(f"❌ Ошибка при создании шаблона {filename}: {str(e)}")
            self.stats["errors"] += 1
    
    def process_folder_structure(self, structure: Dict[str, Any], parent_path: Path):
        """
        Рекурсивная обработка структуры папок
        
        Args:
            structure: Словарь со структурой
            parent_path: Родительский путь
        """
        for folder_name, folder_data in structure.items():
            folder_path = parent_path / folder_name
            
            # Получаем описание
            description = ""
            if isinstance(folder_data, dict):
                description = folder_data.get('description', '')
            
            # Создаем папку
            self.create_folder(folder_path, description)
            
            if isinstance(folder_data, dict):
                # Создаем подпапки
                if 'folders' in folder_data:
                    self.process_folder_structure(folder_data['folders'], folder_path)
                
                # Создаем примеры файлов
                if 'example_files' in folder_data:
                    for example_file in folder_data['example_files']:
                        self.create_example_file(folder_path, example_file)
                
                # Создаем шаблоны
                if 'root_files' in folder_data:
                    for template_file in folder_data['root_files']:
                        self.create_template_file(folder_path, template_file)
                
                # Добавляем example_structure в README если есть
                if 'example_structure' in folder_data:
                    readme_path = folder_path / "README.md"
                    if readme_path.exists():
                        with open(readme_path, 'a', encoding='utf-8') as f:
                            f.write("\n## Пример структуры:\n\n")
                            f.write("```\n")
                            f.write(folder_data['example_structure'])
                            f.write("\n```\n")
    
    def create_root_files(self, target_path: Path):
        """
        Создание файлов в корне структуры
        
        Args:
            target_path: Корневой путь
        """
        root_files = self.config.get('root_files', {})
        
        for filename, file_data in root_files.items():
            try:
                file_path = target_path / filename
                
                if not file_path.exists():
                    content = ""
                    if isinstance(file_data, dict) and 'content' in file_data:
                        content = file_data['content']
                    elif isinstance(file_data, str):
                        content = file_data
                    
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    
                    self.stats["files_created"] += 1
                    print(f"📄 Создаю файл: {filename}")
                    
            except Exception as e:
                print(f"❌ Ошибка при создании файла {filename}: {str(e)}")
                self.stats["errors"] += 1
    
    def print_stats(self):
        """Печать статистики"""
        print()
        print("=" * 60)
        print("📊 СТАТИСТИКА")
        print("=" * 60)
        print(f"✅ Папок создано: {self.stats['folders_created']}")
        print(f"✅ Файлов создано: {self.stats['files_created']}")
        print(f"❌ Ошибок: {self.stats['errors']}")
        print("=" * 60)
        print()
    
    def generate(self) -> bool:
        """
        Генерация структуры
        
        Returns:
            True если успешно, False иначе
        """
        self.print_header()
        
        # Загрузка конфигурации
        if not self.load_config():
            return False
        
        self.print_config_info()
        
        # Получение целевого пути
        target_path = self.get_target_path()
        
        # Подтверждение
        if not self.confirm_creation(target_path):
            print("❌ Отменено пользователем.")
            return False
        
        print()
        print("🚀 Начинаю создание структуры...")
        print()
        
        try:
            # Создаем корневую папку
            target_path.mkdir(parents=True, exist_ok=True)
            
            # Создаем файлы в корне
            self.create_root_files(target_path)
            
            # Создаем структуру папок
            structure = self.config.get('structure', {})
            self.process_folder_structure(structure, target_path)
            
            # Печать статистики
            self.print_stats()
            
            if self.stats["errors"] == 0:
                print("🎉 Структура успешно создана!")
                print(f"📁 Расположение: {target_path}")
                print()
                return True
            else:
                print("⚠️  Структура создана с ошибками.")
                print(f"📁 Расположение: {target_path}")
                print()
                return False
                
        except Exception as e:
            print(f"❌ Критическая ошибка: {str(e)}")
            return False


def print_usage():
    """Печать справки по использованию"""
    print("Company Structure Generator v" + CompanyStructureGenerator.VERSION)
    print()
    print("Использование:")
    print("  python create_structure.py [JSON_FILE] [OPTIONS]")
    print()
    print("Аргументы:")
    print("  JSON_FILE              Путь к JSON файлу конфигурации")
    print("                         (по умолчанию: structure.json)")
    print()
    print("Опции:")
    print("  --path, -p PATH        Базовая директория для создания")
    print("                         (по умолчанию: текущая директория)")
    print("  --version, -v          Показать версию")
    print("  --help, -h             Показать эту справку")
    print()
    print("Примеры:")
    print("  python create_structure.py")
    print("  python create_structure.py my_structure.json")
    print("  python create_structure.py --path ~/Documents/")
    print("  python create_structure.py my_structure.json --path ~/OneDrive/")
    print()


def main():
    """Главная функция"""
    # Параметры по умолчанию
    config_file = "structure.json"
    base_path = "."
    
    # Парсинг аргументов
    args = sys.argv[1:]
    i = 0
    
    while i < len(args):
        arg = args[i]
        
        if arg in ['-h', '--help']:
            print_usage()
            return 0
        elif arg in ['-v', '--version']:
            print(f"Company Structure Generator v{CompanyStructureGenerator.VERSION}")
            return 0
        elif arg in ['-p', '--path']:
            if i + 1 < len(args):
                base_path = args[i + 1]
                i += 2
            else:
                print("❌ Ошибка: --path требует аргумент")
                return 1
        elif not arg.startswith('-'):
            config_file = arg
            i += 1
        else:
            print(f"❌ Неизвестный аргумент: {arg}")
            print("Используйте --help для справки")
            return 1
    
    # Создание генератора и запуск
    generator = CompanyStructureGenerator(config_file, base_path)
    success = generator.generate()
    
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())

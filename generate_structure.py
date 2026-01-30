#!/usr/bin/env python3
"""
自动生成项目文件结构图
python3 generate_structure.py --output PROJECT_STRUCTURE.md --max-depth 3 --exclude-dirs build bin --exclude-files "*.mod" "*.o" "*.py"
Luo Guoyu, 2025-11-21
"""

import os
import argparse
from pathlib import Path

class ProjectStructure:
    def __init__(self, root_dir='.', exclude_dirs=None, exclude_files=None, max_depth=4):
        self.root_dir = Path(root_dir)
        self.exclude_dirs = set(exclude_dirs or [])
        self.exclude_files = set(exclude_files or [])
        self.max_depth = max_depth
        
        # 常见忽略模式
        self.default_exclude_dirs = {
            '.git', '.vscode', '.idea', '__pycache__', 'node_modules',
            'build', 'dist', 'bin', 'obj', '.pytest_cache'
        }
        self.default_exclude_files = {
            '.DS_Store', 'Thumbs.db', '*.pyc', '*.pyo', '*.so', '*.dll',
            '*.exe', '*.mod', '*.o', '*.a'
        }
        
        self.exclude_dirs.update(self.default_exclude_dirs)
        self.exclude_files.update(self.default_exclude_files)
    
    def should_exclude(self, path, is_dir=True):
        """检查是否应该排除该路径"""
        name = path.name
        
        if is_dir:
            return name in self.exclude_dirs or any(pattern in name for pattern in self.exclude_dirs)
        else:
            # 检查文件扩展名和完整文件名
            if name in self.exclude_files:
                return True
            for pattern in self.exclude_files:
                if pattern.startswith('*') and name.endswith(pattern[1:]):
                    return True
            return False
    
    def get_file_icon(self, filename):
        """根据文件类型返回图标"""
        icons = {
            '.f90': '📊', '.f95': '📊', '.f03': '📊', '.f08': '📊',
            '.py': '🐍', '.js': '📜', '.ts': '📘', '.java': '☕',
            '.cpp': '⚡', '.c': '🔧', '.h': '📄', '.hpp': '📄',
            '.md': '📖', '.txt': '📄', '.json': '📋', '.yaml': '⚙️', '.yml': '⚙️',
            '.xml': '📦', '.html': '🌐', '.css': '🎨',
            'Makefile': '🛠️', 'Dockerfile': '🐳',
            '.gitignore': '👁️', '.dockerignore': '🐳',
            'LICENSE': '📜', 'README': '📖'
        }
        
        # 检查完整文件名
        if filename in icons:
            return icons[filename]
        
        # 检查文件扩展名
        ext = Path(filename).suffix
        return icons.get(ext, '📄')
    
    def generate_structure(self, current_path=None, prefix="", depth=0, is_last=True):
        """生成文件结构"""
        if depth > self.max_depth:
            return ""
        
        if current_path is None:
            current_path = self.root_dir
        
        output = []
        current_name = current_path.name if current_path != self.root_dir else "."
        
        # 添加当前目录/文件
        if depth == 0:
            output.append("```\n")
            output.append(f"{current_name}/\n")
        else:
            connector = "└── " if is_last else "├── "
            if current_path.is_dir():
                icon = "📁"
                output.append(f"{prefix}{connector}{icon} {current_name}/\n")
            else:
                icon = self.get_file_icon(current_path.name)
                output.append(f"{prefix}{connector}{icon} {current_name}\n")
        
        # 如果是目录，递归处理子项
        if current_path.is_dir():
            try:
                items = sorted([item for item in current_path.iterdir() 
                              if not self.should_exclude(item, item.is_dir())])
                
                for index, item in enumerate(items):
                    is_last_item = (index == len(items) - 1)
                    new_prefix = prefix + ("    " if is_last else "│   ")
                    
                    if depth == 0:
                        new_prefix = ""
                    
                    output.append(self.generate_structure(
                        item, new_prefix, depth + 1, is_last_item
                    ))
            except PermissionError:
                pass
        
        if depth == 0:
            output.append("```\n")
        
        return "".join(output)
    
    def generate_markdown(self, title="项目文件结构"):
        """生成完整的Markdown格式"""
        structure = self.generate_structure()
        
        markdown = f"""# {title}

{structure}

## 目录说明

{self.generate_directory_descriptions()}

"""
        return markdown
    
    def generate_directory_descriptions(self):
        """生成目录说明"""
        descriptions = {
            'src': '源代码目录，包含所有核心模块和实现',
            'test': '测试目录，包含单元测试和性能测试',
            'apps': '应用示例目录，展示库的实际使用方式',
            'docs': '文档目录（如存在）',
            'examples': '使用示例目录（如存在）',
            'scripts': '脚本工具目录（如存在）'
        }
        
        output = []
        for dir_path in self.root_dir.iterdir():
            if dir_path.is_dir() and not self.should_exclude(dir_path, True):
                dir_name = dir_path.name
                description = descriptions.get(dir_name, '项目相关目录')
                output.append(f"- **{dir_name}/**: {description}")
        
        return "\n".join(output)

def main():
    parser = argparse.ArgumentParser(description='生成项目文件结构图')
    parser.add_argument('--root', default='.', help='项目根目录')
    parser.add_argument('--output', '-o', help='输出文件')
    parser.add_argument('--max-depth', type=int, default=4, help='最大深度')
    parser.add_argument('--exclude-dirs', nargs='+', help='排除的目录')
    parser.add_argument('--exclude-files', nargs='+', help='排除的文件')
    
    args = parser.parse_args()
    
    generator = ProjectStructure(
        root_dir=args.root,
        exclude_dirs=args.exclude_dirs,
        exclude_files=args.exclude_files,
        max_depth=args.max_depth
    )
    
    markdown = generator.generate_markdown()
    
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(markdown)
        print(f"文件结构已保存到: {args.output}")
    else:
        print(markdown)

if __name__ == "__main__":
    main()

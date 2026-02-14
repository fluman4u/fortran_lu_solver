# 环境配置指南

## 1. 系统要求

### 1.1 操作系统支持

| 操作系统    | 支持状态   | 备注                  |
| ------- | ------ | ------------------- |
| Linux   | ✅ 完全支持 | 推荐使用                |
| macOS   | ✅ 完全支持 | 需安装Xcode命令行工具       |
| Windows | ✅ 支持   | 需使用MSYS2、WSL或Cygwin |

### 1.2 硬件要求

| 配置项  | 最低要求        | 推荐配置    |
| ---- | ----------- | ------- |
| CPU  | 任意x86_64处理器 | 多核处理器   |
| 内存   | 512 MB      | 2 GB 以上 |
| 磁盘空间 | 50 MB       | 100 MB  |

### 1.3 软件依赖

| 软件         | 版本要求                    | 用途       |
| ---------- | ----------------------- | -------- |
| Fortran编译器 | gfortran 7+ 或 ifort 19+ | 编译源代码    |
| make       | GNU Make 4.0+           | 构建管理     |
| Git        | 2.0+                    | 版本控制（可选） |

## 2. Fortran 编译器安装

### 2.1 Linux 系统

#### Ubuntu/Debian

```bash
# 安装 gfortran
sudo apt update
sudo apt install gfortran make

# 验证安装
gfortran --version
```

#### CentOS/RHEL/Fedora

```bash
# CentOS/RHEL
sudo yum install gcc-gfortran make

# Fedora
sudo dnf install gcc-gfortran make

# 验证安装
gfortran --version
```

#### Arch Linux

```bash
# 安装 gcc (包含 gfortran)
sudo pacman -S gcc make

# 验证安装
gfortran --version
```

### 2.2 macOS 系统

```bash
# 方法1: 使用 Homebrew
brew install gcc make

# 验证安装
gfortran --version

# 方法2: 安装 Xcode 命令行工具
xcode-select --install
# 注意: Xcode 自带的 clang 不包含 Fortran，需额外安装 gfortran
```

### 2.3 Windows 系统

#### 方法1: MSYS2 (推荐)

```powershell
# 1. 下载并安装 MSYS2: https://www.msys2.org/

# 2. 打开 MSYS2 终端，运行以下命令:
pacman -Syu
pacman -S mingw-w64-x86_64-gcc-fortran mingw-w64-x86_64-make

# 3. 添加到系统 PATH:
# C:\msys64\mingw64\bin

# 4. 验证安装 (在 PowerShell 或 CMD 中)
gfortran --version
```

#### 方法2: WSL (Windows Subsystem for Linux)

```powershell
# 1. 启用 WSL
wsl --install

# 2. 安装 Ubuntu 发行版
wsl --install -d Ubuntu

# 3. 在 WSL 中安装 gfortran
sudo apt update
sudo apt install gfortran make
```

#### 方法3: Intel oneAPI

```powershell
# 1. 下载 Intel oneAPI HPC Toolkit
#    https://www.intel.com/content/www/us/en/developer/tools/oneapi/hpc-toolkit.html

# 2. 安装后使用 Intel Fortran 编译器
ifort --version
```

## 3. 项目获取与构建

### 3.1 获取源代码

```bash
# 使用 Git 克隆 (推荐)
git clone https://gitee.com/fluman2024/fortran_lu_solver.git
cd fortran_lu_solver

# 或下载压缩包
# wget https://gitee.com/fluman2024/fortran_lu_solver/repository/archive/master.zip
# unzip master.zip
# cd fortran_lu_solver
```

### 3.2 项目构建

```bash
# 查看可用构建目标
make help    # 如果 Makefile 支持
# 或直接查看 Makefile

# 编译所有目标 (测试程序 + 应用程序)
make all

# 仅编译测试程序
make bin/test_basic bin/test_performance

# 仅编译应用程序
make bin/circuit_solver

# 清理构建产物
make clean
```

### 3.3 构建产物说明

```
构建后的目录结构:

fortran_lu_solver/
├── build/                    # 编译中间文件
│   ├── ludecomp_m.o
│   ├── matrix_utils.o
│   └── linear_solvers.o
├── bin/                      # 可执行文件
│   ├── test_basic           # 基础测试程序
│   ├── test_performance     # 性能测试程序
│   └── circuit_solver       # 电路分析应用
├── *.mod                     # 模块文件
│   ├── ludecomp_m.mod
│   ├── matrix_utils.mod
│   └── linear_solvers.mod
```

## 4. 运行测试

### 4.1 运行完整测试套件

```bash
# 运行所有测试
make test

# 输出示例:
# 运行基础测试...
# === 基础功能测试 ===
# 测试1: 简单4x4矩阵
# ...
# 运行性能测试...
# === 性能测试 (比较原始算法和选主元算法) ===
# ...
```

### 4.2 单独运行测试程序

```bash
# 运行基础功能测试
./bin/test_basic

# 运行性能测试
./bin/test_performance

# 运行电路分析应用
./bin/circuit_solver
```

### 4.3 测试结果解读

#### 基础测试 (test_basic)

```
预期输出:
=== 基础功能测试 ===
测试1: 简单4x4矩阵
系数矩阵:
    4.000000    1.000000    2.000000    1.000000
    1.000000    5.000000    3.000000    2.000000
    2.000000    3.000000    6.000000    1.000000
    1.000000    2.000000    1.000000    7.000000
...
求解成功!
残差: [很小的数值，如 1.0E-7]
```

#### 性能测试 (test_performance)

```
预期输出:
=== 性能测试 (比较原始算法和选主元算法) ===
矩阵大小, 原始时间(秒), 原始残差, 选主元时间(秒), 选主元残差
   50,   0.001234,   1.23E-10,   0.001456,   1.45E-10
  100,   0.005678,   2.34E-10,   0.006789,   2.56E-10
  ...
```

## 5. 开发环境配置

### 5.1 IDE/编辑器配置

#### Visual Studio Code

```json
// 推荐扩展
{
  "recommendations": [
    "fortran-lang.linter-gfortran",
    "fortran-lang.fortran-lang-server",
    "ms-vscode.makefile-tools"
  ]
}

// settings.json 配置
{
  "fortran.linter.compiler": "gfortran",
  "fortran.linter.compilerArgs": [
    "-Wall",
    "-Wextra",
    "-O2"
  ]
}
```

#### Vim/Neovim

```vim
" 安装 vim-fortran 插件
Plug 'vim-scripts/vim-fortran'

" 配置语法高亮
let fortran_free_source=1
let fortran_have_gfortran=1
```

#### JetBrains IDE (CLion/IntelliJ)

```
1. 安装 Fortran 插件
2. 配置 Toolchain:
   - Settings → Build → Toolchains
   - 添加 Fortran 编译器路径
3. 配置 Makefile 项目支持
```

### 5.2 调试配置

#### GDB 调试

```bash
# 编译时添加调试符号
make clean
FC=gfortran FFLAGS="-g -O0 -Wall" make all

# 使用 GDB 调试
gdb ./bin/test_basic

# GDB 常用命令
(gdb) break main
(gdb) run
(gdb) step
(gdb) print variable_name
(gdb) backtrace
```

#### 内存检查 (Valgrind)

```bash
# 安装 Valgrind (Linux)
sudo apt install valgrind

# 检查内存问题
valgrind --leak-check=full ./bin/test_basic

# 输出解读:
# ==12345== HEAP SUMMARY:
# ==12345==   in use at exit: 0 bytes in 0 blocks
# ==12345==   total heap usage: 1 allocs, 1 frees, 1,024 bytes allocated
# ==12345== All heap blocks were freed -- no leaks are possible
```

## 6. 编译选项说明

### 6.1 Makefile 变量

| 变量       | 默认值               | 说明          |
| -------- | ----------------- | ----------- |
| FC       | gfortran          | Fortran 编译器 |
| FFLAGS   | -O2 -Wall -Wextra | 编译选项        |
| SRCDIR   | src               | 源代码目录       |
| TESTDIR  | test              | 测试代码目录      |
| APPDIR   | apps              | 应用代码目录      |
| BUILDDIR | build             | 编译中间文件目录    |
| BINDIR   | bin               | 可执行文件目录     |

### 6.2 常用编译选项

```makefile
# 优化级别
-O0     # 无优化，用于调试
-O1     # 基本优化
-O2     # 推荐的生产级别优化
-O3     # 激进优化，可能影响数值精度

# 警告选项
-Wall       # 启用常见警告
-Wextra     # 启用额外警告
-Wpedantic  # 严格遵循标准
-Werror     # 将警告视为错误

# 调试选项
-g          # 生成调试信息
-fcheck=all # 运行时检查（数组越界等）
-fbacktrace # 错误时打印调用栈

# 其他选项
-std=f2008  # 指定 Fortran 标准版本
-ffpe-trap=invalid,zero,overflow  # 浮点异常捕获
```

### 6.3 自定义编译

```bash
# 使用不同的编译器
make FC=ifort FFLAGS="-O3 -ipo" all

# 调试版本
make FFLAGS="-g -O0 -Wall -Wextra -fcheck=all -fbacktrace" all

# 性能优化版本
make FFLAGS="-O3 -march=native -ffast-math" all
```

## 7. 常见安装问题

### 7.1 编译器未找到

```bash
# 问题: gfortran: command not found

# 解决方案:
# Linux (Debian/Ubuntu)
sudo apt install gfortran

# macOS
brew install gcc

# Windows (MSYS2)
pacman -S mingw-w64-x86_64-gcc-fortran
```

### 7.2 模块文件找不到

```bash
# 问题: Fatal Error: Can't open module file 'ludecomp_m.mod'

# 解决方案: 确保按正确顺序编译
make clean
make all
```

### 7.3 权限问题

```bash
# 问题: Permission denied

# 解决方案: 检查文件权限
chmod +x ./bin/test_basic
# 或重新编译
make clean && make all
```

### 7.4 Windows 路径问题

```powershell
# 问题: 路径分隔符问题

# 解决方案: 使用正斜杠或使用 MSYS2/Git Bash
cd /e/git_projects/fortran_lu_solver
make all
```

## 8. 环境验证清单

完成以下检查确认环境配置正确：

- [ ] Fortran 编译器已安装并可执行
  
  ```bash
  gfortran --version
  ```

- [ ] make 工具已安装
  
  ```bash
  make --version
  ```

- [ ] 项目可成功编译
  
  ```bash
  make clean && make all
  ```

- [ ] 测试程序可正常运行
  
  ```bash
  make test
  ```

- [ ] 应用程序可正常运行
  
  ```bash
  ./bin/circuit_solver
  ```

## 9. 下一步

环境配置完成后，您可以：

1. 阅读 [开发规范](04-development-guidelines.md) 了解代码规范
2. 查看 [API参考](05-api-reference.md) 学习接口使用
3. 运行示例程序了解项目功能

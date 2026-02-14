# 部署流程

## 1. 部署概述

本文档描述 Fortran LU Solver 项目的部署流程，包括编译构建、测试验证、打包发布等环节。

### 1.1 部署架构

```
┌─────────────────────────────────────────────────────────────┐
│                      部署流程图                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐  │
│  │ 源代码  │───►│  编译   │───►│  测试   │───►│  打包   │  │
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘  │
│                                                     │        │
│                                                     ▼        │
│                                              ┌─────────┐    │
│                                              │  发布   │    │
│                                              └─────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 部署环境

| 环境 | 用途 | 说明 |
|------|------|------|
| 开发环境 | 日常开发 | 本地机器 |
| 测试环境 | CI/CD测试 | 自动化流程 |
| 生产环境 | 最终部署 | 用户环境 |

## 2. 构建流程

### 2.1 标准构建

```bash
# 1. 获取源代码
git clone https://gitee.com/fluman2024/fortran_lu_solver.git
cd fortran_lu_solver

# 2. 清理旧构建
make clean

# 3. 编译所有目标
make all

# 4. 运行测试验证
make test
```

### 2.2 生产环境构建

```bash
# 使用优化选项构建
make FFLAGS="-O3 -march=native -Wall" all

# 运行完整测试
make test

# 验证可执行文件
./bin/test_basic
./bin/test_performance
./bin/circuit_solver
```

### 2.3 调试版本构建

```bash
# 构建调试版本
make FFLAGS="-g -O0 -Wall -Wextra -fcheck=all -fbacktrace" clean all

# 使用GDB调试
gdb ./bin/test_basic
```

## 3. 构建产物

### 3.1 目录结构

```
构建完成后的目录结构:

fortran_lu_solver/
├── build/                      # 编译中间文件
│   ├── ludecomp_m.o           # LU分解模块目标文件
│   ├── matrix_utils.o         # 矩阵工具模块目标文件
│   └── linear_solvers.o       # 线性求解器模块目标文件
│
├── bin/                        # 可执行文件
│   ├── test_basic             # 基础功能测试程序
│   ├── test_performance       # 性能测试程序
│   └── circuit_solver         # 电路分析应用
│
├── *.mod                       # Fortran模块文件
│   ├── ludecomp_m.mod
│   ├── matrix_utils.mod
│   └── linear_solvers.mod
│
└── src/                        # 源代码（不变）
    ├── ludecomp_m.f90
    ├── linear_solvers.f90
    └── matrix_utils.f90
```

### 3.2 文件说明

| 文件类型 | 扩展名 | 用途 |
|----------|--------|------|
| 目标文件 | .o | 编译后的二进制对象 |
| 模块文件 | .mod | Fortran模块接口信息 |
| 可执行文件 | 无扩展名 | 最终可运行程序 |

## 4. 测试验证

### 4.1 测试流程

```bash
# 运行完整测试套件
make test

# 或单独运行各测试
./bin/test_basic      # 基础功能测试
./bin/test_performance # 性能测试
```

### 4.2 测试验证清单

| 检查项 | 命令 | 预期结果 |
|--------|------|----------|
| 编译成功 | `make all` | 无错误警告 |
| 基础测试 | `./bin/test_basic` | 所有测试通过 |
| 性能测试 | `./bin/test_performance` | 正常输出性能数据 |
| 应用运行 | `./bin/circuit_solver` | 正确输出电路分析结果 |

### 4.3 验证脚本示例

```bash
#!/bin/bash
# validate_build.sh - 构建验证脚本

set -e

echo "=== 开始构建验证 ==="

# 编译
echo "1. 编译项目..."
make clean
make all

# 运行测试
echo "2. 运行基础测试..."
./bin/test_basic

echo "3. 运行性能测试..."
./bin/test_performance

echo "4. 运行应用示例..."
./bin/circuit_solver

echo "=== 构建验证完成 ==="
```

## 5. 打包发布

### 5.1 发布包结构

```
fortran-lu-solver-v1.0.0/
├── src/                        # 源代码
│   ├── ludecomp_m.f90
│   ├── linear_solvers.f90
│   └── matrix_utils.f90
├── apps/                       # 应用示例
│   └── circuit_solver.f90
├── test/                       # 测试代码
│   ├── test_basic.f90
│   └── test_performance.f90
├── docs/                       # 技术文档
│   ├── README.md
│   ├── 01-overview.md
│   ├── 02-architecture.md
│   ├── 03-environment-setup.md
│   ├── 04-development-guidelines.md
│   ├── 05-api-reference.md
│   ├── 06-deployment.md
│   ├── 07-faq.md
│   └── 08-changelog.md
├── Makefile                    # 构建脚本
├── README.md                   # 项目说明
├── LICENSE                     # 许可证
└── changelog.md                # 变更日志
```

### 5.2 打包命令

```bash
# 创建发布包
VERSION="v1.0.0"
PACKAGE_NAME="fortran-lu-solver-${VERSION}"

# 清理构建产物
make clean

# 创建压缩包
tar -czvf ${PACKAGE_NAME}.tar.gz \
    --exclude='.git' \
    --exclude='build' \
    --exclude='bin' \
    --exclude='*.mod' \
    --exclude='*.o' \
    --transform "s,^,${PACKAGE_NAME}/," \
    .

# 创建ZIP包 (Windows用户)
zip -r ${PACKAGE_NAME}.zip . \
    -x ".git/*" \
    -x "build/*" \
    -x "bin/*" \
    -x "*.mod" \
    -x "*.o"

# 验证包内容
tar -tzvf ${PACKAGE_NAME}.tar.gz
```

### 5.3 发布检查清单

- [ ] 更新版本号
- [ ] 更新 CHANGELOG.md
- [ ] 运行完整测试套件
- [ ] 清理构建产物
- [ ] 创建发布包
- [ ] 验证包内容完整
- [ ] 上传发布包

## 6. 集成部署

### 6.1 作为库集成

将本项目作为库集成到其他项目中：

#### 方法1: 源码集成

```bash
# 复制源文件到目标项目
cp -r fortran_lu_solver/src/* /your-project/lib/lu_solver/

# 在目标项目的Makefile中添加
LU_SRC = lib/lu_solver/ludecomp_m.f90 \
         lib/lu_solver/matrix_utils.f90 \
         lib/lu_solver/linear_solvers.f90

LU_OBJ = $(LU_SRC:.f90=.o)

your_program: $(LU_OBJ) your_source.o
    $(FC) $(FFLAGS) -o $@ $^
```

#### 方法2: 模块文件集成

```bash
# 编译生成模块文件
cd fortran_lu_solver
make all

# 复制模块文件和目标文件
mkdir -p /your-project/lib/lu_solver
cp *.mod build/*.o /your-project/lib/lu_solver/

# 在目标项目中使用
# your_source.f90:
#   use linear_solvers
#   use matrix_utils

# Makefile:
FFLAGS += -I/path/to/lu_solver
LDFLAGS += /path/to/lu_solver/*.o
```

### 6.2 C/C++ 项目集成

通过 ISO_C_BINDING 与 C/C++ 项目集成：

```fortran
! lu_c_interface.f90
module lu_c_interface
  use, intrinsic :: iso_c_binding
  use linear_solvers
  implicit none
  
contains
  
  subroutine c_solve_linear_system(n, a, b, x, ierr) bind(c)
    integer(c_int), intent(in), value :: n
    real(c_double), intent(inout) :: a(n,n)
    real(c_double), intent(in) :: b(n)
    real(c_double), intent(out) :: x(n)
    integer(c_int), intent(out) :: ierr
    
    call solve_linear_system_with_pivot(a, b, x, ierr)
  end subroutine c_solve_linear_system
  
end module lu_c_interface
```

```c
// lu_solver.h
#ifndef LU_SOLVER_H
#define LU_SOLVER_H

extern void c_solve_linear_system(int n, double* a, double* b, 
                                   double* x, int* ierr);

#endif
```

## 7. 持续集成 (CI)

### 7.1 GitHub Actions 配置

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  build:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
        compiler: [gfortran]
        
    steps:
    - uses: actions/checkout@v3
    
    - name: Install gfortran (Ubuntu)
      if: matrix.os == 'ubuntu-latest'
      run: sudo apt-get install -y gfortran
      
    - name: Install gfortran (macOS)
      if: matrix.os == 'macos-latest'
      run: brew install gcc
      
    - name: Build
      run: make all
      
    - name: Test
      run: make test
```

### 7.2 Gitee Go 配置

```yaml
# .gitee/pipelines/ci.yml
name: CI Pipeline

stages:
  - stage:
      name: Build
      jobs:
        - job:
            name: Compile
            steps:
              - step: shell@3
                  with:
                    script: |
                      make clean
                      make all
                      
  - stage:
      name: Test
      jobs:
        - job:
            name: RunTests
            steps:
              - step: shell@3
                  with:
                    script: |
                      make test
```

## 8. 版本发布流程

### 8.1 发布前准备

```bash
# 1. 确保在主分支
git checkout main
git pull origin main

# 2. 运行完整测试
make clean && make all && make test

# 3. 更新版本号和变更日志
# 编辑 changelog.md 添加新版本记录

# 4. 提交版本更新
git add .
git commit -m "chore: prepare release v1.1.0"
```

### 8.2 创建发布

```bash
# 1. 创建版本标签
git tag -a v1.1.0 -m "Release v1.1.0"

# 2. 推送标签
git push origin v1.1.0

# 3. 创建发布包
make clean
VERSION="v1.1.0"
tar -czvf fortran-lu-solver-${VERSION}.tar.gz \
    --exclude='.git' \
    --exclude='build' \
    --exclude='bin' \
    --exclude='*.mod' \
    --exclude='*.o' \
    .

# 4. 在代码托管平台创建Release并上传发布包
```

### 8.3 发布后操作

```bash
# 1. 推送主分支更新
git push origin main

# 2. 通知用户
# - 更新项目主页
# - 发布公告

# 3. 归档发布包
mkdir -p releases
mv fortran-lu-solver-*.tar.gz releases/
```

## 9. 回滚流程

### 9.1 版本回滚

```bash
# 回滚到上一个版本
git checkout v1.0.0

# 重新构建
make clean && make all && make test

# 如需恢复到最新版本
git checkout main
```

### 9.2 紧急修复

```bash
# 从稳定版本创建修复分支
git checkout -b hotfix/v1.0.1 v1.0.0

# 进行修复...

# 测试验证
make test

# 合并回主分支
git checkout main
git merge hotfix/v1.0.1

# 发布修复版本
git tag -a v1.0.1 -m "Hotfix release v1.0.1"
git push origin v1.0.1
```

## 10. 部署检查清单

### 10.1 发布前检查

- [ ] 所有测试通过
- [ ] 无编译警告
- [ ] 文档已更新
- [ ] 版本号已更新
- [ ] 变更日志已更新

### 10.2 发布后检查

- [ ] 发布包可正常下载
- [ ] 发布包内容完整
- [ ] 新用户可正常构建
- [ ] 示例程序可正常运行

### 10.3 监控与维护

- [ ] 监控Issue反馈
- [ ] 及时响应问题报告
- [ ] 定期更新依赖（如有）
- [ ] 维护文档更新

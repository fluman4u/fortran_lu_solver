# Fortran LU Solver 技术文档

欢迎访问 Fortran LU Solver 项目技术文档中心。本文档体系提供完整的项目说明、开发指南和API参考。

## 文档导航

| 文档                                   | 描述             | 适用读者     |
| ------------------------------------ | -------------- | -------- |
| [项目概述](01-overview.md)               | 项目简介、功能特性、快速开始 | 所有用户     |
| [架构设计](02-architecture.md)           | 系统架构、模块设计、数据流  | 开发者、架构师  |
| [环境配置](03-environment-setup.md)      | 开发环境搭建、编译安装    | 新用户、运维人员 |
| [开发规范](04-development-guidelines.md) | 代码规范、贡献指南      | 贡献者、开发者  |
| [API参考](05-api-reference.md)         | 详细接口文档、使用示例    | 开发者      |
| [部署流程](06-deployment.md)             | 构建发布、持续集成      | 运维人员     |
| [常见问题](07-faq.md)                    | 问题排查、解决方案      | 所有用户     |
| [版本历史](08-changelog.md)              | 版本更新记录         | 所有用户     |

## 快速开始

### 5分钟快速上手

```bash
# 1. 获取项目
git clone https://gitee.com/fluman2024/fortran_lu_solver.git
cd fortran_lu_solver

# 2. 编译
make all

# 3. 测试
make test
```

### 基本使用示例

```fortran
program demo
  use linear_solvers
  implicit none

  real :: A(3,3), b(3), x(3)
  integer :: ierr

  ! 定义系数矩阵
  A = reshape([2.0, 1.0, 1.0, &
               4.0, 3.0, 3.0, &
               8.0, 7.0, 9.0], [3,3])

  ! 定义右端向量
  b = [1.0, 2.0, 3.0]

  ! 求解线性方程组 Ax = b
  call solve_linear_system_with_pivot(A, b, x, ierr)

  if (ierr == 0) then
    print *, '解向量 x:', x
  else
    print *, '求解失败，错误代码:', ierr
  end if
end program demo
```

## 项目简介

**Fortran LU Solver** 是一个高性能、稳定的 Fortran 库，用于执行 LU 矩阵分解并求解线性方程组。

### 核心特性

- ✅ **高性能 LU 分解** - 针对稠密矩阵优化的分解算法
- ✅ **数值稳定** - 部分选主元策略处理病态矩阵
- ✅ **完整求解器** - 一站式求解 Ax = b
- ✅ **丰富工具** - 矩阵生成、范数计算、残差验证
- ✅ **模块化设计** - 清晰的代码结构，易于集成
- ✅ **全面测试** - 单元测试、性能测试、应用示例

### 技术规格

| 项目  | 规格                     |
| --- | ---------------------- |
| 语言  | Fortran 90/95          |
| 编译器 | gfortran 7+, ifort 19+ |
| 依赖  | 无外部依赖                  |
| 许可证 | MIT License            |

## 模块概览

```
┌─────────────────────────────────────────────────────────────┐
│                     linear_solvers                          │
│                   (线性求解器接口)                           │
├─────────────────────────────────────────────────────────────┤
│              ludecomp_m          │       matrix_utils       │
│             (LU分解核心)          │       (矩阵工具)         │
└─────────────────────────────────────────────────────────────┘
```

| 模块               | 功能        |
| ---------------- | --------- |
| `ludecomp_m`     | LU分解算法实现  |
| `linear_solvers` | 线性方程组求解接口 |
| `matrix_utils`   | 矩阵工具函数    |

## 常用API速查

```fortran
! 求解线性方程组 (推荐)
call solve_linear_system_with_pivot(A, b, x, ierr)

! 仅执行LU分解
call ludeco_with_pivot(A, pivot, ierr)

! 计算残差验证结果
residual = matrix_residual(A_orig, x, b)

! 生成测试矩阵
call generate_diagonal_dominant(A, n)
call generate_hilbert_matrix(H, n)
```

## 目录结构

```
fortran_lu_solver/
├── src/                    # 源代码
│   ├── ludecomp_m.f90      # LU分解模块
│   ├── linear_solvers.f90  # 线性求解器
│   └── matrix_utils.f90    # 矩阵工具
├── apps/                   # 应用示例
│   └── circuit_solver.f90  # 电路分析
├── test/                   # 测试代码
│   ├── test_basic.f90      # 基础测试
│   └── test_performance.f90# 性能测试
├── docs/                   # 技术文档
│   ├── README.md           # 文档索引
│   ├── 01-overview.md      # 项目概述
│   ├── 02-architecture.md  # 架构设计
│   ├── 03-environment-setup.md
│   ├── 04-development-guidelines.md
│   ├── 05-api-reference.md # API参考
│   ├── 06-deployment.md    # 部署流程
│   ├── 07-faq.md           # 常见问题
│   └── 08-changelog.md     # 版本历史
├── Makefile                # 构建脚本
├── README.md               # 项目说明
└── LICENSE                 # 许可证
```

## 获取帮助

- **问题反馈**: [Gitee Issues](https://gitee.com/fluman2024/fortran_lu_solver/issues)
- **项目主页**: [Gitee Repository](https://gitee.com/fluman2024/fortran_lu_solver)

## 许可证

本项目基于 MIT 许可证开源，详见 [LICENSE](../LICENSE) 文件。

# 架构设计

## 1. 系统架构概览

### 1.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                        应用层 (Applications)                      │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  circuit_solver.f90                      │   │
│  │                  (电路分析应用示例)                       │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       接口层 (Interface)                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │               linear_solvers.f90                         │   │
│  │        (线性求解器高级接口模块)                           │   │
│  │                                                          │   │
│  │  • solve_linear_system()                                │   │
│  │  • solve_linear_system_with_pivot()                     │   │
│  │  • lusolve() / lusolve_with_pivot()                     │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       核心层 (Core)                              │
│  ┌───────────────────────┐    ┌───────────────────────┐        │
│  │   ludecomp_m.f90      │    │   matrix_utils.f90    │        │
│  │   (LU分解核心模块)     │    │   (矩阵工具模块)       │        │
│  │                       │    │                       │        │
│  │  • ludeco()           │    │  • 矩阵生成函数        │        │
│  │  • ludeco_with_pivot()│    │  • 范数计算           │        │
│  │  • get_lu_components()│    │  • 残差计算           │        │
│  └───────────────────────┘    └───────────────────────┘        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       测试层 (Testing)                           │
│  ┌───────────────────────┐    ┌───────────────────────┐        │
│  │   test_basic.f90      │    │  test_performance.f90 │        │
│  │   (基础功能测试)       │    │  (性能基准测试)        │        │
│  └───────────────────────┘    └───────────────────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 架构层次说明

| 层次  | 模块                       | 职责                |
| --- | ------------------------ | ----------------- |
| 应用层 | apps/                    | 提供实际应用案例，展示库的使用方法 |
| 接口层 | linear_solvers           | 提供高级封装接口，简化用户调用   |
| 核心层 | ludecomp_m, matrix_utils | 实现核心算法和工具函数       |
| 测试层 | test/                    | 验证功能正确性和性能表现      |

## 2. 模块详细设计

### 2.1 LU分解模块 (ludecomp_m)

#### 2.1.1 模块职责

`ludecomp_m` 模块是项目的核心，负责实现 LU 分解算法。

#### 2.1.2 模块结构

```fortran
module ludecomp_m
  implicit none
  private
  public :: ludeco, get_lu_components, ludeco_with_pivot

contains
  ! 基本LU分解（无选主元）
  subroutine ludeco(a, ierr, pivot_threshold)

  ! 带部分选主元的LU分解
  subroutine ludeco_with_pivot(a, pivot, ierr, pivot_threshold)

  ! 提取L和U矩阵分量
  subroutine get_lu_components(a, L, U)
end module ludecomp_m
```

#### 2.1.3 算法流程

**基本LU分解算法 (ludeco)**

```
输入: 方阵 A (n×n)
输出: 原地存储的 LU 分解结果

1. 检查矩阵是否为方阵
2. 对 k = 1 到 n-1:
   a. 检查主元 a(k,k) 是否过小
   b. 对 i = k+1 到 n:
      - 计算 a(i,k) = a(i,k) / a(k,k)
      - 更新 a(i,k+1:n) = a(i,k+1:n) - a(i,k) * a(k,k+1:n)
3. 返回分解结果
```

**带选主元的LU分解算法 (ludeco_with_pivot)**

```
输入: 方阵 A (n×n)
输出: 原地存储的 LU 分解结果 + 置换向量 pivot

1. 初始化置换向量 pivot = [1, 2, ..., n]
2. 对 k = 1 到 n-1:
   a. 在第k列中找最大元素作为主元
   b. 若需要，交换行并更新置换向量
   c. 检查主元是否过小（奇异矩阵检测）
   d. 执行消元操作
3. 检查最后一个主元
4. 返回分解结果和置换向量
```

#### 2.1.4 数据结构

```
LU分解结果存储格式（原地存储）:

原始矩阵 A:                    分解后存储:
┌─────────────┐               ┌─────────────┐
│ a11 a12 a13 │               │ u11 u12 u13 │  ← U的上三角部分
│ a21 a22 a23 │    ────►      │ l21 u22 u23 │
│ a31 a32 a33 │               │ l31 l32 u33 │
└─────────────┘               └─────────────┘
                                   ↑
                              L的下三角部分（对角线隐含为1）
```

### 2.2 线性求解器模块 (linear_solvers)

#### 2.2.1 模块职责

`linear_solvers` 模块提供高级接口，封装完整的求解流程。

#### 2.2.2 模块结构

```fortran
module linear_solvers
  use ludecomp_m, only: ludeco, ludeco_with_pivot
  implicit none
  private
  public :: lusolve, solve_linear_system, condition_number_estimate, &
            lusolve_with_pivot, solve_linear_system_with_pivot

contains
  ! 基本LU求解（前向+后向替换）
  subroutine lusolve(a, b, x, ierr)

  ! 带选主元的求解
  subroutine lusolve_with_pivot(a, b, x, pivot, ierr)

  ! 完整求解接口（无选主元）
  subroutine solve_linear_system(A, b, x, ierr, pivot_threshold)

  ! 完整求解接口（带选主元）
  subroutine solve_linear_system_with_pivot(A, b, x, ierr, pivot_threshold)

  ! 条件数估计
  function condition_number_estimate(A) result(cond_est)
end module linear_solvers
```

#### 2.2.3 求解流程

```
solve_linear_system_with_pivot 调用流程:

┌──────────────────┐
│ 输入: A, b       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 复制矩阵 A_copy  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ ludeco_with_pivot│ ──► 分解 + 置换向量
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│lusolve_with_pivot│ ──► 前向+后向替换
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 输出: x, ierr    │
└──────────────────┘
```

### 2.3 矩阵工具模块 (matrix_utils)

#### 2.3.1 模块职责

`matrix_utils` 模块提供矩阵操作相关的辅助工具函数。

#### 2.3.2 模块结构

```fortran
module matrix_utils
  implicit none
  private
  public :: generate_hilbert_matrix, generate_diagonal_dominant, &
            generate_random_matrix, print_matrix, print_vector, &
            matrix_residual, is_symmetric, matrix_norm

contains
  ! 生成希尔伯特矩阵（病态矩阵）
  subroutine generate_hilbert_matrix(A, n)

  ! 生成对角占优矩阵
  subroutine generate_diagonal_dominant(A, n, dominance_factor)

  ! 生成随机矩阵
  subroutine generate_random_matrix(A, n, symmetric)

  ! 打印矩阵
  subroutine print_matrix(A, name)

  ! 打印向量
  subroutine print_vector(v, name)

  ! 计算相对残差
  function matrix_residual(A, x, b) result(residual)

  ! 检查矩阵对称性
  function is_symmetric(A, tolerance) result(symm)

  ! 计算矩阵范数
  function matrix_norm(A, norm_type) result(norm_val)
end module matrix_utils
```

#### 2.3.3 功能分类

| 类别   | 函数                         | 用途        |
| ---- | -------------------------- | --------- |
| 矩阵生成 | generate_hilbert_matrix    | 生成测试用病态矩阵 |
|      | generate_diagonal_dominant | 生成稳定可解矩阵  |
|      | generate_random_matrix     | 生成随机测试矩阵  |
| 输出工具 | print_matrix               | 格式化输出矩阵   |
|      | print_vector               | 格式化输出向量   |
| 验证工具 | matrix_residual            | 计算求解残差    |
|      | is_symmetric               | 检验矩阵对称性   |
|      | matrix_norm                | 计算矩阵范数    |

## 3. 数据流设计

### 3.1 主数据流

```
用户程序
    │
    │ use linear_solvers
    │ call solve_linear_system_with_pivot(A, b, x, ierr)
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│                    linear_solvers 模块                       │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 1. 创建矩阵副本 A_copy                               │   │
│  │ 2. 调用 ludeco_with_pivot(A_copy, pivot, ierr)      │   │
│  │ 3. 调用 lusolve_with_pivot(A_copy, b, x, pivot)     │   │
│  └─────────────────────────────────────────────────────┘   │
│                         │                                    │
│                         │ use ludecomp_m                     │
│                         ▼                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              ludecomp_m 模块                         │   │
│  │                                                      │   │
│  │  • 执行LU分解                                        │   │
│  │  • 记录行置换                                        │   │
│  │  • 返回错误状态                                      │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
    │
    │ 返回 x, ierr
    ▼
用户程序继续执行
```

### 3.2 错误处理流程

```
错误代码定义:
┌────────┬────────────────────────────────────────┐
│ 错误码 │ 含义                                   │
├────────┼────────────────────────────────────────┤
│   0    │ 成功完成                               │
│   1    │ 矩阵非方阵或维度不匹配                  │
│   2    │ 零主元或矩阵奇异                       │
│   3    │ 向量维度不匹配                         │
└────────┴────────────────────────────────────────┘

错误处理策略:
1. 可选错误参数 (optional ierr)
   - 若提供 ierr: 返回错误码，程序继续
   - 若未提供 ierr: 调用 error stop 终止

2. 错误传播
   - 底层模块错误向上传播到调用者
   - 高层接口统一处理错误状态
```

## 4. 依赖关系

### 4.1 模块依赖图

```
┌───────────────────┐
│  circuit_solver   │
│    (应用示例)      │
└─────────┬─────────┘
          │ use
          ▼
┌───────────────────┐     ┌───────────────────┐
│  linear_solvers   │────►│   matrix_utils    │
│   (求解器接口)     │     │   (矩阵工具)       │
└─────────┬─────────┘     └───────────────────┘
          │ use
          ▼
┌───────────────────┐
│    ludecomp_m     │
│   (LU分解核心)     │
└───────────────────┘
```

### 4.2 编译依赖顺序

```makefile
编译顺序（按依赖关系）:

1. ludecomp_m.f90    → ludecomp_m.o, ludecomp_m.mod
2. matrix_utils.f90  → matrix_utils.o, matrix_utils.mod
3. linear_solvers.f90→ linear_solvers.o, linear_solvers.mod
4. 应用/测试程序     → 可执行文件
```

## 5. 性能设计

### 5.1 时间复杂度

| 操作   | 复杂度   | 说明       |
| ---- | ----- | -------- |
| LU分解 | O(n³) | 标准稠密矩阵分解 |
| 前向替换 | O(n²) | 下三角求解    |
| 后向替换 | O(n²) | 上三角求解    |
| 完整求解 | O(n³) | 分解+求解    |

### 5.2 空间复杂度

| 存储   | 复杂度   | 说明         |
| ---- | ----- | ---------- |
| 矩阵存储 | O(n²) | 原地分解，无额外空间 |
| 置换向量 | O(n)  | 记录行交换信息    |
| 解向量  | O(n)  | 存储求解结果     |

### 5.3 内存布局

```
Fortran 列优先存储:

矩阵 A(3,3) 在内存中的布局:
┌────┬────┬────┬────┬────┬────┬────┬────┬────┐
│a11 │a21 │a31 │a12 │a22 │a32 │a13 │a23 │a33 │
└────┴────┴────┴────┴────┴────┴────┴────┴────┘
  │    │    │
  └────┴────┴─── 第1列连续存储

优势: 列访问具有缓存友好性
```

## 6. 扩展性设计

### 6.1 可扩展点

| 扩展方向 | 当前实现  | 扩展建议            |
| ---- | ----- | --------------- |
| 矩阵类型 | 实数单精度 | 支持双精度、复数        |
| 存储格式 | 稠密矩阵  | 支持稀疏矩阵格式        |
| 分解算法 | LU分解  | 支持Cholesky、QR分解 |
| 并行化  | 单线程   | OpenMP并行优化      |

### 6.2 接口稳定性

```
公共接口 (保证向后兼容):
├── ludecomp_m 模块
│   ├── ludeco()
│   ├── ludeco_with_pivot()
│   └── get_lu_components()
├── linear_solvers 模块
│   ├── solve_linear_system()
│   ├── solve_linear_system_with_pivot()
│   ├── lusolve()
│   └── lusolve_with_pivot()
└── matrix_utils 模块
    ├── generate_hilbert_matrix()
    ├── generate_diagonal_dominant()
    ├── generate_random_matrix()
    ├── print_matrix()
    ├── print_vector()
    ├── matrix_residual()
    ├── is_symmetric()
    └── matrix_norm()

内部实现 (可能变更):
├── 算法细节优化
├── 内部辅助函数
└── 数据结构微调
```

## 7. 安全性设计

### 7.1 输入验证

```fortran
验证项目:
├── 矩阵维度检查
│   └── 确保矩阵为方阵
├── 向量维度匹配
│   └── 确保 b, x 与 A 维度一致
├── 数值有效性
│   └── 检测 NaN, Inf
└── 主元阈值检查
    └── 检测奇异或近奇异矩阵
```

### 7.2 数值稳定性

```fortran
稳定性措施:
├── 部分选主元
│   └── 避免小主元导致的误差放大
├── 主元阈值
│   └── 可配置的奇异检测阈值 (默认 1e-12)
└── 残差验证
    └── 提供 matrix_residual() 验证求解质量
```

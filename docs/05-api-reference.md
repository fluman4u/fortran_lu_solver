# API 接口文档

## 1. 概述

本文档详细描述 Fortran LU Solver 库的所有公共 API 接口。项目包含三个主要模块：

| 模块 | 文件 | 功能描述 |
|------|------|----------|
| `ludecomp_m` | src/ludecomp_m.f90 | LU分解核心算法 |
| `linear_solvers` | src/linear_solvers.f90 | 线性方程组求解接口 |
| `matrix_utils` | src/matrix_utils.f90 | 矩阵工具函数 |

## 2. 快速参考

### 2.1 常用接口速查

```fortran
! 最常用: 求解线性方程组 Ax = b
use linear_solvers
call solve_linear_system_with_pivot(A, b, x, ierr)

! 仅执行LU分解
use ludecomp_m
call ludeco_with_pivot(A, pivot, ierr)

! 计算残差验证解的正确性
use matrix_utils
residual = matrix_residual(A, x, b)
```

### 2.2 错误代码

| 错误码 | 含义 | 触发条件 |
|--------|------|----------|
| 0 | 成功 | 操作正常完成 |
| 1 | 维度错误 | 矩阵非方阵或维度不匹配 |
| 2 | 数值错误 | 零主元或矩阵奇异 |
| 3 | 向量错误 | 向量维度不匹配 |

---

## 3. ludecomp_m 模块

LU分解核心模块，提供矩阵分解算法。

### 3.1 ludeco

执行基本LU分解（无选主元）。

#### 语法

```fortran
call ludeco(a [, ierr] [, pivot_threshold])
```

#### 参数

| 参数 | 类型 | 意图 | 必需 | 描述 |
|------|------|------|------|------|
| a | real(:,:) | inout | 是 | 待分解的方阵，分解后原地存储LU结果 |
| ierr | integer | out | 否 | 错误代码，0表示成功 |
| pivot_threshold | real | in | 否 | 主元阈值，默认1.0e-12 |

#### 返回值

无返回值。分解结果存储在 `a` 中：
- 上三角部分（含对角线）存储 U 矩阵
- 下三角部分（不含对角线）存储 L 矩阵
- L 的对角线元素隐含为 1

#### 错误代码

| 代码 | 描述 |
|------|------|
| 0 | 分解成功 |
| 1 | 矩阵非方阵 |
| 2 | 遇到零主元或主元小于阈值 |

#### 示例

```fortran
program example_ludeco
  use ludecomp_m
  implicit none
  
  real :: A(3,3)
  integer :: ierr
  
  A = reshape([4.0, 3.0, 2.0, &
               3.0, 5.0, 1.0, &
               2.0, 1.0, 6.0], [3,3])
  
  call ludeco(A, ierr)
  
  if (ierr == 0) then
    print *, "LU分解成功"
    ! A 现在包含 LU 分解结果
  else
    print *, "LU分解失败，错误代码:", ierr
  end if
end program example_ludeco
```

#### 注意事项

- 此函数不进行选主元，对病态矩阵可能不稳定
- 推荐使用 `ludeco_with_pivot` 获得更好的数值稳定性
- 若不提供 `ierr` 参数，错误时程序将终止

---

### 3.2 ludeco_with_pivot

执行带部分选主元的LU分解。

#### 语法

```fortran
call ludeco_with_pivot(a, pivot [, ierr] [, pivot_threshold])
```

#### 参数

| 参数 | 类型 | 意图 | 必需 | 描述 |
|------|------|------|------|------|
| a | real(:,:) | inout | 是 | 待分解的方阵，分解后存储LU结果 |
| pivot | integer(:) | out | 是 | 置换向量，记录行交换信息 |
| ierr | integer | out | 否 | 错误代码，0表示成功 |
| pivot_threshold | real | in | 否 | 主元阈值，默认1.0e-12 |

#### 返回值

无返回值。分解结果存储在 `a` 中，置换信息存储在 `pivot` 中。

#### 置换向量说明

`pivot` 向量记录了行交换的历史：
- `pivot(i)` 表示原始矩阵第 `pivot(i)` 行被交换到当前位置 i
- 可用于对右端向量进行相应置换

#### 错误代码

| 代码 | 描述 |
|------|------|
| 0 | 分解成功 |
| 1 | 矩阵非方阵或置换向量维度不匹配 |
| 2 | 矩阵奇异或近奇异 |

#### 示例

```fortran
program example_ludeco_pivot
  use ludecomp_m
  implicit none
  
  real :: A(3,3)
  integer :: pivot(3), ierr, i
  
  A = reshape([1.0, 2.0, 3.0, &
               4.0, 5.0, 6.0, &
               7.0, 8.0, 10.0], [3,3])
  
  call ludeco_with_pivot(A, pivot, ierr)
  
  if (ierr == 0) then
    print *, "LU分解成功"
    print *, "置换向量:", pivot
  else
    print *, "LU分解失败，错误代码:", ierr
  end if
end program example_ludeco_pivot
```

---

### 3.3 get_lu_components

从LU分解结果中提取L和U矩阵。

#### 语法

```fortran
call get_lu_components(a, L, U)
```

#### 参数

| 参数 | 类型 | 意图 | 必需 | 描述 |
|------|------|------|------|------|
| a | real(:,:) | in | 是 | LU分解后的矩阵 |
| L | real(:,:) | out | 是 | 输出的下三角矩阵 |
| U | real(:,:) | out | 是 | 输出的上三角矩阵 |

#### 说明

- `L` 是单位下三角矩阵（对角线元素为1）
- `U` 是上三角矩阵
- 验证：`matmul(L, U)` 应近似等于原始矩阵

#### 示例

```fortran
program example_get_lu
  use ludecomp_m
  implicit none
  
  real :: A(3,3), L(3,3), U(3,3), LU_product(3,3)
  integer :: ierr
  
  A = reshape([4.0, 3.0, 2.0, &
               3.0, 5.0, 1.0, &
               2.0, 1.0, 6.0], [3,3])
  
  call ludeco(A, ierr)
  
  if (ierr == 0) then
    call get_lu_components(A, L, U)
    
    print *, "L矩阵:"
    print '(3F10.4)', L
    print *, "U矩阵:"
    print '(3F10.4)', U
    
    LU_product = matmul(L, U)
    print *, "验证 L*U:"
    print '(3F10.4)', LU_product
  end if
end program example_get_lu
```

---

## 4. linear_solvers 模块

线性方程组求解模块，提供高级封装接口。

### 4.1 solve_linear_system

求解线性方程组 Ax = b（无选主元版本）。

#### 语法

```fortran
call solve_linear_system(A, b, x [, ierr] [, pivot_threshold])
```

#### 参数

| 参数 | 类型 | 意图 | 必需 | 描述 |
|------|------|------|------|------|
| A | real(:,:) | inout | 是 | 系数矩阵（会被修改） |
| b | real(:) | in | 是 | 右端向量 |
| x | real(:) | out | 是 | 解向量 |
| ierr | integer | out | 否 | 错误代码 |
| pivot_threshold | real | in | 否 | 主元阈值，默认1.0e-12 |

#### 说明

- 此函数会修改输入矩阵 A
- 内部执行 LU 分解和前向/后向替换
- 对于病态矩阵，推荐使用 `solve_linear_system_with_pivot`

#### 示例

```fortran
program example_solve
  use linear_solvers
  implicit none
  
  real :: A(3,3), b(3), x(3)
  integer :: ierr
  
  A = reshape([3.0, 2.0, 1.0, &
               2.0, 4.0, 2.0, &
               1.0, 2.0, 5.0], [3,3])
  b = [6.0, 8.0, 10.0]
  
  call solve_linear_system(A, b, x, ierr)
  
  if (ierr == 0) then
    print *, "解向量:", x
  else
    print *, "求解失败，错误代码:", ierr
  end if
end program example_solve
```

---

### 4.2 solve_linear_system_with_pivot

求解线性方程组 Ax = b（带选主元版本，推荐使用）。

#### 语法

```fortran
call solve_linear_system_with_pivot(A, b, x [, ierr] [, pivot_threshold])
```

#### 参数

| 参数 | 类型 | 意图 | 必需 | 描述 |
|------|------|------|------|------|
| A | real(:,:) | inout | 是 | 系数矩阵（会被修改） |
| b | real(:) | in | 是 | 右端向量 |
| x | real(:) | out | 是 | 解向量 |
| ierr | integer | out | 否 | 错误代码 |
| pivot_threshold | real | in | 否 | 主元阈值，默认1.0e-12 |

#### 说明

- 这是**推荐使用**的求解接口
- 内部使用部分选主元策略，数值稳定性更好
- 能有效处理病态矩阵

#### 示例

```fortran
program example_solve_pivot
  use linear_solvers
  use matrix_utils
  implicit none
  
  real :: A(3,3), A_orig(3,3), b(3), x(3)
  integer :: ierr
  real :: residual
  
  A = reshape([2.0, 1.0, 1.0, &
               4.0, 3.0, 3.0, &
               8.0, 7.0, 9.0], [3,3])
  A_orig = A  ! 保存原始矩阵用于验证
  b = [1.0, 2.0, 3.0]
  
  call solve_linear_system_with_pivot(A, b, x, ierr)
  
  if (ierr == 0) then
    print *, "解向量:", x
    
    ! 验证解的正确性
    residual = matrix_residual(A_orig, x, b)
    print *, "相对残差:", residual
  else
    print *, "求解失败，错误代码:", ierr
  end if
end program example_solve_pivot
```

---

### 4.3 lusolve

在已执行LU分解的矩阵上求解（无选主元）。

#### 语法

```fortran
call lusolve(a, b, x [, ierr])
```

#### 参数

| 参数 | 类型 | 意图 | 必需 | 描述 |
|------|------|------|------|------|
| a | real(:,:) | in | 是 | 已执行LU分解的矩阵 |
| b | real(:) | in | 是 | 右端向量 |
| x | real(:) | out | 是 | 解向量 |
| ierr | integer | out | 否 | 错误代码 |

#### 说明

- 用于在已分解的矩阵上多次求解不同右端向量
- 内部执行前向替换和后向替换

#### 示例

```fortran
program example_lusolve
  use ludecomp_m
  use linear_solvers
  implicit none
  
  real :: A(3,3), b1(3), b2(3), x(3)
  integer :: ierr
  
  A = reshape([4.0, 3.0, 2.0, &
               3.0, 5.0, 1.0, &
               2.0, 1.0, 6.0], [3,3])
  
  ! 先执行LU分解
  call ludeco(A, ierr)
  
  if (ierr == 0) then
    ! 求解第一个右端向量
    b1 = [1.0, 2.0, 3.0]
    call lusolve(A, b1, x)
    print *, "解1:", x
    
    ! 求解第二个右端向量（复用分解结果）
    b2 = [4.0, 5.0, 6.0]
    call lusolve(A, b2, x)
    print *, "解2:", x
  end if
end program example_lusolve
```

---

### 4.4 lusolve_with_pivot

在已执行带选主元LU分解的矩阵上求解。

#### 语法

```fortran
call lusolve_with_pivot(a, b, x, pivot [, ierr])
```

#### 参数

| 参数 | 类型 | 意图 | 必需 | 描述 |
|------|------|------|------|------|
| a | real(:,:) | in | 是 | 已执行LU分解的矩阵 |
| b | real(:) | in | 是 | 右端向量 |
| x | real(:) | out | 是 | 解向量 |
| pivot | integer(:) | in | 是 | 置换向量 |
| ierr | integer | out | 否 | 错误代码 |

#### 示例

```fortran
program example_lusolve_pivot
  use ludecomp_m
  use linear_solvers
  implicit none
  
  real :: A(3,3), b(3), x(3)
  integer :: pivot(3), ierr
  
  A = reshape([1.0, 2.0, 3.0, &
               4.0, 5.0, 6.0, &
               7.0, 8.0, 10.0], [3,3])
  
  ! 执行带选主元的LU分解
  call ludeco_with_pivot(A, pivot, ierr)
  
  if (ierr == 0) then
    b = [1.0, 2.0, 3.0]
    call lusolve_with_pivot(A, b, x, pivot)
    print *, "解向量:", x
  end if
end program example_lusolve_pivot
```

---

### 4.5 condition_number_estimate

估计矩阵条件数。

#### 语法

```fortran
cond_est = condition_number_estimate(A)
```

#### 参数

| 参数 | 类型 | 意图 | 必需 | 描述 |
|------|------|------|------|------|
| A | real(:,:) | in | 是 | 输入矩阵 |

#### 返回值

返回矩阵条件数的估计值（real类型）。

#### 说明

- 当前实现为简化估计，用于粗略判断矩阵病态程度
- 条件数越大，矩阵越病态，求解误差可能越大

---

## 5. matrix_utils 模块

矩阵工具函数模块，提供辅助功能。

### 5.1 generate_hilbert_matrix

生成希尔伯特矩阵（经典病态矩阵）。

#### 语法

```fortran
call generate_hilbert_matrix(A, n)
```

#### 参数

| 参数 | 类型 | 意图 | 必需 | 描述 |
|------|------|------|------|------|
| A | real(:,:) | out | 是 | 输出矩阵 |
| n | integer | in | 是 | 矩阵维度 |

#### 说明

希尔伯特矩阵定义为：
```
A(i,j) = 1 / (i + j - 1)
```

这是一个著名的病态矩阵，常用于测试数值算法的稳定性。

#### 示例

```fortran
program example_hilbert
  use matrix_utils
  implicit none
  
  real, allocatable :: H(:,:)
  integer :: n
  
  n = 5
  allocate(H(n, n))
  
  call generate_hilbert_matrix(H, n)
  call print_matrix(H, "希尔伯特矩阵")
  
  deallocate(H)
end program example_hilbert
```

---

### 5.2 generate_diagonal_dominant

生成对角占优矩阵。

#### 语法

```fortran
call generate_diagonal_dominant(A, n [, dominance_factor])
```

#### 参数

| 参数 | 类型 | 意图 | 必需 | 描述 |
|------|------|------|------|------|
| A | real(:,:) | out | 是 | 输出矩阵 |
| n | integer | in | 是 | 矩阵维度 |
| dominance_factor | real | in | 否 | 对角优势因子，默认10.0 |

#### 说明

- 对角占优矩阵保证LU分解无需选主元即可稳定进行
- 适用于生成测试用稳定矩阵

---

### 5.3 generate_random_matrix

生成随机矩阵。

#### 语法

```fortran
call generate_random_matrix(A, n [, symmetric])
```

#### 参数

| 参数 | 类型 | 意图 | 必需 | 描述 |
|------|------|------|------|------|
| A | real(:,:) | out | 是 | 输出矩阵 |
| n | integer | in | 是 | 矩阵维度 |
| symmetric | logical | in | 否 | 是否生成对称矩阵，默认false |

#### 说明

- 元素值范围：[-5, 5]
- 使用 Fortran 内置 `random_number` 函数

---

### 5.4 print_matrix

格式化打印矩阵。

#### 语法

```fortran
call print_matrix(A [, name])
```

#### 参数

| 参数 | 类型 | 意图 | 必需 | 描述 |
|------|------|------|------|------|
| A | real(:,:) | in | 是 | 要打印的矩阵 |
| name | character(len=*) | in | 否 | 矩阵名称 |

#### 示例

```fortran
real :: A(2,2)
A = reshape([1.0, 2.0, 3.0, 4.0], [2,2])
call print_matrix(A, "矩阵A")
```

---

### 5.5 print_vector

格式化打印向量。

#### 语法

```fortran
call print_vector(v [, name])
```

#### 参数

| 参数 | 类型 | 意图 | 必需 | 描述 |
|------|------|------|------|------|
| v | real(:) | in | 是 | 要打印的向量 |
| name | character(len=*) | in | 否 | 向量名称 |

---

### 5.6 matrix_residual

计算相对残差范数。

#### 语法

```fortran
residual = matrix_residual(A, x, b)
```

#### 参数

| 参数 | 类型 | 意图 | 必需 | 描述 |
|------|------|------|------|------|
| A | real(:,:) | in | 是 | 系数矩阵 |
| x | real(:) | in | 是 | 解向量 |
| b | real(:) | in | 是 | 右端向量 |

#### 返回值

返回相对残差：`||Ax - b|| / ||b||`

#### 说明

- 用于验证求解结果的正确性
- 残差越小，解越精确
- 一般认为残差小于 1e-6 为可接受

#### 示例

```fortran
program verify_solution
  use linear_solvers
  use matrix_utils
  implicit none
  
  real :: A(3,3), A_orig(3,3), b(3), x(3)
  integer :: ierr
  real :: residual
  
  A = reshape([3.0, 2.0, 1.0, &
               2.0, 4.0, 2.0, &
               1.0, 2.0, 5.0], [3,3])
  A_orig = A
  b = [6.0, 8.0, 10.0]
  
  call solve_linear_system_with_pivot(A, b, x, ierr)
  
  if (ierr == 0) then
    residual = matrix_residual(A_orig, x, b)
    print *, "相对残差:", residual
    
    if (residual < 1.0e-6) then
      print *, "求解精度良好"
    else
      print *, "求解精度较低，请检查矩阵条件数"
    end if
  end if
end program verify_solution
```

---

### 5.7 is_symmetric

检查矩阵是否对称。

#### 语法

```fortran
result = is_symmetric(A [, tolerance])
```

#### 参数

| 参数 | 类型 | 意图 | 必需 | 描述 |
|------|------|------|------|------|
| A | real(:,:) | in | 是 | 输入矩阵 |
| tolerance | real | in | 否 | 容差，默认1.0e-6 |

#### 返回值

返回逻辑值：`.true.` 表示对称，`.false.` 表示不对称。

---

### 5.8 matrix_norm

计算矩阵范数。

#### 语法

```fortran
norm_val = matrix_norm(A [, norm_type])
```

#### 参数

| 参数 | 类型 | 意图 | 必需 | 描述 |
|------|------|------|------|------|
| A | real(:,:) | in | 是 | 输入矩阵 |
| norm_type | character(len=1) | in | 否 | 范数类型 |

#### 范数类型

| 类型 | 描述 |
|------|------|
| '1' | 1-范数（列和最大值），默认 |
| 'I' | 无穷范数（行和最大值） |
| 'F' | Frobenius范数 |

#### 示例

```fortran
real :: A(3,3), n1, ni, nf

A = reshape([1.0, 2.0, 3.0, &
             4.0, 5.0, 6.0, &
             7.0, 8.0, 9.0], [3,3])

n1 = matrix_norm(A, '1')   ! 1-范数
ni = matrix_norm(A, 'I')   ! 无穷范数
nf = matrix_norm(A, 'F')   ! Frobenius范数
```

---

## 6. 完整使用示例

### 6.1 基本求解流程

```fortran
program basic_solver
  use linear_solvers
  use matrix_utils
  implicit none
  
  integer, parameter :: n = 4
  real :: A(n,n), A_orig(n,n), b(n), x(n)
  integer :: ierr
  real :: residual
  
  ! 定义系数矩阵
  A = reshape([ &
    4.0, 1.0, 2.0, 1.0, &
    1.0, 5.0, 3.0, 2.0, &
    2.0, 3.0, 6.0, 1.0, &
    1.0, 2.0, 1.0, 7.0], [n,n])
  A_orig = A
  
  ! 定义右端向量
  b = [1.0, 2.0, 3.0, 4.0]
  
  ! 打印输入
  call print_matrix(A, "系数矩阵 A")
  call print_vector(b, "右端向量 b")
  
  ! 求解方程组
  call solve_linear_system_with_pivot(A, b, x, ierr)
  
  ! 输出结果
  if (ierr == 0) then
    call print_vector(x, "解向量 x")
    
    ! 验证结果
    residual = matrix_residual(A_orig, x, b)
    print *, "相对残差:", residual
  else
    print *, "求解失败，错误代码:", ierr
    select case(ierr)
    case(1)
      print *, "原因: 矩阵维度错误"
    case(2)
      print *, "原因: 矩阵奇异或近奇异"
    case(3)
      print *, "原因: 向量维度不匹配"
    end select
  end if
end program basic_solver
```

### 6.2 多次求解（复用分解）

```fortran
program multi_solve
  use ludecomp_m
  use linear_solvers
  implicit none
  
  integer, parameter :: n = 3
  real :: A(n,n)
  integer :: pivot(n), ierr
  real :: b(n), x(n)
  integer :: i
  
  ! 定义矩阵
  A = reshape([4.0, 3.0, 2.0, &
               3.0, 5.0, 1.0, &
               2.0, 1.0, 6.0], [n,n])
  
  ! 执行一次LU分解
  call ludeco_with_pivot(A, pivot, ierr)
  
  if (ierr /= 0) then
    print *, "LU分解失败"
    stop
  end if
  
  ! 求解多个右端向量
  do i = 1, 5
    call random_number(b)
    b = b * 10.0
    call lusolve_with_pivot(A, b, x, pivot)
    print *, "解", i, ":", x
  end do
end program multi_solve
```

### 6.3 病态矩阵处理

```fortran
program ill_conditioned
  use linear_solvers
  use matrix_utils
  implicit none
  
  integer, parameter :: n = 10
  real, allocatable :: H(:,:), H_orig(:,:), b(:), x(:), x_exact(:)
  integer :: ierr, i
  real :: residual
  
  allocate(H(n,n), H_orig(n,n), b(n), x(n), x_exact(n))
  
  ! 生成希尔伯特矩阵
  call generate_hilbert_matrix(H, n)
  H_orig = H
  
  ! 设置精确解
  x_exact = [(real(i), i=1, n)]
  b = matmul(H_orig, x_exact)
  
  ! 求解
  call solve_linear_system_with_pivot(H, b, x, ierr)
  
  if (ierr == 0) then
    residual = matrix_residual(H_orig, x, b)
    print *, "相对残差:", residual
    print *, "最大误差:", maxval(abs(x - x_exact))
  else
    print *, "求解失败"
  end if
  
  deallocate(H, H_orig, b, x, x_exact)
end program ill_conditioned
```

---

## 7. 最佳实践

### 7.1 推荐用法

1. **优先使用带选主元的接口**
   ```fortran
   ! 推荐
   call solve_linear_system_with_pivot(A, b, x, ierr)
   
   ! 不推荐（除非确定矩阵性质良好）
   call solve_linear_system(A, b, x, ierr)
   ```

2. **始终检查错误代码**
   ```fortran
   call solve_linear_system_with_pivot(A, b, x, ierr)
   if (ierr /= 0) then
     ! 处理错误
   end if
   ```

3. **验证求解结果**
   ```fortran
   residual = matrix_residual(A_orig, x, b)
   if (residual > 1.0e-6) then
     print *, "警告: 求解精度较低"
   end if
   ```

4. **多次求解时复用分解结果**
   ```fortran
   ! 先分解
   call ludeco_with_pivot(A, pivot, ierr)
   
   ! 多次求解
   do i = 1, num_rhs
     call lusolve_with_pivot(A, b(:,i), x(:,i), pivot)
   end do
   ```

### 7.2 性能建议

- 对于大规模矩阵，考虑使用优化编译选项 `-O3`
- 多次求解相同矩阵时，复用LU分解结果
- 避免不必要的矩阵复制

### 7.3 数值精度建议

- 注意矩阵条件数，病态矩阵可能导致精度损失
- 希尔伯特矩阵等病态矩阵可用于测试算法稳定性
- 使用 `matrix_residual` 验证求解质量

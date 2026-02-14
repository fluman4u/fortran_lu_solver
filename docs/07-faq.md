# 常见问题解决方案

## 1. 编译问题

### 1.1 找不到编译器

**问题描述**:
```
gfortran: command not found
```

**解决方案**:

| 操作系统 | 解决方法 |
|----------|----------|
| Ubuntu/Debian | `sudo apt install gfortran` |
| CentOS/RHEL | `sudo yum install gcc-gfortran` |
| Fedora | `sudo dnf install gcc-gfortran` |
| macOS | `brew install gcc` |
| Windows (MSYS2) | `pacman -S mingw-w64-x86_64-gcc-fortran` |

### 1.2 模块文件找不到

**问题描述**:
```
Fatal Error: Can't open module file 'ludecomp_m.mod' for reading at (1)
```

**原因**: 编译顺序错误或模块文件未生成。

**解决方案**:
```bash
# 清理并重新编译
make clean
make all

# 确保按正确顺序编译
# 1. ludecomp_m.f90 (无依赖)
# 2. matrix_utils.f90 (依赖 ludecomp_m)
# 3. linear_solvers.f90 (依赖 ludecomp_m, matrix_utils)
```

### 1.3 编译警告处理

**问题描述**:
```
Warning: Nonstandard type declaration
```

**解决方案**:
```bash
# 检查代码是否符合 Fortran 标准
# 使用标准兼容选项编译
make FFLAGS="-std=f2008 -Wall -Wextra" all
```

### 1.4 Windows 路径问题

**问题描述**:
```
make: *** No rule to make target
```

**解决方案**:
```powershell
# 使用 MSYS2 或 Git Bash 终端
# 或确保 Makefile 使用正斜杠

# 在 PowerShell 中使用完整路径
& "C:\msys64\mingw64\bin\make.exe" all
```

---

## 2. 运行时问题

### 2.1 程序崩溃

**问题描述**:
程序运行时突然终止，无明确错误信息。

**诊断步骤**:
```bash
# 使用调试选项重新编译
make FFLAGS="-g -O0 -fcheck=all -fbacktrace" clean all

# 运行程序
./bin/test_basic

# 使用 GDB 调试
gdb ./bin/test_basic
(gdb) run
(gdb) backtrace
```

**常见原因**:
- 数组越界
- 空指针访问
- 栈溢出（大数组）

### 2.2 数值溢出/下溢

**问题描述**:
```
Program received signal SIGFPE: Floating-point exception
```

**解决方案**:
```fortran
! 检查数值范围
! 使用双精度处理大数
integer, parameter :: dp = kind(1.0d0)
real(dp) :: large_number

! 捕获浮点异常
! 编译时添加选项: -ffpe-trap=invalid,zero,overflow
```

### 2.3 内存不足

**问题描述**:
处理大矩阵时内存不足。

**解决方案**:
```fortran
! 使用可分配数组
real, allocatable :: A(:,:)
integer :: n

n = 10000
allocate(A(n, n))

! 使用后释放
deallocate(A)

! 或使用自动释放
block
  real, allocatable :: temp(:,:)
  allocate(temp(n, n))
  ! 使用 temp...
  ! 退出 block 时自动释放
end block
```

---

## 3. 数值问题

### 3.1 求解结果不正确

**问题描述**:
求解结果明显偏离预期，残差很大。

**诊断步骤**:
```fortran
! 1. 检查残差
residual = matrix_residual(A_orig, x, b)
print *, "相对残差:", residual

! 2. 检查矩阵条件数
cond = condition_number_estimate(A_orig)
print *, "条件数估计:", cond

! 3. 检查矩阵是否奇异
if (abs(det(A)) < 1.0e-10) then
  print *, "警告: 矩阵可能奇异"
end if
```

**解决方案**:
```fortran
! 使用带选主元的求解器
call solve_linear_system_with_pivot(A, b, x, ierr)

! 调整主元阈值
call solve_linear_system_with_pivot(A, b, x, ierr, pivot_threshold=1.0e-14)
```

### 3.2 矩阵奇异错误

**问题描述**:
```
Error: Matrix is singular or nearly singular
错误代码: 2
```

**原因分析**:
- 矩阵行列式为零
- 矩阵存在线性相关的行/列
- 矩阵条件数极大

**解决方案**:
```fortran
! 1. 检查矩阵结构
call print_matrix(A, "矩阵A")

! 2. 检查行列是否线性相关
! 3. 考虑使用正则化方法
! 4. 检查问题建模是否正确

! 如果矩阵确实奇异，需要重新审视问题定义
```

### 3.3 精度损失

**问题描述**:
对于病态矩阵，求解精度不够。

**解决方案**:
```fortran
! 1. 使用双精度
integer, parameter :: dp = kind(1.0d0)
real(dp) :: A(n,n), b(n), x(n)

! 2. 使用迭代改进
! x = x + A^{-1} * (b - A*x)

! 3. 检查并调整主元阈值
call solve_linear_system_with_pivot(A, b, x, ierr, pivot_threshold=1.0e-15)
```

### 3.4 希尔伯特矩阵求解失败

**问题描述**:
希尔伯特矩阵（病态矩阵）求解精度很差。

**原因**:
希尔伯特矩阵是著名的病态矩阵，条件数随维度急剧增长。

| 维度 n | 条件数数量级 |
|--------|-------------|
| 5 | 10^5 |
| 10 | 10^13 |
| 15 | 10^21 |
| 20 | 10^28 |

**解决方案**:
```fortran
! 对于高维希尔伯特矩阵，需要:
! 1. 使用双精度或四精度
! 2. 接受更大的残差容限
! 3. 考虑使用专门的病态矩阵求解算法

! 实际应用中应避免使用希尔伯特矩阵
! 改用对角占优矩阵
call generate_diagonal_dominant(A, n, dominance_factor=10.0)
```

---

## 4. 性能问题

### 4.1 求解速度慢

**问题描述**:
大规模矩阵求解时间过长。

**优化建议**:

```bash
# 1. 使用优化编译选项
make FFLAGS="-O3 -march=native" all

# 2. 使用并行编译器
make FC=ifort FFLAGS="-O3 -parallel" all
```

```fortran
! 3. 复用LU分解结果
! 对于多次求解相同矩阵:
call ludeco_with_pivot(A, pivot, ierr)  ! 分解一次

do i = 1, num_rhs
  call lusolve_with_pivot(A, b(:,i), x(:,i), pivot)  ! 多次求解
end do
```

### 4.2 内存使用过高

**问题描述**:
大矩阵占用过多内存。

**解决方案**:
```fortran
! 1. 及时释放不再使用的数组
deallocate(temp_array)

! 2. 使用块处理方法
! 将大矩阵分块处理

! 3. 考虑使用稀疏矩阵格式（如果适用）
! 本项目当前仅支持稠密矩阵
```

---

## 5. 集成问题

### 5.1 与其他Fortran项目集成

**问题描述**:
模块命名冲突或编译顺序问题。

**解决方案**:
```makefile
# 在 Makefile 中明确指定模块路径
FFLAGS += -J./mod_files -I./mod_files

# 确保编译顺序正确
# 先编译依赖模块，再编译使用模块
```

### 5.2 与C/C++项目集成

**问题描述**:
Fortran与C之间的数据传递问题。

**解决方案**:
```fortran
! 使用 ISO_C_BINDING
use, intrinsic :: iso_c_binding

! C兼容的类型声明
integer(c_int) :: n
real(c_double) :: x
real(c_double), dimension(*) :: arr  ! C风格数组

! 导出C兼容接口
subroutine my_solver(n, a, b, x) bind(c, name="my_solver")
  integer(c_int), value :: n
  real(c_double) :: a(n,n), b(n), x(n)
  ! ...
end subroutine
```

### 5.3 Python 调用

**问题描述**:
从Python调用Fortran库。

**解决方案**:
```python
# 使用 f2py (NumPy 附带)
# 1. 创建签名文件
f2py -m lu_solver -h lu_solver.pyf src/*.f90

# 2. 编译生成Python模块
f2py -c lu_solver.pyf src/*.f90

# 3. 在Python中使用
import lu_solver
import numpy as np

A = np.array([[4, 1], [1, 3]], dtype=np.float32)
b = np.array([1, 2], dtype=np.float32)
x = lu_solver.solve(A, b)
```

---

## 6. 错误代码速查

| 错误码 | 含义 | 常见原因 | 解决方案 |
|--------|------|----------|----------|
| 0 | 成功 | - | 正常继续 |
| 1 | 维度错误 | 矩阵非方阵 | 检查矩阵维度 |
| 1 | 维度错误 | 向量维度不匹配 | 确保b, x维度与A一致 |
| 1 | 维度错误 | 置换向量维度错误 | 确保pivot维度正确 |
| 2 | 数值错误 | 零主元 | 检查矩阵是否奇异 |
| 2 | 数值错误 | 矩阵奇异 | 重新审视问题定义 |
| 2 | 数值错误 | 主元小于阈值 | 调整pivot_threshold |
| 3 | 向量错误 | 向量维度不匹配 | 检查b, x维度 |

---

## 7. 调试技巧

### 7.1 启用详细输出

```fortran
! 在代码中添加调试输出
print *, "矩阵维度:", size(A, 1), "x", size(A, 2)
print *, "向量维度:", size(b)
print *, "主元阈值:", pivot_threshold

! 打印中间结果
call print_matrix(A, "分解后的矩阵")
call print_vector(x, "解向量")
```

### 7.2 使用断言

```fortran
subroutine assert(condition, message)
  logical, intent(in) :: condition
  character(len=*), intent(in) :: message
  
  if (.not. condition) then
    print *, "断言失败: ", message
    error stop
  end if
end subroutine assert

! 使用示例
call assert(size(A,1) == size(A,2), "矩阵必须为方阵")
call assert(size(b) == size(A,1), "向量维度必须与矩阵匹配")
```

### 7.3 内存检查

```bash
# 使用 Valgrind 检查内存问题 (Linux)
valgrind --leak-check=full ./bin/test_basic

# 使用 AddressSanitizer (GCC)
make FFLAGS="-g -fsanitize=address" all
./bin/test_basic
```

---

## 8. 获取帮助

### 8.1 报告问题

当遇到无法解决的问题时，请提供以下信息：

1. **环境信息**
   - 操作系统及版本
   - 编译器及版本 (`gfortran --version`)
   - 项目版本

2. **问题描述**
   - 完整的错误信息
   - 复现步骤
   - 预期行为 vs 实际行为

3. **示例代码**
   - 最小可复现示例
   - 输入数据

### 8.2 问题模板

```markdown
## 环境信息
- 操作系统: Ubuntu 22.04
- 编译器: gfortran 11.3.0
- 项目版本: v1.0.0

## 问题描述
[描述问题]

## 复现步骤
1. [步骤1]
2. [步骤2]

## 错误信息
```
[粘贴错误信息]
```

## 示例代码
```fortran
[粘贴代码]
```
```

### 8.3 资源链接

| 资源 | 链接 |
|------|------|
| 问题反馈 | https://gitee.com/fluman2024/fortran_lu_solver/issues |
| 项目主页 | https://gitee.com/fluman2024/fortran_lu_solver |
| Fortran教程 | https://fortran-lang.org/learn/ |
| gfortran文档 | https://gcc.gnu.org/onlinedocs/gfortran/ |

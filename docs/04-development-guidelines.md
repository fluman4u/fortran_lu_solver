# 开发规范

## 1. 代码风格指南

### 1.1 Fortran 代码规范

#### 1.1.1 基本格式

本项目采用 **自由格式 (Free Format)** Fortran 90/95 标准。

```fortran
! 正确示例
program example
  implicit none
  integer :: i, j
  real :: x

  x = 0.0
  do i = 1, 10
    x = x + real(i)
  end do
end program example
```

#### 1.1.2 命名约定

| 类型    | 命名规则              | 示例                              |
| ----- | ----------------- | ------------------------------- |
| 程序单元  | 小写下划线分隔           | `solve_linear_system`           |
| 模块    | 小写下划线分隔，以 `_m` 结尾 | `ludecomp_m`                    |
| 子程序   | 小写下划线分隔           | `ludeco_with_pivot`             |
| 函数    | 小写下划线分隔           | `matrix_norm`                   |
| 变量    | 小写下划线分隔           | `pivot_threshold`               |
| 常量/参数 | 大写下划线分隔           | `MAX_SIZE`, `DEFAULT_TOLERANCE` |
| 派生类型  | 驼峰命名              | `MatrixType`, `SolverConfig`    |

#### 1.1.3 缩进与空白

```fortran
! 缩进: 2个空格 (不使用Tab)
program example
  implicit none
  integer :: i

  do i = 1, 10
    if (i > 5) then
      print *, i
    end if
  end do
end program example

! 空行规则:
! - 程序单元之间空2行
! - 逻辑块之间空1行
! - 声明块与执行语句之间空1行

! 空格规则:
! - 运算符两侧加空格: a = b + c
! - 逗号后加空格: func(a, b, c)
! - 括号内侧不加空格: func(a) 而非 func( a )
```

#### 1.1.4 行长度限制

- 最大行长度: **100 字符**
- 过长行使用续行符 `&`

```fortran
! 续行示例
call solve_linear_system_with_pivot(A, b, x, &
                                    ierr=ierr, &
                                    pivot_threshold=1.0e-10)
```

### 1.2 模块结构规范

#### 1.2.1 标准模块模板

```fortran
module module_name
  implicit none
  private

  ! 公共接口声明
  public :: public_subroutine, public_function

  ! 常量定义
  integer, parameter, public :: MODULE_CONSTANT = 100

  ! 派生类型定义 (如有)
  type :: TypeName
    private
    integer :: field1
    real :: field2
  contains
    procedure :: method_name
  end type TypeName

contains

  ! 子程序实现
  subroutine public_subroutine(arg1, arg2)
    integer, intent(in) :: arg1
    real, intent(out) :: arg2

    ! 实现...
  end subroutine public_subroutine

  ! 函数实现
  function public_function(arg) result(res)
    real, intent(in) :: arg
    real :: res

    ! 实现...
  end function public_function

end module module_name
```

#### 1.2.2 模块组织原则

```fortran
! 模块内顺序:
! 1. implicit none
! 2. private 声明 (默认私有)
! 3. public 列表
! 4. 常量/参数定义
! 5. 派生类型定义
! 6. 接口块
! 7. 变量声明 (模块级变量应尽量避免)
! 8. contains
! 9. 子程序/函数实现
```

### 1.3 子程序与函数规范

#### 1.3.1 参数声明

```fortran
subroutine example(a, b, c, d, e, optional_param)
  ! 参数按 intent 分组声明
  integer, intent(in) :: a, b           ! 输入参数
  real, intent(out) :: c                ! 输出参数
  real, intent(inout) :: d              ! 输入输出参数
  character(len=*), intent(in) :: e     ! 字符串参数

  ! 可选参数放在最后
  integer, intent(in), optional :: optional_param

  ! 局部变量
  integer :: i, j
  real :: temp
end subroutine example
```

#### 1.3.2 错误处理模式

```fortran
subroutine robust_operation(data, ierr)
  real, intent(inout) :: data(:)
  integer, intent(out), optional :: ierr

  integer :: error_flag

  error_flag = 0

  ! 输入验证
  if (size(data) == 0) then
    error_flag = 1
    if (present(ierr)) then
      ierr = error_flag
      return
    else
      error stop "Error: Empty data array"
    end if
  end if

  ! 主操作...

  ! 返回错误状态
  if (present(ierr)) ierr = error_flag
end subroutine robust_operation
```

## 2. 文档规范

### 2.1 代码注释

#### 2.1.1 模块注释

```fortran
!> @brief LU分解模块
!!
!! 本模块实现带部分选主元的LU分解算法，
!! 用于求解线性方程组 Ax = b。
!!
!! @author 项目作者
!! @version 1.0.0
module ludecomp_m
  implicit none
  private
  public :: ludeco, ludeco_with_pivot, get_lu_components

contains

  !> @brief 执行LU分解
  !!
  !! 对方阵A进行原地LU分解，结果存储在A中。
  !! L的对角线元素隐含为1，不显式存储。
  !!
  !! @param[inout] a    待分解的方阵，分解后存储LU结果
  !! @param[out]   ierr 错误代码 (可选)
  !!                    - 0: 成功
  !!                    - 1: 矩阵非方阵
  !!                    - 2: 零主元/奇异矩阵
  !! @param[in]    pivot_threshold 主元阈值 (可选，默认1e-12)
  subroutine ludeco(a, ierr, pivot_threshold)
    real, intent(inout) :: a(:,:)
    integer, intent(out), optional :: ierr
    real, intent(in), optional :: pivot_threshold

    ! 实现...
  end subroutine ludeco
end module ludecomp_m
```

#### 2.1.2 行内注释

```fortran
! 计算乘数并更新行
do i = k+1, n
  a(i, k) = a(i, k) / a(k, k)  ! 计算乘数
  a(i, k+1:n) = a(i, k+1:n) - a(i,k) * a(k, k+1:n)  ! 消元
end do
```

### 2.2 提交信息规范

#### 2.2.1 提交信息格式

```
<类型>(<范围>): <简短描述>

<详细描述> (可选)

<页脚信息> (可选)
```

#### 2.2.2 类型说明

| 类型       | 说明    | 示例                           |
| -------- | ----- | ---------------------------- |
| feat     | 新功能   | feat(solver): 添加Cholesky分解支持 |
| fix      | 修复bug | fix(pivot): 修复选主元索引错误        |
| docs     | 文档更新  | docs(api): 更新API文档           |
| style    | 代码格式  | style: 统一缩进为2空格              |
| refactor | 重构    | refactor(ludeco): 优化循环结构     |
| test     | 测试    | test: 添加边界条件测试用例             |
| chore    | 构建/工具 | chore: 更新Makefile编译选项        |

#### 2.2.3 提交示例

```
feat(solver): 添加条件数估计功能

- 实现基于范数的条件数估计
- 添加相应的单元测试
- 更新API文档

Closes #12
```

## 3. 测试规范

### 3.1 测试组织

```
test/
├── test_basic.f90        # 基础功能测试
├── test_performance.f90  # 性能测试
└── test_edge_cases.f90   # 边界条件测试 (建议添加)
```

### 3.2 测试用例编写

#### 3.2.1 测试模板

```fortran
program test_module_name
  use module_name
  implicit none

  integer :: test_count, pass_count

  test_count = 0
  pass_count = 0

  print *, "=== 模块名称测试 ==="

  ! 测试1: 正常情况
  call test_normal_case()

  ! 测试2: 边界情况
  call test_edge_case()

  ! 测试3: 错误情况
  call test_error_case()

  ! 输出测试结果
  print *, "测试完成: ", pass_count, "/", test_count, " 通过"

contains

  subroutine test_normal_case()
    ! 测试实现
    test_count = test_count + 1
    ! ... 断言检查
    pass_count = pass_count + 1
    print *, "  [PASS] 正常情况测试"
  end subroutine test_normal_case

  subroutine test_edge_case()
    ! 边界测试实现
    test_count = test_count + 1
    ! ... 断言检查
    pass_count = pass_count + 1
    print *, "  [PASS] 边界情况测试"
  end subroutine test_edge_case

  subroutine test_error_case()
    ! 错误处理测试
    test_count = test_count + 1
    ! ... 断言检查
    pass_count = pass_count + 1
    print *, "  [PASS] 错误处理测试"
  end subroutine test_error_case

end program test_module_name
```

#### 3.2.2 断言辅助函数

```fortran
subroutine assert_equal(actual, expected, message, passed)
  real, intent(in) :: actual, expected
  character(len=*), intent(in) :: message
  logical, intent(out) :: passed
  real, parameter :: tolerance = 1.0e-10

  passed = abs(actual - expected) < tolerance
  if (.not. passed) then
    print *, "  [FAIL] ", message
    print *, "    期望: ", expected
    print *, "    实际: ", actual
  end if
end subroutine assert_equal

subroutine assert_true(condition, message, passed)
  logical, intent(in) :: condition
  character(len=*), intent(in) :: message
  logical, intent(out) :: passed

  passed = condition
  if (.not. passed) then
    print *, "  [FAIL] ", message
  end if
end subroutine assert_true
```

### 3.3 测试覆盖要求

| 测试类型 | 覆盖要求   | 示例            |
| ---- | ------ | ------------- |
| 功能测试 | 所有公共接口 | 每个子程序至少1个测试   |
| 边界测试 | 边界条件   | 空矩阵、单位矩阵、奇异矩阵 |
| 错误测试 | 错误路径   | 维度不匹配、奇异矩阵    |
| 性能测试 | 关键路径   | 大规模矩阵求解       |

## 4. 版本控制规范

### 4.1 分支策略

```
main (master)
  │
  ├── develop          # 开发分支
  │   │
  │   ├── feature/xxx  # 功能分支
  │   ├── fix/xxx      # 修复分支
  │   └── refactor/xxx # 重构分支
  │
  └── release/vX.Y.Z   # 发布分支
```

### 4.2 分支命名

| 分支类型 | 命名格式         | 示例                             |
| ---- | ------------ | ------------------------------ |
| 功能   | feature/描述   | feature/cholesky-decomposition |
| 修复   | fix/描述       | fix/pivot-index-error          |
| 重构   | refactor/描述  | refactor/optimize-loops        |
| 发布   | release/v版本号 | release/v1.1.0                 |

### 4.3 版本号规范

采用语义化版本 (Semantic Versioning): `MAJOR.MINOR.PATCH`

- **MAJOR**: 不兼容的API变更
- **MINOR**: 向后兼容的功能新增
- **PATCH**: 向后兼容的问题修复

示例:

- `1.0.0` → `1.0.1`: 修复bug
- `1.0.1` → `1.1.0`: 新增功能
- `1.1.0` → `2.0.0`: 破坏性变更

## 5. 代码审查清单

### 5.1 功能正确性

- [ ] 代码实现了预期功能
- [ ] 边界条件已处理
- [ ] 错误情况已处理
- [ ] 数值精度符合要求

### 5.2 代码质量

- [ ] 遵循命名规范
- [ ] 代码结构清晰
- [ ] 无冗余代码
- [ ] 注释充分且准确

### 5.3 测试覆盖

- [ ] 新功能有对应测试
- [ ] 测试用例覆盖边界情况
- [ ] 所有测试通过

### 5.4 文档更新

- [ ] API文档已更新
- [ ] 变更日志已更新
- [ ] README已更新 (如有必要)

## 6. 贡献流程

### 6.1 贡献步骤

```
1. Fork 项目仓库
   │
   ▼
2. 创建功能分支
   git checkout -b feature/my-feature
   │
   ▼
3. 编写代码和测试
   │
   ▼
4. 运行测试确保通过
   make test
   │
   ▼
5. 提交代码
   git commit -m "feat: 添加新功能"
   │
   ▼
6. 推送到远程仓库
   git push origin feature/my-feature
   │
   ▼
7. 创建 Pull Request
   │
   ▼
8. 等待代码审查
   │
   ▼
9. 根据反馈修改
   │
   ▼
10. 合并到主分支
```

### 6.2 Pull Request 模板

```markdown
## 变更描述
简要描述本次PR的变更内容

## 变更类型
- [ ] 新功能 (feat)
- [ ] Bug修复 (fix)
- [ ] 文档更新 (docs)
- [ ] 代码重构 (refactor)
- [ ] 测试相关 (test)
- [ ] 其他

## 测试情况
- [ ] 已添加测试用例
- [ ] 所有测试通过
- [ ] 手动测试通过

## 相关Issue
Closes #issue_number

## 检查清单
- [ ] 代码遵循项目规范
- [ ] 文档已更新
- [ ] 无编译警告
```

## 7. 持续集成

### 7.1 CI 流程

```yaml
# 示例 CI 配置 (GitHub Actions)
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Install gfortran
        run: sudo apt install gfortran

      - name: Build
        run: make all

      - name: Test
        run: make test
```

### 7.2 质量门禁

- 所有测试必须通过
- 无编译警告
- 代码覆盖率不低于阈值
- 文档构建成功

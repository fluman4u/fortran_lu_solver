program test_basic
  use ludecomp_m
  use linear_solvers
  use matrix_utils
  implicit none
  
  integer, parameter :: n = 4
  real :: A(n,n), A_orig(n,n), b(n), x(n), L(n,n), U(n,n)
  integer :: ierr
  real :: residual
  
  print *, "=== 基础功能测试 ==="
  
  ! 测试1: 简单矩阵
  print *, "测试1: 简单4x4矩阵"
  A_orig = reshape([ &
    4.0, 1.0, 2.0, 1.0, &
    1.0, 5.0, 3.0, 2.0, &
    2.0, 3.0, 6.0, 1.0, &
    1.0, 2.0, 1.0, 7.0], [n, n])
  
  b = [1.0, 2.0, 3.0, 4.0]
  
  A = A_orig

  call print_matrix(A, "系数矩阵")
  call print_vector(b, "右端向量")

  call solve_linear_system(A, b, x, ierr=ierr)
  
  if (ierr == 0) then
    residual = matrix_residual(A_orig, x, b)
    print *, "求解成功!"
    print *, "残差:", residual
    call print_vector(x, "解向量")
  else
    print *, "求解失败，错误代码:", ierr
  end if
  
  ! 测试2: LU分解验证
  print *, "测试2: LU分解验证"
  A = A_orig
  call ludeco(A, ierr=ierr)
  
  if (ierr == 0) then
    call get_lu_components(A, L, U)
    call print_matrix(L, "L矩阵")
    call print_matrix(U, "U矩阵")
    
    ! 验证 L*U = A_orig
    A = matmul(L, U)
    residual = matrix_norm(A - A_orig, 'F')
    print *, "LU分解误差:", residual
  end if
  
end program test_basic

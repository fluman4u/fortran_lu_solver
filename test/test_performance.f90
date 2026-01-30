program test_performance
  use linear_solvers
  use matrix_utils
  implicit none

  integer, parameter :: max_size = 500, step = 50
  integer :: n, i, ierr
  real, allocatable :: A(:,:), b(:), x(:), x_exact(:)
  real :: start_time, end_time, residual, residual_pivot
  real :: total_time, avg_time

  print *, "=== 性能测试 (比较原始算法和选主元算法) ==="
  print *, "矩阵大小, 原始时间(秒), 原始残差, 选主元时间(秒), 选主元残差"

  do n = 50, max_size, step
    allocate(A(n,n), b(n), x(n), x_exact(n))

    ! 生成对角占优矩阵（保证可解）
    call generate_diagonal_dominant(A, n, 10.0)  ! 增加对角优势
    call random_number(x_exact)
    x_exact = x_exact * 10.0
    b = matmul(A, x_exact)  ! 计算精确解对应的b

    ! 测试原始算法
    call cpu_time(start_time)
    call solve_linear_system(A, b, x, ierr=ierr)
    call cpu_time(end_time)

    if (ierr == 0) then
      residual = matrix_residual(A, x, b)
    else
      residual = huge(1.0)
    end if

    ! 测试选主元算法
    call cpu_time(start_time)
    call solve_linear_system_with_pivot(A, b, x, ierr=ierr)
    call cpu_time(end_time)
    if (ierr == 0) then
      residual_pivot = matrix_residual(A, x, b)
    else
      residual_pivot = huge(1.0)
    end if

    print '(I5, ", ", F10.6, ", ", E12.4, ", ", F10.6, ", ", E12.4)', &
          n, end_time - start_time, residual, end_time - start_time, residual_pivot

    deallocate(A, b, x, x_exact)
  end do

  ! 测试病态矩阵
  print *, "=== 病态矩阵测试 (希尔伯特矩阵) ==="
  print *, "矩阵大小, 选主元时间(秒), 选主元残差"

  do n = 5, 20, 5
    allocate(A(n,n), b(n), x(n), x_exact(n))

    ! 生成希尔伯特矩阵（著名的病态矩阵）
    call generate_hilbert_matrix(A, n)
    call random_number(x_exact)
    x_exact = x_exact * 5.0
    b = matmul(A, x_exact)

    call cpu_time(start_time)
    call solve_linear_system_with_pivot(A, b, x, ierr=ierr)
    call cpu_time(end_time)

    if (ierr == 0) then
      residual_pivot = matrix_residual(A, x, b)
      print '(I5, ", ", F10.6, ", ", E12.4)', n, end_time - start_time, residual_pivot
    else
      print '(I5, ", ", A)', n, "Failed"
    end if

    deallocate(A, b, x, x_exact)
  end do

end program test_performance

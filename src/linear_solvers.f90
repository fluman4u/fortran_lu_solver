module linear_solvers
  use ludecomp_m, only: ludeco, ludeco_with_pivot
  implicit none
  private
  public :: lusolve, solve_linear_system, condition_number_estimate, &
            lusolve_with_pivot, solve_linear_system_with_pivot

contains

  subroutine lusolve(a, b, x, ierr)
    real, intent(in) :: a(:,:)
    real, intent(in) :: b(:)
    real, intent(out) :: x(:)
    integer, intent(out), optional :: ierr

    integer :: n, i, j
    real :: temp
    integer :: error_flag

    n = size(a, 1)
    error_flag = 0

    if (size(b) /= n .or. size(x) /= n) then
      error_flag = 3
      if (present(ierr)) then
        ierr = error_flag
        return
      else
        error stop "Error: Dimension mismatch"
      end if
    end if

    ! 前向替换
    x(1) = b(1)
    do i = 2, n
      temp = b(i)
      do j = 1, i-1
        temp = temp - a(i,j) * x(j)
      end do
      x(i) = temp
    end do

    ! 后向替换
    x(n) = x(n) / a(n,n)
    do i = n-1, 1, -1
      temp = x(i)
      do j = i+1, n
        temp = temp - a(i,j) * x(j)
      end do
      x(i) = temp / a(i,i)
    end do

    if (present(ierr)) ierr = 0

  end subroutine lusolve

  ! 带选主元的求解器
  subroutine lusolve_with_pivot(a, b, x, pivot, ierr)
    real, intent(in) :: a(:,:)
    real, intent(in) :: b(:)
    real, intent(out) :: x(:)
    integer, intent(in) :: pivot(:)
    integer, intent(out), optional :: ierr

    integer :: n, i, j
    real :: temp
    real :: b_permuted(size(b))
    integer :: error_flag

    n = size(a, 1)
    error_flag = 0

    if (size(b) /= n .or. size(x) /= n .or. size(pivot) /= n) then
      error_flag = 3
      if (present(ierr)) then
        ierr = error_flag
        return
      else
        error stop "Error: Dimension mismatch"
      end if
    end if

    ! 根据置换向量重新排列b
    do i = 1, n
      b_permuted(i) = b(pivot(i))
    end do

    ! 前向替换
    x(1) = b_permuted(1)
    do i = 2, n
      temp = b_permuted(i)
      do j = 1, i-1
        temp = temp - a(i,j) * x(j)
      end do
      x(i) = temp
    end do

    ! 后向替换
    x(n) = x(n) / a(n,n)
    do i = n-1, 1, -1
      temp = x(i)
      do j = i+1, n
        temp = temp - a(i,j) * x(j)
      end do
      x(i) = temp / a(i,i)
    end do

    if (present(ierr)) ierr = 0

  end subroutine lusolve_with_pivot

  subroutine solve_linear_system(A, b, x, ierr, pivot_threshold)
    real, intent(inout) :: A(:,:)
    real, intent(in) :: b(:)
    real, intent(out) :: x(:)
    integer, intent(out), optional :: ierr
    real, intent(in), optional :: pivot_threshold

    real :: A_copy(size(A,1), size(A,2))
    integer :: error_flag

    A_copy = A
    error_flag = 0

    ! LU分解
    if (present(pivot_threshold)) then
      call ludeco(A_copy, ierr=error_flag, pivot_threshold=pivot_threshold)
    else
      call ludeco(A_copy, ierr=error_flag)
    end if

    if (error_flag /= 0) then
      if (present(ierr)) then
        ierr = error_flag
        return
      else
        error stop "LU decomposition failed"
      end if
    end if

    ! 求解
    call lusolve(A_copy, b, x, ierr=error_flag)

    if (present(ierr)) ierr = error_flag

  end subroutine solve_linear_system

  ! 使用选主元的线性系统求解
  subroutine solve_linear_system_with_pivot(A, b, x, ierr, pivot_threshold)
    real, intent(inout) :: A(:,:)
    real, intent(in) :: b(:)
    real, intent(out) :: x(:)
    integer, intent(out), optional :: ierr
    real, intent(in), optional :: pivot_threshold

    real :: A_copy(size(A,1), size(A,2))
    integer :: pivot(size(A,1))
    integer :: error_flag

    A_copy = A
    error_flag = 0

    ! 带选主元的LU分解
    if (present(pivot_threshold)) then
      call ludeco_with_pivot(A_copy, pivot, ierr=error_flag, pivot_threshold=pivot_threshold)
    else
      call ludeco_with_pivot(A_copy, pivot, ierr=error_flag)
    end if

    if (error_flag /= 0) then
      if (present(ierr)) then
        ierr = error_flag
        return
      else
        error stop "LU decomposition with pivoting failed"
      end if
    end if

    ! 使用置换向量求解
    call lusolve_with_pivot(A_copy, b, x, pivot, ierr=error_flag)

    if (present(ierr)) ierr = error_flag

  end subroutine solve_linear_system_with_pivot

  function condition_number_estimate(A) result(cond_est)
    real, intent(in) :: A(:,:)
    real :: cond_est
    real :: A_inv_norm, A_norm
    integer :: n

    n = size(A, 1)
    A_norm = maxval(sum(abs(A), dim=2))

    ! 简单条件数估计（实际应用中需要更精确的方法）
    cond_est = A_norm * A_norm  ! 简化估计

  end function condition_number_estimate

end module linear_solvers

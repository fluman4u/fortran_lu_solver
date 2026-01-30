module ludecomp_m
  implicit none
  private
  public :: ludeco, get_lu_components, ludeco_with_pivot

contains

  subroutine ludeco(a, ierr, pivot_threshold)
    real, intent(inout) :: a(:,:)
    integer, intent(out), optional :: ierr
    real, intent(in), optional :: pivot_threshold

    integer :: n, j, k, i
    real :: threshold, pivot
    integer :: error_flag

    error_flag = 0
    n = size(a, 1)
    threshold = 1.0e-12
    if (present(pivot_threshold)) threshold = pivot_threshold

    if (size(a, 2) /= n) then
      error_flag = 1
      if (present(ierr)) then
        ierr = error_flag
        return
      else
        error stop "Error: Matrix must be square"
      end if
    end if

    do k = 1, n-1
      if (abs(a(k,k)) < threshold) then
        error_flag = 2
        if (present(ierr)) then
          ierr = error_flag
          return
        else
          error stop "Error: Zero pivot encountered"
        end if
      end if

      a(k, k+1:n) = a(k, k+1:n) / a(k, k)

      do i = k+1, n
        a(i, k+1:n) = a(i, k+1:n) - a(i,k) * a(k, k+1:n)
      end do
    end do

    if (present(ierr)) ierr = 0

  end subroutine ludeco

  ! 新的带部分选主元的LU分解
  subroutine ludeco_with_pivot(a, pivot, ierr, pivot_threshold)
    real, intent(inout) :: a(:,:)
    integer, intent(out) :: pivot(:)
    integer, intent(out), optional :: ierr
    real, intent(in), optional :: pivot_threshold

    integer :: n, j, k, i, max_index
    real :: threshold, max_val, temp
    integer :: error_flag

    error_flag = 0
    n = size(a, 1)
    threshold = 1.0e-12
    if (present(pivot_threshold)) threshold = pivot_threshold

    ! 初始化置换向量
    do i = 1, n
      pivot(i) = i
    end do

    if (size(a, 2) /= n .or. size(pivot) /= n) then
      error_flag = 1
      if (present(ierr)) then
        ierr = error_flag
        return
      else
        error stop "Error: Dimension mismatch"
      end if
    end if

    do k = 1, n-1
      ! 部分选主元：找到第k列中绝对值最大的元素
      max_index = k
      max_val = abs(a(k,k))
      do i = k+1, n
        if (abs(a(i,k)) > max_val) then
          max_val = abs(a(i,k))
          max_index = i
        end if
      end do

      ! 检查主元是否太小
      if (max_val < threshold) then
        error_flag = 2
        if (present(ierr)) then
          ierr = error_flag
          return
        else
          error stop "Error: Matrix is singular or nearly singular"
        end if
      end if

      ! 如果需要，交换行
      if (max_index /= k) then
        ! 交换矩阵行
        do j = 1, n
          temp = a(k,j)
          a(k,j) = a(max_index,j)
          a(max_index,j) = temp
        end do
        ! 更新置换向量
        temp = pivot(k)
        pivot(k) = pivot(max_index)
        pivot(max_index) = temp
      end if

      ! 继续进行LU分解
      do i = k+1, n
        a(i,k) = a(i,k) / a(k,k)
        do j = k+1, n
          a(i,j) = a(i,j) - a(i,k) * a(k,j)
        end do
      end do
    end do

    ! 检查最后一个主元
    if (abs(a(n,n)) < threshold) then
      error_flag = 2
      if (present(ierr)) then
        ierr = error_flag
        return
      else
        error stop "Error: Matrix is singular or nearly singular"
      end if
    end if

    if (present(ierr)) ierr = 0

  end subroutine ludeco_with_pivot

  subroutine get_lu_components(a, L, U)
    real, intent(in) :: a(:,:)
    real, intent(out) :: L(:,:), U(:,:)
    integer :: n, i, j

    n = size(a, 1)
    L = 0.0
    U = 0.0

    do i = 1, n
      L(i,i) = 1.0
      do j = 1, i-1
        L(i,j) = a(i,j)
      end do
      do j = i, n
        U(i,j) = a(i,j)
      end do
    end do

  end subroutine get_lu_components

end module ludecomp_m

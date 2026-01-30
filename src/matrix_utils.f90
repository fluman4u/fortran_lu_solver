module matrix_utils
  implicit none
  private
  public :: generate_hilbert_matrix, generate_diagonal_dominant, &
            generate_random_matrix, print_matrix, print_vector, &
            matrix_residual, is_symmetric, matrix_norm
  
contains
  
  subroutine generate_hilbert_matrix(A, n)
    real, intent(out) :: A(:,:)
    integer, intent(in) :: n
    integer :: i, j
    
    do i = 1, n
      do j = 1, n
        A(i,j) = 1.0 / real(i + j - 1)
      end do
    end do
  end subroutine generate_hilbert_matrix
  
  subroutine generate_diagonal_dominant(A, n, dominance_factor)
    real, intent(out) :: A(:,:)
    integer, intent(in) :: n
    real, intent(in), optional :: dominance_factor
    real :: factor
    integer :: i, j

    factor = 10.0  ! 增加默认的对角优势
    if (present(dominance_factor)) factor = dominance_factor

    call random_number(A)
    A = A * 2.0 - 1.0  ! 范围 [-1, 1]

    do i = 1, n
      A(i,i) = sum(abs(A(i,:))) + factor
    end do
  end subroutine generate_diagonal_dominant
  
  subroutine generate_random_matrix(A, n, symmetric)
    real, intent(out) :: A(:,:)
    integer, intent(in) :: n
    logical, intent(in), optional :: symmetric
    integer :: i, j
    logical :: symm
    
    symm = .false.
    if (present(symmetric)) symm = symmetric
    
    call random_number(A)
    A = A * 10.0 - 5.0  ! 范围 [-5, 5]
    
    if (symm) then
      do i = 1, n
        do j = i+1, n
          A(j,i) = A(i,j)
        end do
      end do
    end if
  end subroutine generate_random_matrix
  
  subroutine print_matrix(A, name)
    real, intent(in) :: A(:,:)
    character(len=*), intent(in), optional :: name
    integer :: i, n
    
    n = size(A, 1)
    if (present(name)) then
      print *, trim(name), ":"
    end if
    
    do i = 1, n
      print '(100F12.6)', A(i,:)
    end do
    print *
  end subroutine print_matrix
  
  subroutine print_vector(v, name)
    real, intent(in) :: v(:)
    character(len=*), intent(in), optional :: name
    integer :: n
    
    n = size(v)
    if (present(name)) then
      print *, trim(name), ":"
    end if
    print '(100F12.6)', v
    print *
  end subroutine print_vector
  
  function matrix_residual(A, x, b) result(residual)
    real, intent(in) :: A(:,:), x(:), b(:)
    real :: residual
    real :: Ax(size(b))
    
    Ax = matmul(A, x)
    residual = sqrt(sum((Ax - b)**2)) / sqrt(sum(b**2))
  end function matrix_residual
  
  function is_symmetric(A, tolerance) result(symm)
    real, intent(in) :: A(:,:)
    real, intent(in), optional :: tolerance
    real :: tol
    logical :: symm
    integer :: n, i, j
    
    n = size(A, 1)
    tol = 1.0e-6
    if (present(tolerance)) tol = tolerance
    
    symm = .true.
    do i = 1, n
      do j = i+1, n
        if (abs(A(i,j) - A(j,i)) > tol) then
          symm = .false.
          return
        end if
      end do
    end do
  end function is_symmetric
  
  function matrix_norm(A, norm_type) result(norm_val)
    real, intent(in) :: A(:,:)
    character(len=1), intent(in), optional :: norm_type
    real :: norm_val
    character(len=1) :: norm_char
    
    norm_char = '1'
    if (present(norm_type)) norm_char = norm_type
    
    select case(norm_char)
    case('1')
      norm_val = maxval(sum(abs(A), dim=1))  ! 1-范数
    case('I')
      norm_val = maxval(sum(abs(A), dim=2))  ! 无穷范数
    case('F')
      norm_val = sqrt(sum(A**2))             ! Frobenius范数
    case default
      norm_val = maxval(sum(abs(A), dim=1))
    end select
  end function matrix_norm
  
end module matrix_utils

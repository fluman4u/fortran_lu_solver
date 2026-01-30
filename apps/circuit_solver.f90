program circuit_solver
  use linear_solvers
  use matrix_utils
  implicit none
  
  integer, parameter :: n_nodes = 6
  real :: conductance(n_nodes, n_nodes), currents(n_nodes), voltages(n_nodes)
  integer :: ierr, i
  character(len=3) :: node_names(n_nodes)  ! 统一长度为3
  
  print *, "=== 电路网络分析 ==="
  
  ! 设置节点名称（统一长度）
  node_names = ['V1 ', 'V2 ', 'V3 ', 'V4 ', 'V5 ', 'GND']  ! 注意添加空格保持长度一致
  
  ! 构建导纳矩阵（电路方程）
  conductance = 0.0
  
  ! 设置导纳值（模拟电阻网络）
  ! 节点之间的连接
  call set_conductance(1, 2, 2.0, conductance)
  call set_conductance(1, 3, 1.0, conductance)
  call set_conductance(2, 3, 1.0, conductance)
  call set_conductance(2, 4, 2.0, conductance)
  call set_conductance(3, 5, 1.5, conductance)
  call set_conductance(4, 5, 1.0, conductance)
  call set_conductance(4, 6, 2.0, conductance)
  call set_conductance(5, 6, 1.5, conductance)
  
  ! 设置自导纳（对角线元素）
  do i = 1, n_nodes
    conductance(i,i) = -sum(conductance(i,:)) + conductance(i,i)
  end do
  
  ! 设置电流源
  currents = 0.0
  currents(1) = 1.0   ! 1A电流注入节点1
  currents(6) = -1.0  ! 从地节点流出
  
  ! 固定地节点电压为0（修改方法）
  ! 更稳健的方法：将地节点对应的行和列设置为单位向量
  conductance(6,:) = 0.0
  conductance(:,6) = 0.0
  conductance(6,6) = 1.0
  currents(6) = 0.0
  
  call print_matrix(conductance, "导纳矩阵")
  call print_vector(currents, "电流向量")
  
  ! 求解节点电压
  call solve_linear_system(conductance, currents, voltages, ierr=ierr)
  
  if (ierr == 0) then
    print *, "电路分析结果:"
    do i = 1, n_nodes
      print '(A, ": ", F10.6, " V")', trim(adjustl(node_names(i))), voltages(i)
    end do
    
    ! 验证结果
    print *, "验证: 所有节点电流总和 = ", sum(matmul(conductance, voltages) - currents)
  else
    print *, "电路分析失败，错误代码:", ierr
  end if
  
contains
  
  subroutine set_conductance(i, j, g, cond_mat)
    integer, intent(in) :: i, j
    real, intent(in) :: g
    real, intent(inout) :: cond_mat(:,:)
    
    if (i /= j) then  ! 非对角线元素
      cond_mat(i,j) = cond_mat(i,j) - g
      cond_mat(j,i) = cond_mat(j,i) - g
    endif
    ! 对角线元素在外部统一处理
  end subroutine set_conductance
  
end program circuit_solver
# 版本历史记录

本文档记录 Fortran LU Solver 项目的所有版本更新历史。

## 版本号说明

本项目采用[语义化版本](https://semver.org/lang/zh-CN/)规范：`MAJOR.MINOR.PATCH`

- **MAJOR**: 不兼容的API变更
- **MINOR**: 向后兼容的功能新增
- **PATCH**: 向后兼容的问题修复

---

## [v1.0.0] - 2026-01-30

### 首次发布

这是项目的首个正式发布版本，包含完整的 LU 分解和线性方程组求解功能。

### Added (新增功能)

#### 核心功能
- 实现 LU 分解算法 (`ludeco`)
- 实现带部分选主元的 LU 分解算法 (`ludeco_with_pivot`)
- 实现前向替换和后向替换求解 (`lusolve`, `lusolve_with_pivot`)
- 提供完整的线性方程组求解接口 (`solve_linear_system`, `solve_linear_system_with_pivot`)

#### 矩阵工具
- 希尔伯特矩阵生成器 (`generate_hilbert_matrix`)
- 对角占优矩阵生成器 (`generate_diagonal_dominant`)
- 随机矩阵生成器 (`generate_random_matrix`)
- 矩阵范数计算 (`matrix_norm`)
- 矩阵对称性检查 (`is_symmetric`)
- 相对残差计算 (`matrix_residual`)
- 矩阵和向量格式化输出 (`print_matrix`, `print_vector`)

#### 应用示例
- 电路网络分析应用 (`circuit_solver.f90`)

#### 测试套件
- 基础功能测试 (`test_basic.f90`)
- 性能基准测试 (`test_performance.f90`)

#### 文档
- 项目 README (中英文版本)
- 项目结构说明 (`PROJECT_STRUCTURE.md`)
- 数值行为说明 (`numerics.md`)

### 技术规格

| 项目 | 规格 |
|------|------|
| 语言标准 | Fortran 90/95 |
| 支持编译器 | gfortran 7+, ifort 19+ |
| 数据类型 | 单精度实数 (real) |
| 矩阵类型 | 稠密矩阵 |

### 已知限制

- 仅支持单精度浮点数
- 仅支持稠密矩阵
- 单线程执行，无并行优化
- 条件数估计为简化版本

---

## 版本规划

### [v1.1.0] - 计划中

#### 预计新增功能
- 双精度支持
- 改进的条件数估计算法
- 更多矩阵工具函数

#### 预计改进
- 性能优化
- 文档完善

### [v1.2.0] - 计划中

#### 预计新增功能
- OpenMP 并行支持
- 更多分解算法 (Cholesky分解)

### [v2.0.0] - 远期规划

#### 预计重大变更
- 稀疏矩阵支持
- 复数矩阵支持
- API 重构

---

## 变更类型说明

| 类型 | 说明 |
|------|------|
| Added | 新增功能 |
| Changed | 功能变更 |
| Deprecated | 即将废弃的功能 |
| Removed | 已移除的功能 |
| Fixed | 问题修复 |
| Security | 安全相关修复 |

---

## 贡献者

感谢所有为本项目做出贡献的开发者。

---

## 升级指南

### 从源码升级

```bash
# 获取最新代码
git pull origin main

# 清理并重新编译
make clean
make all

# 运行测试验证
make test
```

### 版本兼容性

| 版本 | 向后兼容 | 升级注意事项 |
|------|----------|--------------|
| 1.0.x → 1.1.x | ✅ 是 | 无需修改代码 |
| 1.x.x → 2.0.0 | ❌ 否 | 需要适配新API |

---

## 历史版本下载

| 版本 | 发布日期 | 下载链接 |
|------|----------|----------|
| v1.0.0 | 2026-01-30 | [Gitee Release](https://gitee.com/fluman2024/fortran_lu_solver/releases/tag/v1.0.0) |

---

## 反馈与建议

如果您在使用过程中发现问题或有改进建议，欢迎通过以下方式反馈：

- 提交 Issue: https://gitee.com/fluman2024/fortran_lu_solver/issues
- 提交 Pull Request: https://gitee.com/fluman2024/fortran_lu_solver/pulls

# Fortran 编译器
FC = gfortran
FFLAGS = -O2 -Wall -Wextra
SRCDIR = src
TESTDIR = test
APPDIR = apps
BUILDDIR = build
BINDIR = bin

# 源文件
MODULES = $(SRCDIR)/ludecomp_m.f90 $(SRCDIR)/matrix_utils.f90 $(SRCDIR)/linear_solvers.f90
TESTS = $(TESTDIR)/test_basic.f90 $(TESTDIR)/test_performance.f90
APPS = $(APPDIR)/circuit_solver.f90

# 目标文件
MODULE_OBJS = $(BUILDDIR)/ludecomp_m.o $(BUILDDIR)/matrix_utils.o $(BUILDDIR)/linear_solvers.o
TEST_BINS = $(BINDIR)/test_basic $(BINDIR)/test_performance
APP_BINS = $(BINDIR)/circuit_solver

# 默认目标
all: $(TEST_BINS) $(APP_BINS)

# 创建目录
$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BINDIR):
	mkdir -p $(BINDIR)

# 编译模块
$(BUILDDIR)/ludecomp_m.o: $(SRCDIR)/ludecomp_m.f90 | $(BUILDDIR)
	$(FC) $(FFLAGS) -c $< -o $@

$(BUILDDIR)/matrix_utils.o: $(SRCDIR)/matrix_utils.f90 $(BUILDDIR)/ludecomp_m.o | $(BUILDDIR)
	$(FC) $(FFLAGS) -c $< -o $@

$(BUILDDIR)/linear_solvers.o: $(SRCDIR)/linear_solvers.f90 $(BUILDDIR)/ludecomp_m.o $(BUILDDIR)/matrix_utils.o | $(BUILDDIR)
	$(FC) $(FFLAGS) -c $< -o $@

# 编译测试程序
$(BINDIR)/test_basic: $(TESTDIR)/test_basic.f90 $(MODULE_OBJS) | $(BINDIR)
	$(FC) $(FFLAGS) $< $(MODULE_OBJS) -o $@

$(BINDIR)/test_performance: $(TESTDIR)/test_performance.f90 $(MODULE_OBJS) | $(BINDIR)
	$(FC) $(FFLAGS) $< $(MODULE_OBJS) -o $@

# 编译应用程序
$(BINDIR)/circuit_solver: $(APPDIR)/circuit_solver.f90 $(MODULE_OBJS) | $(BINDIR)
	$(FC) $(FFLAGS) $< $(MODULE_OBJS) -o $@

# 测试
test: $(TEST_BINS)
	@echo "运行基础测试..."
	./$(BINDIR)/test_basic
	@echo "运行性能测试..."
	./$(BINDIR)/test_performance

# 清理
clean:
	rm -rf $(BUILDDIR) $(BINDIR)
	rm *.mod

# 安装依赖 (如果需要)
deps:
	@echo "Fortran 项目，无需外部依赖"

.PHONY: all test clean deps

# 数据可视化工具集

本项目提供一系列基于Matlab和Python的数据可视化工具，旨在快速生成高质量、多样化的数据图表。

## 项目结构

```text
Figure-Model/
├── Matlab/                    # Matlab可视化工具集
│   ├── test/                 # 测试脚本目录
│   │   ├── test_bubble_plot.m
│   │   ├── test_diverging_scatter.m
│   │   ├── test_filled_3D_line.m
│   │   ├── test_fill_2D_line.m
│   │   ├── test_grouped_bar.m
│   │   ├── test_grouped_line.m
│   │   ├── test_horizontal_bar.m
│   │   ├── test_horizontal_bar_gt_zero.m
│   │   ├── test_lollipop_plot.m
│   │   ├── test_nightingale_rose.m
│   │   ├── test_scatter_with_boxplot.m
│   │   └── test_scatter_with_histograms.m
│   │
│   ├── bubble_plot.m          # 气泡图
│   ├── create3DPieWithLabels.m # 3D饼图（带标签）
│   ├── diverging_scatter.m    # 发散散点图
│   ├── filled_2D_line.m       # 填充2D线图
│   ├── filled_3D_line.m       # 填充3D线图
│   ├── grouped_bar.m          # 分组柱状图
│   ├── grouped_line.m         # 分组线图
│   ├── hexColormap.m          # 十六进制颜色映射
│   ├── horizontal_bar.m       # 水平柱状图
│   ├── horizontal_bar_gt_zero.m # 正值水平柱状图
│   ├── lollipop_plot.m        # 棒棒糖图
│   ├── nightingale_rose.m     # 南丁格尔玫瑰图
│   ├── sankey_diagram.m       # 桑基图
│   ├── scatter_with_boxplot.m # 带箱线图的散点图
│   ├── scatter_with_histograms.m # 带直方图的散点图
│   ├── stackedBarWithAlluvial.m # 堆叠柱状图（含河流图元素）
│   ├── test_sankey_diagram.m  # 桑基图测试
│   └── ViolinHeatmap.m        # 小提琴热力图
│
└── Python/                    # Python可视化工具集(待完善)
    ├── bubble_plot.py
    ├── diverging_scatter.py
    ├── filled_2D_line.py
    ├── filled_3D_line.py
    ├── grouped_bar.py
    └── grouped_line.py
```

## 功能特性

### Matlab工具集

- **基础图表**: 柱状图、散点图、线图等传统图表
- **特殊图表**: 桑基图、南丁格尔玫瑰图、棒棒糖图等高级可视化
- **3D可视化**: 3D饼图、3D填充线图等
- **组合图表**: 散点图+箱线图、散点图+直方图等复合图表
- **颜色映射**: 支持自定义十六进制颜色映射

### Python工具集

- 待开发中，计划提供与Matlab工具集相对应的Python实现

## 快速开始

### Matlab使用说明

1. 将所需脚本文件添加到Matlab路径中
2. 参考对应的测试脚本了解使用方法
3. 调用相应函数并传入数据参数

## 测试说明

每个主要可视化函数都配有相应的测试脚本，位于`Matlab/test/`目录下。测试脚本提供了使用示例和参数说明。

## 贡献指南

欢迎提交Issue和Pull Request来改进本项目。对于新功能的添加，请确保：

1. 提供相应的测试脚本
2. 更新本README文档
3. 保持代码风格一致

## 许可证

本项目采用MIT许可证，详见LICENSE文件。

## 联系方式

如有问题或建议，请通过Issue提交或联系项目维护者

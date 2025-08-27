import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
from matplotlib.colors import to_rgb
import matplotlib.font_manager as fm
from datetime import datetime, timedelta
import matplotlib.dates as mdates

def filled_3D_line(data, timeVector, fill_colors=None, categories=None):
    """
    绘制三维填充折线图，每组数据位于不同的yOz平面

    输入参数:
        data: 数值矩阵，形状为 (n_time, n_cat)，每列代表一个类别的数据序列（行数代表时间点）
        timeVector: 时间向量，可以是datetime对象列表或数值向量
        fill_colors: 可选，颜色参数，可以是：
                     - None: 使用默认颜色（从 '#D9FF88' 到 '#FFFFFF' 的渐变色）
                     - 列表包含两个十六进制颜色字符串（如 ['#D9FF88', '#FFFFFF']）：生成渐变色
                     - n_cat x 3 数组：直接作为颜色映射，每行是一个 RGB 颜色（值在0-1范围内）
        categories: 可选，类别名称的列表，长度应为 n_cat

    输出:
        fig: matplotlib 图窗对象

    示例:
        n_time = 10
        n_cat = 3
        data = np.random.rand(n_time, n_cat) * 100
        timeVector = [datetime(2023, 1, 1) + timedelta(days=i) for i in range(n_time)]
        fill_colors = ['#D9FF88', '#FFFFFF']
        categories = ['Category A', 'Category B', 'Category C']
        fig = filled_3D_line(data, timeVector, fill_colors, categories)
    """
    # 参数检查
    if data is None:
        raise ValueError('必须提供 data 参数')
    data = np.array(data)
    n_time, n_cat = data.shape

    if timeVector is None or len(timeVector) != n_time:
        raise ValueError('时间向量长度必须与数据的时间点数一致')

    if categories is None:
        categories = [f'Category {i+1}' for i in range(n_cat)]
    elif len(categories) != n_cat:
        raise ValueError('categories 长度必须与 data 的列数一致')

    # 处理 fill_colors 参数
    if fill_colors is None:
        # 使用默认颜色
        hex1 = '#D9FF88'
        hex2 = '#FFFFFF'
        fill_colors = generate_color_map(hex1, hex2, n_cat)
    elif isinstance(fill_colors, list) and len(fill_colors) == 2:
        # 如果 fill_colors 是列表且有两个元素，假设是十六进制颜色
        hex1 = fill_colors[0]
        hex2 = fill_colors[1]
        fill_colors = generate_color_map(hex1, hex2, n_cat)
    else:
        # 检查 fill_colors 是否为数组
        fill_colors = np.array(fill_colors)
        if fill_colors.ndim == 2:
            if fill_colors.shape == (n_cat, 3):
                # 尺寸正确，n_cat x 3
                pass
            elif fill_colors.shape == (3, n_cat):
                fill_colors = fill_colors.T  # 转置为 n_cat x 3
            else:
                raise ValueError('fill_colors 矩阵必须是 n_cat x 3 或 3 x n_cat 的尺寸')
        else:
            raise ValueError('无效的 fill_colors 参数')
        # 归一化颜色值到 [0,1] 范围（如果值大于1）
        if np.max(fill_colors) > 1:
            fill_colors = fill_colors / 255.0

    # 将时间向量转换为数值（对于datetime对象）
    if isinstance(timeVector[0], datetime):
        timeVector_num = mdates.date2num(timeVector)
    else:
        timeVector_num = np.array(timeVector)

    # 创建三维图形
    fig = plt.figure(figsize=(12, 6), facecolor='white', dpi=100)
    ax = fig.add_subplot(111, projection='3d')
    ax.set_facecolor('white')
    fig.canvas.manager.set_window_title('三维填充折线图')

    # 设置中文字体
    ax.set_xlabel('类别', fontproperties=chinese_font)
    ax.set_ylabel('时间', fontproperties=chinese_font)
    ax.set_zlabel('销售额', fontproperties=chinese_font)

    # 设置x轴位置（每组数据在x轴上的位置）
    x_positions = np.arange(1, n_cat + 1)

    # 循环绘制每个类别
    for i in range(n_cat):
        z_data = data[:, i]
        x_i = x_positions[i]
        color_i = fill_colors[i]

        # 创建填充多边形的顶点
        # 顶部边界 (数据线)
        top_verts = list(zip([x_i] * n_time, timeVector_num, z_data))
        # 底部边界 (z=0平面)
        bottom_verts = list(zip([x_i] * n_time, timeVector_num, [0] * n_time))
        
        # 创建多边形面片
        polygons = []
        for j in range(n_time - 1):
            # 每个四边形由两个三角形组成
            # 第一个三角形
            poly1 = [top_verts[j], top_verts[j+1], bottom_verts[j+1], bottom_verts[j]]
            polygons.append(poly1)
            
        # 创建Poly3DCollection并添加到图中
        poly_collection = Poly3DCollection(polygons, alpha=0.7, linewidths=0)
        poly_collection.set_facecolor([color_i] * len(polygons))
        ax.add_collection3d(poly_collection)

        # 绘制数据线（顶部边界）
        ax.plot([x_i] * n_time, timeVector_num, z_data, color=color_i * 0.7, linewidth=1.5, label=categories[i])

        # 绘制底面边界（z=0平面）
        ax.plot([x_i] * n_time, timeVector_num, [0] * n_time, color=[0.5, 0.5, 0.5], linewidth=0.5, linestyle='--')

        # 添加侧面连接线（前后边界）
        ax.plot([x_i, x_i], [timeVector_num[0], timeVector_num[0]], [0, z_data[0]], color=[0.7, 0.7, 0.7], linewidth=0.5)
        ax.plot([x_i, x_i], [timeVector_num[-1], timeVector_num[-1]], [0, z_data[-1]], color=[0.7, 0.7, 0.7], linewidth=0.5)

    # 设置x轴刻度和标签
    ax.set_xticks(x_positions)
    ax.set_xticklabels(categories, fontproperties=chinese_font)

    # 设置y轴为时间格式
    if isinstance(timeVector[0], datetime):
        # 使用日期格式化器
        ax.yaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d'))
        
        # 自动选择合适的时间间隔
        time_min = min(timeVector)
        time_max = max(timeVector)
        time_range = time_max - time_min

        if time_range.days < 60:
            # 小于60天，显示日期间隔为每周
            ax.yaxis.set_major_locator(mdates.WeekdayLocator())
        elif time_range.days < 365:
            # 小于1年，显示月间隔
            ax.yaxis.set_major_locator(mdates.MonthLocator())
        elif time_range.days < 365 * 3:
            # 1-3年，显示季度间隔
            ax.yaxis.set_major_locator(mdates.MonthLocator(interval=3))
        else:
            # 大于3年，显示年间隔
            ax.yaxis.set_major_locator(mdates.YearLocator())
    else:
        # 数值型时间格式
        ax.set_ylabel('时间点', fontproperties=chinese_font)

    # 设置坐标轴范围
    ax.set_xlim(0, n_cat + 1)
    ax.set_ylim(min(timeVector_num), max(timeVector_num))
    ax.set_zlim(0, np.max(data) * 1.1)  # z轴从0开始，稍微扩展上限

    # 设置视角
    ax.view_init(elev=30, azim=-40)  # 对应Matlab的view(-40, 30)

    # 添加图例
    ax.legend(prop=chinese_font)

    return fig

def generate_color_map(hex1, hex2, n):
    """
    生成从 hex1 到 hex2 的渐变色图

    输入:
        hex1: 起始颜色字符串（如 '#D9FF88'）
        hex2: 结束颜色字符串（如 '#FFFFFF'）
        n: 颜色数量

    输出:
        cmap: n x 3 数组，每行是一个 RGB 颜色
    """
    rgb1 = to_rgb(hex1)
    rgb2 = to_rgb(hex2)
    r = np.linspace(rgb1[0], rgb2[0], n)
    g = np.linspace(rgb1[1], rgb2[1], n)
    b = np.linspace(rgb1[2], rgb2[2], n)
    cmap = np.column_stack((r, g, b))
    return cmap

def set_chinese_font():
    """
    尝试设置中文字体，如果失败则使用默认字体并打印警告
    """
    try:
        # 尝试使用SimHei（黑体）
        font_path = fm.findfont(fm.FontProperties(family='SimHei'))
        chinese_font = fm.FontProperties(fname=font_path)
        print("使用中文字体: SimHei")
    except:
        try:
            # 尝试使用Microsoft YaHei（微软雅黑）
            font_path = fm.findfont(fm.FontProperties(family='Microsoft YaHei'))
            chinese_font = fm.FontProperties(fname=font_path)
            print("使用中文字体: Microsoft YaHei")
        except:
            # 如果还是失败，使用默认字体并警告
            chinese_font = fm.FontProperties()
            print("警告: 未找到中文字体，使用默认字体，中文可能显示异常")
    return chinese_font

# 全局中文字体设置
chinese_font = set_chinese_font()

if __name__ == '__main__':
    # 测试 filled_3D_line 函数，基于附件 test_filled_3D_line.m
    np.random.seed(42)  # 设置随机种子以确保可重现

    n_time = 10  # 时间点数
    n_cat = 3    # 类别数
    data = np.random.rand(n_time, n_cat) * 100  # 随机数据，范围0-100

    # 创建时间向量：使用datetime对象
    start_date = datetime(2023, 1, 1)
    timeVector = [start_date + timedelta(days=i) for i in range(n_time)]

    categories = ['Category A', 'Category B', 'Category C']  # 类别名称

    # 指定十六进制颜色
    hex1 = '#D9FF88'
    hex2 = '#FFFFFF'
    fill_colors = [hex1, hex2]  # 作为列表传递

    # 调用函数
    fig = filled_3D_line(data, timeVector, fill_colors, categories)
    plt.title('三维填充折线图测试', fontproperties=chinese_font)
    plt.show()

    # 输出数据信息
    print('测试数据统计:')
    print(f'时间点数: {n_time}')
    print(f'类别数: {n_cat}')
    print(f'数据范围: [{np.min(data):.2f}, {np.max(data):.2f}]')
    print(f'时间范围: {timeVector[0]} 到 {timeVector[-1]}')

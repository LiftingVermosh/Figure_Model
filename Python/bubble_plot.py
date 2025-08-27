import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
from matplotlib.colors import LinearSegmentedColormap, to_rgb
import matplotlib.font_manager as fm

def bubble_plot(points, v, colormap_param=None, r=10, alpha_value=0.6):
    """
    绘制气泡图
    该函数根据点的坐标和数值向量绘制气泡图，气泡半径由数值向量归一化后缩放，颜色可自定义。

    输入参数：
        points: 2 x n 或 n x 2 数组，表示 n 个点的 [x, y] 坐标。
        v: 1 x n 或 n x 1 数值向量，用于控制气泡半径的缩放。
        colormap_param: 可选，颜色参数，可以是：
                        - None 或缺失：所有点使用默认颜色（从 '#00F260' 到 '#0575E6' 的渐变色，基于 x 轴映射）
                        - 2元素列表或元组：使用 create_hex_colormap 生成从 hex1 到 hex2 的渐变色，并基于 x 轴映射颜色
                        - n元素列表：每个元素是颜色字符串（如 '#ff0000'）或 RGB 元组（如 (1.0, 0.0, 0.0)），按索引直接使用
                        - n x 3 数组：直接作为颜色映射，每行是一个 RGB 颜色
        r: 可选，基础半径值，默认值为 10。实际半径为 r * v_nor_i。
        alpha_value: 可选，透明度值，范围 0-1，默认值为 0.6。

    输出：
        fig: matplotlib 图窗对象

    示例：
        points = np.array([[1, 2], [3, 4], [5, 6]])  # 3x2 数组，三个点
        v = np.array([0.1, 0.5, 0.9])  # 3x1 向量
        colormap_param = ['#ff0000', '#0000ff']  # 红到蓝渐变
        r = 15
        alpha_value = 0.5
        fig = bubble_plot(points, v, colormap_param, r, alpha_value)
    """
    # 参数检查：必须提供 points 和 v
    if points is None or v is None:
        raise ValueError('必须提供 points 和 v 参数')
    
    # 将 points 转换为 numpy 数组以便处理
    points = np.array(points)
    v = np.array(v)
    
    # 检查 points 是否为 2xn 或 nx2 数组
    if points.ndim != 2 or (points.shape[0] != 2 and points.shape[1] != 2):
        raise ValueError('points 必须是 2 x n 或 n x 2 数组')
    
    # 统一 points 为 n x 2 数组（每行是一个点 [x, y]）
    if points.shape[0] == 2:
        n = points.shape[1]
        points = points.T  # 转置为 n x 2
    else:
        n = points.shape[0]
        if points.shape[1] != 2:
            raise ValueError('points 必须是 2 x n 或 n x 2 数组')
    
    # 检查 v 是否为向量且长度匹配 points 的点数 n
    if v.ndim != 1 or len(v) != n:
        raise ValueError('v 必须是长度为 n 的向量')
    v = v.flatten()  # 确保 v 是一维数组
    
    # 归一化 v: v_nor = (v - min(v)) / (max(v) - min(v))
    v_min = np.min(v)
    v_max = np.max(v)
    if v_max == v_min:
        # 如果所有 v 值相同，设置 v_nor 为 0.5 避免除零
        v_nor = 0.5 * np.ones_like(v)
    else:
        v_nor = (v - v_min) / (v_max - v_min)
    
    # 处理可选参数 colormap_param、r、alpha_value
    if colormap_param is None:
        colormap_param = []  # 设置为空列表以触发默认颜色处理
    
    # 颜色处理逻辑
    if colormap_param is None or (isinstance(colormap_param, list) and len(colormap_param) == 0):
        # 默认颜色：使用从 '#00F260' 到 '#0575E6' 的渐变色，基于 x 轴映射
        hex1 = '#00F260'
        hex2 = '#0575E6'
        cmap = create_hex_colormap(hex1, hex2, n_colors=256)
        x_coords = points[:, 0]
        x_min = np.min(x_coords)
        x_max = np.max(x_coords)
        if x_max == x_min:
            # 所有 x 相同，使用颜色图中间颜色
            color_val = 0.5
            colors = cmap(color_val)[:3]  # 获取 RGB，忽略 alpha
            colors = np.tile(colors, (n, 1))
        else:
            pos = (x_coords - x_min) / (x_max - x_min)
            colors = cmap(pos)[:, :3]  # 获取每个点的 RGB，忽略 alpha
    elif isinstance(colormap_param, (list, tuple)) and (len(colormap_param) == 2 or len(colormap_param) == 3):
        # 两个颜色列表：生成渐变色图并基于 x 轴映射
        hex1 = colormap_param[0]
        hex2 = colormap_param[1]
        n_colors = 256
        cmap = create_hex_colormap(hex1, hex2, n_colors)
        x_coords = points[:, 0]
        x_min = np.min(x_coords)
        x_max = np.max(x_coords)
        if x_max == x_min:
            color_val = 0.5
            colors = cmap(color_val)[:3]
            colors = np.tile(colors, (n, 1))
        else:
            pos = (x_coords - x_min) / (x_max - x_min)
            colors = cmap(pos)[:, :3]
    elif isinstance(colormap_param, (list, tuple)) and len(colormap_param) == n:
        # n 个颜色列表：直接使用指定颜色
        colors = np.zeros((n, 3))
        for i in range(n):
            if isinstance(colormap_param[i], str):
                # 转换 hex 字符串为 RGB
                colors[i, :] = to_rgb(colormap_param[i])
            elif isinstance(colormap_param[i], (list, tuple)) and len(colormap_param[i]) == 3:
                # 直接使用 RGB 元组或列表
                colors[i, :] = colormap_param[i]
            else:
                raise ValueError('colormap_param 列表元素必须是颜色字符串或 RGB 元组')
    elif isinstance(colormap_param, np.ndarray) and colormap_param.shape == (n, 3):
        # n x 3 数组：直接作为颜色映射
        colors = colormap_param
    else:
        raise ValueError('无效的 colormap_param 参数')
    
    # 创建图窗
    fig, ax = plt.subplots(figsize=(8, 6), facecolor='white', dpi=200)
    ax.set_facecolor('white')
    fig.canvas.manager.set_window_title('气泡图')
    
    # 绘制每个点作为气泡（圆）
    for i in range(n):
        x_i = points[i, 0]
        y_i = points[i, 1]
        rad_i = r * v_nor[i]  # 计算实际半径
        color_i = colors[i, :]
        
        # 使用 Circle patch 绘制圆
        circle = Circle((x_i, y_i), rad_i, color=color_i, alpha=alpha_value, edgecolor='none')
        ax.add_patch(circle)
    
    # 设置轴标签和标题（使用中文）
    ax.set_xlabel('X 坐标', fontproperties=chinese_font)
    ax.set_ylabel('Y 坐标', fontproperties=chinese_font)
    ax.set_title('气泡图', fontproperties=chinese_font)
    
    # 调整轴范围以适应所有气泡，考虑半径
    x_coords = points[:, 0]
    y_coords = points[:, 1]
    max_rad = np.max(r * v_nor)  # 最大半径
    x_min = np.min(x_coords) - max_rad
    x_max = np.max(x_coords) + max_rad
    y_min = np.min(y_coords) - max_rad
    y_max = np.max(y_coords) + max_rad
    ax.set_xlim(x_min, x_max)
    ax.set_ylim(y_min, y_max)
    ax.set_aspect('equal')  # 保持纵横比
    
    return fig

def create_hex_colormap(hex1, hex2, n_colors=256):
    """
    创建从 hex1 到 hex2 的渐变色图
    输入：hex1 和 hex2 为颜色字符串，n_colors 为颜色数量
    输出：LinearSegmentedColormap 对象
    """
    rgb1 = to_rgb(hex1)
    rgb2 = to_rgb(hex2)
    cmap = LinearSegmentedColormap.from_list('custom_cmap', [rgb1, rgb2], n_colors)
    return cmap

# 设置中文字体支持
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
        # 如果找不到SimHei，尝试其他中文字体或默认字体
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
    # 测试气泡图函数 bubble_plot
    # 设置随机种子以确保结果可重现
    np.random.seed(42)
    
    # 生成 n 个随机点 (x, y)
    n = 200
    x = np.random.rand(n) * 100  # x坐标在0-100之间
    y = np.random.rand(n) * 100  # y坐标在0-100之间
    points = np.column_stack((x, y))
    
    # 生成权重向量v，模拟不同大小的气泡
    # 使用正态分布生成权重，然后归一化到0-1范围
    v = np.abs(np.random.randn(n))
    v = (v - np.min(v)) / (np.max(v) - np.min(v))
    
    # 设置基础半径和透明度
    r = 5
    alpha_value = 0.6
    
    # 测试用例1: 使用默认颜色
    fig1 = bubble_plot(points, v, None, r, alpha_value)  # 使用 None 而不是 {}
    plt.title('测试用例1: 默认颜色', fontproperties=chinese_font)
    plt.show()
    
    # 测试用例2: 使用双色渐变，基于x轴映射
    colormap_param2 = ['#009FFF', '#EC2F4B']  # 蓝到红渐变
    fig2 = bubble_plot(points, v, colormap_param2, r, alpha_value)
    plt.title('测试用例2: 蓝到红渐变 (基于x轴映射)', fontproperties=chinese_font)
    plt.show()
    
    # 测试用例3: 使用三色渐变，基于x轴映射
    colormap_param3 = ['#FEAC5E', '#C779D0', '#4BC0C8']  # 3色渐变
    fig3 = bubble_plot(points, v, colormap_param3, r, alpha_value)
    plt.title('测试用例3: 3色渐变 (基于x轴映射)', fontproperties=chinese_font)
    plt.show()
    
    # 测试用例4: 为每个点指定单独的颜色
    # 生成随机颜色
    colors = np.random.rand(n, 3)  # 生成n个RGB颜色
    colormap_param4 = [tuple(color) for color in colors]  # 转换为列表 of tuples
    fig4 = bubble_plot(points, v, colormap_param4, r, alpha_value)
    plt.title('测试用例4: 随机颜色 (每个点单独指定)', fontproperties=chinese_font)
    plt.show()
    
    # 测试用例5: 使用预定义的彩虹色
    # 生成彩虹色映射
    rainbow_colors = plt.cm.hsv(np.linspace(0, 1, n))[:, :3]  # 使用HSV颜色空间生成彩虹色，忽略alpha
    colormap_param5 = rainbow_colors
    fig5 = bubble_plot(points, v, colormap_param5, r, alpha_value)
    plt.title('测试用例5: 彩虹色', fontproperties=chinese_font)
    plt.show()
    
    # 测试用例6: 使用不同的半径和透明度
    r_large = 8  # 更大的半径
    alpha_low = 0.3  # 更低的透明度
    fig6 = bubble_plot(points, v, colormap_param2, r_large, alpha_low)
    plt.title('测试用例6: 更大半径和更低透明度', fontproperties=chinese_font)
    plt.show()
    
    # 显示数据统计信息
    print('测试数据统计:')
    print(f'点数: {n}')
    print(f'x坐标范围: [{np.min(x):.2f}, {np.max(x):.2f}]')
    print(f'y坐标范围: [{np.min(y):.2f}, {np.max(y):.2f}]')
    print(f'权重范围: [{np.min(v):.2f}, {np.max(v):.2f}]')
    print(f'基础半径: {r:.2f}')
    print(f'透明度: {alpha_value:.2f}')

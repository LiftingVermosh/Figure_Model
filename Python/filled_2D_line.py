import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import to_rgb, LinearSegmentedColormap
import matplotlib.font_manager as fm
from matplotlib.patches import Polygon

def filled_2D_line(data_matrix, colormap_param=None):
    """
    绘制带颜色映射和填充的线图
    该函数绘制 n 条线，每条线有 m 个点，并根据颜色参数设置线条颜色和填充区域。

    输入参数：
        data_matrix: n x m x 2 数组，表示 n 条线，每条线有 m 个二维点 [x, y]。
        colormap_param: 可选，颜色参数，可以是：
                        - None 或缺失：使用从红到紫的色环过渡色，映射到 x 轴
                        - 2元素列表：使用 create_hex_colormap 生成渐变色，并映射到 x 轴
                        - n元素列表：每个元素是颜色字符串（如 '#ff0000'），按索引直接使用
                        - n x 3 数组：直接作为颜色映射，每行是一个 RGB 颜色

    输出：
        fig: matplotlib 图窗对象

    示例：
        data = np.random.rand(3, 10, 2)  # 3条线，每条10个点
        colormap_param = ['#ff6e7f', '#bfe9ff']
        fig = filled_2D_line(data, colormap_param)
    """
    # 参数检查
    if data_matrix is None:
        raise ValueError('必须提供 data_matrix 参数')
    
    data_matrix = np.array(data_matrix)
    # 检查 data_matrix 是否为 n x m x 2 数组
    if data_matrix.ndim != 3 or data_matrix.shape[2] != 2:
        raise ValueError('data_matrix 必须是 n x m x 2 数组')
    
    n = data_matrix.shape[0]  # 线的数量
    m = data_matrix.shape[1]  # 每条线的点数
    
    # 处理颜色参数 colormap_param
    if colormap_param is None:
        # 默认情况：使用从红到紫的色环过渡色，映射到 x 轴
        x_all = data_matrix[:, :, 0]
        x_nonzero = x_all[x_all != 0]
        if len(x_nonzero) == 0:
            x_min = 0
            x_max = 1
        else:
            x_min = np.min(x_nonzero)
            x_max = np.max(x_nonzero)
        
        line_colors = np.zeros((n, 3))
        for i in range(n):
            x = data_matrix[i, :, 0]
            valid_indices = x != 0
            x_valid = x[valid_indices]
            
            if len(x_valid) > 0:
                x_start = x_valid[0]  # 每条线起点的 x 坐标
                norm_x = (x_start - x_min) / (x_max - x_min)
                norm_x = max(0, min(1, norm_x))  # 限制在 [0,1] 范围内
                
                # 使用HSV颜色空间创建从红到紫的色环过渡
                # 红色: H=0, 紫色: H≈0.83 (300°/360°)
                hue = norm_x * 0.83
                saturation = 1
                value = 1
                # 将HSV转换为RGB
                line_colors[i, :] = hsv_to_rgb(hue, saturation, value)
            else:
                line_colors[i, :] = [0.5, 0.5, 0.5]  # 默认灰色
    elif isinstance(colormap_param, list) and len(colormap_param) == 2:
        # 两个颜色元素：生成渐变色并映射到 x 轴
        hex1 = colormap_param[0]
        hex2 = colormap_param[1]
        x_all = data_matrix[:, :, 0]
        x_nonzero = x_all[x_all != 0]
        if len(x_nonzero) == 0:
            x_min = 0
            x_max = 1
        else:
            x_min = np.min(x_nonzero)
            x_max = np.max(x_nonzero)
        
        cmap = create_hex_colormap(hex1, hex2, 256)
        line_colors = np.zeros((n, 3))
        for i in range(n):
            x = data_matrix[i, :, 0]
            valid_indices = x != 0
            x_valid = x[valid_indices]
            
            if len(x_valid) > 0:
                x_start = x_valid[0]
                norm_x = (x_start - x_min) / (x_max - x_min)
                norm_x = max(0, min(1, norm_x))
                idx = int(round(norm_x * 255))  # 映射到颜色索引 (0-255)
                line_colors[i, :] = cmap(idx)[:3]  # 获取RGB，忽略alpha
            else:
                line_colors[i, :] = [0.5, 0.5, 0.5]
    elif isinstance(colormap_param, list) and len(colormap_param) == n:
        # n 个颜色元素：直接使用提供的颜色
        line_colors = np.zeros((n, 3))
        for i in range(n):
            if isinstance(colormap_param[i], str):
                line_colors[i, :] = to_rgb(colormap_param[i])
            elif isinstance(colormap_param[i], (list, tuple)) and len(colormap_param[i]) == 3:
                line_colors[i, :] = colormap_param[i]
            else:
                raise ValueError('colormap_param 列表元素必须是颜色字符串或 RGB 元组')
    elif isinstance(colormap_param, np.ndarray) and colormap_param.shape[1] == 3 and colormap_param.shape[0] >= n:
        # n x 3 数组：直接使用前 n 行作为颜色
        line_colors = colormap_param[:n, :]
    else:
        raise ValueError('无效的 colormap_param 参数')
    
    # 创建图窗
    fig, ax = plt.subplots(figsize=(8, 6), facecolor='white', dpi=200)
    ax.set_facecolor('white')
    fig.canvas.manager.set_window_title('线图带填充')
    
    # 设置填充透明度
    fill_alpha = 0.3
    
    # 遍历每条线
    for i in range(n):
        x = data_matrix[i, :, 0]  # 当前线的 x 坐标
        y = data_matrix[i, :, 1]  # 当前线的 y 坐标
        
        # 找出有效点（非零）
        valid_indices = x != 0
        x_valid = x[valid_indices]
        y_valid = y[valid_indices]
        
        if len(x_valid) == 0:
            continue  # 跳过没有有效点的线
        
        color = line_colors[i, :]  # 当前线的颜色
        
        # 生成较浅的颜色用于填充
        lighter_color = color + np.array([0.3, 0.3, 0.3])
        lighter_color = np.clip(lighter_color, 0, 1)  # 确保颜色值不超过 1
        
        # 绘制线条
        ax.plot(x_valid, y_valid, color=color, linewidth=2)
        
        # 填充区域：从曲线到x轴
        # 创建填充的多边形：x_valid 和 y_valid 为上线，x_valid 和 zeros 为下线
        x_fill = np.concatenate([x_valid, x_valid[::-1]])  # [x_valid, reverse(x_valid)]
        y_fill = np.concatenate([y_valid, np.zeros_like(x_valid)])  # [y_valid, zeros]
        poly = Polygon(np.column_stack((x_fill, y_fill)), facecolor=lighter_color, edgecolor='none', alpha=fill_alpha)
        ax.add_patch(poly)
    
    # 设置轴标签和标题（使用中文）
    ax.set_xlabel('X 坐标', fontproperties=chinese_font)
    ax.set_ylabel('Y 坐标', fontproperties=chinese_font)
    ax.set_title('带颜色映射和填充的线图', fontproperties=chinese_font)
    
    # 调整轴范围以适应数据
    x_all = data_matrix[:, :, 0]
    y_all = data_matrix[:, :, 1]
    x_nonzero = x_all[x_all != 0]
    y_nonzero = y_all[y_all != 0]
    if len(x_nonzero) == 0 or len(y_nonzero) == 0:
        x_min = 0
        x_max = 1
        y_min = 0
        y_max = 1
    else:
        x_min = np.min(x_nonzero)
        x_max = np.max(x_all)
        y_min = np.min(y_nonzero)
        y_max = np.max(y_all)
    
    x_range = x_max - x_min
    y_range = y_max - y_min
    ax.set_xlim(x_min - 0.1 * x_range, x_max + 0.1 * x_range)
    ax.set_ylim(y_min, y_max + 0.1 * y_range)
    
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

def hsv_to_rgb(h, s, v):
    """
    将HSV颜色转换为RGB颜色
    输入：h (色调, 0-1), s (饱和度, 0-1), v (值, 0-1)
    输出：RGB元组 (r, g, b)，每个值在0-1之间
    """
    # 基于标准HSV到RGB转换算法
    if s == 0:
        return (v, v, v)
    
    i = int(h * 6)
    f = (h * 6) - i
    p = v * (1 - s)
    q = v * (1 - s * f)
    t = v * (1 - s * (1 - f))
    
    if i % 6 == 0:
        r, g, b = v, t, p
    elif i % 6 == 1:
        r, g, b = q, v, p
    elif i % 6 == 2:
        r, g, b = p, v, t
    elif i % 6 == 3:
        r, g, b = p, q, v
    elif i % 6 == 4:
        r, g, b = t, p, v
    else:
        r, g, b = v, p, q
    
    return (r, g, b)

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
    # 测试 filled_2D_line 函数，基于 test_fill_2D_line.m 的内容
    np.random.seed(44)  # 设置随机种子以确保结果可重现
    
    # 参数设置
    n = 10  # 线段数量
    min_points = 500  # 每条线段最少点数
    max_points = 1000  # 每条线段最多点数
    x_min_global = 0  # x坐标全局最小值
    x_max_global = 200  # x坐标全局最大值
    
    # 生成测试数据 - 正态分布样式且起始点都在x轴
    data_matrix = np.zeros((n, max_points, 2))  # 预分配空间
    
    for i in range(n):
        # 随机确定当前线段的点数
        m = np.random.randint(min_points, max_points + 1)
        
        # 随机生成起始点和结束点，确保在0~200之间且起始点都在x轴
        x_start = np.random.rand() * (x_max_global - 50)  # 起始点随机，留有余地确保结束点<=200
        x_end = x_start + np.random.rand() * (x_max_global - x_start)
        x_end = min(x_end, x_max_global)  # 确保结束点不超过200
        
        # 生成x坐标 - 在起始点和结束点之间均匀分布
        x = np.linspace(x_start, x_end, m)
        
        # 生成y坐标 - 使用正态分布样式，确保起始点和结束点都在x轴(y=0)
        x_mid = (x_start + x_end) / 2
        sigma = (x_end - x_start) / 6  # 计算标准差，控制曲线的宽度
        y = np.random.rand() * 20 * np.exp(-(x - x_mid)**2 / (2 * sigma**2))  # 振幅最大为20
        
        # 将数据存入矩阵
        data_matrix[i, :m, 0] = x
        data_matrix[i, :m, 1] = y
        
        # 剩余部分填充0（函数会跳过0值点）
        if m < max_points:
            data_matrix[i, m:, :] = 0
    
    # 测试1：使用默认颜色（从红到紫的色环过渡）
    print('测试1：使用默认颜色（从红到紫的色环过渡）')
    fig1 = filled_2D_line(data_matrix, None)
    plt.title('测试1：使用默认颜色（从红到紫的色环过渡）', fontproperties=chinese_font)
    plt.show()
    
    # 测试2：使用两个颜色的渐变映射到x轴
    print('测试2：使用两个颜色的渐变映射到x轴')
    colormap_param2 = ['#ff6e7f', '#bfe9ff']  # 粉红色到淡蓝色的渐变
    fig2 = filled_2D_line(data_matrix, colormap_param2)
    plt.title('测试2：使用两个颜色的渐变映射到x轴', fontproperties=chinese_font)
    plt.show()
    
    print('所有测试完成！')

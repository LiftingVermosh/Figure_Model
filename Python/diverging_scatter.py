import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import to_rgb
import matplotlib.font_manager as fm

def diverging_scatter(center_points, data_matrix, colormap_param, center_visible):
    """
    绘制发散PCA散点图（二维点版本）
    该函数绘制发散散点图，每个类有一个二维中心点，多个二维数据点，并用线连接中心点与数据点。

    输入参数：
        center_points: 2 x n 或 n x 2 数组，表示 n 个二维中心点。每列或每行是一个中心点的 [x, y] 坐标。
        data_matrix: n x m x 2 数组，表示数据点。n 是类数，m 是每个类的点数，第三维是坐标 [x, y]。
                     空值用 [0, 0] 表示，会被跳过。
        colormap_param: 颜色参数，可以是：
                        - None：使用默认颜色渐变
                        - 2元素列表：使用 generate_gradient_colors 生成渐变色，并均匀采样 n 个颜色
                        - n元素列表：每个元素是颜色字符串（如 '#ff0000'）或 RGB 元组（如 (1.0, 0.0, 0.0)），按索引直接使用
                        - n x 3 数组：直接作为颜色映射，每行是一个 RGB 颜色
        center_visible: 布尔值或 0/1，控制中心点是否可见

    输出：
        fig: matplotlib 图窗对象

    示例：
        center_points = np.array([[1, 2], [3, 4]])  # 2x2 数组，两个中心点
        data_matrix = np.array([[[5, 6], [7, 8]], [[9, 10], [11, 12]]])  # 2x2x2 数组
        colormap_param = ['#ff6e7f', '#bfe9ff']
        center_visible = True
        fig = diverging_scatter(center_points, data_matrix, colormap_param, center_visible)
    """
    # 参数检查：必须提供所有参数
    if center_points is None or data_matrix is None or colormap_param is None or center_visible is None:
        raise ValueError('必须提供所有参数')
    
    # 将输入转换为 numpy 数组
    center_points = np.array(center_points)
    data_matrix = np.array(data_matrix)
    
    # 检查 center_points 是否为 2xn 或 nx2 数组
    if center_points.ndim != 2 or (center_points.shape[0] != 2 and center_points.shape[1] != 2):
        raise ValueError('center_points 必须是 2 x n 或 n x 2 数组')
    
    # 统一 center_points 为 n x 2 数组（每行是一个中心点）
    if center_points.shape[0] == 2:
        n = center_points.shape[1]
        center_points = center_points.T  # 转置为 n x 2
    else:
        n = center_points.shape[0]
        if center_points.shape[1] != 2:
            raise ValueError('center_points 必须是 2 x n 或 n x 2 数组')
    
    # 检查 data_matrix 是否为 n x m x 2 数组
    if data_matrix.ndim != 3 or data_matrix.shape[2] != 2:
        raise ValueError('data_matrix 必须是 n x m x 2 数组')
    if data_matrix.shape[0] != n:
        raise ValueError('data_matrix 的第一个维度必须与 center_points 的类数 n 一致')
    m = data_matrix.shape[1]  # 每个类的点数
    
    # 检查 center_visible 是否为布尔值或 0/1
    if isinstance(center_visible, int):
        if center_visible == 0 or center_visible == 1:
            center_visible = bool(center_visible)
        else:
            raise ValueError('center_visible 必须是布尔值或 0/1')
    elif not isinstance(center_visible, bool):
        raise ValueError('center_visible 必须是布尔值或 0/1')
    
    # 处理颜色参数
    if colormap_param is None:
        # 默认颜色：使用特定颜色或渐变色
        if n <= 5:
            hex_colors = ['#37FF00', '#00FFB3', '#FF5100', '#9000FF', '#D2D900']
            groupColors = np.array([to_rgb(hex) for hex in hex_colors])
            groupColors = groupColors[:n]  # 取前 n 个颜色
        else:
            hex1 = '#00FFB3'
            hex2 = '#A64568'
            groupColors = generate_gradient_colors(hex1, hex2, n)
    elif isinstance(colormap_param, np.ndarray) and colormap_param.shape[1] == 3:
        # 如果 colormap_param 是 n x 3 数组，直接使用或采样
        if colormap_param.shape[0] < n:
            raise ValueError('colormap_param 数组的行数必须至少为 n')
        indices = np.round(np.linspace(0, colormap_param.shape[0]-1, n)).astype(int)
        groupColors = colormap_param[indices, :]
    elif isinstance(colormap_param, list):
        num_colors = len(colormap_param)
        if num_colors == 2:
            # 使用两个颜色生成渐变色
            hex1 = colormap_param[0]
            hex2 = colormap_param[1]
            groupColors = generate_gradient_colors(hex1, hex2, n)
        elif num_colors == n:
            # 直接使用 n 个颜色
            groupColors = np.zeros((n, 3))
            for i in range(n):
                if isinstance(colormap_param[i], str):
                    groupColors[i, :] = to_rgb(colormap_param[i])
                elif isinstance(colormap_param[i], (list, tuple)) and len(colormap_param[i]) == 3:
                    groupColors[i, :] = colormap_param[i]
                else:
                    raise ValueError('colormap_param 列表元素必须是颜色字符串或 RGB 元组')
        else:
            raise ValueError('colormap_param 列表必须包含 2 个或 n 个元素')
    else:
        raise ValueError('colormap_param 必须是 None、列表或 n x 3 数组')
    
    # 创建图窗
    fig, ax = plt.subplots(figsize=(8, 6))
    ax.set_facecolor('white')
    fig.patch.set_facecolor('white')
    fig.canvas.manager.set_window_title('发散聚类散点图')
    
    # 设置中文字体
    chinese_font = set_chinese_font()
    
    # 设置透明度参数
    line_alpha = 0.3
    point_alpha = 0.75
    
    # 收集所有点的坐标用于设置轴范围
    all_x = center_points[:, 0].tolist()
    all_y = center_points[:, 1].tolist()
    
    # 遍历每个类
    for k in range(n):
        center = center_points[k, :]
        color = groupColors[k, :]
        
        # 生成连线颜色（较浅）
        lineColor = color + 0.3
        lineColor = np.clip(lineColor, 0, 0.9)
        
        # 生成数据点颜色（较浅）
        lightColor = color + 0.15
        lightColor = np.clip(lightColor, 0, 0.8)
        
        # 生成中心点颜色（较深）
        darkerColor = color * 0.9
        darkerColor = np.clip(darkerColor, 0, 1)
        
        # 获取当前类的数据点
        data_points = data_matrix[k, :, :].reshape(m, 2)
        
        # 遍历每个数据点
        for j in range(m):
            point = data_points[j, :]
            if not np.all(point == 0):  # 跳过空值 [0, 0]
                # 绘制连接线
                ax.plot([center[0], point[0]], [center[1], point[1]], color=lineColor, alpha=line_alpha, linewidth=3)
                # 绘制数据点
                ax.scatter(point[0], point[1], s=150, marker='o', linewidth=2, edgecolor='white', facecolor=lightColor, alpha=point_alpha)
                # 添加坐标到列表
                all_x.append(point[0])
                all_y.append(point[1])
        
        # 绘制中心点
        if center_visible:
            ax.scatter(center[0], center[1], s=80, marker='o', edgecolor='white', facecolor=darkerColor)
    
    # 设置轴标签
    ax.set_xlabel('X 坐标', fontproperties=chinese_font)
    ax.set_ylabel('Y 坐标', fontproperties=chinese_font)
    
    # 设置轴范围
    all_x = np.array(all_x)
    all_y = np.array(all_y)
    if len(all_x) > 0 and len(all_y) > 0:
        x_min = np.min(all_x)
        x_max = np.max(all_x)
        y_min = np.min(all_y)
        y_max = np.max(all_y)
        x_range = x_max - x_min
        y_range = y_max - y_min
        margin_x = 0.1 * x_range
        margin_y = 0.1 * y_range
        ax.set_xlim(x_min - margin_x, x_max + margin_x)
        ax.set_ylim(y_min - margin_y, y_max + margin_y)
    
    return fig

def generate_gradient_colors(hex1, hex2, n):
    """
    生成从 hex1 到 hex2 的渐变色列表
    输入：hex1 和 hex2 为颜色字符串，n 为颜色数量
    输出：n x 3 的 RGB 数组
    """
    rgb1 = to_rgb(hex1)
    rgb2 = to_rgb(hex2)
    colors = []
    for i in range(n):
        t = i / (n-1) if n > 1 else 0.5
        r = rgb1[0] * (1-t) + rgb2[0] * t
        g = rgb1[1] * (1-t) + rgb2[1] * t
        b = rgb1[2] * (1-t) + rgb2[2] * t
        colors.append([r, g, b])
    return np.array(colors)

def set_chinese_font():
    """
    设置中文字体，如果失败则使用默认字体并打印警告
    返回：FontProperties 对象
    """
    try:
        font_path = fm.findfont(fm.FontProperties(family='SimHei'))
        chinese_font = fm.FontProperties(fname=font_path)
        print("使用中文字体: SimHei")
    except:
        try:
            font_path = fm.findfont(fm.FontProperties(family='Microsoft YaHei'))
            chinese_font = fm.FontProperties(fname=font_path)
            print("使用中文字体: Microsoft YaHei")
        except:
            chinese_font = fm.FontProperties()
            print("警告: 未找到中文字体，使用默认字体，中文可能显示异常")
    return chinese_font

# 测试代码
if __name__ == '__main__':
    # 示例测试
    center_points = np.array([[1, 2], [3, 4]])  # 2个中心点
    data_matrix = np.array([[[5, 6], [7, 8]], [[9, 10], [11, 12]]])  # 2类，每类2个点
    colormap_param = ['#ff6e7f', '#bfe9ff']  # 2颜色渐变
    center_visible = True
    fig = diverging_scatter(center_points, data_matrix, colormap_param, center_visible)
    plt.show()

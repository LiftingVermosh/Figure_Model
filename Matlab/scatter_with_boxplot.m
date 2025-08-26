function fig = scatter_with_boxplot(data_matrix, colormap_param)
    % SCATTER_WITH_BOXPLOT 绘制散点图并添加箱线图以探索分布
    %   输入：
    %       data_matrix: n x 2 矩阵，每行是一个数据点的 [x, y] 坐标
    %       colormap_param: 颜色参数，可选。如果缺失或空，使用默认颜色图；
    %                      如果为2元素单元数组，生成从第一个颜色到第二个颜色的渐变色图，并映射到x轴
    %   输出：
    %       fig: 图窗对象句柄
    %
    %   示例：
    %       data = randn(100, 2); % 生成随机数据
    %       colormap_param = {'#ff0000', '#0000ff'}; % 红到蓝的渐变
    %       fig = scatter_with_boxplot(data, colormap_param);

    % 参数检查
    if nargin < 2
        colormap_param = []; % 如果缺失颜色参数，设置为空
    end
    
    % 检查 data_matrix 是否为 n x 2 矩阵
    if ~ismatrix(data_matrix) || size(data_matrix, 2) ~= 2
        error('data_matrix 必须是 n x 2 矩阵');
    end
    
    n = size(data_matrix, 1); % 数据点数量
    x = data_matrix(:, 1); % 提取 x 坐标
    y = data_matrix(:, 2); % 提取 y 坐标
    
    % 处理颜色参数
    if isempty(colormap_param)
        % 使用默认颜色图（parula），并设置箱线图颜色为默认蓝色
        num_colors = 256; % 颜色图分辨率
        cmap = parula(num_colors);
        box_color = [0, 0.4470, 0.7410]; % MATLAB 默认蓝色
    elseif iscell(colormap_param) && numel(colormap_param) == 2
        % 如果颜色参数为2元素单元数组，生成渐变色图
        color1 = colormap_param{1};
        color2 = colormap_param{2};
        num_colors = 256;
        % 转换颜色到 RGB
        if ischar(color1)
            color1_rgb = hex2rgb(color1);
        else
            color1_rgb = color1; % 假设为 RGB 向量
        end
        if ischar(color2)
            color2_rgb = hex2rgb(color2);
        else
            color2_rgb = color2;
        end
        % 生成从 color1 到 color2 的渐变色图
        cmap = [linspace(color1_rgb(1), color2_rgb(1), num_colors)', ...
                linspace(color1_rgb(2), color2_rgb(2), num_colors)', ...
                linspace(color1_rgb(3), color2_rgb(3), num_colors)'];
        box_color = color1_rgb; % 箱线图使用第一个颜色
    else
        error('colormap_param 必须为空或2元素单元数组');
    end
    
    % 创建图窗 - 增大整个图窗尺寸以提供更多空间
    fig = figure('Color', 'w', 'Name', '散点图与箱线图', 'Position', [100, 100, 900, 700]);
    
    % 设置子图位置：增大箱线图区域
    % 主散点图位置调整，为箱线图腾出更多空间
    ax_scatter = subplot('Position', [0.1, 0.35, 0.5, 0.55]); % 减小散点图宽度
    
    % 增大右侧箱线图区域
    ax_boxy = subplot('Position', [0.65, 0.35, 0.25, 0.55]); % 增大宽度和高度
    
    % 增大下方箱线图区域
    ax_boxx = subplot('Position', [0.1, 0.1, 0.5, 0.2]); % 保持宽度，稍微增大高度
    
    % 在主散点图上绘制
    axes(ax_scatter);
    % 计算 x 范围用于颜色映射
    x_min = min(x);
    x_max = max(x);
    x_range = x_max - x_min;
    if x_range == 0
        x_range = 1; % 避免除零
    end
    % 归一化 x 值到 [0,1] 并计算颜色索引
    norm_x = (x - x_min) / x_range;
    color_indices = round(norm_x * (num_colors - 1)) + 1; % 索引从 1 到 num_colors
    colors = cmap(color_indices, :); % 获取每个点的颜色
    
    scatter(x, y, 50, colors, 'filled'); % 绘制散点图，点大小50，填充颜色
    grid on;
    
    % 设置散点图的轴范围，添加10%边距
    xlim([x_min - 0.1 * x_range, x_max + 0.1 * x_range]);
    y_min_val = min(y);
    y_max_val = max(y);
    y_range_val = y_max_val - y_min_val;
    if y_range_val == 0
        y_range_val = 1;
    end
    ylim([y_min_val - 0.1 * y_range_val, y_max_val + 0.1 * y_range_val]);
    
    % 绘制右箱线图（y分布）- 竖向
    axes(ax_boxy);
    boxplot(y, 'Orientation', 'vertical', 'Colors', box_color, 'Symbol', 'k+', 'Widths', 0.5);
    set(ax_boxy, 'YAxisLocation', 'right'); % 将 y 轴放在右侧
    grid off;
    % 设置 ylim 与散点图一致
    ylim([y_min_val - 0.1 * y_range_val, y_max_val + 0.1 * y_range_val]);
    yticklabels([]);
    xticklabels([]);
    
    % 增大箱线图的线条宽度
    box_handles = findobj(ax_boxy, 'Tag', 'Box');
    set(box_handles, 'LineWidth', 1.5);
    
    % 绘制下箱线图（x分布）- 横向
    axes(ax_boxx);
    boxplot(x, 'Orientation', 'horizontal', 'Colors', box_color, 'Symbol', 'k+', 'Widths', 0.5);
    
    % 翻转坐标轴设置（x轴在上，y轴向下）
    set(ax_boxx, 'XAxisLocation', 'top');  % 将x轴放在上方
    set(ax_boxx, 'YDir', 'reverse');       % 反转y轴方向（使y轴向下）
    
    grid off;
    % 设置 xlim 与散点图一致
    xlim([x_min - 0.1 * x_range, x_max + 0.1 * x_range]);
    yticklabels([]);
    xticklabels([]);
    
    % 增大箱线图的线条宽度
    box_handles = findobj(ax_boxx, 'Tag', 'Box');
    set(box_handles, 'LineWidth', 1.5);
    
    % 返回图窗对象
end

% 局部函数：将 hex 颜色字符串转换为 RGB
function rgb = hex2rgb(hexStr)
    if hexStr(1) == '#'
        hexStr = hexStr(2:end); % 去除 # 符号
    end
    r = hex2dec(hexStr(1:2)) / 255;
    g = hex2dec(hexStr(3:4)) / 255;
    b = hex2dec(hexStr(5:6)) / 255;
    rgb = [r, g, b];
end

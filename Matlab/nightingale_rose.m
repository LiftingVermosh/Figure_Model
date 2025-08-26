function fig = nightingale_rose(labels, values, colormap_param, sorted)
% NIGHTINGALE_ROSE_CHART 绘制南丁格尔玫瑰图
%   fig = NIGHTINGALE_ROSE_CHART(labels, values, colormap_param) 绘制南丁格尔玫瑰图，
%   其中 labels 为标签向量，values 为数值向量，colormap_param 为颜色参数（可选）。
%   函数会对数值进行升序排序，并相应调整标签顺序，然后绘制玫瑰图。
%   颜色从顶部开始顺时针环绕，颜色采样方式与 grouped_line 函数类似。
%   在右侧添加图例，以"正方形色块 + 标签"的形式展示所有标签。
%   返回图形句柄。
%
%   参数：
%       labels: 标签向量，例如 {'A', 'B', 'C'}
%       values: 数值向量，与 labels 等长
%       colormap_param: 颜色参数，可以是颜色映射矩阵（n行3列）或用于 hexColormap 的单元数组（可选）
%       sorted: 布尔值，true 对数据及标签进行排序，false 不排序（可选，默认为true）
%
%   示例：
%       labels = {'A', 'B', 'C', 'D'};
%       values = [10, 20, 15, 25];
%       colormap_param = {'#ff6e7f', '#bfe9ff'};
%       fig = nightingale_rose_chart(labels, values, colormap_param);
%
%   示例 without colormap_param:
%       fig = nightingale_rose_chart(labels, values); % 使用默认颜色渐变

    % 验证输入参数
    if nargin < 2
        error('需要至少两个参数: labels 和 values');
    end
    if ~iscell(labels) || ~isvector(values)
        error('labels 必须是元胞数组，values 必须是向量');
    end
    if length(labels) ~= length(values)
        error('labels 和 values 长度必须相等');
    end

    n = length(values); % 条形数量

    % 处理颜色参数
    if nargin < 3 || isempty(colormap_param) 
        % 如果未提供 colormap_param 或 colormap_param 为空，使用默认颜色渐变
        hex1 = '#F9D423';
        hex2 = '#00EAFF';
        cmap = generateColorMap(hex1, hex2, n); % 生成颜色映射
    else
        if ismatrix(colormap_param) && size(colormap_param, 2) == 3
            % 如果 colormap_param 是矩阵，直接使用
            cmap = colormap_param;
        elseif iscell(colormap_param)
            % 如果 colormap_param 是单元数组，使用 hexColormap 生成颜色映射
            try
                cmap = hexColormap(colormap_param{:});
            catch ME
                error('生成颜色映射失败: %s', ME.message);
            end
        else
            error('colormap_param 必须是颜色映射矩阵（n-by-3）或用于 hexColormap 的单元数组');
        end
    end

    % 处理是否排序
    if nargin < 4
        % 对数值进行升序排序，并调整标签顺序
        [values_sorted, sort_idx] = sort(values, 'descend');
        labels_sorted = labels(sort_idx);
    else
        if ~islogical(sorted) && ~(isnumeric(sorted) && (sorted == 0 || sorted == 1))
            error('sorted 必须是布尔值（true/false）或0/1');
        end
        if isnumeric(sorted)
            sorted = logical(sorted);
        end
        if sorted
            % 对数值进行升序排序，并调整标签顺序
            [values_sorted, sort_idx] = sort(values, 'descend');
            labels_sorted = labels(sort_idx);
        else
            % 使用原数据
            values_sorted = values;
            labels_sorted = labels;
        end
    end
    
    % 均匀采样颜色：根据条形数量从颜色映射中采样
    C = size(cmap, 1);
    indices = round(linspace(1, C, n));
    groupColors = cmap(indices, :);

    % 创建图窗
    fig = figure('Color', 'w', 'Position', [100, 100, 1200, 800], 'Name', '南丁格尔玫瑰图');
    
    % 创建主坐标轴（用于绘制玫瑰图）
    ax_main = axes('Parent', fig, 'Position', [0.1, 0.1, 0.6, 0.8]);
    hold(ax_main, 'on');
    
    % 设置坐标轴为等比例，并隐藏坐标轴
    axis(ax_main, 'equal');
    axis(ax_main, 'off');
    
    % 计算每个扇形的角度范围（从顶部开始，顺时针）
    angles = linspace(0, 2*pi, n+1); % 0到2π，包含n+1个点
    angles = angles(1:end-1); % 移除最后一个重复点
    
    % 调整角度，使0度位于顶部
    angles = angles + pi/2;
    
    % 绘制每个扇形
    for i = 1:n
        % 当前扇形的角度范围
        if i == 1
            start_angle = angles(i);
        else
            start_angle = angles(i) - 0.05*pi/n;
        end
        end_angle = angles(i) + 2*pi/n;
        % 创建扇形路径
        theta = linspace(start_angle, end_angle, 50); % 50个点用于平滑扇形
        r = [0, values_sorted(i), values_sorted(i)]; % 径向距离
        
        % 创建扇形坐标
        x = [0, r(2)*cos(theta), 0];
        y = [0, r(2)*sin(theta), 0];
        
        % 绘制扇形
        fill(ax_main, x, y, groupColors(i, :), 'EdgeColor', 'none');

    end
    
    hold(ax_main, 'off');
    
    % 设置视图
    view(ax_main, 2); % 2D视图
    
    % 创建图例坐标轴（右侧）
    ax_legend = axes('Parent', fig, 'Position', [0.75, 0.1, 0.2, 0.8]);
    axis(ax_legend, 'off');
    hold(ax_legend, 'on');
    
    % 设置图例坐标轴的范围，确保所有内容都能显示
    xlim(ax_legend, [0, 1]);
    ylim(ax_legend, [0, 1]);
    
    % 计算图例中每个条目的位置
    legend_height = 0.8; % 图例区域高度（相对于坐标轴）
    entry_height = legend_height / n; % 每个条目的高度
    y_positions = linspace(0.9, 0.1, n); % 从上到下的y位置
    
    % 正方形色块的边长
    square_size = 0.05;
    
    % 绘制图例条目（正方形色块 + 标签）
    for i = 1:n
        % 绘制正方形色块
        % 调整x位置，使正方形居中
        x_pos = 0.1;
        rectangle(ax_legend, 'Position', [x_pos, y_positions(i)-square_size/2, square_size + 0.1, square_size], ...
                 'FaceColor', groupColors(n + 1 - i, :), 'EdgeColor', 'none');

        % 添加标签文本
        text(ax_legend, x_pos + square_size + 0.15, y_positions(i), labels_sorted{n + 1 - i}, ...
             'VerticalAlignment', 'middle', ...
             'FontSize', 12, ...
             'HorizontalAlignment', 'left', ...
             'FontName', 'TimesSimsun');
    end
    
    % 添加图例标题
    text(ax_legend, x_pos + square_size + 0.15, 0.975, '图例', ...
         'HorizontalAlignment', 'center', ...
         'FontSize', 14, ...
         'FontWeight', 'bold', ...
         'FontName', 'TimesSimsun');
    
    hold(ax_legend, 'off');
end

% 局部函数：生成颜色映射（从 hex 颜色到 RGB 映射）
function cmap = generateColorMap(hex1, hex2, n)
    rgb1 = hex2rgb(hex1);
    rgb2 = hex2rgb(hex2);
    r = linspace(rgb1(1), rgb2(1), n)';
    g = linspace(rgb1(2), rgb2(2), n)';
    b = linspace(rgb1(3), rgb2(3), n)';
    cmap = [r, g, b];
end

% 局部函数：将 hex 颜色字符串转换为 RGB
function rgb = hex2rgb(hexStr)
    if hexStr(1) == '#'
        hexStr = hexStr(2:end);
    end
    r = hex2dec(hexStr(1:2)) / 255;
    g = hex2dec(hexStr(3:4)) / 255;
    b = hex2dec(hexStr(5:6)) / 255;
    rgb = [r, g, b];
end

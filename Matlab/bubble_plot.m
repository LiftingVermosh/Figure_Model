function fig = bubble_plot(points, v, colormap_param, r, alpha_value)
% BUBBLE_PLOT 绘制气泡图
%   该函数根据点的坐标和数值向量绘制气泡图，气泡半径由数值向量归一化后缩放，颜色可自定义。
%
%   输入参数：
%       points: 2 x n 或 n x 2 矩阵，表示 n 个点的 [x, y] 坐标。
%       v: 1 x n 或 n x 1 数值向量，用于控制气泡半径的缩放。
%       colormap_param: 可选，颜色参数，可以是：
%                       - 空值或缺失：所有点使用默认颜色（蓝色）
%                       - 2元素单元数组：使用 hexColormap 生成从 hex1 到 hex2 的渐变色，并基于 x 轴映射颜色
%                       - n元素单元数组：每个元素是颜色字符串（如 '#ff0000'）或 RGB 向量，按索引直接使用
%                       - n x 3 矩阵：直接作为颜色映射，每行是一个 RGB 颜色
%       r: 可选，基础半径值，默认值为 10。实际半径为 r * v_nor_i。
%       alpha_value: 可选，透明度值，范围 0-1，默认值为 0.6。
%
%   输出：
%       fig: 图窗对象句柄
%
%   示例：
%       points = [1, 2; 3, 4; 5, 6]; % 3x2 矩阵，三个点
%       v = [0.1; 0.5; 0.9]; % 3x1 向量
%       colormap_param = {'#ff0000', '#0000ff'}; % 红到蓝渐变
%       r = 15;
%       alpha_value = 0.5;
%       fig = bubble_plot(points, v, colormap_param, r, alpha_value);

    % 参数检查：必须提供 points 和 v
    if nargin < 2
        error('必须提供 points 和 v 参数');
    end
    
    % 检查 points 是否为 2xn 或 nx2 矩阵
    if ~ismatrix(points) || (size(points, 1) ~= 2 && size(points, 2) ~= 2)
        error('points 必须是 2 x n 或 n x 2 矩阵');
    end
    
    % 统一 points 为 n x 2 矩阵（每行是一个点 [x, y]）
    if size(points, 1) == 2
        n = size(points, 2);
        points = points'; % 转置为 n x 2
    else
        n = size(points, 1);
        if size(points, 2) ~= 2
            error('points 必须是 2 x n 或 n x 2 矩阵');
        end
    end
    
    % 检查 v 是否为向量且长度匹配 points 的点数 n
    if ~isvector(v) || length(v) ~= n
        error('v 必须是长度为 n 的向量');
    end
    v = v(:); % 确保 v 是列向量
    
    % 归一化 v: v_nor = (v - min(v)) / (max(v) - min(v))
    v_min = min(v);
    v_max = max(v);
    if v_max == v_min
        % 如果所有 v 值相同，设置 v_nor 为 0.5 避免除零
        v_nor = 0.5 * ones(size(v));
    else
        v_nor = (v - v_min) / (v_max - v_min);
    end
    
    % 处理可选参数 colormap_param、r、alpha_value
    if nargin < 3 || isempty(colormap_param)
        colormap_param = [];
    end
    
    if nargin < 4
        r = 10; % 默认基础半径
    end
    
    if nargin < 5
        alpha_value = 0.6; % 默认透明度
    end
    
    % 颜色处理逻辑
    if isempty(colormap_param)
            hex1 = '#00F260';
            hex2 = '#0575E6';
            cmap = hexColormap(hex1, hex2, n);
            colors = cmap;
    elseif iscell(colormap_param) && (numel(colormap_param) == 2 || numel(colormap_param) == 3)
        % 两个颜色单元数组：生成渐变色图并基于 x 轴映射
        hex1 = colormap_param{1};
        hex2 = colormap_param{2};
        n_colors = 256; % 固定颜色图大小
        cmap = hexColormap(hex1, hex2, n_colors); % 调用 hexColormap 函数生成渐变色
        
        % 获取 x 坐标范围
        x_coords = points(:, 1);
        x_min = min(x_coords);
        x_max = max(x_coords);
        if x_max == x_min
            % 所有 x 相同，使用颜色图中间颜色
            idx = round(n_colors / 2);
            colors = repmat(cmap(idx, :), n, 1);
        else
            % 计算每个点的 x 位置比例，映射到颜色索引
            pos = (x_coords - x_min) / (x_max - x_min);
            idx = round(pos * (n_colors - 1) + 1);
            idx = max(1, min(n_colors, idx)); % 确保索引在范围内
            colors = cmap(idx, :);
        end
    elseif iscell(colormap_param) && numel(colormap_param) == n
        % n 个颜色单元数组：直接使用指定颜色
        colors = zeros(n, 3);
        for i = 1:n
            if ischar(colormap_param{i})
                % 转换 hex 字符串为 RGB
                colors(i, :) = hex2rgb(colormap_param{i});
            elseif isnumeric(colormap_param{i}) && numel(colormap_param{i}) == 3
                % 直接使用 RGB 向量
                colors(i, :) = colormap_param{i};
            else
                error('colormap_param 单元数组元素必须是颜色字符串或 RGB 向量');
            end
        end
    elseif ismatrix(colormap_param) && size(colormap_param, 2) == 3 && size(colormap_param, 1) == n
        % n x 3 矩阵：直接作为颜色映射
        colors = colormap_param;
    else
        error('无效的 colormap_param 参数');
    end
    
    % 创建图窗
    fig = figure('Color', 'w', 'Name', '气泡图', 'Position', [100, 100, 800, 600]);
    hold on;
    
    % 绘制每个点作为气泡（圆）
    for i = 1:n
        x_i = points(i, 1);
        y_i = points(i, 2);
        rad_i = r * v_nor(i); % 计算实际半径
        color_i = colors(i, :);
        
        % 使用 fill 绘制圆
        theta = linspace(0, 2*pi, 100); % 创建圆的点
        x_circle = x_i + rad_i * cos(theta);
        y_circle = y_i + rad_i * sin(theta);
        
        fill(x_circle, y_circle, color_i, 'FaceAlpha', alpha_value, 'EdgeColor', 'none');
    end
    
    hold off;
    
    % 设置轴标签和标题
    xlabel('X 坐标');
    ylabel('Y 坐标');
    title('气泡图');
    
    % 调整轴范围以适应所有气泡，考虑半径
    x_coords = points(:, 1);
    y_coords = points(:, 2);
    max_rad = max(r * v_nor); % 最大半径
    x_min = min(x_coords) - max_rad;
    x_max = max(x_coords) + max_rad;
    y_min = min(y_coords) - max_rad;
    y_max = max(y_coords) + max_rad;
    xlim([x_min, x_max]);
    ylim([y_min, y_max]);
    axis equal; % 保持纵横比
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

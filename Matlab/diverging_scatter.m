function fig = diverging_scatter(center_points, data_matrix, colormap_param, center_visible)
    % DIVERGING_SCATTER 绘制发散PCA散点图（二维点版本）
    %   该函数绘制发散散点图，每个类有一个二维中心点，多个二维数据点，并用线连接中心点与数据点。
    %
    %   输入参数：
    %       center_points: 2 x n 或 n x 2 矩阵，表示 n 个二维中心点。每列或每行是一个中心点的 [x, y] 坐标。
    %       data_matrix: n x m x 2 矩阵，表示数据点。n 是类数，m 是每个类的点数，第三维是坐标 [x, y]。
    %                   空值用 [0, 0] 表示，会被跳过。
    %       colormap_param: 颜色参数，可以是：
    %                       - 空值或缺失：使用默认颜色渐变
    %                       - 2元素单元数组：使用 hexColormap 生成渐变色，并均匀采样 n 个颜色
    %                       - n元素单元数组：每个元素是颜色字符串（如 '#ff0000'），按索引直接使用
    %                       - n x 3 矩阵：直接作为颜色映射，每行是一个 RGB 颜色
    %       center_visible: 布尔值，控制中心点是否可见（true 或 false）
    %
    %   输出：
    %       fig: 图窗对象句柄
    %
    %   示例：
    %       center_points = [1, 2; 3, 4]'; % 2x2 矩阵，两个中心点 [1,3] 和 [2,4]
    %       data_matrix = cat(3, [5,6; 7,8], [9,10; 11,12]); % 2x2x2 矩阵，两个类，每个类两个点
    %       colormap_param = {'#ff6e7f', '#bfe9ff'};
    %       center_visible = true;
    %       fig = diverging_scatter(center_points, data_matrix, colormap_param, center_visible);

    % 参数检查
    if nargin < 4
        error('必须提供所有参数');
    end
    
    % 检查 center_points 是否为 2xn 或 nx2 矩阵
    if ~ismatrix(center_points) || (size(center_points, 1) ~= 2 && size(center_points, 2) ~= 2)
        error('center_points 必须是 2 x n 或 n x 2 矩阵');
    end
    
    % 统一 center_points 为 n x 2 矩阵（每行是一个中心点）
    if size(center_points, 1) == 2
        n = size(center_points, 2);
        center_points = center_points'; % 转置为 n x 2
    else
        n = size(center_points, 1);
        if size(center_points, 2) ~= 2
            error('center_points 必须是 2 x n 或 n x 2 矩阵');
        end
    end
    
    % 检查 data_matrix 是否为 n x m x 2 矩阵
    if ndims(data_matrix) ~= 3 || size(data_matrix, 3) ~= 2
        error('data_matrix 必须是 n x m x 2 矩阵');
    end
    if size(data_matrix, 1) ~= n
        error('data_matrix 的第一个维度必须与 center_points 的类数 n 一致');
    end
    m = size(data_matrix, 2); % 每个类的点数
    
    % 检查 center_visible 是否为布尔值
    if ~islogical(center_visible)
        if isnumeric(center_visible) && (center_visible == 0 || center_visible == 1)
            center_visible = logical(center_visible);
        else
            error('center_visible 必须是布尔值或 0/1');
        end
    end
    
    % 处理颜色参数
    if nargin < 3 || isempty(colormap_param)
        % 默认颜色：使用 hexColormap 生成 n 个颜色的渐变色
        if n <= 5
        groupColors = [hex2rgb('#37FF00'); hex2rgb('#00FFB3');  hex2rgb('#FF5100');
            hex2rgb('#9000FF'); hex2rgb('#D2D900')];
        else
            hex1 = '#00FFB3';
            hex2 = '#A64568';
            cmap = hexColormap(hex1, hex2, n);
            groupColors = cmap;
        end
    elseif ismatrix(colormap_param) && size(colormap_param, 2) == 3
        % 如果 colormap_param 是 n x 3 矩阵，直接使用
        if size(colormap_param, 1) < n
            error('colormap_param 矩阵的行数必须至少为 n');
        end
        cmap = colormap_param;
        indices = round(linspace(1, size(cmap, 1), n));
        groupColors = cmap(indices, :);
    elseif iscell(colormap_param)
        numColors = numel(colormap_param);
        if numColors == 2
            % 如果单元数组有2个元素，使用 hexColormap 生成渐变色
            cmap = hexColormap(colormap_param{1}, colormap_param{2}, n);
            groupColors = cmap;
        elseif numColors == n
            % 如果单元数组有 n 个元素，按索引直接使用颜色
            groupColors = zeros(n, 3);
            for i = 1:n
                if ischar(colormap_param{i})
                    % 如果是颜色字符串，转换为 RGB
                    rgb = hex2rgb(colormap_param{i});
                    groupColors(i, :) = rgb;
                elseif isnumeric(colormap_param{i}) && numel(colormap_param{i}) == 3
                    % 如果是 RGB 向量，直接使用
                    groupColors(i, :) = colormap_param{i};
                else
                    error('colormap_param 单元数组元素必须是颜色字符串或 RGB 向量');
                end
            end
        else
            error('colormap_param 单元数组必须包含 2 个或 n 个元素');
        end
    else
        error('colormap_param 必须是矩阵、单元数组或空值');
    end
    
    % 创建图窗
    fig = figure('Color', 'w', 'Name', '发散聚类散点图', 'Position', [100, 100, 800, 600]);
    hold on;
    
    % 设置透明度参数
    line_alpha_value = 0.3; % 线条透明度，范围 0-1，值越小越透明
    point_alpha_value = 0.75;
    
    % 遍历每个类
    for k = 1:n
        center_point = center_points(k, :); % 当前类的中心点 [x, y]
        color = groupColors(k, :); % 当前类的颜色
        
        % 生成最浅的颜色用于连线（带透明度）
        lineColor = color + [0.3, 0.3, 0.3];
        lineColor = min(lineColor, 0.9); % 确保颜色值不超过 0.9

        % 生成较浅的颜色用于数据点
        lightColor = color + [0.15, 0.15, 0.15];
        lightColor = min(lightColor, 0.8); % 确保颜色值不超过 0.8
        
        % 生成较深的颜色用于中心点
        darkerColor = color * 0.9;
        darkerColor = max(darkerColor, 0); % 确保颜色值不低于 0
        
        % 获取当前类的数据点：重塑为 m x 2 矩阵
        data_points = reshape(data_matrix(k, :, :), m, 2);
        
        % 遍历每个数据点
        for j = 1:m
            point = data_points(j, :); % 当前数据点 [x, y]
            if ~all(point == 0) % 跳过空值 [0, 0]
                % 绘制从中心点到数据点的连接线，线宽 2.5，使用类颜色，并设置透明度
                h_line = plot([center_point(1), point(1)], [center_point(2), point(2)], ...
                    'Color', lineColor, 'LineWidth', 3);
                
                % 设置线条透明度（MATLAB 2023b 方法）
                set(h_line, 'Color', [get(h_line, 'Color'), line_alpha_value]);
                
                % 绘制数据点：标记大小 12，边缘白色，填充较浅颜色
                h_point = scatter(point(1), point(2), 150, 'Marker', 'o', ...
                    'LineWidth', 2, ...
                    'MarkerEdgeColor', 'w', ...
                    'MarkerFaceColor', lightColor, ...
                    'MarkerFaceAlpha', point_alpha_value);


            end
        end
        
        % 如果 center_visible 为 true，绘制中心点
        if center_visible
            scatter(center_point(1), center_point(2), 80, 'filled', 'MarkerEdgeColor', 'w', 'MarkerFaceColor', darkerColor);
        end
    end
    
    hold off;
    
    % 设置轴标签和标题
    xlabel('X 坐标');
    ylabel('Y 坐标');
    
    % 调整轴范围以适应数据
    all_x = center_points(:, 1);
    all_y = center_points(:, 2);
    % 收集所有非空数据点
    for k = 1:n
        data_points = reshape(data_matrix(k, :, :), m, 2);
        for j = 1:m
            point = data_points(j, :);
            if ~all(point == 0)
                all_x = [all_x; point(1)];
                all_y = [all_y; point(2)];
            end
        end
    end
    if ~isempty(all_x) && ~isempty(all_y)
        x_min = min(all_x);
        x_max = max(all_x);
        y_min = min(all_y);
        y_max = max(all_y);
        x_range = x_max - x_min;
        y_range = y_max - y_min;
        % 添加10%的边距
        xlim([x_min - 0.1 * x_range, x_max + 0.1 * x_range]);
        ylim([y_min - 0.1 * y_range, y_max + 0.1 * y_range]);
    end
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

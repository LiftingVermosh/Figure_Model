function fig = lollipop_plot(data_matrix, colormap_param)
    % LOLLIPOP_PLOT 绘制棒棒糖图（支持负值）
    %   该函数绘制棒棒糖图，每个数据点用一条垂直线连接到基准线（y=0或数据最小值），并在数据点位置绘制一个点。
    %   颜色参数用于控制点的颜色，支持默认颜色、渐变映射到x轴或直接指定颜色。
    %
    %   输入参数：
    %       data_matrix: n x 2 矩阵，每行是一个数据点的 [x, y] 坐标。
    %       colormap_param: 可选，颜色参数。可以是：
    %                       - 空值或缺失：使用默认颜色（蓝色）
    %                       - 2元素单元数组：包含两个hex颜色字符串（如 {'#ff0000', '#00ff00'}），
    %                         生成从hex1到hex2的平滑渐变颜色，并映射到x轴范围（xlim(1)到xlim(2)）
    %                       - n元素单元数组：每个元素是颜色字符串或RGB向量，按顺序为每个点上色
    %                       - n x 3 矩阵：直接作为颜色映射，每行是一个RGB颜色
    %
    %   输出：
    %       fig: 图窗对象句柄
    %
    %   示例：
    %       data = [1, 2; 2, -1; 3, 4; 4, -2]; % 包含正值和负值
    %       colormap_param = {'#ff0000', '#00ff00'}; % 红到绿渐变
    %       fig = lollipop_plot(data, colormap_param);

    % 参数检查：data_matrix 必须提供且为 n x 2 矩阵
    if nargin < 1
        error('必须提供 data_matrix 参数');
    end
    if ~ismatrix(data_matrix) || size(data_matrix, 2) ~= 2
        error('data_matrix 必须是 n x 2 矩阵');
    end
    n = size(data_matrix, 1); % 数据点数量
    x_data = data_matrix(:, 1); % 提取x坐标
    y_data = data_matrix(:, 2); % 提取y坐标

    % 处理颜色参数
    if nargin < 2 || isempty(colormap_param)
        hex1 = '#00F260';
        hex2 = '#0575E6';
        cmap = hexColormap(hex1, hex2, n);
        point_colors = cmap;
    else
        if iscell(colormap_param)
            numColors = numel(colormap_param);
            if numColors == 2
                % 两个hex颜色：生成平滑渐变并映射到x轴
                hex1 = colormap_param{1};
                hex2 = colormap_param{2};
                rgb1 = hex2rgb(hex1);
                rgb2 = hex2rgb(hex2);
                % 计算x轴范围
                x_min = min(x_data);
                x_max = max(x_data);
                if x_min == x_max
                    % 如果所有x相同，使用中间颜色
                    t = 0.5 * ones(n, 1);
                else
                    % 归一化x坐标到[0,1]范围
                    t = (x_data - x_min) / (x_max - x_min);
                end
                % 线性插值计算每个点的颜色
                point_colors = zeros(n, 3);
                for i = 1:n
                    point_colors(i, :) = rgb1 + t(i) * (rgb2 - rgb1);
                end
            elseif numColors == n
                % n个颜色：直接使用提供的颜色
                point_colors = zeros(n, 3);
                for i = 1:n
                    if ischar(colormap_param{i})
                        % 如果是字符串，转换为RGB
                        point_colors(i, :) = hex2rgb(colormap_param{i});
                    elseif isnumeric(colormap_param{i}) && numel(colormap_param{i}) == 3
                        % 如果是RGB向量，直接使用
                        point_colors(i, :) = colormap_param{i};
                    else
                        error('colormap_param 单元数组元素必须是颜色字符串或 RGB 向量');
                    end
                end
            else
                error('colormap_param 单元数组必须包含 2 个或 n 个元素');
            end
        elseif ismatrix(colormap_param) && size(colormap_param, 2) == 3
            % n x 3 矩阵：直接作为颜色映射
            if size(colormap_param, 1) == n
                point_colors = colormap_param;
            else
                error('colormap_param 矩阵的行数必须与数据点数量 n 一致');
            end
        else
            error('colormap_param 必须是单元数组或 n x 3 矩阵');
        end
    end

    % 确定基准线位置（连接线的起点）
    % 基准线为0
    baseline = 0;

    % 创建图窗
    fig = figure('Color', 'w', 'Name', '棒棒糖图', 'Position', [100, 100, 800, 600]);
    hold on;

    % 绘制基准线
    x_range = max(x_data) - min(x_data);
    if x_range == 0
        x_range = 1; % 避免除零
    end
    plot([min(x_data) - 0.1*x_range, max(x_data) + 0.1*x_range], [baseline, baseline], ...
         'k--', 'LineWidth', 1, 'Color', [0.5, 0.5, 0.5]);
    
    % 绘制棒棒糖图：对于每个点，绘制垂直线和点
    for i = 1:n
        x = x_data(i);
        y = y_data(i);
        color = point_colors(i, :);
        
        % 绘制垂直线从 (x, baseline) 到 (x, y)，使用点的颜色，线宽2
        line([x, x], [baseline, y], 'Color', color, 'LineWidth', 2);
        
        % 绘制点 at (x, y)，大小100，填充颜色，白色边缘
        scatter(x, y, 100, 'filled', 'MarkerEdgeColor', 'w', 'MarkerFaceColor', color);
    end

    hold off;

    % 设置轴标签和标题

    % 调整轴范围以适应数据，添加10%边距
    x_min = min(x_data);
    x_max = max(x_data);
    y_min = min(y_data);
    y_max = max(y_data);
    x_range = x_max - x_min;
    y_range = y_max - y_min;
    
    % 确保y轴范围包含基准线
    if baseline < y_min
        y_min = baseline;
    end
    
    if x_range == 0
        x_range = 1; % 避免除零
    end
    if y_range == 0
        y_range = 1; % 避免除零
    end
    
    xlim([x_min - 0.1 * x_range, x_max + 0.1 * x_range]);
    ylim([y_min - 0.1 * y_range, y_max + 0.1 * y_range]);
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

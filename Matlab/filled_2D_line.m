function fig = filled_2D_line(data_matrix, colormap_param)
    % FILLED_2D_LINE 绘制带颜色映射和填充的线图
    %   该函数绘制 n 条线，每条线有 m 个点，并根据颜色参数设置线条颜色和填充区域。
    %
    %   输入参数：
    %       data_matrix: n x m x 2 矩阵，表示 n 条线，每条线有 m 个二维点 [x, y]。
    %       colormap_param: 颜色参数，可以是：
    %                       - 空值或缺失：使用从红到紫的色环过渡色，映射到 x 轴
    %                       - 2元素单元数组：使用 hexColormap 生成渐变色，并映射到 x 轴
    %                       - n元素单元数组：每个元素是颜色字符串（如 '#ff0000'），按索引直接使用
    %                       - n x 3 矩阵：直接作为颜色映射，每行是一个 RGB 颜色
    %
    %   输出：
    %       fig: 图窗对象句柄
    %
    %   示例：
    %       data = rand(3, 10, 2); % 3条线，每条10个点
    %       colormap_param = {'#ff6e7f', '#bfe9ff'};
    %       fig = filled_2D_line(data, colormap_param);

    % 参数检查
    if nargin < 1
        error('必须提供 data_matrix 参数');
    end
    
    % 检查 data_matrix 是否为 n x m x 2 矩阵
    if ndims(data_matrix) ~= 3 || size(data_matrix, 3) ~= 2
        error('data_matrix 必须是 n x m x 2 矩阵');
    end
    
    n = size(data_matrix, 1); % 线的数量
    m = size(data_matrix, 2); % 每条线的点数
    
    % 处理颜色参数 colormap_param
    if nargin < 2 || isempty(colormap_param)
        % 默认情况：使用从红到紫的色环过渡色，映射到 x 轴
        x_all = data_matrix(:,:,1);
        x_nonzero = x_all(x_all ~= 0);
        if isempty(x_nonzero)
            x_min = 0;
            x_max = 1;
        else
            x_min = min(x_nonzero);
            x_max = max(x_nonzero);
        end
        
        % 生成从红到紫的HSV色环过渡色
        lineColors = zeros(n, 3);
        for i = 1:n
            % 获取当前线的有效点（非零）
            x = squeeze(data_matrix(i, :, 1));
            valid_indices = x ~= 0;
            x_valid = x(valid_indices);
            
            if ~isempty(x_valid)
                x_start = x_valid(1); % 每条线起点的 x 坐标
                norm_x = (x_start - x_min) / (x_max - x_min);
                norm_x = max(0, min(1, norm_x)); % 限制在 [0,1] 范围内
                
                % 使用HSV颜色空间创建从红到紫的色环过渡
                % 红色: H=0, 紫色: H≈0.83 (300°/360°)
                hue = norm_x * 0.83; % 映射到0-0.83范围
                saturation = 1; % 最大饱和度
                value = 1; % 最大亮度
                
                % 将HSV转换为RGB
                lineColors(i,:) = hsv2rgb([hue, saturation, value]);
            else
                lineColors(i,:) = [0.5, 0.5, 0.5]; % 默认灰色
            end
        end
    elseif iscell(colormap_param) && numel(colormap_param) == 2
        % 两个颜色元素：生成渐变色并映射到 x 轴
        hex1 = colormap_param{1};
        hex2 = colormap_param{2};
        % 获取所有 x 坐标的范围
        x_all = data_matrix(:,:,1);
        x_nonzero = x_all(x_all ~= 0);
        if isempty(x_nonzero)
            x_min = 0;
            x_max = 1;
        else
            x_min = min(x_nonzero);
            x_max = max(x_nonzero);
        end
        % 生成 256 级渐变色图
        cmap = hexColormap(hex1, hex2, 256);
        lineColors = zeros(n, 3);
        for i = 1:n
            % 获取当前线的有效点（非零）
            x = squeeze(data_matrix(i, :, 1));
            valid_indices = x ~= 0;
            x_valid = x(valid_indices);
            
            if ~isempty(x_valid)
                x_start = x_valid(1); % 每条线起点的 x 坐标
                norm_x = (x_start - x_min) / (x_max - x_min);
                norm_x = max(0, min(1, norm_x)); % 限制在 [0,1] 范围内
                idx = round(norm_x * 255) + 1; % 映射到颜色索引 (1-256)
                lineColors(i,:) = cmap(idx,:);
            else
                lineColors(i,:) = [0.5, 0.5, 0.5]; % 默认灰色
            end
        end
    elseif iscell(colormap_param) && numel(colormap_param) == n
        % n 个颜色元素：直接使用提供的颜色
        lineColors = zeros(n, 3);
        for i = 1:n
            if ischar(colormap_param{i})
                rgb = hex2rgb(colormap_param{i});
                lineColors(i,:) = rgb;
            elseif isnumeric(colormap_param{i}) && numel(colormap_param{i}) == 3
                lineColors(i,:) = colormap_param{i};
            else
                error('colormap_param 单元数组元素必须是颜色字符串或 RGB 向量');
            end
        end
    elseif isnumeric(colormap_param) && size(colormap_param, 2) == 3 && size(colormap_param, 1) >= n
        % n x 3 矩阵：直接使用前 n 行作为颜色
        lineColors = colormap_param(1:n, :);
    else
        error('无效的 colormap_param 参数');
    end
    
    % 创建图窗
    fig = figure('Color', 'w', 'Name', '线图带填充', 'Position', [100, 100, 800, 600]);
    hold on;
    
    % 设置填充区域的透明度
    fill_alpha = 0.3; % 填充透明度
    
    % 遍历每条线
    for i = 1:n
        x = squeeze(data_matrix(i, :, 1)); % 当前线的 x 坐标
        y = squeeze(data_matrix(i, :, 2)); % 当前线的 y 坐标
        
        % 找出有效点（非零）
        valid_indices = x ~= 0;
        x_valid = x(valid_indices);
        y_valid = y(valid_indices);
        
        if isempty(x_valid)
            continue; % 跳过没有有效点的线
        end
        
        color = lineColors(i, :); % 当前线的颜色
        
        % 生成较浅的颜色用于填充
        lighter_color = color + [0.3, 0.3, 0.3];
        lighter_color = min(lighter_color, 1); % 确保颜色值不超过 1
        
        % 绘制线条
        plot(x_valid, y_valid, 'Color', color, 'LineWidth', 2);
        
        % 修复填充区域：从曲线到x轴，然后沿着x轴闭合
        x_patch = [x_valid, fliplr(x_valid)];
        y_patch = [y_valid, zeros(1, length(x_valid))];
        patch(x_patch, y_patch, lighter_color, 'EdgeColor', 'none', 'FaceAlpha', fill_alpha);
    end
    
    hold off;
    
    % 设置轴标签和标题
    xlabel('X 坐标');
    ylabel('Y 坐标');
    title('带颜色映射和填充的线图');
    
    % 调整轴范围以适应数据
    x_all = data_matrix(:,:,1);
    y_all = data_matrix(:,:,2);
    x_nonzero = x_all(x_all ~= 0);
    y_nonzero = y_all(y_all ~= 0);
    if isempty(x_nonzero) || isempty(y_nonzero)
        x_min = 0;
        x_max = 1;
        y_min = 0;
        y_max = 1;
    else
        x_min = min(x_nonzero);
        x_max = max(x_all(:));
        y_min = min(y_nonzero);
        y_max = max(y_all(:));
    end
    x_range = x_max - x_min;
    y_range = y_max - y_min;
    xlim([x_min - 0.1 * x_range, x_max + 0.1 * x_range]);
    ylim([y_min, y_max + 0.1 * y_range]);
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

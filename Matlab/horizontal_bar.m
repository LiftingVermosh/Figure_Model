function fig = horizontal_bar(labels, data, colormap_param, towards, bar_width)
    % horizontal_bar 绘制横向条形图
    % 输入：
    %   labels - 类标签，可以是字符串数组或单元格数组
    %   data - 数值向量，长度与labels一致
    %   colormap_param - 可选，颜色映射参数，可以是颜色映射矩阵或颜色参数单元数组
    %   towards - 可选，y轴朝向，"up"或"down"，默认为"down"
    %   bar_width - 可选，条宽，默认为0.5
    % 输出：
    %   fig - 图形句柄
    
    % 检查输入参数数量
    if nargin < 2
        error('输入参数至少需要两个: labels 和 data');
    end
    
    % 设置默认参数
    if nargin < 3
        colormap_param = [];
    end

    if nargin < 4
        towards = "down"; % 默认y轴朝下
    end

    if nargin < 5
        bar_width = 0.5;
    end
    
    % 验证towards参数
    if ~(strcmpi(towards, "up") || strcmpi(towards, "down"))
        error('towards参数必须是"up"或"down"');
    end
    
    % 检查labels和data的长度是否一致
    if length(labels) ~= length(data)
        error('labels 和 data 的长度必须一致');
    end
    
    % 检查data是否为空或长度大于0
    if isempty(data)
        error('data 不能为空');
    end
    
    % 移除对data必须大于0的检查，允许负值
    
    % 将data转换为列向量以确保一致性
    data = data(:);
    % 如果labels是行向量，转换为列向量（适用于单元格数组或字符串数组）
    if isrow(labels)
        labels = labels';
    end
    
    num_bars = length(data); % 条形数量
    
    % 检查数据是否包含负值
    has_negative = any(data < 0);
    
    % 处理颜色映射参数
    if isempty(colormap_param)
        % 如果没有提供colormap_param，使用默认渐变
        if has_negative
            % 对于包含负值的数据，使用双色渐变（红色到蓝色）
            hex1 = '#FEAC5E'; % 红色（负值）
            hex2 = '#4BC0C8'; % 蓝色（正值）
            cmap = generateColorMap(hex1, hex2, num_bars);
        else
            % 对于全正值数据，使用默认渐变
            hex1 = '#0575E6'; % 蓝色
            hex2 = '#00F260'; % 绿色
            cmap = generateColorMap(hex1, hex2, num_bars);
        end
    else
        % 处理颜色参数
        if ismatrix(colormap_param) && size(colormap_param, 2) == 3
            % 如果colormap_param是矩阵，直接使用它作为颜色映射
            cmap = colormap_param;
        elseif iscell(colormap_param)
            % 如果colormap_param是cell数组，尝试使用hexColormap生成颜色映射
            try
                cmap = hexColormap(colormap_param{:});
            catch ME
                error('无法使用hexColormap生成颜色映射: %s', ME.message);
            end
        else
            error('colormap_param必须是颜色映射矩阵(n×3)或用于hexColormap的单元数组');
        end
    end
    
    % 均匀采样颜色
    C = size(cmap, 1); % 颜色数量
    indices = round(linspace(1, C, num_bars)); % 索引数组
    barColors = cmap(indices, :); % 条形颜色数组
    
    % 创建新图形窗口
    fig = figure('Color', 'w', 'Name', '横向条形图');
    
    % 设置图窗大小而不固定位置
    screen_size = get(0, 'ScreenSize');
    max_abs_data = max(abs(data)); % 使用绝对值计算最大值
    num_labels = length(labels);
    
    % 计算图窗宽度和高度
    fig_width = min(30 * max_abs_data, screen_size(3) * 0.9);  % 限制最大宽度为屏幕宽度的90%
    fig_height = min(100 * num_labels, screen_size(4) * 0.8);  % 限制最大高度为屏幕高度的80%
    
    % 计算居中位置
    left_pos = (screen_size(3) - fig_width) / 2;
    bottom_pos = (screen_size(4) - fig_height) / 2;
    
    % 设置图窗位置和大小
    set(fig, 'Position', [left_pos, bottom_pos, fig_width, fig_height]);

    % 绘制横向条形图
    h_bar = barh(data, 'FaceColor', 'flat', 'EdgeColor', 'none', 'BarWidth', bar_width);
    
    % 根据towards参数设置y轴方向和x轴位置
    if strcmpi(towards, "down")
        set(gca, 'YDir', 'reverse');
        set(gca, 'XAxisLocation', 'top'); % y轴朝下时，x轴在上方
    else
        set(gca, 'YDir', 'normal');
        set(gca, 'XAxisLocation', 'bottom'); % y轴朝上时，x轴在下方
    end
    
    % 设置条形颜色
    h_bar.CData = barColors;
    
    % 取消纵轴刻度
    set(gca, 'YTick', []);
    
    % 调整y轴范围，使条形间距更均匀
    ylim([0.3, num_bars + 0.7]); % 减小上下的空白区域
    
    % 在条形右侧添加数值文本
    for i = 1:num_bars
        % 计算文本位置
        offset = 0.02 * max_abs_data; % 使用数据绝对值的2%作为偏移量
        if data(i) >= 0
            % 正值：文本在条形右侧
            x_pos = data(i) + offset;
            horz_align = 'left';
        else
            % 负值：文本在条形左侧
            x_pos = data(i) - offset;
            horz_align = 'right';
        end
        y_pos = i;
        
        % 添加文本
        text(x_pos, y_pos, num2str(data(i)), ...
            'HorizontalAlignment', horz_align, ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 12, ...
            'FontWeight', 'bold', ...
            'FontName', 'TimesSimsun');
    end
    
    % 设置y轴标签位置
    for i = 1:num_bars
        if data(i) >= 0
            % 正值：标签在左侧
            x_pos = -0.02 * max_abs_data;
            horz_align = 'right';
        else
            % 负值：标签在右侧（关于y轴的对侧）
            x_pos = 0.02 * max_abs_data;
            horz_align = 'left';
        end
        
        text(x_pos, i, labels{i}, ...
            'HorizontalAlignment', horz_align, ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 12, ...
            'FontWeight', 'bold', ...
            'FontName', 'TimesSimsun');
    end
    
    % 设置x轴范围，考虑正负值
    max_abs_data = max(abs(data));
    xlim([-max_abs_data*1.1, max_abs_data*1.1]);
    
    % 设置字体和样式
    ax = gca;
    ax.FontName = 'TimesSimsun';
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ax.LineWidth = 1.5;
    box off;
    
    % 添加坐标轴箭头（根据towards参数调整箭头方向）
    addAxisArrows(ax, towards, num_bars, has_negative);
end

% 局部函数：生成颜色映射
function cmap = generateColorMap(hex1, hex2, n)
    % hex2rgb
    rgb1 = hex2rgb(hex1);
    rgb2 = hex2rgb(hex2);
    % 均匀采样
    r = linspace(rgb1(1), rgb2(1), n)';
    g = linspace(rgb1(2), rgb2(2), n)';
    b = linspace(rgb1(3), rgb2(3), n)';
    cmap = [r, g, b];
end

% 局部函数：hex2rgb
function rgb = hex2rgb(hexStr)
    % 移除 '#'
    if hexStr(1) == '#'
        hexStr = hexStr(2:end);
    end
    % 转换为 RGB 值
    r = hex2dec(hexStr(1:2)) / 255;
    g = hex2dec(hexStr(3:4)) / 255;
    b = hex2dec(hexStr(5:6)) / 255;
    rgb = [r, g, b];
end

function addAxisArrows(ax, towards, num_bars, has_negative)
    % 设置y轴位于x=0处
    ax.YAxisLocation = 'origin';
    
    % 获取坐标轴位置和范围
    axPos = ax.Position;
    xLim = ax.XLim;
    yLim = ax.YLim;
    
    % 计算x=0在归一化坐标中的位置
    x0_normalized = axPos(1) + (0 - xLim(1)) / (xLim(2) - xLim(1)) * axPos(3);
    
    % 计算y=0在归一化坐标中的位置
    y0_normalized = axPos(2) + (0 - yLim(1)) / (yLim(2) - yLim(1)) * axPos(4);
    
    % 根据towards参数设置箭头位置
    if strcmpi(towards, "down")
        % X轴正方向箭头（向右）
        xRightArrowX = [axPos(1) + axPos(3), axPos(1) + axPos(3) + 0.02];
        xRightArrowY = [axPos(2) + axPos(4), axPos(2) + axPos(4)];
        
        % Y轴箭头（指向下）
        yArrowX = [x0_normalized + 1e-3, x0_normalized + 1e-3];
        yArrowY = [y0_normalized + 0.03, y0_normalized];
    else
        % X轴正方向箭头（向右）
        xRightArrowX = [axPos(1) + axPos(3), axPos(1) + axPos(3) + 0.02];
        xRightArrowY = [axPos(2), axPos(2)];
        
        % Y轴箭头（指向上）
        yArrowX = [x0_normalized, x0_normalized];
        yArrowY = [axPos(2) + axPos(4), axPos(2) + axPos(4) + 0.02];
    end
    
    % 创建X轴正方向箭头
    annotation('arrow', xRightArrowX, xRightArrowY, 'Color', 'k', 'LineWidth', 1.5);
    
    % 创建Y轴箭头
    annotation('arrow', yArrowX, yArrowY, 'Color', 'k', 'LineWidth', 1.5);
    
    % 如果有负值，添加X轴负方向箭头（向左）
    if has_negative
        if strcmpi(towards, "down")
            % X轴负方向箭头（向左）
            xLeftArrowX = [axPos(1) , axPos(1) - 0.02];
            xLeftArrowY = [axPos(2) + axPos(4), axPos(2) + axPos(4)];
        else
            % X轴负方向箭头（向左）
            xLeftArrowX = [axPos(1) , axPos(1) - 0.02];
            xLeftArrowY = [axPos(2), axPos(2)];
        end
        
        % 创建X轴负方向箭头
        annotation('arrow', xLeftArrowX, xLeftArrowY, 'Color', 'k', 'LineWidth', 1.5);
    end
    
    % 调整坐标轴范围，为箭头留出空间，同时避免与条形重叠
    xLim = ax.XLim;
    yLim = ax.YLim;
    
    % 根据条形数量调整y轴扩展比例
    y_expansion = min(0.05 * num_bars, 0.2); % 限制最大扩展比例
    
    % 如果有负值，需要为X轴箭头留出空间
    if has_negative
        x_expansion = 0.05;
        ax.XLim = [xLim(1) - x_expansion * diff(xLim), xLim(2) + x_expansion * diff(xLim)];
    else
        ax.XLim = [xLim(1), xLim(2) + 0.05 * diff(xLim)];
    end
    
    if strcmpi(towards, "down")
        ax.YLim = [yLim(1) - y_expansion, yLim(2)]; % 为y轴箭头留出空间
    else
        ax.YLim = [yLim(1), yLim(2) + y_expansion]; % 为y轴箭头留出空间
    end
end

function fig = horizontal_bar_gt_zero(labels, data, colormap_param, towards, bar_width)
    % horizontal_bar_gt_zero 绘制数值大于0的横向条形图
    % 输入：
    %   labels - 类标签，可以是字符串数组或单元格数组
    %   data - 数值向量，长度与labels一致，且所有值大于0
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
    
    % 检查data的所有值是否大于0
    if any(data <= 0)
        error('data 的所有值必须大于0');
    end
    
    % 将data转换为列向量以确保一致性
    data = data(:);
    % 如果labels是行向量，转换为列向量（适用于单元格数组或字符串数组）
    if isrow(labels)
        labels = labels';
    end
    
    num_bars = length(data); % 条形数量
    
    % 处理颜色映射参数
    if isempty(colormap_param)
        % 如果没有提供colormap_param，使用默认渐变
        hex1 = '#0575E6'; % 蓝色
        hex2 = '#00F260'; % 绿色
        cmap = generateColorMap(hex1, hex2, num_bars);
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
    max_data = max(data, [], 'all');
    num_labels = length(labels);
    
    % 计算图窗宽度和高度
    fig_width = min(30 * max_data, screen_size(3) * 0.9);  % 限制最大宽度为屏幕宽度的90%
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
        % 计算文本位置：x为数据值加 small offset（避免重叠），y为条形索引
        offset = 0.02 * max(data); % 使用数据最大值的2%作为偏移量
        x_pos = data(i) + offset;
        y_pos = i;
        % 添加文本，左对齐，垂直居中
        text(x_pos, y_pos, num2str(data(i)), ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 12, ...
            'FontWeight', 'bold', ...
            'FontName', 'TimesSimsun');
    end
    
    % 设置y轴标签位置（在条形左侧）
    for i = 1:num_bars
        text(-0.02 * max(data), i, labels{i}, ...
            'HorizontalAlignment', 'right', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 12, ...
            'FontWeight', 'bold', ...
            'FontName', 'TimesSimsun');
    end
    
    % 设置x轴范围
    max_data = max(data, [], 'all');
    min_data = min(data, [], 'all');
    xlim([min(0, min_data*0.9), max_data*1.1]);
    
    % 设置字体和样式
    ax = gca;
    ax.FontName = 'TimesSimsun';
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ax.LineWidth = 1.5;
    box off;
    
    % 添加坐标轴箭头（根据towards参数调整箭头方向）
    addAxisArrows(ax, towards, num_bars);
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

function addAxisArrows(ax, towards, num_bars)
    % 获取坐标轴位置（归一化坐标）
    axPos = ax.Position;
    
    % 根据towards参数设置箭头位置
    if strcmpi(towards, "down")
        % X轴箭头（在上方，指向右）
        xArrowX = [axPos(1) + axPos(3) - 0.02, axPos(1) + axPos(3)];
        xArrowY = [axPos(2) + axPos(4), axPos(2) + axPos(4)];
        
        % Y轴箭头（在左侧，指向下）
        yArrowX = [axPos(1), axPos(1)];
        yArrowY = [axPos(2) + 0.02, axPos(2)]; % 从0.02位置到底部，箭头向下
    else
        % X轴箭头（在下方，指向右）
        xArrowX = [axPos(1) + axPos(3) - 0.02, axPos(1) + axPos(3)];
        xArrowY = [axPos(2), axPos(2)];
        
        % Y轴箭头（在左侧，指向上）
        yArrowX = [axPos(1), axPos(1)];
        yArrowY = [axPos(2) + axPos(4) - 0.02, axPos(2) + axPos(4)]; % 从顶部-0.02位置到顶部，箭头向上
    end
    
    % 创建X轴箭头
    annotation('arrow', xArrowX, xArrowY, 'Color', 'k', 'LineWidth', 1.5);
    
    % 创建Y轴箭头
    annotation('arrow', yArrowX, yArrowY, 'Color', 'k', 'LineWidth', 1.5);
    
    % 调整坐标轴范围，为箭头留出空间，同时避免与条形重叠
    xLim = ax.XLim;
    yLim = ax.YLim;
    
    % 根据条形数量调整y轴扩展比例
    y_expansion = min(0.05 * num_bars, 0.2); % 限制最大扩展比例
    
    ax.XLim = [xLim(1), xLim(2) + 0.05 * diff(xLim)];
    
    if strcmpi(towards, "down")
        ax.YLim = [yLim(1) - y_expansion, yLim(2)]; % 为y轴箭头留出空间
    else
        ax.YLim = [yLim(1), yLim(2) + y_expansion]; % 为y轴箭头留出空间
    end
end

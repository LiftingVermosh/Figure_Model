function fig = grouped_bar(x, y, colormap_param)
% PLOTGROUPEDBAR 使用指定颜色映射绘制分组条形图
%   fig = PLOTGROUPEDBAR(x, y, colormap_param) 绘制分组条形图，其中 x 为水平轴，
%   y 的列作为不同的组。颜色从颜色映射中均匀采样。
%   colormap_param 可以是一个颜色映射矩阵（n行3列）或一个用于 hexColormap 的参数单元数组。
%   如果 colormap_param 缺失，则使用默认渐变。
%   返回图形句柄。
%
%   示例：
%       x = 1:3;
%       y = [1 4; 2 5; 3 6]; % 3 行, 2 列
%       colormap_param = {'#ff6e7f', '#bfe9ff'}; % 用于 hexColormap 的参数
%       fig = plotGroupedBar(x, y, colormap_param);
%
%   示例 without colormap_param:
%       fig = plotGroupedBar(x, y); % 使用默认颜色渐变

    % 验证 x 和 y
    if ~isvector(x)
        error('x must be a vector.');
    end
    if size(y, 1) ~= length(x)
        error('Number of rows in y must match the length of x.');
    end

    numGroups = size(y, 2); % 组数（y 的列数）

    % 检查 colormap_param 是否提供
    if nargin < 3
        % 如果 colormap_param 缺失，使用默认的 Hex1 和 Hex2
        hex1 = '#0575E6'; %
        hex2 = '#00F260'; % 
        % 生成从 hex1 到 hex2 的颜色映射
        cmap = generateColorMap(hex1, hex2, numGroups);
    else
        % 处理颜色参数
        if ismatrix(colormap_param) && size(colormap_param, 2) == 3
            % 如果 colormap_param 是矩阵，直接使用它作为颜色映射
            cmap = colormap_param;
        elseif iscell(colormap_param)
            % 如果 colormap_param 是 cell 数组，尝试使用 hexColormap 生成颜色映射
            try
                cmap = hexColormap(colormap_param{:});
            catch ME
                error('Failed to generate colormap using hexColormap: %s', ME.message);
            end
        else
            error('colormap_param must be a colormap matrix (n-by-3) or a cell array for hexColormap.');
        end
    end
    % 均匀采样颜色
    C = size(cmap, 1); % 颜色数量
    indices = round(linspace(1, C, numGroups)); % 索引数组
    groupColors = cmap(indices, :); % 组颜色数组

    % 绘制图形
    fig = figure('Position', [100, 100, 1200, 800]);
    b = bar(x, y); % 绘制条形图

    % 设置
    for k = 1:numGroups
        b(k).FaceColor = groupColors(k, :); % 设置组颜色
        b(k).EdgeColor = "none";
    end

    % 设置字体
    ax = gca;
    ax.FontName = 'TimesSimsun';
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ax.LineWidth = 1.5;
    box off;

    max_y = max(y, [], 'all');
    min_y = min(y, [], 'all');
    ylim([min(0, min_y*0.9), max_y*1.1]);

    addAxisArrows(ax);

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

function addAxisArrows(ax)
    % 获取坐标轴范围
    xLim = ax.XLim;
    yLim = ax.YLim;
    
    % 获取坐标轴位置（归一化坐标）
    axPos = ax.Position;
    
    % 计算箭头的位置（归一化坐标）
    % X轴箭头
    xArrowX = [axPos(1) + axPos(3) - 0.02, axPos(1) + axPos(3)];
    xArrowY = [axPos(2), axPos(2)];
    
    % Y轴箭头
    yArrowX = [axPos(1), axPos(1)];
    yArrowY = [axPos(2) + axPos(4) - 0.02, axPos(2) + axPos(4)];
    
    % 创建X轴箭头
    annotation('arrow', xArrowX, xArrowY, 'Color', 'k', 'LineWidth', 1.5);
    
    % 创建Y轴箭头
    annotation('arrow', yArrowX, yArrowY, 'Color', 'k', 'LineWidth', 1.5);
    
    % 调整坐标轴范围，为箭头留出空间
    ax.XLim = [xLim(1), xLim(2) + 0.05 * diff(xLim)];
    ax.YLim = [yLim(1), yLim(2) + 0.05 * diff(yLim)];
end

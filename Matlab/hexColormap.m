function cmap = hexColormap(hex1, hex2, hex3, n)
% HEXCOLORMAP 创建2色或3色渐变色图
%   cmap = hexColormap(hex1, hex2)       创建从hex1到hex2的256级渐变色图
%   cmap = hexColormap(hex1, hex2, hex3) 创建hex1→hex2→hex3的三段渐变
%   cmap = hexColormap(..., n)           指定色图级数n
%
% 示例：
%   cmap = hexColormap('#ff6e7f', '#bfe9ff');       % 双色渐变
%   cmap = hexColormap('#ff6e7f', 'white', '#bfe9ff'); % 三色渐变

    % 参数验证与默认值
    if nargin < 2
        error('至少需要2个颜色参数！');
    end
    
    % 处理可选参数
    if nargin == 2               % hexColormap(hex1, hex2)
        n = 256;
        colors = {hex1, hex2};
    elseif nargin == 3           % hexColormap(hex1, hex2, hex3) 或 hexColormap(hex1, hex2, n)
        if ischar(hex3)          % 第三个参数是颜色
            colors = {hex1, hex2, hex3};
            n = 256;
        else                     % 第三个参数是n
            n = hex3;
            colors = {hex1, hex2};
        end
    elseif nargin == 4           % hexColormap(hex1, hex2, hex3, n)
        colors = {hex1, hex2, hex3};
    end
    
    % 检查颜色数量
    numColors = numel(colors);
    if numColors < 2 || numColors > 3
        error('颜色参数必须是2个或3个！');
    end
    
    % 去除所有颜色的#符号并转换为RGB
    rgb = zeros(numColors, 3);
    for i = 1:numColors
        hex = strrep(colors{i}, '#', '');
        rgb(i,:) = sscanf(hex, '%2x%2x%2x')' / 255;
    end
    
    % 生成渐变色图
    if numColors == 2
        % 双色线性渐变
        cmap = zeros(n, 3);
        for i = 1:3
            cmap(:,i) = linspace(rgb(1,i), rgb(2,i), n);
        end
    else
        % 三色分段渐变（中间点为50%）
        half = floor(n/2);
        cmap = zeros(n, 3);
        for i = 1:3
            % 第一段：hex1 → hex2
            cmap(1:half,i) = linspace(rgb(1,i), rgb(2,i), half);
            % 第二段：hex2 → hex3
            cmap(half+1:end,i) = linspace(rgb(2,i), rgb(3,i), n-half);
        end
    end
end
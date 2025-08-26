function fig = stackedBarWithAlluvial(dataMatrix, rowLabels, colLabels, colorList)
% 绘制带冲积图链接的堆叠柱状图
% 输入参数：
%   dataMatrix - 数值矩阵 (n×m)，n为分组数，m为类别数（需为百分比形式）
%   rowLabels  - 单元格数组 (n×1)，分组标签（X轴刻度标签）
%   colLabels  - 单元格数组 (1×m)，类别标签（图例项）
%   colorList  - 颜色矩阵 (m×3)，可选参数，指定每个类别的RGB颜色

%% 参数验证与默认设置
if nargin < 4
    % 默认颜色方案（若未提供）
    colorList = [144,170,220; 169,209,143; 255,231,153; 219,219,219]./255;
end

%% 图形初始化
fig = figure('Units','normalized', 'Position',[.2,.2,.5,.55], 'Color', 'w');
ax = axes(fig);

%% 绘制堆叠柱状图
barHdl = bar(ax, dataMatrix, 'stacked',...
    'BarWidth', 0.35,...
    'EdgeColor', 'w',...
    'LineWidth', 1);
barHdl(1).BaseLine.LineStyle = 'none';  % 隐藏基准线

%% 设置柱状图颜色
for k = 1:numel(barHdl)
    barHdl(k).FaceColor = colorList(k,:);
end

%% 添加图例
lgd = legend(ax, colLabels,...
    'AutoUpdate', 'off',...
    'Box', 'off',...
    'FontName', 'TimesSimsun', ...
    'Location', 'eastoutside');
lgd.ItemTokenSize = [15, 8];  % 调整图例标记大小

%% 坐标轴美化
ax.Box = 'off';
ax.TickDir = 'out';
ax.LineWidth = 2;
ax.XLim = [0.5, size(dataMatrix,1)+0.5];
ax.YLim = [-1, 100];
ax.XTick = 1:size(dataMatrix,1);
ax.YTick = 0:25:100;
ax.XTickLabel = rowLabels;
xlabel(ax, 'Explained variation(%)', 'FontSize', 20, 'FontName', 'TimesSimsun');
ax.FontSize = 18;
ax.FontName = 'TimesSimsun';
ylabel(ax, 'Explained variation(%)', 'FontSize', 20, 'FontName', 'TimesSimsun');

%% 绘制冲积图连接部分
hold(ax, 'on');
numGroups = size(dataMatrix,1);  % 分组数量
numCategories = size(dataMatrix,2);  % 类别数量

% 获取每个柱子的顶部Y坐标
yEndPoints = zeros(numCategories, numGroups);
for k = 1:numCategories
    yEndPoints(k,:) = barHdl(k).YEndPoints;
end

% 绘制连接块
barWidth = 0.35 * 0.5;  % 与柱状图宽度匹配
for groupIdx = 1:numGroups-1
    for catIdx = 1:numCategories
        % 计算当前类别在两个相邻柱子上的位置
        x = [groupIdx + barWidth, groupIdx + 1 - barWidth,...
             groupIdx + 1 - barWidth, groupIdx + barWidth];
        
        % 计算Y坐标（当前组顶部 -> 下一组底部）
        y = [yEndPoints(catIdx, groupIdx),...      % 当前组顶部
             yEndPoints(catIdx, groupIdx + 1),...  % 下一组顶部
             yEndPoints(catIdx, groupIdx + 1) - dataMatrix(groupIdx + 1, catIdx),... % 下一组底部
             yEndPoints(catIdx, groupIdx) - dataMatrix(groupIdx, catIdx)];           % 当前组底部
        
        % 绘制半透明连接块
        fill(ax, x, y, colorList(catIdx,:),...
            'FaceAlpha', 0.4,...
            'EdgeColor', 'w',...
            'LineWidth', 1);
    end
end
xlim('manual');
hold(ax, 'off');
end

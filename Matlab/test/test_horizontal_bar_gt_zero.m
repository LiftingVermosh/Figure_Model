clc;
clear
close all;

% 示例数据
labels = {'A组', 'B组', 'C组', 'D组', 'E组', 'F组', 'G组', 'H组', 'I组', 'J组'};
data = sin(linspace(0, pi, 10))*10 + 1;

% 使用默认朝向（向下）
fig1 = horizontal_bar_gt_zero(labels, data);
% 指定朝向上
fig2 = horizontal_bar_gt_zero(labels, data, [], "up");
% 指定朝向下
fig3 = horizontal_bar_gt_zero(labels, data, [], "down");
% 使用自定义颜色映射和朝向上
custom_colors = {'#ff6e7f', '#bfe9ff'};
fig4 = horizontal_bar_gt_zero(labels, data, custom_colors, "up");
% 指定 width = 1
fig5 = horizontal_bar_gt_zero(labels, data, [], "up", 0.75);
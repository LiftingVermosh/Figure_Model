clc;
clear;
close all;
% 测试 GroupedBar 函数
x = 1:3; % x 轴数据，3个类别
y = [1, 4; 2, 5; 3, 6]; % y 数据，3行2列，表示2个组
colormap_param = jet(2); % 使用 jet 颜色映射生成2种颜色（MATLAB 内置）

fig1 = GroupedBar(x, y, colormap_param);
xlabel('X 轴'); % 添加 x 轴标签
ylabel('Y 轴'); % 添加 y 轴标签
% 测试 GroupedBar 函数
x = 1:3; % x 轴数据，3个类别
y = [1, 4, 7; 2, 5, 8; 3, 6, 9]; % y 数据，3行2列，表示2个组

fig2 = grouped_bar(x, y);
xlabel('X 轴'); % 添加 x 轴标签
ylabel('Y 轴'); % 添加 y 轴标签

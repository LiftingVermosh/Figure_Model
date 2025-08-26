clc;
clear;
close all;

% 示例数据（包含负值）
labels = {'A组', 'B组', 'C组', 'D组', 'E组', 'F组', 'G组', 'H组', 'I组', 'J组'};
data = sin(linspace(0, 2*pi, 10))*10 + rand(1)*5;

% 使用默认参数
fig1 = horizontal_bar(labels, data);

% 指定朝向上
fig2 = horizontal_bar(labels, data, [], "up");

% 指定条宽
fig3 = horizontal_bar(labels, data, [], "down", 0.3);

% 使用自定义颜色映射
custom_colors = {'#ff0000', '#0000ff'}; % 红色到蓝色
fig4 = horizontal_bar(labels, data, custom_colors, "down");

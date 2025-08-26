clc;
clear;
close all;

x = 1:10; % x轴从1到10
y = zeros(10, 6); % 初始化y矩阵，10行6列

% 生成6组有明显曲折的数据（使用正弦函数和噪声）
for i = 1:6
    frequency = i * 0.2; % 频率随组号增加
    amplitude = i * 0.4; % 幅度随组号增加
    noise = randn(1, 10) * 0.5; % 添加噪声
    y(:, i) = amplitude * frequency * x + noise; % 生成曲折数据
end

% 调用函数，不提供colormap_param（使用默认颜色渐变）
fig = grouped_line(x, y);

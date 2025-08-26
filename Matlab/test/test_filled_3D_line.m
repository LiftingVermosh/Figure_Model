clc
clear;
close all;
n_time = 10; % 时间点数
n_cat = 3;   % 类别数
data = rand(n_time, n_cat) * 100; % 随机数据，范围0-100
timeVector = datetime(2023, 1, 1) + days(0:n_time-1); % 日期时间向量
categories = {'Category A', 'Category B', 'Category C'}; % 类别名称

% 指定十六进制颜色
hex1 = '#D9FF88'; % 用户提供的 hex1
hex2 = '#FFFFFF'; % 用户提供的 hex2
fill_colors = {hex1, hex2}; % 作为单元数组传递

% 调用 plot3DfilledLines
fig = filled_3D_line(data, timeVector, fill_colors, categories);

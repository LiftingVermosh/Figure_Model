% 测试气泡图函数 bubble_plot
clear; clc; close all;

% 设置随机种子以确保结果可重现
rng(42);

% 生成 n 个随机点 (x, y)
n = 200;
x = rand(n, 1) * 100; % x坐标在0-100之间
y = rand(n, 1) * 100; % y坐标在0-100之间
points = [x, y];

% 生成权重向量v，模拟不同大小的气泡
% 使用正态分布生成权重，然后归一化到0-1范围
v = abs(randn(n, 1));
v = (v - min(v)) / (max(v) - min(v));

% 设置基础半径和透明度
r = 5;
alpha_value = 0.6;

% 测试用例1: 使用默认颜色
fig1 = bubble_plot(points, v, {}, r, alpha_value);
title('测试用例1: 默认颜色');

% 测试用例2: 使用双色渐变，基于x轴映射
colormap_param2 = {'#009FFF', '#EC2F4B'}; % 红到蓝渐变
fig2 = bubble_plot(points, v, colormap_param2, r, alpha_value);
title('测试用例2: 红到蓝渐变 (基于x轴映射)');

% 测试用例3: 使用三色渐变，基于x轴映射
colormap_param3 = {'#FEAC5E', '#C779D0', '#4BC0C8'}; % 3色渐变
fig3 = bubble_plot(points, v, colormap_param3, r, alpha_value);
title('测试用例3: 3色渐变 (基于x轴映射)');

% % 测试用例4: 为每个点指定单独的颜色
% % 生成随机颜色
% colors = rand(n, 3); % 生成n个RGB颜色
% colormap_param4 = mat2cell(colors, ones(n,1), 3); % 转换为单元数组
% fig4 = bubble_plot(points, v, colormap_param4, r, alpha_value);
% title('测试用例4: 随机颜色 (每个点单独指定)');

% % 测试用例5: 使用预定义的彩虹色
% % 生成彩虹色映射
% rainbow_colors = hsv(n); % 使用HSV颜色空间生成彩虹色
% colormap_param5 = rainbow_colors;
% fig5 = bubble_plot(points, v, colormap_param5, r, alpha_value);
% title('测试用例5: 彩虹色');

% 测试用例6: 使用不同的半径和透明度
r_large = 8; % 更大的半径
alpha_low = 0.3; % 更低的透明度
fig6 = bubble_plot(points, v, colormap_param2, r_large, alpha_low);
title('测试用例6: 更大半径和更低透明度');

% 显示数据统计信息
fprintf('测试数据统计:\n');
fprintf('点数: %d\n', n);
fprintf('x坐标范围: [%.2f, %.2f]\n', min(x), max(x));
fprintf('y坐标范围: [%.2f, %.2f]\n', min(y), max(y));
fprintf('权重范围: [%.2f, %.2f]\n', min(v), max(v));
fprintf('基础半径: %.2f\n', r);
fprintf('透明度: %.2f\n', alpha_value);

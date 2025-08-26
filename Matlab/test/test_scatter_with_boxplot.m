clc;
clear;
close all;

fprintf('开始测试 scatter_with_histograms 函数...\n');

% 测试1：默认颜色参数
fprintf('\n测试1：默认颜色参数\n');
data1 = randn(100, 2); % 生成100个随机点
fig1 = scatter_with_boxplot(data1);

% 测试2：两个hex颜色渐变
fprintf('\n测试2：两个hex颜色渐变\n');
data2 = [randn(50, 1), randn(50, 1)]; % 生成50个点，x为随机正态分布，y为均匀分布
colormap_param2 = {'#ff0000', '#0000ff'}; % 从红到蓝渐变
fig2 = scatter_with_boxplot(data2, colormap_param2);


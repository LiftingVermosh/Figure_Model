% 生成测试用例并测试 filled_2D_line 函数
% 设置随机种子以确保结果可重现
rng(44);

% 参数设置
n = 10; % 线段数量
min_points = 500; % 每条线段最少点数
max_points = 1000; % 每条线段最多点数
x_min_global = 0; % x坐标全局最小值
x_max_global = 200; % x坐标全局最大值

% 生成测试数据 - 正态分布样式且起始点都在x轴
data_matrix = zeros(n, max_points, 2); % 预分配空间

for i = 1:n
    % 随机确定当前线段的点数
    m = randi([min_points, max_points]);
    
    % 随机生成起始点和结束点，确保在0~200之间且起始点都在x轴
    x_start = rand() * (x_max_global - 50); % 起始点随机，留有余地确保结束点<=200
    x_end = x_start + rand() * (x_max_global - x_start); % 结束点随机，但大于起始点
    x_end = min(x_end, x_max_global); % 确保结束点不超过200
    
    % 生成x坐标 - 在起始点和结束点之间均匀分布
    x = linspace(x_start, x_end, m);
    
    % 生成y坐标 - 使用正态分布样式，确保起始点和结束点都在x轴(y=0)
    % 计算中点位置
    x_mid = (x_start + x_end) / 2;
    % 计算标准差，控制曲线的宽度
    sigma = (x_end - x_start) / 6; % 确保曲线在±3σ内
    % 生成正态分布曲线
    y = rand() * 20 * exp(-(x - x_mid).^2 / (2 * sigma^2)); % 振幅最大为20
    
    % 将数据存入矩阵
    data_matrix(i, 1:m, 1) = x;
    data_matrix(i, 1:m, 2) = y;
    
    % 剩余部分填充0（函数会跳过0值点）
    if m < max_points
        data_matrix(i, m+1:end, :) = 0;
    end
end

% 测试1：使用默认颜色（从红到紫的色环过渡）
disp('测试1：使用默认颜色（从红到紫的色环过渡）');
fig1 = filled_2D_line(data_matrix, []);
title('测试1：使用默认颜色（从红到紫的色环过渡）');

% % 测试2：使用两个颜色的渐变映射到x轴
% disp('测试2：使用两个颜色的渐变映射到x轴');
% colormap_param = {'#ff6e7f', '#bfe9ff'}; % 粉红色到淡蓝色的渐变
% fig2 = filled_2D_line(data_matrix, colormap_param);
% title('测试2：使用两个颜色的渐变映射到x轴');

disp('所有测试完成！');

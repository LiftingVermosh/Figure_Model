
% TEST_DIVERGING_SCATTER 测试 diverging_scatter 函数
%   生成大规模测试数据，包含多个类，每类20-50个点，测试不同颜色参数和可见性设置

% 设置随机种子以确保结果可重现
rng(42);

% 定义参数
n_classes = 2; % 类数
min_points = 100; % 每类最少点数
max_points = 200; % 每类最多点数

% 生成中心点 (2 x n 矩阵)
center_points = 10 * rand(2, n_classes);

% 生成数据矩阵 (n x m x 2)
% 确定每类的点数
points_per_class = randi([min_points, max_points], 1, n_classes);
max_points_per_class = max(points_per_class);

% 初始化数据矩阵
data_matrix = zeros(n_classes, max_points_per_class, 2);

% 为每个类生成数据点
for i = 1:n_classes
    n_points = points_per_class(i);
    
    % 生成围绕中心点的随机点
    center = center_points(:, i)';
    data_points = zeros(n_points, 2);
    
    for j = 1:n_points
        % 随机方向和距离
        angle = 2 * pi * rand();
        distance = 2 * rand();
        
        % 计算点坐标
        data_points(j, 1) = center(1) + distance * cos(angle);
        data_points(j, 2) = center(2) + distance * sin(angle);
    end
    
    % 将数据点放入矩阵
    data_matrix(i, 1:n_points, :) = reshape(data_points, [1, n_points, 2]);
    
    % 随机添加一些空值 (0,0)
    empty_indices = randperm(n_points, floor(n_points/10));
    data_matrix(i, empty_indices, :) = 0;
end

% 测试1: 使用默认颜色
fprintf('测试1: 使用默认颜色，中心点可见\n');
fig1 = diverging_scatter(center_points, data_matrix, [], false);
set(fig1, 'Name', '测试1: 默认颜色，中心点可见');

% % 测试2: 使用双色渐变
% fprintf('测试2: 使用双色渐变，中心点不可见\n');
% fig2 = diverging_scatter(center_points, data_matrix, {'#ff6e7f', '#bfe9ff'}, false);
% set(fig2, 'Name', '测试2: 双色渐变，中心点不可见');
% 
% % 测试3: 为每个类指定颜色
% fprintf('测试3: 为每个类指定颜色，中心点可见\n');
% colors = {'#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7'};
% fig3 = diverging_scatter(center_points, data_matrix, colors, true);
% set(fig3, 'Name', '测试3: 每个类指定颜色，中心点可见');
% 
% % 测试4: 使用颜色矩阵
% fprintf('测试4: 使用颜色矩阵，中心点可见\n');
% color_matrix = [
%     0.8, 0.2, 0.2;  % 红色
%     0.2, 0.8, 0.2;  % 绿色
%     0.2, 0.2, 0.8;  % 蓝色
%     0.8, 0.8, 0.2;  % 黄色
%     0.8, 0.2, 0.8   % 紫色
% ];
% fig4 = diverging_scatter(center_points, data_matrix, color_matrix, true);
% set(fig4, 'Name', '测试4: 颜色矩阵，中心点可见');
% 
% % 显示数据统计信息
% fprintf('\n测试数据统计:\n');
% fprintf('类数: %d\n', n_classes);
% for i = 1:n_classes
%     n_points = points_per_class(i);
%     n_empty = sum(all(reshape(data_matrix(i, :, :), max_points_per_class, 2) == 0, 2));
%     fprintf('类 %d: %d 个点 (%d 个空值)\n', i, n_points, n_empty);
% end

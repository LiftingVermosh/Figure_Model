function test_lollipop_plot()
    % TEST_LOLLIPOP_PLOT 测试棒棒糖图函数
    %   该函数测试 lollipop_plot 函数的不同使用场景，不保存图像
    
    clc;
    close all;

    fprintf('开始测试棒棒糖图函数...\n');
    
    % 创建测试数据
    x = linspace(0, 10, 40)';
    y = 5 * sin(x);
    test_data = [x, y];
    
    % 测试用例1: 默认颜色
    fprintf('测试用例1: 默认颜色\n');
    fig1 = lollipop_plot(test_data);
    
    % 测试用例2: 双色渐变
    fprintf('测试用例2: 双色渐变\n');
    colormap_param = {'#ff0000', '#0000ff'}; % 红到蓝渐变
    fig2 = lollipop_plot(test_data, colormap_param);
    
    % 测试用例3: 直接指定颜色
    fprintf('测试用例3: 直接指定颜色\n');
    % 创建一组颜色
    colors = cell(size(test_data, 1), 1);
    for i = 1:size(test_data, 1)
        % 根据y值大小选择颜色
        if test_data(i, 2) > 0
            colors{i} = '#00ff00'; % 绿色表示正值
        else
            colors{i} = '#ff0000'; % 红色表示负值
        end
    end
    fig3 = lollipop_plot(test_data, colors);
    
    % 测试用例4: RGB矩阵
    fprintf('测试用例4: RGB矩阵\n');
    rgb_matrix = zeros(size(test_data, 1), 3);
    for i = 1:size(test_data, 1)
        % 根据x值创建渐变颜色
        t = (test_data(i, 1) - min(test_data(:, 1))) / (max(test_data(:, 1)) - min(test_data(:, 1)));
        rgb_matrix(i, :) = [t, 0, 1-t]; % 从紫色到蓝色渐变
    end
    fig4 = lollipop_plot(test_data, rgb_matrix);
    
    % 测试用例5: 空颜色参数
    fprintf('测试用例5: 空颜色参数\n');
    fig5 = lollipop_plot(test_data, []);
    
    % 测试用例6: 边缘情况 - 单点数据
    fprintf('测试用例6: 单点数据\n');
    single_point = [5, 3];
    fig6 = lollipop_plot(single_point, {'#ff9900'});

    % 测试用例7: 相同x值
    fprintf('测试用例7: 相同x值\n');
    same_x = [ones(5,1), rand(5,1)*2];
    fig7 = lollipop_plot(same_x, {'#ff0000', '#00ff00'});
    
    fprintf('所有测试用例完成!\n');
end

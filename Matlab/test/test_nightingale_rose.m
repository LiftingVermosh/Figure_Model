function test_nightingale_rose()
% TEST_NIGHTINGALE_ROSE 测试南丁格尔玫瑰图函数
%   生成12个数据点，并调用nightingale_rose_chart函数进行测试
    
    % 生成12个月份的标签
    months = {'一月', '二月', '三月', '四月', '五月', '六月', ...
              '七月', '八月', '九月', '十月', '十一月', '十二月'};
    
    % 生成12个随机数值（范围在10到100之间）
    values = randi([10, 100], 1, 12);
    
    % % 定义颜色参数（使用蓝到红的渐变）
    % colormap_param = {'#3498db', '#db346e'};
    
    % 调用南丁格尔玫瑰图函数
    fig = nightingale_rose(months, values, []);
    
    fig = nightingale_rose(months, values, [], false);
    % 显示生成的数据
    fprintf('测试数据：\n');
    for i = 1:length(months)
        fprintf('%s: %.1f\n', months{i}, values(i));
    end
end

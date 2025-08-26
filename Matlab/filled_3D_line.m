function fig = filled_3D_line(data, timeVector, fill_colors, categories)
    % 绘制三维填充折线图，每组数据位于不同的yOz平面
    % 输入:
    %   data        - 数值矩阵，每列代表一个类别的数据序列（行数代表时间点）
    %   timeVector  - 时间向量（日期时间数组或数值向量）
    %   fill_colors - RGB颜色矩阵（n_cat x 3或3 x n_cat）或单元数组包含两个十六进制颜色字符串（如{'#D9FF88','#FFFFFF'}）
    %   categories  - 类别名称的元胞数组
    
    % 获取数据维度
    [n_time, n_cat] = size(data);
    
    % 验证时间向量长度
    if length(timeVector) ~= n_time
        error('时间向量长度必须与数据的时间点数一致');
    end
    
    % 处理 fill_colors 参数
    if nargin < 3 || isempty(fill_colors)
        % 使用默认十六进制颜色
        hex1 = '#D9FF88';
        hex2 = '#FFFFFF';
        fill_colors = generateColorMap(hex1, hex2, n_cat);
    elseif iscell(fill_colors)
        % 如果 fill_colors 是单元数组，假设包含两个十六进制颜色
        if numel(fill_colors) >= 2
            hex1 = fill_colors{1};
            hex2 = fill_colors{2};
            fill_colors = generateColorMap(hex1, hex2, n_cat);
        else
            error('如果 fill_colors 是单元数组，必须包含至少两个十六进制颜色字符串。');
        end
    else
        % fill_colors 是矩阵，检查尺寸并归一化
        if size(fill_colors, 1) ~= n_cat || size(fill_colors, 2) ~= 3
            if size(fill_colors, 2) == 3 && size(fill_colors, 1) == n_cat
                % 尺寸正确，n_cat x 3
            elseif size(fill_colors, 1) == 3 && size(fill_colors, 2) == n_cat
                fill_colors = fill_colors'; % 转置为 n_cat x 3
            else
                error('fill_colors 矩阵必须是 n_cat x 3 或 3 x n_cat 的尺寸。');
            end
        end
        % 归一化颜色值到 [0,1] 范围
        if max(fill_colors(:)) > 1
            fill_colors = fill_colors / 255;
        end
    end
    
    % 创建三维图形
    fig = figure('Position', [100 100 1200 600], 'Color', 'w');
    ax = gca;
    ax.FontName = 'TimesSimsun';
    ax.FontWeight = 'bold';
    
    hold on;
    grid on;
    view(3); % 设置三维视角
    
    % 设置x轴位置（每组数据在x轴上的位置）
    x_positions = 1:(n_cat+1);
    
    % 循环绘制每个类别
    for i = 1:n_cat
        % 当前类别的数据
        z_data = data(:, i);
        
        % 当前类别在x轴上的位置
        x_i = x_positions(i);
        
        % 创建填充多边形的顶点
        X_fill = [repmat(x_i, n_time, 1); flipud(repmat(x_i, n_time, 1))];
        Y_fill = [timeVector(:); flipud(timeVector(:))];  % 使用时间向量
        Z_fill = [z_data; zeros(n_time, 1)];
        
        % 绘制填充区域
        fill3(X_fill, Y_fill, Z_fill, fill_colors(i, :), ...
              'FaceAlpha', 0.7, ...    % 设置透明度
              'EdgeColor', 'none', ...  % 去掉填充边界
              'DisplayName', categories{i});
        
        % 绘制数据线（顶部边界）
        plot3(repmat(x_i, n_time, 1), timeVector, z_data, ...
              'Color', fill_colors(i, :) * 0.7, ... % 使用更深的同色系
              'LineWidth', 1.5, ...
              'HandleVisibility', 'off');
        
        % 绘制底面边界（z=0平面）
        plot3(repmat(x_i, n_time, 1), timeVector, zeros(n_time, 1), ...
              'Color', [0.5 0.5 0.5], ... 
              'LineWidth', 0.5, ...
              'LineStyle', '--', ...
              'HandleVisibility', 'off');
        
        % 添加侧面连接线（前后边界）
        plot3([x_i, x_i], [timeVector(1), timeVector(1)], [0, z_data(1)], ...
              'Color', [0.7 0.7 0.7], 'LineWidth', 0.5, ...
              'HandleVisibility', 'off');
        plot3([x_i, x_i], [timeVector(end), timeVector(end)], [0, z_data(end)], ...
              'Color', [0.7 0.7 0.7], 'LineWidth', 0.5, ...
              'HandleVisibility', 'off');
    end
    
    % 设置x轴刻度和标签
    set(gca, 'XTick', x_positions(1:n_cat), 'XTickLabel', categories);
    
    % 设置y轴为时间格式
    if isdatetime(timeVector)
        ylabel('日期');
        
        % 自动选择合适的时间间隔
        timeRange = range(timeVector);
        if timeRange < days(60)
            % 小于60天，显示日期间隔为每周
            set(gca, 'YTick', timeVector(1):days(7):timeVector(end));
            ytickformat('yyyy-MM-dd');
        elseif timeRange < days(365)
            % 小于1年，显示月间隔
            set(gca, 'YTick', dateshift(timeVector(1), 'start', 'month'):calmonths(1):dateshift(timeVector(end), 'start', 'month'));
            ytickformat('yyyy-MM');
        elseif timeRange < days(365*3)
            % 1-3年，显示季度间隔 - 修正部分
            % 获取季度开始日期
            startQuarter = dateshift(timeVector(1), 'start', 'quarter');
            endQuarter = dateshift(timeVector(end), 'start', 'quarter');

            % 按季度生成序列
            quarters = startQuarter:calmonths(3):endQuarter;

            % 设置刻度并格式化标签
            set(gca, 'YTick', quarters);
            set(gca, 'YTickLabel', arrayfun(@(d) sprintf('%d-Q%d', year(d), quarter(d)), quarters, 'UniformOutput', false));
        else
            % 大于3年，显示年间隔
            set(gca, 'YTick', dateshift(timeVector(1), 'start', 'year'):calyears(1):dateshift(timeVector(end), 'start', 'year'));
            ytickformat('yyyy');
        end
    else
        % 数值型时间格式
        ylabel('时间点');
    end
    
    % 设置坐标轴标签
    xlabel('类别');
    zlabel('销售额');
    
    % 美化图形
    xlim([0, (n_cat+1)]);
    ylim([min(timeVector), max(timeVector)]);
    box on;
    
    lighting gouraud;
    material dull;  % 使用更自然的材质反射
    
    % 设置视角
    view(-40, 30); % 调整视角角度
    
    hold off;
end

% 局部函数：生成颜色映射
function cmap = generateColorMap(hex1, hex2, n)
    rgb1 = hex2rgb(hex1);
    rgb2 = hex2rgb(hex2);
    r = linspace(rgb1(1), rgb2(1), n)';
    g = linspace(rgb1(2), rgb2(2), n)';
    b = linspace(rgb1(3), rgb2(3), n)';
    cmap = [r, g, b];
end

% 局部函数：十六进制转RGB
function rgb = hex2rgb(hexStr)
    if hexStr(1) == '#'
        hexStr = hexStr(2:end);
    end
    r = hex2dec(hexStr(1:2)) / 255;
    g = hex2dec(hexStr(3:4)) / 255;
    b = hex2dec(hexStr(5:6)) / 255;
    rgb = [r, g, b];
end

function create3DPieWithLabels(data, labels, fig_title, colors)
    %% 注解
    % @Function create3DPieWithLabels
    % @Description 创建带有标签和高度变化的3D饼图
    % @Param data: 数值数组，表示每个扇区的值
    % @Param labels: 字符串数组，表示每个扇区的标签
    % @Param fig_title: 字符串，图表标题
    % @Param colors: Nx3矩阵，表示每个扇区的RGB颜色
    % @Return 无返回值，直接生成图形窗口
    
    %% ==================== 参数检查 ==================== 
    % @Check 参数规模一致性检查
    if length(data) ~= length(labels) || length(data) ~= size(colors,1)
        error('参数规模不匹配: data(%d), labels(%d), colors(%d)', ...
              length(data), length(labels), size(colors,1));
    end
    
    % @Check 数据有效性检查
    if any(data <= 0)
        error('所有data值必须为正数');
    end
    
    % @Check 颜色矩阵检查
    if size(colors,2) ~= 3 || any(colors(:) < 0) || any(colors(:) > 1)
        error('颜色矩阵必须为Nx3格式，且值在0-1范围内');
    end
    
    %% ==================== 图形初始化 ====================
    % @Init 创建图形窗口
    figure('Position', [100, 100, 1000, 800], 'Color', 'white');
    set(gcf, 'Name', '3D高度可变饼图', 'NumberTitle', 'off');
    
    % @Compute 计算基本参数
    total = sum(data);
    heights = data / total;  % 高度归一化
    cum_angles = [0, cumsum(data)/total * 2*pi];  % 累积角度

    % @Init 创建3D坐标系
    ax = axes('Position', [0.15 0.1 0.7 0.8]);
    hold(ax, 'on');
    axis(ax, 'equal', 'vis3d');
    view(ax, 135, 30);
    grid(ax, 'on');
    title(ax, fig_title, 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Simsun');
    
    % @Config 曲面平滑度控制
    n_segments = 50;  % 分段数
    
    %% ==================== 绘制扇区 ====================
    % @Loop 遍历每个数据点绘制扇区
    for i = 1:length(data)
        % @Get 当前扇区参数
        theta_start = cum_angles(i);
        theta_end = cum_angles(i+1);
        h = heights(i);
        color = colors(i,:);
        mid_angle = (theta_start + theta_end)/2;  % 中间角度
        
        % @Draw 绘制侧面 (曲面)
        theta = linspace(theta_start, theta_end, n_segments);
        z = linspace(0, h, 2)';
        x = [cos(theta); cos(theta)];
        y = [sin(theta); sin(theta)];
        z = repmat(z, 1, length(theta));
        surf(ax, x, y, z, 'FaceColor', color, 'EdgeColor', 'none', 'FaceAlpha', 0.9);
        
        % @Draw 绘制顶面 (扇形)
        x_top = [0, cos(theta), 0];
        y_top = [0, sin(theta), 0];
        z_top = h * ones(size(x_top));
        fill3(ax, x_top, y_top, z_top, color, 'EdgeColor', 'none', 'FaceAlpha', 0.9, 'HandleVisibility', 'off');
        
        % @Draw 绘制两个直边
        patch(ax, [0, cos(theta_start), cos(theta_start), 0], ...
                 [0, sin(theta_start), sin(theta_start), 0], ...
                 [0, 0, h, h], color, 'EdgeColor', 'none', 'FaceAlpha', 0.8, 'HandleVisibility', 'off');
        patch(ax, [0, cos(theta_end), cos(theta_end), 0], ...
                 [0, sin(theta_end), sin(theta_end), 0], ...
                 [0, 0, h, h], color, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
        
        %% ========== 添加引注线 ==========
        % @Config 引注线参数
        start_radius = 0.8;  % 起点在扇区上的位置
        label_radius = 1.6;  % 标签在饼图外的位置
        
        % @Compute 计算引注线坐标
        x_start = start_radius * cos(mid_angle);
        y_start = start_radius * sin(mid_angle);
        z_start = h;
        x_label = label_radius * cos(mid_angle);
        y_label = label_radius * sin(mid_angle);
        z_label = h + 0.05;
        
        % @Compute 计算引注线转折点
        if abs(mid_angle) < pi/4 || abs(mid_angle - pi) < pi/4
            % 右侧区域
            x_mid = x_label;
            y_mid = y_start;
        elseif abs(mid_angle - pi/2) < pi/4 || abs(mid_angle - 3*pi/2) < pi/4
            % 顶部/底部区域
            x_mid = x_start;
            y_mid = y_label;
        else
            % 左侧区域
            x_mid = x_label;
            y_mid = y_start;
        end
        
        % @Draw 绘制引注线
        plot3(ax, [x_start, x_mid, x_label], ...
                 [y_start, y_mid, y_label], ...
                 [z_start, z_start, z_label], ...
                 'Color', '#B3B3B3', 'LineWidth', 1, 'LineStyle', '-', 'HandleVisibility', 'off');
        
        % @Draw 添加标签文本
        label_str = sprintf('%s: %.1f%%', labels{i}, data(i)/total*100);
        text(ax, x_label, 1.1*y_label, 1.1*z_label, label_str, ...
             'FontSize', 10, 'FontWeight', 'bold', ...
             'HorizontalAlignment', 'center', ...
             'BackgroundColor', 'white', ...
             'EdgeColor', 'white', ...
             'Margin', 2.5, 'FontName', 'Simsun');

        % @Draw 添加数据点标记
        scatter3(ax, x_start, y_start, z_start, 80, 'filled', ...
                 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
    end

    %% ==================== 图形美化 ====================
    % @Effect 添加光照效果
    light('Position', [-1,0,1], 'Style', 'infinite');
    light('Position', [0,1,0.5], 'Style', 'infinite');
    lighting gouraud;
    
    % @Layer 调整对象显示优先级
    % @Note 确保文本和标记在最上层
    uistack(findobj(ax, 'Type', 'Scatter'), 'top');
    uistack(findobj(ax, 'Type', 'Text'), 'top');
    uistack(findobj(ax, 'Type', 'Light'), 'top');
    uistack(findobj(ax, 'Type', 'patch'), 'bottom');
    uistack(findobj(ax, 'Type', 'Line'), 'bottom');

    % @Config 坐标轴设置
    axis(ax, [-1.8 1.8 -1.8 1.8 0 max(heights)+0.1]);
    grid off;
    box off;
    ax.ZAxis.Visible = 'off';
    ax.XAxis.Visible = 'off';
    ax.YAxis.Visible = 'off';
    
    % @UI 添加图例
    legend_labels = cellfun(@(lbl, d, h) sprintf('%s: %2.2f%%', lbl, h*100), ...
                          labels, num2cell(data), num2cell(heights), 'UniformOutput', false);
    legend(ax, legend_labels, 'Location', 'best', 'FontSize', 10, 'FontName', 'Simsun');
    
    hold(ax, 'off');
end
function fig = sankey_diagram(data, connection, colormap_param)
% SANKEYPLOT 绘制桑基图
%   输入:
%       data: n x m 矩阵，n 是层级数，m 是每层最大节点数。data(i,j) > 0 表示节点存在，值为流量。
%       connection: (n-1) x m x m 矩阵，connection(i,j,k) 表示从层级 i 节点 j 到层级 i+1 节点 k 的流量。
%       colormap_param: 可选，颜色参数。如果缺失或空，使用默认颜色；如果是两个元素的细胞数组，包含颜色hex码（如 {'#FF0000', '#0000FF'}），
%                       则生成从第一个颜色到第二个颜色的平滑过渡颜色图，映射到x轴。
%   输出:
%       fig: 图窗对象

% 参数检查
if nargin < 3
    colormap_param = [];
end

% 获取 data 的维度
[n, m] = size(data);

% 检查 connection 的维度
if size(connection, 1) ~= n-1 || size(connection, 2) ~= m || size(connection, 3) ~= m
    error('Connection 矩阵的维度必须为 (n-1) x m x m');
end

% 检查 connection 中边两端的节点是否存在
for i = 1:n-1
    for j = 1:m
        for k = 1:m
            if connection(i,j,k) > 0
                if data(i,j) <= 0 || data(i+1,k) <= 0
                    error('连接从层级 %d 节点 %d 到层级 %d 节点 %d 的流量为正，但节点不存在', i, j, i+1, k);
                end
            end
        end
    end
end

% 设置绘图参数
x_min = 0; % x轴最小值
x_max = 1 * 1.5 * m; % x轴最大值
y_min = 0; % y轴最小值
y_max = 1 * m; % y轴最大值
l = 0.1 * m;   % 节点矩形固定长度（x方向）
epsilon = 0.05 * m; % 同层级节点间的空隙

% 计算层级中心 x 位置，均匀分布在 x 轴上，考虑节点宽度
x_positions = linspace(x_min + l/2, x_max - l/2, n);

% 计算每层总流量
layer_sums = sum(data, 2); % n x 1 向量，每层流量总和

% 初始化节点高度和 y 底部位置矩阵
node_heights = zeros(n, m);
node_y_bottoms = zeros(n, m);

% 计算每个节点的 y 位置和高度
for i = 1:n
    valid_indices = find(data(i, :) > 0); % 该层存在的节点索引
    num_valid = length(valid_indices);
    if num_valid == 0
        continue;
    end
    % 该层可用总高度（减去空隙）
    total_available_height = (y_max - y_min) - num_valid * epsilon;
    % 计算每个节点的高度
    heights = (data(i, valid_indices) / layer_sums(i)) * total_available_height;
    % 计算 y 底部位置，从 y_min 开始堆叠
    current_y = y_min;
    for idx = 1:num_valid
        j = valid_indices(idx);
        node_heights(i, j) = heights(idx);
        node_y_bottoms(i, j) = current_y;
        current_y = current_y + heights(idx) + epsilon;
    end
end

% 处理颜色映射
if isempty(colormap_param)
    color1 = hex2rgb('#43CBFF');
    color2 = hex2rgb('#9708CC');
    % 创建颜色映射函数，基于 x 位置
    colormap_fn = @(x) (1 - x) * color1 + x * color2;
else
    if numel(colormap_param) ~= 2
        error('colormap_param 必须包含两个颜色值（hex 码）');
    end
    % 解析 hex 颜色
    color1 = hex2rgb(colormap_param{1});
    color2 = hex2rgb(colormap_param{2});
    % 创建颜色映射函数，基于 x 位置
    colormap_fn = @(x) (1 - x) * color1 + x * color2;
end

% 创建图窗
fig = figure('Position', [100, 100, 800, 600], 'Color', 'w', 'Name', '桑基图');
hold on;
axis equal;
xlim([x_min, x_max]);
ylim([y_min, y_max]);

% 绘制节点矩形
for i = 1:n
    for j = 1:m
        if data(i, j) > 0
            x_center = x_positions(i);
            x_left = x_center - l/2;
            y_bottom = node_y_bottoms(i, j);
            height = node_heights(i, j);
            
            % 计算节点中心点的归一化x位置
            x_norm_node = (x_center - x_min) / (x_max - x_min);
            
            % 使用颜色映射函数获取颜色
            node_color = colormap_fn(x_norm_node);
            
            % 绘制矩形，使用节点中心点对应的颜色
            rectangle('Position', [x_left, y_bottom, l, height], ...
                     'FaceColor', node_color, 'EdgeColor', 'none');
        end
    end
end

% 绘制连接
for i = 1:n-1
    for j = 1:m
        if data(i, j) <= 0
            continue; % 源节点不存在，跳过
        end
        % 获取源节点 (i,j) 的所有流出流量
        out_flows = squeeze(connection(i, j, :));
        valid_k = find(out_flows > 0);
        if isempty(valid_k)
            continue;
        end
        % 计算流出流量的累计比例（用于确定 y 位置）
        total_out = sum(out_flows);
        cum_flow = cumsum(out_flows(valid_k)) / total_out;
        % 源节点参数
        src_x_right = x_positions(i) + l/2;
        src_y_bottom = node_y_bottoms(i, j);
        src_height = node_heights(i, j);
        
        for idx = 1:length(valid_k)
            k = valid_k(idx);
            if data(i+1, k) <= 0
                continue; % 目标节点不存在，跳过
            end
            flow_val = out_flows(k);
            % 计算源侧 y 范围（基于累计流量）
            if idx == 1
                y_src_start = src_y_bottom;
            else
                y_src_start = src_y_bottom + cum_flow(idx-1) * src_height;
            end
            y_src_end = src_y_bottom + cum_flow(idx) * src_height;
            
            % 目标节点 (i+1,k) 参数
            tgt_x_left = x_positions(i+1) - l/2;
            tgt_y_bottom = node_y_bottoms(i+1, k);
            tgt_height = node_heights(i+1, k);
            % 获取目标节点的所有流入流量
            in_flows = squeeze(connection(i, :, k));
            valid_j_in = find(in_flows > 0);
            total_in = sum(in_flows);
            cum_in_flow = cumsum(in_flows(valid_j_in)) / total_in;
            % 找到当前源节点 j 在流入中的索引
            j_idx_in = find(valid_j_in == j, 1);
            if isempty(j_idx_in)
                continue;
            end
            % 计算目标侧 y 范围
            if j_idx_in == 1
                y_tgt_start = tgt_y_bottom;
            else
                y_tgt_start = tgt_y_bottom + cum_in_flow(j_idx_in-1) * tgt_height;
            end
            y_tgt_end = tgt_y_bottom + cum_in_flow(j_idx_in) * tgt_height;
            
            % 计算连接的中心 x 位置用于颜色映射
            x_mid = (src_x_right + tgt_x_left) / 2;
            x_norm = (x_mid - x_min) / (x_max - x_min); % 归一化到 [0,1]
            color = colormap_fn(x_norm);
            
            % 绘制平滑连接（使用二次贝塞尔曲线近似）
            num_points = 20; % 曲线点数
            t = linspace(0, 1, num_points);
            % 控制点设置 for curvature
            ctrl_x = (src_x_right + tgt_x_left) / 2;
            ctrl_y_offset = 0.025 * (tgt_x_left - src_x_right) * m; % 弯曲偏移量
            ctrl_y_low = (y_src_start + y_tgt_start) / 2 + ctrl_y_offset;
            ctrl_y_high = (y_src_end + y_tgt_end) / 2 - ctrl_y_offset;
            
            % 计算下边界曲线点
            x_low = (1-t).^2 * src_x_right + 2*(1-t).*t * ctrl_x + t.^2 * tgt_x_left;
            y_low = (1-t).^2 * y_src_start + 2*(1-t).*t * ctrl_y_low + t.^2 * y_tgt_start;
            
            % 计算上边界曲线点
            x_high = (1-t).^2 * src_x_right + 2*(1-t).*t * ctrl_x + t.^2 * tgt_x_left;
            y_high = (1-t).^2 * y_src_end + 2*(1-t).*t * ctrl_y_high + t.^2 * y_tgt_end;
            
            % 绘制多边形填充连接
            % 将连接带分成多个小段，每段使用其中心点对应的颜色
            % 设置分段数量
            num_segments = 100; % 可以根据需要调整，值越大渐变越平滑
            % 对每个连接带进行分段绘制
            for seg = 1:num_segments
                % 计算当前段的参数范围
                t_start = (seg-1)/num_segments;
                t_end = seg/num_segments;
                
                % 计算当前段的中心点用于颜色映射
                t_mid = (t_start + t_end) / 2;
                x_mid = (1-t_mid)^2 * src_x_right + 2*(1-t_mid)*t_mid * ctrl_x + t_mid^2 * tgt_x_left;
                x_norm = (x_mid - x_min) / (x_max - x_min); % 归一化到 [0,1]
                segment_color = colormap_fn(x_norm);
                
                % 计算当前段的下边界曲线点
                t_segment = linspace(t_start, t_end, 3); % 使用3个点定义段
                x_low_seg = (1-t_segment).^2 * src_x_right + 2*(1-t_segment).*t_segment * ctrl_x + t_segment.^2 * tgt_x_left;
                y_low_seg = (1-t_segment).^2 * y_src_start + 2*(1-t_segment).*t_segment * ctrl_y_low + t_segment.^2 * y_tgt_start;
                
                % 计算当前段的上边界曲线点
                x_high_seg = (1-t_segment).^2 * src_x_right + 2*(1-t_segment).*t_segment * ctrl_x + t_segment.^2 * tgt_x_left;
                y_high_seg = (1-t_segment).^2 * y_src_end + 2*(1-t_segment).*t_segment * ctrl_y_high + t_segment.^2 * y_tgt_end;
                
                % 绘制当前段的多边形
                x_patch_seg = [x_low_seg, fliplr(x_high_seg)];
                y_patch_seg = [y_low_seg, fliplr(y_high_seg)];
                patch(x_patch_seg, y_patch_seg, segment_color, 'EdgeColor', 'none', ...
                      'FaceAlpha', 0.7, ...
                      'LineStyle', 'none');
            end
        end
    end
end

ylim([-epsilon, y_max + epsilon]);
xlim([-epsilon, x_max + epsilon]);

hold off;
axis off;


end

% 辅助函数：将 hex 颜色码转换为 RGB 向量
function rgb = hex2rgb(hex_str)
    hex_str = strrep(hex_str, '#', '');
    if length(hex_str) ~= 6
        error('无效的 hex 颜色码');
    end
    r = hex2dec(hex_str(1:2)) / 255;
    g = hex2dec(hex_str(3:4)) / 255;
    b = hex2dec(hex_str(5:6)) / 255;
    rgb = [r, g, b];
end
function test_sankey_diagram()
    % TEST_SANKEY_DIAGRAM 测试 sankey_diagram 函数
    %   该函数演示如何调用 sankey_diagram 并检查其基本功能。
    
    clc;
    close all;

    % 用例1: 两层桑基图 with color transition
    disp('测试用例1: 两层桑基图 with color transition');
    data1 = [10, 20; 15, 15]; % 2x2 矩阵，第一层流量[10,20]，第二层流量[15,15]
    connection1 = zeros(1,2,2); % 初始化连接矩阵，1x2x2
    connection1(1,1,1) = 5;    % 从层1节点1到层2节点1流量5
    connection1(1,1,2) = 5;    % 从层1节点1到层2节点2流量5
    connection1(1,2,1) = 10;   % 从层1节点2到层2节点1流量10
    connection1(1,2,2) = 10;   % 从层1节点2到层2节点2流量10
    colormap_param1 = {'#FF0000', '#0000FF'}; % 颜色从红到蓝过渡
    
    fig1 = sankey_diagram(data1, connection1, colormap_param1);
    disp('用例1完成');
    
    % 用例2: 三层桑基图 with default color
    disp('测试用例2: 三层桑基图 with default color');
    data2 = [10, 20; 15, 15; 10, 20]; % 3x2 矩阵，三层流量
    connection2 = zeros(2,2,2); % 初始化连接矩阵，2x2x2
    % 层1到层2连接
    connection2(1,1,1) = 5;
    connection2(1,1,2) = 5;
    connection2(1,2,1) = 10;
    connection2(1,2,2) = 10;
    % 层2到层3连接
    connection2(2,1,1) = 10;   % 从层2节点1到层3节点1流量10
    connection2(2,1,2) = 5;    % 从层2节点1到层3节点2流量5
    connection2(2,2,1) = 0;    % 从层2节点2到层3节点1流量0
    connection2(2,2,2) = 15;   % 从层2节点2到层3节点2流量15
    colormap_param2 = []; % 使用默认颜色
    
    fig2 = sankey_diagram(data2, connection2, colormap_param2);
    disp('用例2完成');

    % 用例3: 四层桑基图 with color transition
    disp('测试用例3: 四层桑基图 with color transition');
    % 定义数据矩阵：4层，每层最多3个节点
    data3 = [
        30, 20, 10;   % 层1: 节点1=30, 节点2=20, 节点3=10
        25, 15, 20;   % 层2: 节点1=25, 节点2=15, 节点3=20
        10, 30, 20;   % 层3: 节点1=10, 节点2=30, 节点3=20
        20, 25, 15    % 层4: 节点1=20, 节点2=25, 节点3=15
    ];
    % 连接矩阵：3x3x3 (因为从层1到层2、层2到层3、层3到层4)
    connection3 = zeros(3,3,3);
    % 层1到层2连接
    connection3(1,1,1) = 15;   % 从层1节点1到层2节点1
    connection3(1,1,2) = 10;   % 从层1节点1到层2节点2
    connection3(1,1,3) = 5;    % 从层1节点1到层2节点3
    connection3(1,2,1) = 5;    % 从层1节点2到层2节点1
    connection3(1,2,2) = 10;   % 从层1节点2到层2节点2
    connection3(1,2,3) = 5;    % 从层1节点2到层2节点3
    connection3(1,3,1) = 5;    % 从层1节点3到层2节点1
    connection3(1,3,2) = 0;    % 从层1节点3到层2节点2
    connection3(1,3,3) = 5;    % 从层1节点3到层2节点3
    % 层2到层3连接
    connection3(2,1,1) = 10;   % 从层2节点1到层3节点1
    connection3(2,1,2) = 10;   % 从层2节点1到层3节点2
    connection3(2,1,3) = 5;    % 从层2节点1到层3节点3
    connection3(2,2,1) = 5;    % 从层2节点2到层3节点1
    connection3(2,2,2) = 5;    % 从层2节点2到层3节点2
    connection3(2,2,3) = 5;    % 从层2节点2到层3节点3
    connection3(2,3,1) = 0;    % 从层2节点3到层3节点1
    connection3(2,3,2) = 15;   % 从层2节点3到层3节点2
    connection3(2,3,3) = 5;    % 从层2节点3到层3节点3
    % 层3到层4连接
    connection3(3,1,1) = 5;    % 从层3节点1到层4节点1
    connection3(3,1,2) = 5;    % 从层3节点1到层4节点2
    connection3(3,1,3) = 0;    % 从层3节点1到层4节点3
    connection3(3,2,1) = 5;    % 从层3节点2到层4节点1
    connection3(3,2,2) = 20;   % 从层3节点2到层4节点2
    connection3(3,2,3) = 5;    % 从层3节点2到层4节点3
    connection3(3,3,1) = 10;   % 从层3节点3到层4节点1
    connection3(3,3,2) = 0;    % 从层3节点3到层4节点2
    connection3(3,3,3) = 10;   % 从层3节点3到层4节点3
    colormap_param3 = {'#00FF00', '#FFFF00'}; % 颜色从绿到黄过渡
    
    fig3 = sankey_diagram(data3, connection3, colormap_param3);
    disp('用例3完成');

    % 用例4: 五层桑基图 with default color
    disp('测试用例4: 五层桑基图 with default color');
    % 定义数据矩阵：5层，每层最多3个节点
    data4 = [
        40, 30, 20;   % 层1
        35, 25, 30;   % 层2
        20, 40, 30;   % 层3
        30, 35, 25;   % 层4
        25, 30, 35    % 层5
    ];
    % 连接矩阵：4x3x3
    connection4 = zeros(4,3,3);
    % 层1到层2连接
    connection4(1,1,1) = 20;
    connection4(1,1,2) = 10;
    connection4(1,1,3) = 10;
    connection4(1,2,1) = 10;
    connection4(1,2,2) = 10;
    connection4(1,2,3) = 10;
    connection4(1,3,1) = 5;
    connection4(1,3,2) = 10;
    connection4(1,3,3) = 5;
    % 层2到层3连接
    connection4(2,1,1) = 15;
    connection4(2,1,2) = 10;
    connection4(2,1,3) = 10;
    connection4(2,2,1) = 10;
    connection4(2,2,2) = 10;
    connection4(2,2,3) = 5;
    connection4(2,3,1) = 5;
    connection4(2,3,2) = 15;
    connection4(2,3,3) = 10;
    % 层3到层4连接
    connection4(3,1,1) = 10;
    connection4(3,1,2) = 5;
    connection4(3,1,3) = 5;
    connection4(3,2,1) = 5;
    connection4(3,2,2) = 25;
    connection4(3,2,3) = 10;
    connection4(3,3,1) = 5;
    connection4(3,3,2) = 10;
    connection4(3,3,3) = 15;
    % 层4到层5连接
    connection4(4,1,1) = 10;
    connection4(4,1,2) = 10;
    connection4(4,1,3) = 10;
    connection4(4,2,1) = 5;
    connection4(4,2,2) = 20;
    connection4(4,2,3) = 10;
    connection4(4,3,1) = 10;
    connection4(4,3,2) = 0;
    connection4(4,3,3) = 15;
    colormap_param4 = []; % 使用默认颜色
    
    fig4 = sankey_diagram(data4, connection4, colormap_param4);
    disp('用例4完成');
    
    % 用例5: 测试错误情况（可选，注释掉以避免中断）
    % disp('测试用例5: 错误情况 - 连接指向不存在的节点');
    % data5 = [10, 0; 0, 10]; % 层1节点2不存在，层2节点1不存在
    % connection5 = zeros(1,2,2);
    % connection5(1,2,1) = 10; % 从层1节点2（不存在）到层2节点1（不存在）
    % try
    %     fig5 = sankey_diagram(data5, connection5, []);
    % catch ME
    %     disp(['错误捕获: ', ME.message]);
    % end
end

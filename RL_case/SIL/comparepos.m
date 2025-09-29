% 实际水平位置
UAV = load('pos.mat').ans;
%期望水平位置
UAV_d = load('pos_d.mat').ans;

%无人机实际位置
x = UAV.Data(:, 1);
y = UAV.Data(:, 2);

%无人机期望位置
x_d = UAV_d.Data(:, 1);
y_d = UAV_d.Data(:, 2);


plot(x_d, y_d, 'b-', 'LineWidth', 2); % 期望轨迹，使用蓝色实线，线宽为2
hold on; % 保持当前图像，以便在同一幅图上绘制第二条曲线
plot(x, y, 'r-', 'LineWidth', 2); % 实际轨迹，使用红色实线，线宽为2
  
axis equal;
grid on;
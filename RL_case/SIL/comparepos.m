% ʵ��ˮƽλ��
UAV = load('pos.mat').ans;
%����ˮƽλ��
UAV_d = load('pos_d.mat').ans;

%���˻�ʵ��λ��
x = UAV.Data(:, 1);
y = UAV.Data(:, 2);

%���˻�����λ��
x_d = UAV_d.Data(:, 1);
y_d = UAV_d.Data(:, 2);


plot(x_d, y_d, 'b-', 'LineWidth', 2); % �����켣��ʹ����ɫʵ�ߣ��߿�Ϊ2
hold on; % ���ֵ�ǰͼ���Ա���ͬһ��ͼ�ϻ��Ƶڶ�������
plot(x, y, 'r-', 'LineWidth', 2); % ʵ�ʹ켣��ʹ�ú�ɫʵ�ߣ��߿�Ϊ2
  
axis equal;
grid on;
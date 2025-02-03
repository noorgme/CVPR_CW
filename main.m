% Cylinder End Effector
file_path = fullfile(pwd, 'PR_CW_mat', 'cylinder_papillarray_single.mat');

% Load the .mat file
data = load(file_path);

poses = data.end_effector_poses;

% Use row number as time index 
time = 1:size(poses, 1);

figure;
plot3(poses(:,1), poses(:,2), poses(:,3), 'b', 'LineWidth', 1.5);
xlabel('X Position');
ylabel('Y Position');
zlabel('Z Position');
title('3D Trajectory of End Effector');
grid on;
axis equal;
view(3);

figure;
subplot(3,1,1);
plot(time, poses(:,1), 'r');
xlabel('Time'); ylabel('X Position');
title('End Effector X Position Over Time');
grid on;

subplot(3,1,2);
plot(time, poses(:,2), 'g');
xlabel('Time'); ylabel('Y Position');
title('End Effector Y Position Over Time');
grid on;

subplot(3,1,3);
plot(time, poses(:,3), 'b');
xlabel('Time'); ylabel('Z Position');
title('End Effector Z Position Over Time');
grid on;

figure;
subplot(3,1,1);
plot(time, poses(:,4), 'r');
xlabel('Time'); ylabel('Roll (°)');
title('Roll Over Time');
grid on;

subplot(3,1,2);
plot(time, poses(:,5), 'g');
xlabel('Time'); ylabel('Pitch (°)');
title('Pitch Over Time');
grid on;

subplot(3,1,3);
plot(time, poses(:,6), 'b');
xlabel('Time'); ylabel('Yaw (°)');
title('Yaw Over Time');
grid on;

ft_values = data.ft_values;

figure;
subplot(3,1,1);
plot(time, ft_values(:,1), 'r');
xlabel('Time'); ylabel('Fx');
title('Force in X Direction');
grid on;

subplot(3,1,2);
plot(time, ft_values(:,2), 'g');
xlabel('Time'); ylabel('Fy');
title('Force in Y Direction');
grid on;

subplot(3,1,3);
plot(time, ft_values(:,3), 'b');
xlabel('Time'); ylabel('Fz');
title('Force in Z Direction');
grid on;


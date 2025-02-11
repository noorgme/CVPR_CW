%% load data

normal_data = load("PR_CW_mat/cylinder_papillarray_single.mat");
TPU_data = load("PR_CW_mat/cylinder_TPU_papillarray_single.mat");
rubber_data = load("PR_CW_mat/cylinder_rubber_papillarray_single.mat");


%% extract segment indicies

normal_segments = load("contact_segments/contact_peaks_cylinder_papillarray_single.mat");
TPU_segments = load("contact_segments/contact_peaks_cylinder_TPU_papillarray_single.mat");
rubber_segments = load("contact_segments/contact_peaks_cylinder_rubber_papillarray_single.mat");

normal_segments = normal_segments.peak_indices;
TPU_segments = TPU_segments.peak_indices;
rubber_segments = rubber_segments.peak_indices;

%% Extract force values of middle papilae

pap_number = 4;

normal_force = normal_data.sensor_matrices_force(normal_segments, (pap_number * 3) + 1 : ((pap_number * 3) + 2) + 1);
TPU_force = TPU_data.sensor_matrices_force(TPU_segments, (pap_number * 3) + 1 : ((pap_number * 3) + 2) + 1);
rubber_force = rubber_data.sensor_matrices_force(rubber_segments, (pap_number * 3) + 1 : ((pap_number * 3) + 2) + 1);


%% 3D scatter plot for middle papillae

figure;
hold on;
view(45, 30); % Adjust azimuth and elevation angles
scatter3(normal_force(:,1), normal_force(:,2), normal_force(:,3), 10, 'r', 'filled'); % Red for normal
scatter3(TPU_force(:,1), TPU_force(:,2), TPU_force(:,3), 10, 'g', 'filled'); % Green for TPU
scatter3(rubber_force(:,1), rubber_force(:,2), rubber_force(:,3), 10, 'b', 'filled'); % Blue for rubber

xlabel('Force in X direction');
ylabel('Force in Y direction');
zlabel('Force in Z direction');
title('3D Scatter Plot of Force Data - Middle Papillae');
legend({'Normal', 'TPU', 'Rubber'});
grid on;
hold off;

%% Extract force values of a corner papillae (e.g., papillae 0)
corner_pap_number = 0;

corner_normal_force = normal_data.sensor_matrices_force(normal_segments, (corner_pap_number * 3) + 1 : ((corner_pap_number * 3) + 2) + 1);
corner_TPU_force = TPU_data.sensor_matrices_force(TPU_segments, (corner_pap_number * 3) + 1 : ((corner_pap_number * 3) + 2) + 1);
corner_rubber_force = rubber_data.sensor_matrices_force(rubber_segments, (corner_pap_number * 3) + 1 : ((corner_pap_number * 3) + 2) + 1);

%% 3D Scatter Plot for Corner Papillae
figure;
hold on;
view(45, 30); % Adjust azimuth and elevation angles

scatter3(corner_normal_force(:,1), corner_normal_force(:,2), corner_normal_force(:,3), 10, 'r', 'filled'); % Red for normal
scatter3(corner_TPU_force(:,1), corner_TPU_force(:,2), corner_TPU_force(:,3), 10, 'g', 'filled'); % Green for TPU
scatter3(corner_rubber_force(:,1), corner_rubber_force(:,2), corner_rubber_force(:,3), 10, 'b', 'filled'); % Blue for rubber

xlabel('Force in X direction');
ylabel('Force in Y direction');
zlabel('Force in Z direction');
title('3D Scatter Plot of Force Data - Corner Papillae');
legend({'Normal', 'TPU', 'Rubber'});
grid on;
hold off;
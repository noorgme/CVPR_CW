%% Load Data
normal_data = load("PR_CW_mat/cylinder_papillarray_single.mat");
TPU_data = load("PR_CW_mat/cylinder_TPU_papillarray_single.mat");
rubber_data = load("PR_CW_mat/cylinder_rubber_papillarray_single.mat");

%% Extract Segment Indices
normal_segments = load("contact_segments/contact_peaks_cylinder_papillarray_single.mat");
TPU_segments = load("contact_segments/contact_peaks_cylinder_TPU_papillarray_single.mat");
rubber_segments = load("contact_segments/contact_peaks_cylinder_rubber_papillarray_single.mat");

normal_segments = normal_segments.peak_indices;
TPU_segments = TPU_segments.peak_indices;
rubber_segments = rubber_segments.peak_indices;

%% Extract Force Values for Middle Papillae
pap_number = 4; % Middle papillae index
normal_force = normal_data.sensor_matrices_force(normal_segments, (pap_number * 3) + 1 : (pap_number * 3) + 3);
TPU_force = TPU_data.sensor_matrices_force(TPU_segments, (pap_number * 3) + 1 : (pap_number * 3) + 3);
rubber_force = rubber_data.sensor_matrices_force(rubber_segments, (pap_number * 3) + 1 : (pap_number * 3) + 3);

%% Extract Force Values for Corner Papillae
corner_pap_number = 0; % Corner papillae index
corner_normal_force = normal_data.sensor_matrices_force(normal_segments, (corner_pap_number * 3) + 1 : (corner_pap_number * 3) + 3);
corner_TPU_force = TPU_data.sensor_matrices_force(TPU_segments, (corner_pap_number * 3) + 1 : (corner_pap_number * 3) + 3);
corner_rubber_force = rubber_data.sensor_matrices_force(rubber_segments, (corner_pap_number * 3) + 1 : (corner_pap_number * 3) + 3);

%% 🎨 Aesthetic 3D Scatter Plot with Subplots
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.8, 0.7]); 
tiledlayout(1,2, 'TileSpacing', 'compact', 'Padding', 'compact'); 

% Define colors and markers
colors = {'r', 'g', 'b'};
labels = {'PLA', 'TPU', 'Rubber'};
marker_size = 20;

% 🎯 **Subplot 1: Middle Papillae**
nexttile;
hold on;
view(45, 30); % Adjust view for clarity
scatter3(normal_force(:,1), normal_force(:,2), normal_force(:,3), marker_size, colors{1}, 'filled'); 
scatter3(TPU_force(:,1), TPU_force(:,2), TPU_force(:,3), marker_size, colors{2}, 'filled'); 
scatter3(rubber_force(:,1), rubber_force(:,2), rubber_force(:,3), marker_size, colors{3}, 'filled'); 
xlabel('\bf Force in X direction', 'FontSize', 14);
ylabel('\bf Force in Y direction', 'FontSize', 14);
zlabel('\bf Force in Z direction', 'FontSize', 14);
title('\bf 3D Force Scatter Plot - Middle Papillae', 'FontSize', 16);
grid on;
set(gca, 'FontSize', 12, 'FontName', 'Times New Roman', 'LineWidth', 1);

% 🎯 **Subplot 2: Corner Papillae**
nexttile;
hold on;
view(45, 30);
scatter3(corner_normal_force(:,1), corner_normal_force(:,2), corner_normal_force(:,3), marker_size, colors{1}, 'filled'); 
scatter3(corner_TPU_force(:,1), corner_TPU_force(:,2), corner_TPU_force(:,3), marker_size, colors{2}, 'filled'); 
scatter3(corner_rubber_force(:,1), corner_rubber_force(:,2), corner_rubber_force(:,3), marker_size, colors{3}, 'filled'); 
xlabel('\bf Force in X direction', 'FontSize', 14);
ylabel('\bf Force in Y direction', 'FontSize', 14);
zlabel('\bf Force in Z direction', 'FontSize', 14);
title('\bf 3D Force Scatter Plot - Corner Papillae', 'FontSize', 16);
grid on;
set(gca, 'FontSize', 12, 'FontName', 'Times New Roman', 'LineWidth', 1);

% 📌 **Single Legend for All Subplots**
legend(labels, 'FontSize', 14, 'FontWeight', 'bold', 'Location', 'southoutside', 'Orientation', 'horizontal');

hold off;

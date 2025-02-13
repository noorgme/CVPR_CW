%% 📌 Load Data for Hexagon Object (Central Papillae Only)
clear; clc;

% Load displacement data for three materials
normal_data = load("PR_CW_mat/hexagon_papillarray_single.mat");
TPU_data = load("PR_CW_mat/hexagon_TPU_papillarray_single.mat");
rubber_data = load("PR_CW_mat/hexagon_rubber_papillarray_single.mat");

% Load contact segment indices
normal_segments = load("contact_segments/contact_peaks_hexagon_papillarray_single.mat");
TPU_segments = load("contact_segments/contact_peaks_hexagon_TPU_papillarray_single.mat");
rubber_segments = load("contact_segments/contact_peaks_hexagon_rubber_papillarray_single.mat");

% Extract peak indices
normal_segments = normal_segments.peak_indices;
TPU_segments = TPU_segments.peak_indices;
rubber_segments = rubber_segments.peak_indices;

%% 📌 Extract Displacement Values for Central Papillae (P4)
pap_number = 4; % Central papillae index

normal_disp = normal_data.sensor_matrices_displacement(normal_segments, (pap_number * 3) + (1:3));
TPU_disp = TPU_data.sensor_matrices_displacement(TPU_segments, (pap_number * 3) + (1:3));
rubber_disp = rubber_data.sensor_matrices_displacement(rubber_segments, (pap_number * 3) + (1:3));

%% 📌 Combine Data & Labels
all_data = [normal_disp; TPU_disp; rubber_disp]; % Concatenating all material data
labels = [ones(size(normal_disp,1),1); 2*ones(size(TPU_disp,1),1); 3*ones(size(rubber_disp,1),1)]; % 1: PLA, 2: TPU, 3: Rubber

%% (a) Scatter Plot for the 3 Materials (3D)
figure;
scatter3(normal_disp(:,1), normal_disp(:,2), normal_disp(:,3), 20, 'r', 'filled'); hold on;
scatter3(TPU_disp(:,1), TPU_disp(:,2), TPU_disp(:,3), 20, 'g', 'filled');
scatter3(rubber_disp(:,1), rubber_disp(:,2), rubber_disp(:,3), 20, 'b', 'filled');
xlabel('D_X (mm)'); ylabel('D_Y (mm)'); zlabel('D_Z (mm)');
title('3D Scatter Plot of Central Papillae Displacement');
legend({'PLA', 'TPU', 'Rubber'}, 'Location', 'best');
grid on; view(45,30);
hold off;

%% (b) Apply K-means Clustering (Using 3D Data)
k = 3; % We expect 3 clusters (one per material)
[idx, C] = kmeans(all_data, k); % K-means clustering

% 📌 3D Scatter Plot of Clusters
figure;
scatter3(all_data(idx==1,1), all_data(idx==1,2), all_data(idx==1,3), 20, 'r', 'filled'); hold on;
scatter3(all_data(idx==2,1), all_data(idx==2,2), all_data(idx==2,3), 20, 'g', 'filled');
scatter3(all_data(idx==3,1), all_data(idx==3,2), all_data(idx==3,3), 20, 'b', 'filled');
scatter3(C(:,1), C(:,2), C(:,3), 100, 'kx', 'LineWidth', 2); % Centroids
xlabel('D_X (mm)'); ylabel('D_Y (mm)'); zlabel('D_Z (mm)');
title('K-means Clustering in 3D');
legend({'Cluster 1', 'Cluster 2', 'Cluster 3', 'Centroids'}, 'Location', 'best');
grid on; view(45,30);
hold off;

%% 📌 2D Projection of Clustering Results
figure;
tiledlayout(1,3, 'TileSpacing', 'compact');

% D_X vs D_Y
nexttile;
gscatter(all_data(:,1), all_data(:,2), idx, 'rgb', 'osd', 8);
xlabel('D_X (mm)'); ylabel('D_Y (mm)');
title('Clusters: D_X vs D_Y');

% D_X vs D_Z
nexttile;
gscatter(all_data(:,1), all_data(:,3), idx, 'rgb', 'osd', 8);
xlabel('D_X (mm)'); ylabel('D_Z (mm)');
title('Clusters: D_X vs D_Z');

% D_Y vs D_Z
nexttile;
gscatter(all_data(:,2), all_data(:,3), idx, 'rgb', 'osd', 8);
xlabel('D_Y (mm)'); ylabel('D_Z (mm)');
title('Clusters: D_Y vs D_Z');

%% (c) Apply K-means Clustering with a Different Distance Metric (City Block)
opts = statset('MaxIter', 1000); % Ensure convergence
[idx2, C2] = kmeans(all_data, k, 'Distance', 'cityblock', 'Options', opts); % Using city block distance

% 📌 3D Scatter Plot of New Clusters
figure;
scatter3(all_data(idx2==1,1), all_data(idx2==1,2), all_data(idx2==1,3), 20, 'r', 'filled'); hold on;
scatter3(all_data(idx2==2,1), all_data(idx2==2,2), all_data(idx2==2,3), 20, 'g', 'filled');
scatter3(all_data(idx2==3,1), all_data(idx2==3,2), all_data(idx2==3,3), 20, 'b', 'filled');
scatter3(C2(:,1), C2(:,2), C2(:,3), 100, 'kx', 'LineWidth', 2); % Centroids
xlabel('D_X (mm)'); ylabel('D_Y (mm)'); zlabel('D_Z (mm)');
title('K-means Clustering with City Block Distance');
legend({'Cluster 1', 'Cluster 2', 'Cluster 3', 'Centroids'}, 'Location', 'best');
grid on; view(45,30);
hold off;

%% 📌 2D Projection of City Block Clustering
figure;
tiledlayout(1,3, 'TileSpacing', 'compact');

% D_X vs D_Y
nexttile;
gscatter(all_data(:,1), all_data(:,2), idx2, 'rgb', 'osd', 8);
xlabel('D_X (mm)'); ylabel('D_Y (mm)');
title('City Block Clusters: D_X vs D_Y');

% D_X vs D_Z
nexttile;
gscatter(all_data(:,1), all_data(:,3), idx2, 'rgb', 'osd', 8);
xlabel('D_X (mm)'); ylabel('D_Z (mm)');
title('City Block Clusters: D_X vs D_Z');

% D_Y vs D_Z
nexttile;
gscatter(all_data(:,2), all_data(:,3), idx2, 'rgb', 'osd', 8);
xlabel('D_Y (mm)'); ylabel('D_Z (mm)');
title('City Block Clusters: D_Y vs D_Z');

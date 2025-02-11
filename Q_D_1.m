%% Load data
normal_data = load("PR_CW_mat/hexagon_papillarray_single.mat");
TPU_data = load("PR_CW_mat/hexagon_TPU_papillarray_single.mat");
rubber_data = load("PR_CW_mat/hexagon_rubber_papillarray_single.mat");

%% Extract segment indices
normal_segments = load("contact_segments/contact_peaks_hexagon_papillarray_single.mat");
TPU_segments = load("contact_segments/contact_peaks_hexagon_TPU_papillarray_single.mat");
rubber_segments = load("contact_segments/contact_peaks_hexagon_rubber_papillarray_single.mat");

normal_segments = normal_segments.peak_indices;
TPU_segments = TPU_segments.peak_indices;
rubber_segments = rubber_segments.peak_indices;

%% Extract force values of middle papillae
pap_number = 4;
normal_force = normal_data.sensor_matrices_displacement(normal_segments, (pap_number * 3) + 1 : ((pap_number * 3) + 2) + 1);
TPU_force = TPU_data.sensor_matrices_displacement(TPU_segments, (pap_number * 3) + 1 : ((pap_number * 3) + 2) + 1);
rubber_force = rubber_data.sensor_matrices_displacement(rubber_segments, (pap_number * 3) + 1 : ((pap_number * 3) + 2) + 1);

%% a. Scatter Plot for 3 Different Materials
all_data = [normal_force; TPU_force; rubber_force];
labels = [ones(size(normal_force, 1), 1); 2 * ones(size(TPU_force, 1), 1); 3 * ones(size(rubber_force, 1), 1)];

% Scatter plot for the force values
figure;
scatter(normal_force(:, 1), normal_force(:, 2), 20, 'r', 'filled'); hold on;
scatter(TPU_force(:, 1), TPU_force(:, 2), 20, 'g', 'filled');
scatter(rubber_force(:, 1), rubber_force(:, 2), 20, 'b', 'filled');
xlabel('Force X'); ylabel('Force Y');
title('Scatter Plot of Force Values for Different Materials');
legend({'Normal', 'TPU', 'Rubber'});
grid on;

%% b. Apply K-means Clustering & Visualize Outcome
k = 3; % Number of clusters (since we have 3 materials)
[idx, C] = kmeans(all_data, k);

% Visualize the clusters
figure;
gscatter(all_data(:, 1), all_data(:, 2), idx, 'rgb', 'osd', 8); % Scatter plot with colors for each cluster
hold on;
scatter(C(:, 1), C(:, 2), 100, 'kx', 'LineWidth', 2); % Plot the centroids of clusters
xlabel('Force X'); ylabel('Force Y');
title('K-means Clustering for Force Values');
legend({'Cluster 1', 'Cluster 2', 'Cluster 3', 'Centroids'});
grid on;

%% c. Apply K-means Clustering with a Different Distance Metric (City Block)
opts = statset('MaxIter', 1000); % Increase max iterations to ensure convergence
[idx2, C2] = kmeans(all_data, k, 'Distance', 'cityblock', 'Options', opts);

% Visualize the new clusters
figure;
gscatter(all_data(:, 1), all_data(:, 2), idx2, 'rgb', 'osd', 8); % Scatter plot with new cluster colors
hold on;
scatter(C2(:, 1), C2(:, 2), 100, 'kx', 'LineWidth', 2); % Plot the centroids of the new clusters
xlabel('Force X'); ylabel('Force Y');
title('K-means Clustering with City Block Distance');
legend({'Cluster 1', 'Cluster 2', 'Cluster 3', 'Centroids'});
grid on;
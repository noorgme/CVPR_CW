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

%% Combine data for PCA
all_data = [normal_force; TPU_force; rubber_force]; % Stack all datasets together

% Standardize the data (zero mean, unit variance)
standardized_data = (all_data - mean(all_data)) ./ std(all_data);

[coeff, score, latent] = pca(standardized_data);

%% Find indices for each material in PCA space
num_normal = size(normal_force, 1);
num_TPU = size(TPU_force, 1);
num_rubber = size(rubber_force, 1);

normal_idx = 1:num_normal;
TPU_idx = num_normal + (1:num_TPU);
rubber_idx = num_normal + num_TPU + (1:num_rubber);

%% Plot standardized data with principal components
figure;
scatter3(score(normal_idx,1), score(normal_idx,2), score(normal_idx,3), 10, 'r', 'filled');
hold on;
scatter3(score(TPU_idx,1), score(TPU_idx,2), score(TPU_idx,3), 10, 'g', 'filled');
scatter3(score(rubber_idx,1), score(rubber_idx,2), score(rubber_idx,3), 10, 'b', 'filled');

xlabel('PC1'); ylabel('PC2'); zlabel('PC3');
title('3D PCA Scatter Plot of Standardized Force Data');
legend({'Normal', 'TPU', 'Rubber'}); % Labels correspond to original materials, not PCA components
grid on;
view(45,30);
hold off;

%% Reduce data to 2D and replot

% By default the 3rd component has the lowest variance so can be discarded,
% just plot in 2d with pc1 and pc2 for ease

figure;
scatter(score(normal_idx,1), score(normal_idx,2), 10, 'r', 'filled');
hold on;
scatter(score(TPU_idx,1), score(TPU_idx,2), 10, 'g', 'filled');
scatter(score(rubber_idx,1), score(rubber_idx,2), 10, 'b', 'filled');

xlabel('PC1'); ylabel('PC2');
title('2D PCA Projection of Force Data');
legend({'Normal', 'TPU', 'Rubber'});
grid on;
hold off;

%%

disp(latent)

figure;
hold on;

% Plot PC1 scores as a 1D number line
subplot(3,1,1);
plot(score(:,1), zeros(size(score(:,1))), 'k.', 'MarkerSize', 5);  % All data in black dots along PC1
ylim([-1, 1]);  % Just to add a small space on the y-axis for better visibility
xlabel('PC1 Score');
title('Distribution of Data Along PC1');

% Plot PC2 scores as a 1D number line
subplot(3,1,2);
plot(score(:,2), zeros(size(score(:,2))), 'k.', 'MarkerSize', 5);  % All data in black dots along PC2
ylim([-1, 1]);  % Same for better visibility
xlabel('PC2 Score');
title('Distribution of Data Along PC2');

% Plot PC3 scores as a 1D number line
subplot(3,1,3);
plot(score(:,3), zeros(size(score(:,3))), 'k.', 'MarkerSize', 5);  % All data in black dots along PC3
ylim([-1, 1]);  % Same for better visibility
xlabel('PC3 Score');
title('Distribution of Data Along PC3');

hold off;
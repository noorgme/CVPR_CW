%% Load Data

clear;
clc;

normal_data = load("PR_CW_mat/cylinder_papillarray_single.mat");
TPU_data = load("PR_CW_mat/cylinder_TPU_papillarray_single.mat");
rubber_data = load("PR_CW_mat/cylinder_rubber_papillarray_single.mat");

%% Extract Force Values

normal_force = normal_data.sensor_matrices_force;
TPU_force = TPU_data.sensor_matrices_force;
rubber_force = rubber_data.sensor_matrices_force;

%% Combine Data for PCA

all_data = [normal_force; TPU_force; rubber_force]; % Stack all datasets together

num_papillae = 9; % Total papillae
num_components = 3; % X, Y, Z per papilla

% Reshape data to have all papillae's forces in separate columns
all_data_reshaped = reshape(all_data, [], num_papillae * num_components); 

% Standardize Data (zero mean, unit variance)
standardized_data = (all_data_reshaped - mean(all_data_reshaped)) ./ std(all_data_reshaped);

% Perform PCA
[coeff, score, latent] = pca(standardized_data);

%% (a) Create Scree Plot

figure;
plot(1:length(latent), latent / sum(latent) * 100, '-o', 'LineWidth', 2);
xlabel('Principal Component');
ylabel('Variance Explained (%)');
title('Scree Plot');
grid on;

%% Find indices for each material in PCA space
num_normal = size(normal_force, 1);
num_TPU = size(TPU_force, 1);
num_rubber = size(rubber_force, 1);

normal_idx = 1:num_normal;
TPU_idx = num_normal + (1:num_TPU);
rubber_idx = num_normal + num_TPU + (1:num_rubber);

%% (b) 1D Number Line Plots for PC1, PC2, PC3

figure;
subplot(3,1,1);
scatter(score(normal_idx,1), zeros(size(normal_idx)), 10, 'r', 'filled'); hold on;
scatter(score(TPU_idx,1), zeros(size(TPU_idx)), 10, 'g', 'filled');
scatter(score(rubber_idx,1), zeros(size(rubber_idx)), 10, 'b', 'filled');
xlabel('PC1 Scores');
yticks([]);
title('PC1 Number Line');
legend({'Normal', 'TPU', 'Rubber'});
grid on;

subplot(3,1,2);
scatter(score(normal_idx,2), zeros(size(normal_idx)), 10, 'r', 'filled'); hold on;
scatter(score(TPU_idx,2), zeros(size(TPU_idx)), 10, 'g', 'filled');
scatter(score(rubber_idx,2), zeros(size(rubber_idx)), 10, 'b', 'filled');
xlabel('PC2 Scores');
yticks([]);
title('PC2 Number Line');
legend({'Normal', 'TPU', 'Rubber'});
grid on;

subplot(3,1,3);
scatter(score(normal_idx,3), zeros(size(normal_idx)), 10, 'r', 'filled'); hold on;
scatter(score(TPU_idx,3), zeros(size(TPU_idx)), 10, 'g', 'filled');
scatter(score(rubber_idx,3), zeros(size(rubber_idx)), 10, 'b', 'filled');
xlabel('PC3 Scores');
yticks([]);
title('PC3 Number Line');
legend({'Normal', 'TPU', 'Rubber'});
grid on;

%% (c) Reduce Data to 2D and Replot

figure;
scatter(score(normal_idx,1), score(normal_idx,2), 10, 'r', 'filled'); hold on;
scatter(score(TPU_idx,1), score(TPU_idx,2), 10, 'g', 'filled');
scatter(score(rubber_idx,1), score(rubber_idx,2), 10, 'b', 'filled');
xlabel('PC1'); ylabel('PC2');
title('2D PCA Projection of Force Data');
legend({'Normal', 'TPU', 'Rubber'});
grid on;
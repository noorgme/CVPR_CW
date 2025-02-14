%% (1) Load Data for Oblong TPU and Oblong Rubber
clear; clc;

% Load data for TPU and Rubber
TPU_data = load("PR_CW_mat/oblong_TPU_papillarray_single.mat");
rubber_data = load("PR_CW_mat/oblong_rubber_papillarray_single.mat");

% Load contact segment indices for each material
TPU_segments_struct = load("contact_segments/contact_peaks_cylinder_TPU_papillarray_single.mat");
rubber_segments_struct = load("contact_segments/contact_peaks_cylinder_rubber_papillarray_single.mat");
TPU_segments = TPU_segments_struct.peak_indices;
rubber_segments = rubber_segments_struct.peak_indices;

% Extract displacement values for central papillae (Papilla #4)
pap_number = 4;
TPU_displacement = TPU_data.sensor_matrices_displacement(TPU_segments, (pap_number * 3) + (1:3));
rubber_displacement = rubber_data.sensor_matrices_displacement(rubber_segments, (pap_number * 3) + (1:3));

% Combine Data
all_data = [TPU_displacement; rubber_displacement];

% Create Labels: 1 for TPU, 2 for Rubber
labels = [ones(size(TPU_displacement, 1), 1); 2 * ones(size(rubber_displacement, 1), 1)];

%% (2) Standardization (Z-score Normalization Per Feature)
all_data = (all_data - mean(all_data,1)) ./ std(all_data,[],1);

%% (3) 3D Scatter Plot of Central Papillae Displacement
figure;
scatter3(TPU_displacement(:,1), TPU_displacement(:,2), TPU_displacement(:,3), 15, 'g', 'filled'); hold on;
scatter3(rubber_displacement(:,1), rubber_displacement(:,2), rubber_displacement(:,3), 15, 'b', 'filled');
xlabel('D_X (mm)'); ylabel('D_Y (mm)'); zlabel('D_Z (mm)');
title('3D Scatter Plot of Central Papillae Displacement');
legend({'TPU', 'Rubber'}, 'Location', 'best');
grid on;
view(45,30);
hold off;

%% (4) Apply LDA to Each 2D Combination and Plot with Decision Boundaries & LDA Direction
combinations = [1 2; 1 3; 2 3];
titles = {'LDA: D_X vs D_Y', 'LDA: D_X vs D_Z', 'LDA: D_Y vs D_Z'};
xlabel_list = {'D_X (mm)', 'D_X (mm)', 'D_Y (mm)'};
ylabel_list = {'D_Y (mm)', 'D_Z (mm)', 'D_Z (mm)'};

figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.9, 0.3]); 
tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

for i = 1:3
    nexttile;
    feature_pair = all_data(:, combinations(i, :));
    
    % Fit LDA Model
    lda_model = fitcdiscr(feature_pair, labels);
    coef = lda_model.Coeffs(1,2).Linear;
    intercept = lda_model.Coeffs(1,2).Const;
    
    % Decision Boundary Equation: y = -(coef(1)/coef(2))*x - (intercept/coef(2))
    x_vals = linspace(min(feature_pair(:,1)), max(feature_pair(:,1)), 100);
    y_vals = -(coef(1)/coef(2)) * x_vals - (intercept/coef(2));
    
    % Scatter Plot
    scatter(feature_pair(labels==1,1), feature_pair(labels==1,2), 15, 'g', 'filled'); hold on;
    scatter(feature_pair(labels==2,1), feature_pair(labels==2,2), 15, 'b', 'filled');
    plot(x_vals, y_vals, 'r-', 'LineWidth', 2);
    
    xlabel(xlabel_list{i});
    ylabel(ylabel_list{i});
    title(titles{i});
    legend({'TPU', 'Rubber', 'LDA Decision Boundary'}, 'Location', 'best');
    grid on;
    hold off;
end

%% (5) Compute LDA Projection (Following Fisher's LDA)
% Compute Class Means
mean_TPU = mean(all_data(labels == 1, :), 1);
mean_rubber = mean(all_data(labels == 2, :), 1);

% Compute Scatter Matrices
S_W = zeros(3,3);
for i = 1:size(all_data,1)
    xi = all_data(i, :)';
    mi = (labels(i) == 1) * mean_TPU' + (labels(i) == 2) * mean_rubber';
    S_W = S_W + (xi - mi) * (xi - mi)';
end
diff_mean = (mean_TPU - mean_rubber)';
S_B = (diff_mean * diff_mean');

% Compute Eigenvectors
[V, D] = eig(pinv(S_W) * S_B);
[~, sorted_indices] = sort(diag(D), 'descend');
W_LDA = V(:, sorted_indices(1:2)); % First two eigenvectors (LD1 & LD2)

%% (6) Project Data Onto LD1 & LD2 for 2D Scatter Plot
lda_proj = all_data * W_LDA;

% Compute Decision Boundary
proj_TPU = lda_proj(labels == 1, 1);
proj_rubber = lda_proj(labels == 2, 1);
decision_boundary = (mean(proj_TPU) + mean(proj_rubber)) / 2;

figure;
scatter(lda_proj(labels==1,1), lda_proj(labels==1,2), 15, 'g', 'filled'); hold on;
scatter(lda_proj(labels==2,1), lda_proj(labels==2,2), 15, 'b', 'filled');
xline(decision_boundary, 'r-', 'LineWidth', 2);
xlabel('LD1 (Fisher Discriminant)');
ylabel('LD2 (Second Eigenvector)');
title('2D LDA Projection with Fisher’s Discriminant');
legend({'TPU', 'Rubber', 'Decision Boundary'}, 'Location', 'best');
grid on;
hold off;

%% (7) 3D Scatter Plot with LDA Discriminant Plane
[grid_x, grid_y] = meshgrid(linspace(min(all_data(:,1)), max(all_data(:,1)), 10), ...
                            linspace(min(all_data(:,2)), max(all_data(:,2)), 10));
coef_3D = W_LDA(:,1); % LDA discriminant
intercept_3D = -decision_boundary * coef_3D(3);
grid_z = -(coef_3D(1) * grid_x + coef_3D(2) * grid_y + intercept_3D) / coef_3D(3);

figure;
scatter3(all_data(labels==1,1), all_data(labels==1,2), all_data(labels==1,3), 15, 'g', 'filled'); hold on;
scatter3(all_data(labels==2,1), all_data(labels==2,2), all_data(labels==2,3), 15, 'b', 'filled');
surf(grid_x, grid_y, grid_z, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
xlabel('D_X (mm)'); ylabel('D_Y (mm)'); zlabel('D_Z (mm)');
title('3D LDA Projection with Discriminant Plane');
legend({'TPU', 'Rubber', 'LDA Discriminant Plane'}, 'Location', 'best');
grid on;
view(45,30);
hold off;

%% Load Data for Oblong TPU and Oblong Rubber
clear; clc;

TPU_data = load("PR_CW_mat/oblong_TPU_papillarray_single.mat");
rubber_data = load("PR_CW_mat/oblong_rubber_papillarray_single.mat");

%% Extract Segment Indices
TPU_segments = load("contact_segments/contact_peaks_cylinder_TPU_papillarray_single.mat");
rubber_segments = load("contact_segments/contact_peaks_cylinder_rubber_papillarray_single.mat");

TPU_segments = TPU_segments.peak_indices;
rubber_segments = rubber_segments.peak_indices;

%% Extract Displacement Values of Central Papillae
pap_number = 4; 
TPU_displacement = TPU_data.sensor_matrices_displacement(TPU_segments, (pap_number * 3) + (1:3));
rubber_displacement = rubber_data.sensor_matrices_displacement(rubber_segments, (pap_number * 3) + (1:3));

% Combine Data
all_data = [TPU_displacement; rubber_displacement]; % Stack TPU & Rubber together
labels = [ones(size(TPU_displacement, 1), 1); 2 * ones(size(rubber_displacement, 1), 1)]; % 1 for TPU, 2 for Rubber

%% (b) 🔹 3D Scatter Plot of Central Papillae Displacement
figure;
scatter3(TPU_displacement(:,1), TPU_displacement(:,2), TPU_displacement(:,3), 15, 'g', 'filled'); hold on;
scatter3(rubber_displacement(:,1), rubber_displacement(:,2), rubber_displacement(:,3), 15, 'b', 'filled');
xlabel('D_X (mm)'); ylabel('D_Y (mm)'); zlabel('D_Z (mm)');
title('3D Scatter Plot of Central Papillae Displacement');
legend({'TPU', 'Rubber'}, 'Location', 'best');
grid on;
view(45, 30);
hold off;

%% (c) 🔹 Apply LDA to Each 2D Combination and Plot (With Decision Boundaries)
combinations = [1 2; 1 3; 2 3]; % [DX-DY], [DX-DZ], [DY-DZ]
titles = {'LDA: D_X vs D_Y', 'LDA: D_X vs D_Z', 'LDA: D_Y vs D_Z'};
xlabel_list = {'D_X (mm)', 'D_X (mm)', 'D_Y (mm)'};
ylabel_list = {'D_Y (mm)', 'D_Z (mm)', 'D_Z (mm)'};

figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.9, 0.3]); 
tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

for i = 1:3
    nexttile;
    feature_pair = all_data(:, combinations(i, :)); % Select 2D features
    lda_model = fitcdiscr(feature_pair, labels); % Fit LDA model

    % Extract LDA coefficients
    coef = lda_model.Coeffs(1,2).Linear; % Linear discriminant coefficients
    intercept = lda_model.Coeffs(1,2).Const; % Intercept term

    % Define x-axis range for plotting boundary
    x_vals = linspace(min(feature_pair(:,1)), max(feature_pair(:,1)), 100);
    y_vals = -(coef(1)/coef(2)) * x_vals - (intercept/coef(2)); % Decision boundary

    % Scatter plot of original data
    scatter(feature_pair(labels==1,1), feature_pair(labels==1,2), 15, 'g', 'filled'); hold on;
    scatter(feature_pair(labels==2,1), feature_pair(labels==2,2), 15, 'b', 'filled');
    
    % Plot LDA decision boundary
    plot(x_vals, y_vals, 'r-', 'LineWidth', 2, 'DisplayName', 'LDA Decision Boundary');

    xlabel(xlabel_list{i});
    ylabel(ylabel_list{i});
    title(titles{i});
    legend({'TPU', 'Rubber', 'LDA Decision Boundary'}, 'Location', 'best');
    grid on;
end

%% (d.i) 🔹 Reduce to LDA (1D) and Plot
lda_model_1D = fitcdiscr(all_data, labels); % Fit LDA model to 3D data

% Compute LDA projection (only one component available for binary classification)
lda_projection_1D = all_data * lda_model_1D.Coeffs(1,2).Linear; 

% Separate TPU and Rubber points
TPU_LDA_1D = lda_projection_1D(labels==1);
Rubber_LDA_1D = lda_projection_1D(labels==2);

% Scatter plot in 1D LDA space
figure;
scatter(TPU_LDA_1D, zeros(size(TPU_LDA_1D)), 15, 'g', 'filled'); hold on;
scatter(Rubber_LDA_1D, zeros(size(Rubber_LDA_1D)), 15, 'b', 'filled');

xlabel('LD1');
title('LDA Projection (1D, Binary Classification)');
legend({'TPU', 'Rubber'}, 'Location', 'best');
grid on;

%% (d.ii) 🔹 3D Scatter Plot with LDA Discrimination Plane
lda_model_3D = fitcdiscr(all_data, labels); % Fit LDA model to full 3D feature set

% Compute LDA decision plane equation
[grid_x, grid_y] = meshgrid(linspace(min(all_data(:,1)), max(all_data(:,1)), 10), ...
                            linspace(min(all_data(:,2)), max(all_data(:,2)), 10));
coef_3D = lda_model_3D.Coeffs(1,2).Linear; % LDA coefficients for 3D
intercept_3D = lda_model_3D.Coeffs(1,2).Const; 
grid_z = -(coef_3D(1) * grid_x + coef_3D(2) * grid_y + intercept_3D) / coef_3D(3); % Solve for Z

% 3D Scatter Plot with Discriminant Plane
figure;
scatter3(all_data(labels==1,1), all_data(labels==1,2), all_data(labels==1,3), 15, 'g', 'filled'); hold on;
scatter3(all_data(labels==2,1), all_data(labels==2,2), all_data(labels==2,3), 15, 'b', 'filled');

% Plot Discriminant Plane
surf(grid_x, grid_y, grid_z, 'FaceAlpha', 0.3, 'EdgeColor', 'none');

xlabel('D_X (mm)'); ylabel('D_Y (mm)'); zlabel('D_Z (mm)');
title('3D LDA Projection with Discriminant Plane');
legend({'TPU', 'Rubber', 'LDA Discriminant Plane'}, 'Location', 'best');
grid on;
hold off;

%% Load data for Oblong TPU and Oblong Rubber

TPU_data = load("PR_CW_mat/oblong_TPU_papillarray_single.mat");
rubber_data = load("PR_CW_mat/oblong_rubber_papillarray_single.mat");

%% Extract segment indices
TPU_segments = load("contact_segments/contact_peaks_cylinder_TPU_papillarray_single.mat");
rubber_segments = load("contact_segments/contact_peaks_cylinder_rubber_papillarray_single.mat");

TPU_segments = TPU_segments.peak_indices;
rubber_segments = rubber_segments.peak_indices;

%% Extract displacement values of central papillae
pap_number = 4; 
TPU_force = TPU_data.sensor_matrices_displacement(TPU_segments, (pap_number * 3) + (1:3));
rubber_force = rubber_data.sensor_matrices_displacement(rubber_segments, (pap_number * 3) + (1:3));

% Combine data
all_data = [TPU_force; rubber_force]; % Stack TPU & Rubber together
labels = [ones(size(TPU_force, 1), 1); 2 * ones(size(rubber_force, 1), 1)]; % 1 for TPU, 2 for Rubber

%% Apply LDA to all 2D combinations of D_X, D_Y, and D_Z
figure;
comb = nchoosek(1:3, 2); % All 2D combinations of D_X, D_Y, D_Z
for i = 1:size(comb, 1)
    subplot(2, 3, i);
    
    % Select the 2D data for the current combination
    data_2D = all_data(:, comb(i, :));
    
    % Apply LDA
    lda = fitcdiscr(data_2D, labels);
    scatter(data_2D(labels == 1, 1), data_2D(labels == 1, 2), 'r', 'filled'); hold on;
    scatter(data_2D(labels == 2, 1), data_2D(labels == 2, 2), 'b', 'filled');
    
    % Plot LDA decision boundary
    [x, y] = meshgrid(linspace(min(data_2D(:, 1)), max(data_2D(:, 1)), 100), ...
                      linspace(min(data_2D(:, 2)), max(data_2D(:, 2)), 100));
    Z = predict(lda, [x(:), y(:)]);
    Z = reshape(Z, size(x));
    contour(x, y, Z, [1, 1], 'k', 'LineWidth', 2);
    
    xlabel(['D_' num2str(comb(i, 1))]); ylabel(['D_' num2str(comb(i, 2))]);
    title(['LDA: D_' num2str(comb(i, 1)) ' vs D_' num2str(comb(i, 2))]);
    legend({'TPU', 'Rubber', 'Decision Boundary'});
    grid on;
end

%% Apply LDA to 3D data and reduce to 2D for visualization
lda_3D = fitcdiscr(all_data, labels);
[coeff, score] = lda_3D.transform(all_data); % Project the data into the LDA subspace

% i. Re-plot reduced 2D data with LDA discrimination lines
figure;
scatter(score(labels == 1, 1), score(labels == 1, 2), 'r', 'filled');
hold on;
scatter(score(labels == 2, 1), score(labels == 2, 2), 'b', 'filled');

% Plot LDA decision boundary
xrange = linspace(min(score(:, 1)), max(score(:, 1)), 100);
yrange = linspace(min(score(:, 2)), max(score(:, 2)), 100);
[X, Y] = meshgrid(xrange, yrange);
Z = predict(lda_3D, [X(:), Y(:)]);
Z = reshape(Z, size(X));

contour(X, Y, Z, [1, 1], 'k', 'LineWidth', 2);
xlabel('LD1');
ylabel('LD2');
title('LDA: 2D Reduced Displacement Data');
legend({'TPU', 'Rubber', 'Decision Boundary'});
grid on;

% ii. Show 3D plot with discrimination plane
figure;
scatter3(all_data(labels == 1, 1), all_data(labels == 1, 2), all_data(labels == 1, 3), 'r', 'filled');
hold on;
scatter3(all_data(labels == 2, 1), all_data(labels == 2, 2), all_data(labels == 2, 3), 'b', 'filled');

% Plot LDA discrimination plane in 3D
% Create a grid of points
[x, y] = meshgrid(linspace(min(all_data(:, 1)), max(all_data(:, 1)), 30), ...
                  linspace(min(all_data(:, 2)), max(all_data(:, 2)), 30));
z = linspace(min(all_data(:, 3)), max(all_data(:, 3)), 30);
[X, Y, Z] = meshgrid(x, y, z);

% Predict the class labels for the grid
grid_data = [X(:), Y(:), Z(:)];
Z_pred = predict(lda_3D, grid_data);
Z_pred = reshape(Z_pred, size(X));

% Visualize decision boundary (plane) as a contour plot
contour3(X, Y, Z, Z_pred, [1, 1], 'k', 'LineWidth', 2);

xlabel('D_X'); ylabel('D_Y'); zlabel('D_Z');
title('3D LDA: Displacement Data with Discrimination Plane');
legend({'TPU', 'Rubber', 'Decision Boundary'});
grid on;
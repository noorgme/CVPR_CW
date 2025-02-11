%% Load data for Oblong TPU and Oblong Rubber
clear; clc; close all;

TPU_data = load("PR_CW_mat/oblong_TPU_papillarray_single.mat");
rubber_data = load("PR_CW_mat/oblong_rubber_papillarray_single.mat");

%% extract segment indicies

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

%% 3D Scatter Plot: Visualizing tactile displacement
figure;
scatter3(TPU_force(:,1), TPU_force(:,2), TPU_force(:,3), 20, 'r', 'filled');
hold on;
scatter3(rubber_force(:,1), rubber_force(:,2), rubber_force(:,3), 20, 'b', 'filled');

xlabel('D_X'); ylabel('D_Y'); zlabel('D_Z');
title('3D Scatter Plot of Central Papillae Displacement');
legend({'TPU', 'Rubber'});
grid on; view(45,30);
hold off;

%% Apply LDA to all 2D combinations of (D_X, D_Y, D_Z)
pairs = [1 2; 1 3; 2 3]; % (D_X, D_Y), (D_X, D_Z), (D_Y, D_Z)
figure;
for i = 1:3
    X_pair = all_data(:, pairs(i, :)); % Select 2D combination
    Mdl = fitcdiscr(X_pair, labels); % LDA model

    % Predict classification boundaries
    [X1, X2] = meshgrid(linspace(min(X_pair(:,1)), max(X_pair(:,1)), 100), ...
                         linspace(min(X_pair(:,2)), max(X_pair(:,2)), 100));
    X_grid = [X1(:), X2(:)];
    predictions = predict(Mdl, X_grid);
    
    subplot(1,3,i);
    gscatter(X_pair(:,1), X_pair(:,2), labels, 'rb', 'xo', 10);
    hold on;
    contour(X1, X2, reshape(predictions, size(X1)), [1.5 1.5], 'k', 'LineWidth', 1.5);
    xlabel(['D_', num2str(pairs(i,1))]); ylabel(['D_', num2str(pairs(i,2))]);
    title(['LDA on D_', num2str(pairs(i,1)), ' vs D_', num2str(pairs(i,2))]);
    hold off;
end

%% Apply LDA to full 3D displacement data
Mdl3D = fitcdiscr(all_data, labels); % Train LDA on 3D data
score = Mdl3D.predict(all_data); % Get predictions and scores

% Get the discriminant projections (LD1 and LD2)
lda_scores = Mdl3D.X * Mdl3D.Coeffs(1,2).Linear'; % Calculate LDA projection scores

%% 2D LDA visualization
X_lda2D = lda_scores(:, 1:2); % Use the first two LDA dimensions (LD1 and LD2)
figure;
gscatter(X_lda2D(:,1), X_lda2D(:,2), labels, 'rb', 'xo', 10); % 2D scatter plot
hold on;

% Plot decision boundary
[X1, X2] = meshgrid(linspace(min(X_lda2D(:,1)), max(X_lda2D(:,1)), 100), ...
                     linspace(min(X_lda2D(:,2)), max(X_lda2D(:,2)), 100));


xlabel('LD1');
ylabel('LD2');
title('2D LDA Projection of Displacement Data');
grid on;
hold off;

%% Show 3D Scatter Plot with Discrimination Plane
% Generate mesh for discrimination plane
[X1, X2] = meshgrid(linspace(min(all_data(:,1)), max(all_data(:,1)), 50), ...
                     linspace(min(all_data(:,2)), max(all_data(:,2)), 50));
X3 = -(Mdl3D.Coeffs(1,2).Linear(1) * X1 + Mdl3D.Coeffs(1,2).Linear(2) * X2 + Mdl3D.Coeffs(1,2).Const) / ...
      Mdl3D.Coeffs(1,2).Linear(3);

figure;
scatter3(TPU_force(:,1), TPU_force(:,2), TPU_force(:,3), 20, 'r', 'filled');
hold on;
scatter3(rubber_force(:,1), rubber_force(:,2), rubber_force(:,3), 20, 'b', 'filled');
surf(X1, X2, X3, 'FaceAlpha', 0.3, 'EdgeColor', 'none');

xlabel('D_X'); ylabel('D_Y'); zlabel('D_Z');
title('3D LDA with Discrimination Plane');
legend({'TPU', 'Rubber', 'Discrimination Plane'});
grid on; view(45,30);
hold off;
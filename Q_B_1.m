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

%% Extract Force Values of Middle Papillae
pap_number = 4;
normal_force = normal_data.sensor_matrices_force(normal_segments, (pap_number * 3) + 1 : (pap_number * 3) + 3);
TPU_force = TPU_data.sensor_matrices_force(TPU_segments, (pap_number * 3) + 1 : (pap_number * 3) + 3);
rubber_force = rubber_data.sensor_matrices_force(rubber_segments, (pap_number * 3) + 1 : (pap_number * 3) + 3);

%% Combine Data for PCA
all_data = [normal_force; TPU_force; rubber_force];  
standardized_data = (all_data - mean(all_data,1)) ./ std(all_data,1);
[coeff, score, latent] = pca(standardized_data);

%% Find Indices for Each Material in PCA Space
num_normal = size(normal_force, 1);
num_TPU = size(TPU_force, 1);
num_rubber = size(rubber_force, 1);

normal_idx = 1:num_normal;
TPU_idx = num_normal + (1:num_TPU);
rubber_idx = num_normal + num_TPU + (1:num_rubber);

%% 🎨 Create a Compact, Professional Figure
figure('Units', 'normalized', 'Position', [0.15, 0.15, 0.7, 0.7]);  
tiledlayout(2,2, 'TileSpacing', 'compact', 'Padding', 'compact'); 

%% 📌 Plot 1: 3D PCA Scatter with Principal Axes
nexttile;
scatter3(score(normal_idx,1), score(normal_idx,2), score(normal_idx,3), 10, 'r', 'filled'); hold on;
scatter3(score(TPU_idx,1), score(TPU_idx,2), score(TPU_idx,3), 10, 'g', 'filled');
scatter3(score(rubber_idx,1), score(rubber_idx,2), score(rubber_idx,3), 10, 'b', 'filled');

% Overlay principal axes
quiver3(0, 0, 0, coeff(1,1), coeff(2,1), coeff(3,1), 'r', 'LineWidth', 2);
quiver3(0, 0, 0, coeff(1,2), coeff(2,2), coeff(3,2), 'g', 'LineWidth', 2);
quiver3(0, 0, 0, coeff(1,3), coeff(2,3), coeff(3,3), 'b', 'LineWidth', 2);

xlabel('PC1'); ylabel('PC2'); zlabel('PC3');
title('3D PCA Scatter');
grid on; view(45,30);
hold off;

%% 📌 Plot 2: 2D PCA Projection
nexttile;
scatter(score(normal_idx,1), score(normal_idx,2), 10, 'r', 'filled'); hold on;
scatter(score(TPU_idx,1), score(TPU_idx,2), 10, 'g', 'filled');
scatter(score(rubber_idx,1), score(rubber_idx,2), 10, 'b', 'filled');

xlabel('PC1'); ylabel('PC2');
title('2D PCA Projection');
grid on;
hold off;

%% 📌 Plot 3: Variance Explained by Principal Components
nexttile;
bar(latent / sum(latent) * 100, 'FaceColor', [0.3, 0.3, 0.9]);
xlabel('Principal Component'); ylabel('% Variance Explained');
title('PCA Variance Distribution');
grid on;

%% 📌 Plot 4: 1D Number Line for All Principal Components
nexttile;
scatter(score(:,1), ones(size(score(:,1))) * 3, 10, 'r', 'filled'); hold on;
scatter(score(:,2), ones(size(score(:,2))) * 2, 10, 'g', 'filled');
scatter(score(:,3), ones(size(score(:,3))) * 1, 10, 'b', 'filled');
ylim([0.5, 3.5]); yticks([1,2,3]); yticklabels({'PC3','PC2','PC1'});
xlabel('Score Value');
title('Data Distribution Across PCs');
grid on;
hold off;

%% 📌 Global Legend
lgd = legend({'PLA', 'TPU', 'Rubber'}, 'Location', 'southoutside', 'Orientation', 'horizontal');
lgd.FontSize = 12; lgd.Box = 'off';

%% Final Formatting for Professional Presentation
set(findall(gcf,'-property','FontSize'),'FontSize',14);
set(findall(gcf,'-property','FontName'),'FontName','Times New Roman');

%% 🎨 Create Single Figure with 1 Row, 3 Columns
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.9, 0.4]); 
outerTL = tiledlayout(1,3, 'TileSpacing', 'compact', 'Padding', 'compact');

%% 📌 (a) Scree Plot (Variance Explained)
ax1 = nexttile(outerTL);
plot(1:length(latent), latent/sum(latent)*100, '-o', 'LineWidth', 2);
xlabel('Principal Component');
ylabel('Variance Explained (%)');
title('Scree Plot');
grid on;

%% 📌 (b) 2D PCA Projection
ax2 = nexttile(outerTL);
scatter(score(normal_idx,1), score(normal_idx,2), 10, 'r', 'filled'); hold on;
scatter(score(TPU_idx,1), score(TPU_idx,2), 10, 'g', 'filled');
scatter(score(rubber_idx,1), score(rubber_idx,2), 10, 'b', 'filled');
xlabel('PC1'); ylabel('PC2');
title('2D PCA Projection');
grid on; 
hold off;

%% 📌 (c) Nested Tiled Layout for 1D Number Lines

% Create third tile and capture its position
outerTile3 = nexttile(outerTL);
tilePos = outerTile3.Position;  % get the position of this tile
delete(outerTile3);             % remove the blank axes

% Create a uipanel in the same position to host the nested layout
panel = uipanel(outerTL.Parent, 'Units','normalized', 'Position', tilePos);

% Create a nested tiled layout within the uipanel
innerTL = tiledlayout(panel, 3, 1, 'TileSpacing','compact','Padding','compact');

% --- PC1 Plot ---
ax3 = nexttile(innerTL);
scatter(score(normal_idx,1), ones(size(normal_idx)), 10, 'r', 'filled'); hold on;
scatter(score(TPU_idx,1), ones(size(TPU_idx)), 10, 'g', 'filled');
scatter(score(rubber_idx,1), ones(size(rubber_idx)), 10, 'b', 'filled');
xlim([min(score(:,1)) max(score(:,1))]);
set(gca, 'YTick', []);  % Remove y-axis ticks
title('PC1');
grid on;
hold off;

% --- PC2 Plot ---
ax4 = nexttile(innerTL);
scatter(score(normal_idx,2), ones(size(normal_idx)), 10, 'r', 'filled'); hold on;
scatter(score(TPU_idx,2), ones(size(TPU_idx)), 10, 'g', 'filled');
scatter(score(rubber_idx,2), ones(size(rubber_idx)), 10, 'b', 'filled');
xlim([min(score(:,2)) max(score(:,2))]);
set(gca, 'YTick', []);
title('PC2');
grid on;
hold off;

% --- PC3 Plot ---
ax5 = nexttile(innerTL);
scatter(score(normal_idx,3), ones(size(normal_idx)), 10, 'r', 'filled'); hold on;
scatter(score(TPU_idx,3), ones(size(TPU_idx)), 10, 'g', 'filled');
scatter(score(rubber_idx,3), ones(size(rubber_idx)), 10, 'b', 'filled');
xlim([min(score(:,3)) max(score(:,3))]);
set(gca, 'YTick', []);
title('PC3');
grid on;
hold off;

%% 📌 Global Legend (Below All Figures)
lgd = legend({'PLA', 'TPU', 'Rubber'}, 'Location', 'southoutside', 'Orientation', 'horizontal');
lgd.FontSize = 12; 
lgd.Box = 'off';

%% 🎨 Final Formatting for Professional Presentation
set(findall(gcf,'-property','FontSize'),'FontSize',14);
set(findall(gcf,'-property','FontName'),'FontName','Times New Roman');

  %% Section C0: Extract and Save Displacement Data at Peak Contacts (Oblong Objects)

% Define file paths
data_folder = 'PR_CW_mat';  % Ensure data is saved in the correct folder
processed_folder = 'PR_CW_mat'; % Keep output files in the same structure

oblong_files = {'oblong_TPU_papillarray_single.mat', ...
                'oblong_rubber_papillarray_single.mat'};
         
output_files = {'sensor_data_oblong_TPU.mat', ...
                'sensor_data_oblong_Rubber.mat'};

% Loop through each file and process 
for i = 1:length(oblong_files)
    file_path = fullfile(data_folder, oblong_files{i});
    
    % Check if file exists
    if exist(file_path, 'file') ~= 2
        warning('File not found: %s', file_path);
        continue;
    end

    % Load data
    data = load(file_path);

    % Check if force/torque data exists
    if ~isfield(data, 'ft_values')
        warning('Variable "ft_values" not found in %s', oblong_files{i});
        continue;
    end

    % Extract normal force (Z-axis) for peak detection
    normal_force = data.ft_values(:,3);

    % Apply Filtering to Detect Major Contact Peaks
    [peaks, peak_indices] = findpeaks(-normal_force, ...   
        'MinPeakHeight', -5, ...       
        'MinPeakProminence', 2, ...    
        'MinPeakDistance', 50);        

    % Convert back to original force values
    peaks = -peaks;

    % Keep only peaks **strictly below -8N**
    valid_peak_indices = peaks < -8;  
    peaks = peaks(valid_peak_indices);
    peak_indices = peak_indices(valid_peak_indices);

    % Check if there are valid peaks
    if isempty(peak_indices)
        warning('No significant force peaks detected in %s.', oblong_files{i});
        continue;
    end

    % Validate if displacement data exists
    if ~isfield(data, 'sensor_matrices_displacement')
        warning('Displacement data missing in %s', oblong_files{i});
        continue;
    end

    % Extract sensor data at peak contact points
    tactile_displacement = data.sensor_matrices_displacement(peak_indices, :);
    tactile_force = data.sensor_matrices_force(peak_indices, :);
    force_torque = data.ft_values(peak_indices, :);

    % Save the extracted sensor data in PR_CW_mat folder with correct naming convention
    save(fullfile(processed_folder, output_files{i}), ...
        'tactile_force', 'tactile_displacement', 'force_torque');

    fprintf('Extracted and saved sensor data for %s\n', oblong_files{i});
end

disp('Section C0: Displacement and force data extracted and saved in PR_CW_mat.');

%% Section C1a: Load Processed Displacement Data for Oblong TPU and Oblong Rubber

% Define processed data files (saved in PR_CW_mat)
processed_files = {'sensor_data_oblong_TPU.mat', ...
                   'sensor_data_oblong_Rubber.mat'};
labels = [];
displacement_data = [];
colors = {'r', 'b'}; % TPU = Red, Rubber = Blue

% Loop through saved displacement files
for i = 1:length(processed_files)
    file_path = fullfile(data_folder, processed_files{i});

    % Check if processed file exists
    if exist(file_path, 'file') ~= 2
        warning('Processed file not found: %s', file_path);
        continue;
    end
    
    % Load processed displacement data
    data = load(file_path);
    
    if ~isfield(data, 'tactile_displacement')
        warning('Variable "tactile_displacement" not found in %s', processed_files{i});
        continue;
    end

    % Store displacement data and labels
    displacement_data = [displacement_data; data.tactile_displacement];
    labels = [labels; ones(size(data.tactile_displacement, 1), 1) * i]; % 1 = TPU, 2 = Rubber
end

% Final check: If displacement_data is empty, stop execution
if isempty(displacement_data)
    error('No valid displacement data loaded! Check processing in Section C0.');
end

% Display size of loaded data
disp(['Displacement data size: ', num2str(size(displacement_data, 1)), ' x ', num2str(size(displacement_data, 2))]);

disp('Section C1a: Processed displacement data loaded from PR_CW_mat.');


%% Section C1b: Visualize Tactile Displacement with a 3D Scatter Plot (Duplicated for Viewing Angles)

figure;
for j = 1:2  % Create two identical subplots with different angles
    subplot(1,2,j);
    hold on;
    scatter3(displacement_data(labels == 1, 1), displacement_data(labels == 1, 2), displacement_data(labels == 1, 3), ...
             30, colors{1}, 'filled'); % TPU = Red
    scatter3(displacement_data(labels == 2, 1), displacement_data(labels == 2, 2), displacement_data(labels == 2, 3), ...
             30, colors{2}, 'filled'); % Rubber = Blue
    xlabel('Displacement X');
    ylabel('Displacement Y');
    zlabel('Displacement Z');
    title(sprintf('3D Scatter of Central Papillae Displacement - View %d', j));
    legend('Oblong TPU', 'Oblong Rubber');
    grid on;
    
    hold off;
end

disp('Section C1b: 3D scatter plots (duplicated views) created.');


%% Section C1c.1: Standardize Data
displacement_data_std = zscore(displacement_data);
disp('Data standardized.');

%% Section C1c.2: Compute Class Means & Overall Mean
mean_tpu = mean(displacement_data_std(labels == 1, :), 1); % Mean for TPU
mean_rubber = mean(displacement_data_std(labels == 2, :), 1); % Mean for Rubber
overall_mean = mean(displacement_data_std, 1); % Overall mean

disp('Class means computed:');
disp('TPU Mean:'); disp(mean_tpu);
disp('Rubber Mean:'); disp(mean_rubber);
disp('Overall Mean:'); disp(overall_mean);

%% Section C1c.3: Compute Scatter Matrices

% Initialize Within-Class Scatter Matrix (Sw)
Sw = zeros(size(displacement_data_std, 2)); 

for i = 1:size(displacement_data_std, 1) % Loop through each data point
    xi = displacement_data_std(i, :)'; % Convert row vector to column vector (27x1)
    
    if labels(i) == 1
        mi = mean_tpu(:); % Ensure it's 27x1 column vector
    else
        mi = mean_rubber(:); % Ensure it's 27x1 column vector
    end
    
    % Debugging: Display sizes to verify
    if i == 1
        disp(['Size of xi: ', num2str(size(xi))]);
        disp(['Size of mi: ', num2str(size(mi))]);
    end
    
    Sw = Sw + (xi - mi) * (xi - mi)'; % Accumulate
end

% Compute Between-Class Scatter Matrix (Sb)
Sb = (mean_tpu(:) - overall_mean(:)) * (mean_tpu(:) - overall_mean(:))' + ...
     (mean_rubber(:) - overall_mean(:)) * (mean_rubber(:) - overall_mean(:))';

% Print Matrices
disp('Within-Class Scatter Matrix (Sw):'); disp(Sw);
disp('Between-Class Scatter Matrix (Sb):'); disp(Sb);


%% Section C1c.4: Compute Eigenvectors & Eigenvalues
[W, L] = eig(pinv(Sw) * Sb); % Solve for LDA transformation

% Extract eigenvalues & eigenvectors
eigenvalues = diag(L);
[eigenvalues_sorted, index] = sort(eigenvalues, 'descend'); % Sort in descending order
W = W(:, index); % Reorder eigenvectors accordingly

disp('Eigenvalues (sorted):'); disp(eigenvalues_sorted);
disp('Eigenvectors (sorted):'); disp(W);

%% Section C1c.5: Reduce Data to 2D and Replot with LD & Decision Boundaries
lda_projection = displacement_data_std * W(:, 1:2); % Select top 2 eigenvectors

figure;
hold on;
scatter(lda_projection(labels == 1, 1), lda_projection(labels == 1, 2), 30, colors{1}, 'filled');
scatter(lda_projection(labels == 2, 1), lda_projection(labels == 2, 2), 30, colors{2}, 'filled');

% Plot LDA Decision Boundary
x_range = linspace(min(lda_projection(:, 1)), max(lda_projection(:, 1)), 100);
y_range = linspace(min(lda_projection(:, 2)), max(lda_projection(:, 2)), 100);
[X, Y] = meshgrid(x_range, y_range);
Z = predict(fitcdiscr(lda_projection, labels), [X(:), Y(:)]);
Z = reshape(Z, size(X));
contour(X, Y, Z, 'k', 'LineWidth', 2);

xlabel('LD1'); ylabel('LD2');
title('LDA Projection & Decision Boundary');
legend('Oblong TPU', 'Oblong Rubber');
grid on;
hold off;

disp('Section C1c.5: Data reduced to 2D and plotted with decision boundary.');

%% Section C1c.6: 3D Plot with LDA Discrimination Plane (Using patch()), Duplicated for Two Views
figure;

for j = 1:2  % Create two identical subplots for different viewing angles
    subplot(1,2,j);
    hold on;
    
    % Scatter plot for TPU and Rubber
    scatter3(displacement_data_std(labels == 1, 1), displacement_data_std(labels == 1, 2), displacement_data_std(labels == 1, 3), ...
             30, colors{1}, 'filled');
    scatter3(displacement_data_std(labels == 2, 1), displacement_data_std(labels == 2, 2), displacement_data_std(labels == 2, 3), ...
             30, colors{2}, 'filled');

    % Create a 3D discrimination plane
    x_range = linspace(min(displacement_data_std(:, 1)), max(displacement_data_std(:, 1)), 10);
    y_range = linspace(min(displacement_data_std(:, 2)), max(displacement_data_std(:, 2)), 10);
    [X, Y] = meshgrid(x_range, y_range);
    Z = -(W(1,1) * X + W(2,1) * Y) / W(3,1); % Solve for Z

    % Use patch() to plot the LDA plane
    patch([min(X(:)), max(X(:)), max(X(:)), min(X(:))], ...
          [min(Y(:)), min(Y(:)), max(Y(:)), max(Y(:))], ...
          [min(Z(:)), max(Z(:)), max(Z(:)), min(Z(:))], ...
          'g', 'FaceAlpha', 0.5, 'EdgeColor', 'none'); % Green transparent plane

    xlabel('Displacement X'); ylabel('Displacement Y'); zlabel('Displacement Z');
    title(sprintf('3D LDA Projection with Discrimination Plane - View %d', j));
    legend('Oblong TPU', 'Oblong Rubber', 'LDA Plane');
    grid on;
    hold off;
end

disp('Section C1c.6: 3D LDA plots (two views) with discrimination plane created.');

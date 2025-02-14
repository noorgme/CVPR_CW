function contact_peaks = segment_contacts(file_name, save_results)
    % Load Data
    folder_path = fullfile(pwd, 'PR_CW_mat');
    file_path = fullfile(folder_path, file_name);
    data = load(file_path);
    
    normal_force = data.ft_values(:,3); % Assuming Fz (3rd column) is normal force
    time = 1:length(normal_force); % Time index

    force_threshold = 6;  % Absolute force threshold for contact detection
    min_prominence = 4;   % Minimum peak prominence for findpeaks()

    % Identify contact start and end indices
    contact_mask = abs(normal_force) > force_threshold;
    contact_segments = find_contact_segments(contact_mask);

    % If no contacts are found, return empty vector
    if isempty(contact_segments)
        disp('No significant contacts detected.');
        contact_peaks = [];
        return;
    end

    % Initialize empty arrays for peak indices and values
    peak_indices = [];
    peak_values = [];

    % Process each contact segment (ignoring short ones)
    for i = 1:size(contact_segments, 1)
        idx_range = contact_segments(i,1):contact_segments(i,2);
        force_segment = normal_force(idx_range);
        
        % Ignore segments shorter than 10 samples
        if length(force_segment) < 10
            continue;
        end

        % Detect peaks in positive and negative forces
        [pos_peaks, pos_locs] = findpeaks(force_segment, 'MinPeakProminence', min_prominence);
        [neg_peaks, neg_locs] = findpeaks(-force_segment, 'MinPeakProminence', min_prominence);

        % Combine positive and negative peaks
        all_peaks = [pos_peaks, -neg_peaks];  
        all_locs = [pos_locs, neg_locs];      

        if ~isempty(all_peaks)
            % Find the most prominent peak (largest force magnitude)
            [~, max_idx] = max(abs(all_peaks)); 
            peak_values(end+1) = all_peaks(max_idx); % Keep original sign
            peak_indices(end+1) = idx_range(all_locs(max_idx)); % Convert to global index
        else
            % No prominent peaks detected, default to max force in segment
            [max_force, rel_idx] = max(abs(force_segment));
            peak_values(end+1) = force_segment(rel_idx); % Preserve sign
            peak_indices(end+1) = idx_range(rel_idx);
        end
    end

    % Convert to column vectors
    peak_indices = peak_indices(:);
    peak_values = peak_values(:); % flip from negatives

    % Save peaks and indices if requested
    if save_results
        base_name = char(strrep(file_name, '.mat', ''));
        save(['contact_segments/contact_peaks_' base_name '.mat'], 'peak_indices', 'peak_values');
    end

    % 📌 **NEW: Plot Normal Force with Detected Peaks**
    %{
    figure;
    plot(time, normal_force, 'b', 'LineWidth', 1); % Plot normal force
    hold on;
    scatter(peak_indices, peak_values, 60, 'r', 'filled'); % Mark detected peaks
    xlabel('Time (Index)');
    ylabel('Normal Force (N)');
    title(['Normal Force & Detected Peaks - ', file_name], 'Interpreter', 'none');
    grid on;
    legend('Normal Force', 'Detected Peaks');
    hold off;
    %}
    

    % Return only peak indices
    contact_peaks = peak_indices;
end


%% **Helper Function to Find Contact Segments**
function segments = find_contact_segments(contact_mask)
    segments = [];
    in_contact = false;
    start_idx = 0;

    for i = 1:length(contact_mask)
        if ~in_contact && contact_mask(i)
            start_idx = i; % Start of a contact
            in_contact = true;
        elseif in_contact && ~contact_mask(i)
            segments = [segments; start_idx, i-1]; % Store segment
            in_contact = false;
        end
    end

    % If a contact was still active at the end, close the segment
    if in_contact
        segments = [segments; start_idx, length(contact_mask)];
    end
end


function extract_sensor_at_peaks(file_name, contact_peaks)
    folder_path = fullfile(pwd, 'PR_CW_mat');
    file_path = fullfile(folder_path, file_name);
    data = load(file_path);
    ft_values = data.ft_values;
    displacement_values = data.sensor_matrices_displacement;
    force_values = data.sensor_matrices_force;

    ft_force_peaks = ft_values(contact_peaks, 1:3);
    ft_torque_peaks = ft_values(contact_peaks, 4:6);

    displacement_peaks = displacement_values(contact_peaks, :);

    force_peaks = force_values(contact_peaks, :);

    disp(ft_torque_peaks);
    disp(length(ft_torque_peaks));
end






% __MAIN__
% Define folder containing .mat files
folder_path = fullfile(pwd, 'PR_CW_mat');

% Get list of all .mat files in the folder
file_list = dir(fullfile(folder_path, '*.mat'));

% Ensure output directory exists
output_folder = fullfile(pwd, 'contact_segments');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Loop through each .mat file and process it
for i = 1:length(file_list)
    file_name = file_list(i).name;
    
    fprintf('Processing file: %s\n', file_name);
    
    % Run segmentation function
    contact_peaks = segment_contacts(file_name, true);
    
    % If peaks were detected, extract sensor values at peaks
    if ~isempty(contact_peaks)
        extract_sensor_at_peaks(file_name, contact_peaks);
    else
        fprintf('No significant contacts detected in %s\n', file_name);
    end
end

function plot_all_contact_peaks(shapes, materials)
    % PLOT_ALL_CONTACT_PEAKS: Professionally formatted figure with multiple subplots
    % for normal force data with detected peaks across different shapes and materials.
    %
    % INPUT:
    %   shapes - Cell array of shape names (e.g., {'cylinder', 'hexagon', 'oblong'}).
    %   materials - Cell array of materials (e.g., {'PLA', 'rubber', 'TPU'}).

    folder_path = fullfile(pwd, 'PR_CW_mat');
    num_shapes = length(shapes);
    num_materials = length(materials);
    
    % Create high-quality figure
    figure('Units', 'normalized', 'Position', [0.05, 0.05, 0.9, 0.8]); 
    tiledlayout(num_shapes, num_materials, 'TileSpacing', 'compact', 'Padding', 'compact'); % Compact layout

    % Placeholder for legend handles
    h1 = []; h2 = [];

    % Define color scheme
    force_color = [0, 0.447, 0.741]; % MATLAB default blue
    peak_color = [0.850, 0.325, 0.098]; % MATLAB default red

    for i = 1:num_shapes
        for j = 1:num_materials
            shape = shapes{i};
            material = materials{j};

            % Construct filename dynamically
            if strcmp(material, 'PLA')
                material_prefix = "";
            else
                material_prefix = sprintf('%s_', material);
            end
            file_name = sprintf('%s_%spapillarray_single.mat', shape, material_prefix);
            file_path = fullfile(folder_path, file_name);
            
            % Determine subplot index
            nexttile;

            % Load data
            if exist(file_path, 'file')
                data = load(file_path);
                normal_force = data.ft_values(:,3); % Assuming Fz (3rd column) is normal force
                time = 1:length(normal_force);

                % Detect peaks
                [peak_indices, peak_values] = detect_contact_peaks(normal_force);

                % Plot normal force
                h1 = plot(time, normal_force, 'Color', force_color, 'LineWidth', 1.2); 
                hold on;
                % Plot detected peaks
                h2 = scatter(peak_indices, peak_values, 40, peak_color, 'filled'); 

                xlabel('Time (Index)', 'FontSize', 14, 'FontWeight', 'bold');
                ylabel('Normal Force (N)', 'FontSize', 14, 'FontWeight', 'bold');
                title(sprintf('%s - %s', shape, material), 'Interpreter', 'none', 'FontSize', 14, 'FontWeight', 'bold');
                grid on;
                set(gca, 'FontSize', 14, 'FontName', 'Times New Roman', 'LineWidth', 1); % Professional styling
            else
                warning('File not found: %s', file_path);
                title(sprintf('Missing: %s - %s', shape, material), 'Interpreter', 'none', 'FontSize', 14, 'FontWeight', 'bold');
            end
        end
    end

    % 📌 Add a single legend outside the subplots
    if ~isempty(h1) && ~isempty(h2)
        l = legend([h1, h2], {'Normal Force', 'Detected Peaks'}, 'FontSize', 12, 'FontWeight', 'bold');
        l.Layout.Tile = 'southoutside'; % Position the legend below the plots
    end
end

%% **Helper Function to Detect Contact Peaks**
function [peak_indices, peak_values] = detect_contact_peaks(normal_force)
    force_threshold = 7;  % Absolute force threshold for contact detection
    min_prominence = 4;   % Minimum peak prominence for findpeaks()

    % Identify contact start and end indices
    contact_mask = abs(normal_force) > force_threshold;
    contact_segments = find_contact_segments(contact_mask);

    % Initialize empty arrays for peak indices and values
    peak_indices = [];
    peak_values = [];

    % Process each contact segment
    for i = 1:size(contact_segments, 1)
        idx_range = contact_segments(i,1):contact_segments(i,2);
        force_segment = normal_force(idx_range);
        
        if length(force_segment) < 10
            continue;
        end

        % Detect peaks
        [pos_peaks, pos_locs] = findpeaks(force_segment, 'MinPeakProminence', min_prominence);
        [neg_peaks, neg_locs] = findpeaks(-force_segment, 'MinPeakProminence', min_prominence);

        % Combine positive and negative peaks
        all_peaks = [pos_peaks, -neg_peaks];  
        all_locs = [pos_locs, neg_locs];

        if ~isempty(all_peaks)
            [~, max_idx] = max(abs(all_peaks)); 
            peak_values(end+1) = all_peaks(max_idx);
            peak_indices(end+1) = idx_range(all_locs(max_idx));
        else
            [max_force, rel_idx] = max(abs(force_segment));
            peak_values(end+1) = force_segment(rel_idx);
            peak_indices(end+1) = idx_range(rel_idx);
        end
    end

    peak_indices = peak_indices(:);
    peak_values = peak_values(:); % Keep original sign
end

%% **Run Function**
plot_all_contact_peaks({'cylinder', 'hexagon', 'oblong'}, {'PLA', 'rubber', 'TPU'});



fprintf('Processing complete for all files.\n');



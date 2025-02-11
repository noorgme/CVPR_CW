function contact_peaks = segment_contacts(file_name, save_results)
    % Load Data
    folder_path = fullfile(pwd, 'PR_CW_mat');
    file_path = fullfile(folder_path, file_name);
    data = load(file_path);
    
    normal_force = data.ft_values(:,3); % Assuming Fz (3rd column) is normal force

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
    peak_values = peak_values(:);

    % Save peaks and indices if requested
    if save_results
        base_name = char(strrep(file_name, '.mat', ''));
        save(['contact_segments/contact_peaks_' base_name '.mat'], 'peak_indices', 'peak_values');
        %save(['contact_segments/contact_segments_' base_name '.mat'], 'contact_segments');
    end

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

fprintf('Processing complete for all files.\n');



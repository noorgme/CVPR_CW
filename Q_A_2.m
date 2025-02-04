function segment_contacts(file_path, save_results)
    % Load data
    data = load(file_path);
    time = 1:size(data.ft_values,1); % Time index
    normal_force = data.ft_values(:,3); % Assuming Fz (3rd column) is normal force

    force_threshold = 2; % Define contact force threshold

    % Identify when force exceeds threshold (contact events)
    contact_mask = abs(normal_force) > force_threshold;

    % Find start and end indices of each contact segment
    contact_segments = find_contact_segments(contact_mask);

    % Initialize arrays for storing max force peaks
    peak_values = [];
    peak_indices = [];

    % Find max force in each segment
    for i = 1:size(contact_segments, 1)
        idx_range = contact_segments(i,1):contact_segments(i,2);
        [max_force, max_idx] = max(abs(normal_force(idx_range))); % Get max within segment
        peak_values(i) = max_force;
        peak_indices(i) = idx_range(max_idx); % Convert to global time index
    end

    % Plot force data with peaks marked
    figure('Position', [100, 100, 1500, 600]);
    plot(time, normal_force, 'b', 'LineWidth', 1); hold on;
    plot(peak_indices, peak_values, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); % Mark peaks

    % Highlight contact segments
    for i = 1:size(contact_segments, 1)
        idx_range = contact_segments(i,1):contact_segments(i,2);
        plot(idx_range, normal_force(idx_range), 'r', 'LineWidth', 2);
    end

    % Formatting
    xlabel('Time Index', 'FontSize', 12);
    ylabel('Normal Force (N)', 'FontSize', 12);
    title(['Segmented Contact Events with Max Force Peaks - ', file_path], 'Interpreter', 'none', 'FontSize', 14);
    legend('Normal Force', 'Detected Peaks');
    grid on;

    % Display peak indices
    disp('Detected Max Force Peaks at Indices:');
    disp(peak_indices);

    % Save peaks and indices (for 2b)
    if save_results
        save('contact_peaks.mat', 'peak_values', 'peak_indices');
    end

    % Extract tactile sensor data (for 2c)
    extract_contact_data(file_path, peak_indices, save_results);
end

%% **Helper Function to Find Contact Segments**
function segments = find_contact_segments(contact_mask)
    % Identify start and end of each contact period
    contact_diff = diff([0; contact_mask; 0]); % Add 0 at start & end for boundary detection
    contact_starts = find(contact_diff == 1); % Find rising edges
    contact_ends = find(contact_diff == -1) - 1; % Find falling edges

    % Combine into a matrix [start_idx, end_idx]
    segments = [contact_starts, contact_ends];
end

%% **Function to Extract Tactile Sensor Data for 2c**
function extract_contact_data(file_path, peak_indices, save_results)
    % Load data
    data = load(file_path);

    % Extract force and displacement data at peak indices
    force_data_at_peaks = data.sensor_matrices_force(peak_indices, :);
    displacement_data_at_peaks = data.sensor_matrices_displacement(peak_indices, :);
    torque_data_at_peaks = data.ft_values(peak_indices, :); % Full force/torque data

    % Display extracted data size
    disp('Extracted Force Data Size:'), disp(size(force_data_at_peaks));
    disp('Extracted Displacement Data Size:'), disp(size(displacement_data_at_peaks));

    % Save extracted data
    if save_results
        save('contact_sensor_data.mat', 'force_data_at_peaks', 'displacement_data_at_peaks', 'torque_data_at_peaks');
    end
end

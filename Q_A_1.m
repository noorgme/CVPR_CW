function plot_trajectories(shapes, materials)
    % PLOT_TRAJECTORIES: Plots movement and force data for selected shapes.
    % 
    % INPUT:
    %   shapes - Cell array of shape names (e.g., {'cylinder', 'hexagon', 'oblong'}).
    %   materials - Array of which materials to plot for each given shape {'PLA', 'TPU', 'Rubber'}
    %
    % This function processes the selected shapes by loading corresponding .mat
    % files, extracting the end effector pose and force data, and generating
    % clear, readable plots.

    % Data folder
    folder_path = fullfile(pwd, 'PR_CW_mat');

    % empty list for selected files
    selected_files = {};

    % Generate filenames dynamically based on shapes and materials
    for i = 1:length(shapes)
        shape = shapes{i};
        for j = 1:length(materials)
            if strcmp(materials{j}, 'PLA')
                material = "";
            else
                material = sprintf('%s_', materials{j});
            end
       
            selected_files{end+1} = sprintf('%s_%spapillarray_single.mat', shape, material);
        end
    end

    % Process each selected file
    for i = 1:length(selected_files)
        file_path = fullfile(folder_path, selected_files{i});
        fprintf('Processing: %s\n', selected_files{i});
        process_file(file_path, selected_files{i});
    end
end

%% Function to Process Each File
function process_file(file_path, file_name)
    % PROCESS_FILE: Loads and processes movement/force data from a .mat file.

    % Load the .mat file
    data = load(file_path);

    % Extract relevant data
    poses = data.end_effector_poses;  % 6D end-effector position & orientation
    ft_values = data.ft_values;       % Force/torque values
    time = 1:size(poses,1);           % Use row number as time index

    % Generate plots
    plot_trajectory_3D(poses, file_name);
    plot_position_over_time(time, poses, file_name);
    plot_orientation_over_time(time, poses, file_name);
    plot_force_over_time(time, ft_values, file_name);
end

%% 3D Trajectory Plot Function
function plot_trajectory_3D(poses, file_name)
    figure('Position', [100, 100, 1500, 500]);
    plot3(poses(:,1), poses(:,2), poses(:,3), 'b', 'LineWidth', 0.6);
    xlabel('X Position', 'FontSize', 12); 
    ylabel('Y Position', 'FontSize', 12); 
    zlabel('Z Position', 'FontSize', 12);
    title(['3D Trajectory of End Effector - ', file_name], 'Interpreter', 'none', 'FontSize', 14);
    grid on; axis equal; view(3);
end

%% Position Over Time Plot Function
function plot_position_over_time(time, poses, file_name)
    figure('Position', [100, 100, 1500, 500]);
    labels = {'X Position', 'Y Position', 'Z Position'};
    colors = {'r', 'g', 'b'};

    for i = 1:3
        subplot(3,1,i);
        plot(time, poses(:,i), colors{i}, 'LineWidth', 0.6);
        xlabel('Time (index)', 'FontSize', 12);
        ylabel(labels{i}, 'FontSize', 12);
        title([labels{i}, ' Over Time - ', file_name], 'Interpreter', 'none', 'FontSize', 14);
        grid on;
    end
end

%% Orientation Over Time Plot Function
function plot_orientation_over_time(time, poses, file_name)
    figure('Position', [100, 100, 1500, 500]);
    labels = {'Roll', 'Pitch', 'Yaw'};
    colors = {'r', 'g', 'b'};

    for i = 4:6
        subplot(3,1,i-3);
        plot(time, poses(:,i), colors{i-3}, 'LineWidth', 0.6);
        xlabel('Time (index)', 'FontSize', 12);
        ylabel([labels{i-3}, ' (°)'], 'FontSize', 12);
        title([labels{i-3}, ' Over Time - ', file_name], 'Interpreter', 'none', 'FontSize', 14);
        grid on;
    end
end

%% Force Over Time Plot Function
function plot_force_over_time(time, ft_values, file_name)
    figure('Position', [100, 100, 1500, 500]);
    labels = {'Force X (N)', 'Force Y (N)', 'Force Z (N)'};
    colors = {'r', 'g', 'b'};

    for i = 1:3
        subplot(3,1,i);
        plot(time, ft_values(:,i), colors{i}, 'LineWidth', 0.6);
        xlabel('Time (index)', 'FontSize', 12);
        ylabel(labels{i}, 'FontSize', 12);
        title([labels{i}, ' - ', file_name], 'Interpreter', 'none', 'FontSize', 14);
        grid on;
    end
end

function plot_3D_trajectories(shapes, materials)
    % PLOT_3D_TRAJECTORIES: Plots 3D end effector trajectories for two shapes 
    % and three materials in a single figure with six subplots.
    %
    % INPUT:
    %   shapes - Cell array of two shape names (e.g., {'cylinder', 'hexagon'}).
    %   materials - Cell array of three materials (e.g., {'TPU', 'rubber', 'papillarray'}).
    %
    % OUTPUT:
    %   A single figure with six subplots, each showing the 3D trajectory of the end effector.
    
    if length(shapes) ~= 2 || length(materials) ~= 3
        error('This function requires exactly two shapes and three materials.');
    end

    % Data folder path
    folder_path = fullfile(pwd, 'PR_CW_mat');

    % Create figure
    figure('Position', [100, 100, 1200, 800]);
    
    % Loop over shapes and materials
    for i = 1:length(shapes)
        shape = shapes{i};
        for j = 1:length(materials)
            material = materials{j};
            
            % Construct filename
            if strcmp(material, 'PLA')
                material_prefix = "";
            else
                material_prefix = sprintf('%s_', material);
            end
            file_name = sprintf('%s_%spapillarray_single.mat', shape, material_prefix);
            file_path = fullfile(folder_path, file_name);
            
            % Load data
            if exist(file_path, 'file')
                data = load(file_path);
                poses = data.end_effector_poses;  % Extract end effector positions

                % Determine subplot index
                subplot_idx = (i-1) * 3 + j;
                
                % Plot
                subplot(2, 3, subplot_idx);
                plot3(poses(:,1), poses(:,2), poses(:,3), 'b', 'LineWidth', 0.6);
                xlabel('X Position', 'FontSize', 10);
                ylabel('Y Position', 'FontSize', 10);
                zlabel('Z Position', 'FontSize', 10);
                title(sprintf('%s - %s', shape, material), 'Interpreter', 'none', 'FontSize', 12);
                grid on; axis equal; view(3);
            else
                % Handle missing files
                warning('File not found: %s', file_path);
                subplot_idx = (i-1) * 3 + j;
                subplot(2, 3, subplot_idx);
                title(sprintf('Missing: %s - %s', shape, material), 'Interpreter', 'none', 'FontSize', 12);
            end
        end
    end
end

plot_3D_trajectories({'cylinder', 'hexagon'}, {'PLA', 'rubber', 'TPU'});

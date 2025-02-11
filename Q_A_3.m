%% load data

normal_data = load("PR_CW_mat/cylinder_papillarray_single.mat");
TPU_data = load("PR_CW_mat/cylinder_TPU_papillarray_single.mat");
rubber_data = load("PR_CW_mat/cylinder_rubber_papillarray_single.mat");


%% extract segment indicies

normal_segments = load("contact_segments/contact_peaks_cylinder_papillarray_single.mat");
TPU_segments = load("contact_segments/contact_peaks_cylinder_TPU_papillarray_single.mat");
rubber_segments = load("contact_segments/contact_peaks_cylinder_rubber_papillarray_single.mat");

normal_segments = normal_segments.contact_segments;
TPU_segments = TPU_segments.contact_segments;
rubber_segments = rubber_segments.contact_segments;

segment_list = {normal_segments, TPU_segments, rubber_segments};
index_list = [];

% Initialize expanded material list
expanded_segments = cell(1, length(segment_list));

% Iterate over materials
for m = 1:length(segment_list)
    segments = segment_list{m};
    index_list = []; % Initialize index list for the material
    
    % Iterate over each contact segment
    for i = 1:size(segments, 1)
        indices = segments(i,1):segments(i,2); % Expand segment range
        index_list = [index_list, indices]; % Concatenate indices
    end
    
    % Store expanded indices in the material list
    expanded_segments{m} = index_list;
end

normal_segment_list = expanded_segments{1};
TPU_segment_list = expanded_segments{2};
rubber_segment_list = expanded_segments{3};

%% Extract force values of middle papilae

pap_number = 4;

normal_force = normal_data.sensor_matrices_force(normal_segment_list, (pap_number * 3) + 1 : ((pap_number * 3) + 2) + 1);
TPU_force = TPU_data.sensor_matrices_force(TPU_segment_list, (pap_number * 3) + 1 : ((pap_number * 3) + 2) + 1);
rubber_force = rubber_data.sensor_matrices_force(rubber_segment_list, (pap_number * 3) + 1 : ((pap_number * 3) + 2) + 1);



%% 3D scatter plot for middle papillae

figure;
hold on;
view(45, 30); % Adjust azimuth and elevation angles
scatter3(normal_force(:,1), normal_force(:,2), normal_force(:,3), 10, 'r', 'filled'); % Red for normal
scatter3(TPU_force(:,1), TPU_force(:,2), TPU_force(:,3), 10, 'g', 'filled'); % Green for TPU
scatter3(rubber_force(:,1), rubber_force(:,2), rubber_force(:,3), 10, 'b', 'filled'); % Blue for rubber

xlabel('Force in X direction');
ylabel('Force in Y direction');
zlabel('Force in Z direction');
title('3D Scatter Plot of Force Data - Middle Papillae');
legend({'Normal', 'TPU', 'Rubber'});
grid on;
hold off;

%% Extract force values of a corner papillae (e.g., papillae 0)
corner_pap_number = 0;

corner_normal_force = normal_data.sensor_matrices_force(normal_segment_list, (corner_pap_number * 3) + 1 : ((corner_pap_number * 3) + 2) + 1);
corner_TPU_force = TPU_data.sensor_matrices_force(TPU_segment_list, (corner_pap_number * 3) + 1 : ((corner_pap_number * 3) + 2) + 1);
corner_rubber_force = rubber_data.sensor_matrices_force(rubber_segment_list, (corner_pap_number * 3) + 1 : ((corner_pap_number * 3) + 2) + 1);

%% 3D Scatter Plot for Corner Papillae
figure;
hold on;
view(45, 30); % Adjust azimuth and elevation angles

scatter3(corner_normal_force(:,1), corner_normal_force(:,2), corner_normal_force(:,3), 10, 'r', 'filled'); % Red for normal
scatter3(corner_TPU_force(:,1), corner_TPU_force(:,2), corner_TPU_force(:,3), 10, 'g', 'filled'); % Green for TPU
scatter3(corner_rubber_force(:,1), corner_rubber_force(:,2), corner_rubber_force(:,3), 10, 'b', 'filled'); % Blue for rubber

xlabel('Force in X direction');
ylabel('Force in Y direction');
zlabel('Force in Z direction');
title('3D Scatter Plot of Force Data - Corner Papillae');
legend({'Normal', 'TPU', 'Rubber'});
grid on;
hold off;
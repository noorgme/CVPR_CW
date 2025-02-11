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

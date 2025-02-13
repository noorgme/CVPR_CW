%% Load data
normal_data = load("PR_CW_mat/hexagon_papillarray_single.mat");
TPU_data = load("PR_CW_mat/hexagon_TPU_papillarray_single.mat");
rubber_data = load("PR_CW_mat/hexagon_rubber_papillarray_single.mat");

%% Extract segment indices
normal_segments = load("contact_segments/contact_peaks_hexagon_papillarray_single.mat");
TPU_segments = load("contact_segments/contact_peaks_hexagon_TPU_papillarray_single.mat");
rubber_segments = load("contact_segments/contact_peaks_hexagon_rubber_papillarray_single.mat");

normal_segments = normal_segments.peak_indices;
TPU_segments = TPU_segments.peak_indices;
rubber_segments = rubber_segments.peak_indices;

%% Extract displacement values
normal_displacement = normal_data.sensor_matrices_displacement(normal_segments, :);
TPU_displacement= TPU_data.sensor_matrices_displacement(TPU_segments, :);
rubber_displacement= rubber_data.sensor_matrices_displacement(rubber_segments, :);

%% Stack and Apply PCA
all_data = [normal_displacement; TPU_displacement; rubber_displacement]; % Stack all datasets together

num_papillae = 9; % Total papillae
num_components = 3; % X, Y, Z per papilla

% Reshape data to have all papillae's forces in separate columns
all_data_reshaped = reshape(all_data, [], num_papillae * num_components); 

% Standardize Data (zero mean, unit variance)
standardized_data = (all_data_reshaped - mean(all_data_reshaped)) ./ std(all_data_reshaped);

% Perform PCA
[coeff, score, latent] = pca(standardized_data);

%% Bagging
% Define number of trees
num_trees = 100; % You can experiment with different values (e.g., 10, 100)
rng(42); % For reproducibility

% Prepare training data
X = score(:, 1:10); % Use the first 3 principal components
y = [repmat("Normal", size(normal_displacement, 1), 1); 
     repmat("TPU", size(TPU_displacement, 1), 1); 
     repmat("Rubber", size(rubber_displacement, 1), 1)]; % Class labels

% Split into training (70%) and testing (30%)
cv = cvpartition(y, "HoldOut", 0.3);
X_train = X(training(cv), :);
y_train = y(training(cv));
X_test = X(test(cv), :);
y_test = y(test(cv));

% Train a Bagged Ensemble of Decision Trees
bagging_model = fitcensemble(X_train, y_train, 'Method', 'Bag', 'NumLearningCycles', num_trees);

%% Visualize Two Trees
figure;
view(bagging_model.Trained{1}, 'Mode', 'graph');
title("Tree 1 in the Bagged Model");

figure;
view(bagging_model.Trained{2}, 'Mode', 'graph');
title("Tree 2 in the Bagged Model");

%% Evaluate the Model
y_pred = predict(bagging_model, X_test);

y_test = categorical(y_test);
y_pred = categorical(y_pred);

% Confusion Matrix
conf_matrix = confusionmat(y_test, y_pred);
conf_chart = confusionchart(y_test, y_pred);
title("Confusion Matrix");

% Compute Accuracy
accuracy = sum(y_pred == y_test) / numel(y_test);
fprintf("Model Accuracy: %.2f%%\n", accuracy * 100);


%% 2c. Disucssion

% After 32 trees (66.67% accuracy) model accuracy stays at 77.78%, not
% improving for even 1000 trees.

explained_variance = cumsum(latent) / sum(latent) * 100;
disp(explained_variance(1:3)); % See how much variance first few PCs explain

% results show that the first 3 components only show 61% variance in the
% data, increasing the number of principal components to 10, and trees to
% 100 brought the model accuracy up to 88.89%. This accuracy was not beat
% from other configurations - which makes sense, too many Principal
% components at some point will be pointless (point is to acheive
% dimensionality reduction and capture varaince). We will reach an issue
% with dimensionality where a decision tree will overfit to those few
% points scattered in the corners of each respective dimension.

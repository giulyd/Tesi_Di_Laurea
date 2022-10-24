clear all; close all; clc;

%{ 
Script for performing the classification between the "Right Hand" 
and the "Both Feet" tasks by using an Support Vector Machine (SVM).

Giulia Doro
Tesi di laurea
%} 

rng('default');
%% 0. Initialization
%{
Instantiation of variables containing filenames.
%}

% Path to the folder containing the features
input_path = 'Features/Training/features_';

% Filename for the first subject
subject = 'A01T';

% Filename of the input file
input_filename = strcat(input_path, subject, '.mat');

% Path to the folder which will contain the output 
output_path = 'ClassificationResults/Training/';

% File extension for output 
output_extension = '.mat'; 


%% 1. Startup
%{
Loading of the features of interest and creation of variables for 
classification.
%}
PLI_LH_BETA = load(input_filename).pli_lh_beta;
PLI_RH_BETA = load(input_filename).pli_rh_beta;
PLI_BF_BETA = load(input_filename).pli_bf_beta; 
PLI_T_BETA = load(input_filename).pli_t_beta;

X_2_BETA = [PLI_RH_BETA; PLI_LH_BETA];
y_2_BETA = [ones([size(PLI_RH_BETA,1),1])*-1; ones([size(PLI_LH_BETA,1),1])];

%{
Retainment of a part of the training samples for test.
%}

% Create a partition object which allows to identify the training 
% and the test set (with equal percentage of "Right Hand" and "Both 
% Feet" epochs) according to the specification of the percentage 
% for the test set cardinality 
c = cvpartition(y_2_BETA,'Holdout',0.2,'Stratify',true);
idx_training_BETA = training(c);
idx_test_BETA = test(c);

% Create the X_training = X_ALPHA(idx_training,:);

X_training_BETA = X_2_BETA(idx_training_BETA,:);
y_training_BETA = y_2_BETA(idx_training_BETA,1);
X_test_BETA = X_2_BETA(idx_test_BETA,:);
y_test_BETA = y_2_BETA(idx_test_BETA,:);

%% 2. Feature selection 

%Fisher score computation and ranking of the features. Selection of 
%some of these features according to a predefined number.

[idx, scores, events] = fisher_score(X_training_BETA, y_training_BETA);
sel = 231;
% Apply the selection to both training and test set
X_training_sel_BETA = X_training_BETA(:,idx(1:sel)); 
X_test_sel_BETA = X_test_BETA(:,idx(1:sel));

%% 3. SVM Hyperparameter Optimization
%{
Exploitation of a k-fold cross validation and a grid search for 
tuning the hyperparameters.
%}
dataset = [y_training_BETA, X_training_sel_BETA];
testset = [y_test_BETA, X_test_sel_BETA];
kernelType = 'linear';
resultsBayes = SVMDUECLASSI(kernelType,dataset,X_test_sel_BETA,y_test_BETA,subject);

%% 4. Storing the output
%{
Save the output.
%}
save(strcat(output_path,subject, '/BETA/KFOLD5/', '/pli_beta_RH-LH_', subject, '_',output_extension), 'resultsBayes');
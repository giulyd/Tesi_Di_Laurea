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
PLI_LH_ALPHA = load(input_filename).pli_lh_alpha;
PLI_RH_ALPHA = load(input_filename).pli_rh_alpha;
PLI_BF_ALPHA = load(input_filename).pli_bf_alpha; 
PLI_T_ALPHA = load(input_filename).pli_t_alpha;

% X_1_ALPHA = [PLI_RH_ALPHA; PLI_BF_ALPHA];
X_2_ALPHA = [PLI_RH_ALPHA; PLI_LH_ALPHA];
y_2_ALPHA = [ones([size(PLI_RH_ALPHA,1),1])*-1; ones([size(PLI_LH_ALPHA,1),1])];

%{
Retainment of a part of the training samples for test.
%}

% Create a partition object which allows to identify the training 
% and the test set (with equal percentage of "Right Hand" and "Both 
% Feet" epochs) according to the specification of the percentage 
% for the test set cardinality 
c = cvpartition(y_2_ALPHA,'Holdout',0.2,'Stratify',true);
idx_training_ALPHA = training(c);
idx_test_ALPHA = test(c);

% Create the X_training = X_ALPHA(idx_training,:);

X_training_ALPHA = X_2_ALPHA(idx_training_ALPHA,:);
y_training_ALPHA = y_2_ALPHA(idx_training_ALPHA,1);
X_test_ALPHA = X_2_ALPHA(idx_test_ALPHA,:);
y_test_ALPHA = y_2_ALPHA(idx_test_ALPHA,:);

%% 2. Feature selection 

%Fisher score computation and ranking of the features. Selection of 
%some of these features according to a predefined number.

[idx, scores, events] = fisher_score(X_training_ALPHA, y_training_ALPHA);
sel = 231;
% Apply the selection to both training and test set
X_training_sel_ALPHA = X_training_ALPHA(:,idx(1:sel)); 
X_test_sel_ALPHA = X_test_ALPHA(:,idx(1:sel));

%% 3. SVM Hyperparameter Optimization
%{
Exploitation of a k-fold cross validation and a grid search for 
tuning the hyperparameters.
%}
dataset = [y_training_ALPHA, X_training_sel_ALPHA];
testset = [y_test_ALPHA, X_test_sel_ALPHA];
kernelType = 'linear';
resultsBayes = SVM_2_class(kernelType,dataset,X_test_sel_ALPHA,y_test_ALPHA,subject);

%% 4. Storing the output
%{
Save the output.
%}
save(strcat(output_path,subject, '/ALFA/KFOLD5/', '/pli_alfa_RH-LH_', subject, '_',output_extension), 'resultsBayes');

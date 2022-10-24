function results = SVMDUECLASSI(kernelType, dataset, X_test_sel, y_test, subject)
    
% Initialization
features = dataset(:, 2:end); % Features
labels = dataset(:, 1); % Labels
classes = unique(labels);

%% Training

t = templateSVM('KernelFunction',kernelType,'Standardize',true);

% train & test set
cKfold = cvpartition(labels,'Kfold',5,'Stratify',true);

% Optimization options
opts = struct('Optimizer','bayesopt','UseParallel',true,'CVpartition',cKfold,...
    'AcquisitionFunctionName','expected-improvement-plus','ShowPlot',false);
svmOptimization = fitcecoc(features,labels,'Learners',t,...
    'OptimizeHyperparameters',{'BoxConstraint', 'KernelScale'}, 'Coding','onevsone',...
    'HyperparameterOptimizationOptions',opts);

% TRAINING WITH OPTIMIZED PARAMETERS

opts = statset('UseParallel',true);
t= templateSVM('KernelFunction',kernelType,'Standardize',true,...
    'BoxConstraint', svmOptimization.HyperparameterOptimizationResults.XAtMinObjective.BoxConstraint,...
    'KernelScale', svmOptimization.HyperparameterOptimizationResults.XAtMinObjective.KernelScale);

svmCV = fitcecoc(features,labels,'Learners',t,'Options',opts,'CVPartition',cKfold,'Coding','onevsone');

%% Training Evaluation

%fprintf('Classification Performance: %d.\n', CVLoss);
cv_loss = kfoldLoss(svmCV);
[predictions,scores] = kfoldPredict(svmCV);
confmat = confusionmat(labels,predictions);

% CALCULATE ACCURACY, SENSITIVITY, SPECIFICITY AND PRECISION

accuracy = (confmat(1,1)+confmat(2,2))/sum(confmat,'all');
sensitivity = confmat(1,1)/(confmat(1,1)+confmat(2,1));
specificity = confmat(2,2)/(confmat(2,2)+confmat(1,2));
precision = confmat(1,1)/(confmat(1,1)+confmat(1,2));

results.validation.accuracy = accuracy;
results.validation.sensitivity = sensitivity;
results.validation.specificity = specificity;
results.validation.precision = precision;

%% Test
%fprintf('Testing with the whole dataset and optimized parameters.\n');
finalSVM = fitcecoc(features,labels,'Learners',t,'Options',opts,'Coding','onevsone');

%% Test Evaluation

[test_predictions, test_scores] = predict(finalSVM, X_test_sel);

% Extract the classification performance measures
test_confmat = confusionmat(y_test, test_predictions);

% CALCULATE ACCURACY, SENSITIVITY, SPECIFICITY AND PRECISION

test_accuracy = (test_confmat(1, 1)+test_confmat(2, 2))/sum(test_confmat, 'all');
test_sensitivity = test_confmat(1,1)/(test_confmat(1,1)+test_confmat(2,1));
test_specificity = test_confmat(2,2)/(test_confmat(2,2)+test_confmat(1,2));
test_precision = test_confmat(1,1)/(test_confmat(1,1)+test_confmat(1,2));

results.test.accuracy = test_accuracy;
results.test.sensitivity = test_sensitivity;
results.test.sprcificity = test_specificity;
results.test.precision = test_precision;

end
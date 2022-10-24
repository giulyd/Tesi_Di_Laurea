% TIROCINIO - TESI BRAIN COMPUTER INTERFACE
% Edoardo Signoretto

function results = SVMBayes(kernelType, dataset, X_test_sel, y_test, subject, order)
    % Initialization
    features = dataset(:, 2:end); % Features
    labels = dataset(:, 1); % Labels
    classes = unique(labels);
    
    %fprintf('Kernel selezionato: %s.\n', kernelType);
    %fprintf('Soggetto: %s.\n', subject);
    if ~exist('order','var')
        order = 0;
        %fprintf('Nessun ordine del kernel.\n');
        path = strcat('ClassificationResults/Training/bayesopt/',subject,'/KFOLD5/',kernelType);
        %fprintf('path: %s.\n',path);
    else
        %fprintf('Ordine del kernel: %d.\n', order);
        path = strcat('ClassificationResults/Training/bayesopt/',subject,'/KFOLD5/',kernelType,num2str(order),'/');
        %fprintf('path: %s.\n',path);
    end
    
    %% Training
    %fprintf('Starting training...\n');
    
    % HYPERPARAMETERS OPTIMIZATION
    %fprintf('Starting hyperparameters optimization...\n')
    % Kernel template (varargin = polynomial order)
    if order == 0
        t = templateSVM('KernelFunction',kernelType,'Standardize',true);
    else
        t = templateSVM('KernelFunction',kernelType,'Standardize',true,'PolynomialOrder',order);
    end

    % train & test set
    cKfold = cvpartition(labels,'Kfold',5,'Stratify',true);
    
    % Optimization options
    opts = struct('Optimizer','bayesopt','UseParallel',true,'CVpartition',cKfold,...
        'AcquisitionFunctionName','expected-improvement-plus','ShowPlot',false);
    svmOptimization = fitcecoc(features,labels,'Learners',t,...
        'OptimizeHyperparameters',{'BoxConstraint', 'KernelScale'}, 'Coding','onevsone',...
        'HyperparameterOptimizationOptions',opts);
    
    % TRAINING WITH OPTIMIZED PARAMETERS
    %fprintf('Training with optimized parameters...\n')
    opts = statset('UseParallel',true);

    if order == 0
        t= templateSVM('KernelFunction',kernelType,'Standardize',true,...
            'BoxConstraint', svmOptimization.HyperparameterOptimizationResults.XAtMinObjective.BoxConstraint,...
            'KernelScale', svmOptimization.HyperparameterOptimizationResults.XAtMinObjective.KernelScale);
    else
        t= templateSVM('KernelFunction',kernelType,'Standardize',true,'PolynomialOrder',order,...
            'BoxConstraint', svmOptimization.HyperparameterOptimizationResults.XAtMinObjective.BoxConstraint,...
            'KernelScale', svmOptimization.HyperparameterOptimizationResults.XAtMinObjective.KernelScale);
    end
    
    svmCV = fitcecoc(features,labels,'Learners',t,'Options',opts,'CVPartition',cKfold,'Coding','onevsone');
    
    %% Training Evaluation
    %fprintf('Evaluation Training...\n');
    CVLoss = kfoldLoss(svmCV);
    %fprintf('Classification Performance: %d.\n', CVLoss);
    
    % generalized classification error
    predictions = kfoldPredict(svmCV);
    trainConfmat = confusionmat(labels,predictions);
    accuracy(size(classes)) = 0;
    sensitivity(size(classes)) = 0;
    specificity(size(classes)) = 0;
    precision(size(classes)) = 0;
    
    for i = 1:4
        TP = trainConfmat(i,i);
        FP = sum(trainConfmat(i,:))-TP;
        FN = sum(trainConfmat(:,i))-TP;
        TN = sum(trainConfmat,'all') - TP - FP - FN;
        
        accuracy(i) = (TP+TN)/(TP+TN+FP+FN);
        sensitivity(i) = TP/(TP+FN);
        specificity(i) = TN/(TN+FP);
        precision(i) = TP/(TP+FP);
    end
    results.validation.accuracy = accuracy;
    results.validation.sensitivity = sensitivity;
    results.validation.specificity = specificity;
    results.validation.precision = precision;
    results.validation.GAcc = sum(diag(trainConfmat))/(sum(trainConfmat,'all')); %accuracy totale

    %% Test
    %fprintf('Testing with the whole dataset and optimized parameters.\n');
    finalSVM = fitcecoc(features,labels,'Learners',t,'Options',opts,'Coding','onevsone');

    %% Test Evaluation
    %fprintf('Evaluation Testing...\n');
    testPredictions = predict(finalSVM, X_test_sel); 
    testConfmat = confusionmat(y_test, testPredictions);
    
    accuracy(size(classes)) = 0;
    sensitivity(size(classes)) = 0;
    specificity(size(classes)) = 0;
    precision(size(classes)) = 0;
    
    for i = 1:4
        TP = testConfmat(i,i);
        FP = sum(testConfmat(i,:))-TP;
        FN = sum(testConfmat(:,i))-TP;
        TN = sum(testConfmat,'all') - TP - FP - FN;
        
        accuracy(i) = (TP+TN)/(TP+TN+FP+FN);
        sensitivity(i) = TP/(TP+FN);
        specificity(i) = TN/(TN+FP);
        precision(i) = TP/(TP+FP);
    end
    results.test.accuracy = accuracy;
    results.test.sensitivity = sensitivity;
    results.test.specificity = specificity;
    results.test.precision = precision;
    results.test.GAcc = sum(diag(testConfmat))/(sum(testConfmat,'all'));
    
    fprintf('Done.\n');
end
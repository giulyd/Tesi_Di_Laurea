clear all; close all; clc;

%{ 
Script for extracting features from preprocessed eeg signal of the
first subject of the BCI Competition IV (2008), Dataset 2a.

Giulia Doro
Tesi di laurea
%} 

%% 0. Initialization
%{
Instantiation of variables containing filenames.
%}

% Path to the folder containing the preprocessed training samples
input_path = 'Preprocessed/Training/processed_';

% Filename for the first subject
subject = 'A01T';

% Filename of the input file
input_filename = strcat(input_path, subject, '.mat');

% Path to the folder which will contain the output 
output_path = 'Features/Training/';

% File extension for output 
output_extension = '.mat';

% EEGLAB initialization
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

%% 1. Startup
%{
Preprocessed eeg data loading of the first subject, and 
intialization of variables for indicating the events of interest.
%}

% Load data
EEG = load(input_filename).EEG;

display = 1;
%% PLI
% Number of events to consider
nevent = 4;


% Find the index corresponding to the position in EEG.epoch of 
% the considered events

% find the nepoch for every class and put inside "epoch" the corrispondent
% data

for i = 1:length(EEG.epoch)
    if 'Left_Hand' == EEG.epoch(i).type
       epoch(1).ind = i;
       nepochs_LH = size(EEG.epoch(epoch(1).ind).data,3);
       epoch(1).data = EEG.epoch(i).data;
       epoch(1).alpha = EEG.epoch(i).alpha;
       epoch(1).beta = EEG.epoch(i).beta;
       
    end
    if 'Right_Hand' == EEG.epoch(i).type
       epoch(2).ind = i;
       nepochs_RH = size(EEG.epoch(epoch(2).ind).data,3);
       epoch(2).data = EEG.epoch(i).data;
       epoch(2).alpha = EEG.epoch(i).alpha;
       epoch(2).beta = EEG.epoch(i).beta;
    end
    if 'Both_Feet' == EEG.epoch(i).type
       epoch(3).ind = i;
       nepochs_BF = size(EEG.epoch(epoch(3).ind).data,3);
       epoch(3).data = EEG.epoch(i).data;
       epoch(3).alpha = EEG.epoch(i).alpha;
       epoch(3).beta = EEG.epoch(i).beta;
       
    end
    if 'Tongue' == EEG.epoch(i).type
       epoch(4).ind = i;
       nepochs_T = size(EEG.epoch(epoch(4).ind).data,3);
       epoch(4).data = EEG.epoch(i).data;
       epoch(4).alpha = EEG.epoch(i).alpha;
       epoch(4).beta = EEG.epoch(i).beta;
    end
    continue;
end

% show the PLI for all the valid trial
% figure();
% for i = 1: 69
%     
% imagesc((PLI_LH(:,:,i)));
% axis square;
% colorbar;
% xticks(1:1:EEG.nbchan);
% yticks(1:1:EEG.nbchan);
% xticklabels(chanlabels);
% yticklabels(chanlabels)
% xtickangle(90);
% 
% pause;
% end

% Number of samples for each epoch
nsamples = size(EEG.epoch(1).data,2);

% Store the channel labels in an array for visualization purposes
chanlabels = char(EEG.chanlocs(:).labels);

nchannel = size(chanlabels,1);

% computing PLI for all the classes-----------------------------------------
epoch_LH = epoch(1).data;
[PLI_LH, meanLH] = PLI_calculation(nchannel, epoch_LH);

epoch_LH_A = epoch(1).alpha;
[PLI_LH_ALPHA, meanLH_ALPHA] = PLI_calculation(nchannel, epoch_LH_A);

epoch_LH_B = epoch(1).beta;
[PLI_LH_BETA, meanLH_BETA] = PLI_calculation(nchannel, epoch_LH_B);

%RH
epoch_RH = epoch(2).data;
[PLI_RH, meanRH] = PLI_calculation(nchannel, epoch_RH);

epoch_RH_A = epoch(2).alpha;
[PLI_RH_ALPHA, meanRH_ALPHA] = PLI_calculation(nchannel, epoch_RH_A);

epoch_RH_B = epoch(2).beta;
[PLI_RH_BETA, meanRH_BETA] = PLI_calculation(nchannel, epoch_RH_B);

%BF
epoch_BF = epoch(3).data;
[PLI_BF, meanBF] = PLI_calculation(nchannel, epoch_BF);

epoch_BF_A = epoch(3).alpha;
[PLI_BF_ALPHA, meanBF_ALPHA] = PLI_calculation(nchannel, epoch_BF_A);

epoch_BF_B = epoch(3).beta;
[PLI_BF_BETA, meanBF_BETA] = PLI_calculation(nchannel, epoch_BF_B);

%T
epoch_T = epoch(4).data;
[PLI_T, meanT] = PLI_calculation(nchannel, epoch_T);

epoch_T_A = epoch(4).alpha;
[PLI_T_ALPHA, meanT_ALPHA] = PLI_calculation(nchannel, epoch_T_A);

epoca_T_B = epoch(4).beta;
[PLI_T_BETA, meanT_BETA] = PLI_calculation(nchannel, epoca_T_B);

% to set the scale for PLI visualization
maxLH = max(meanLH, [], 'all');
maxLH_A = max(meanLH_ALPHA, [], 'all');
maxLH_B = max(meanLH_BETA, [], 'all');
maxRH = max(meanRH, [], 'all');
maxRH_A = max(meanRH_ALPHA, [], 'all');
maxRH_B = max(meanRH_BETA, [], 'all');
maxBF = max(meanBF, [], 'all');
maxBF_A = max(meanBF_ALPHA, [], 'all');
maxBF_B = max(meanBF_BETA, [], 'all');
maxT = max(meanT, [], 'all');
maxT_A = max(meanT_ALPHA, [], 'all');
maxT_B = max(meanT_BETA, [], 'all');


maxValue = cat(2,maxLH,maxLH_A,maxLH_B,maxRH,maxRH_A,maxRH_B,maxBF,maxBF_A,maxBF_B,maxT,maxT_A,maxT_B);
MAX = max(maxValue, [],'all');
scale = [0 MAX];
 
%PLI LEFT HAND ALPHA

if display == 1
    figure(1);
    imagesc((meanLH_ALPHA(:,:)),scale);
    colorbar;
    axis square;
    colorbar;
    xticks(1:1:EEG.nbchan);
    yticks(1:1:EEG.nbchan);
    xticklabels(chanlabels);
    yticklabels(chanlabels)
    xtickangle(90);
    title("LEFT HAND");
    title("PLI Left hand ALPHA");
    set(gca,'fontsize',16);
end

%PLI LEFT HAND BETA
 
if display == 1
    figure(2);
    imagesc((meanLH_BETA(:,:)),scale);
    axis square;
    colorbar;
    xticks(1:1:EEG.nbchan);
    yticks(1:1:EEG.nbchan);
    xticklabels(chanlabels);
    yticklabels(chanlabels)
    xtickangle(90);
    title("PLI Left hand BETA");
    set(gca,'fontsize',16);
end

% PLI RIGHT HAND ALPHA

if display == 1
    figure(4);
    imagesc((meanRH_ALPHA(:,:)),scale);
    axis square;
    colorbar;
    xticks(1:1:EEG.nbchan);
    yticks(1:1:EEG.nbchan);
    xticklabels(chanlabels);
    yticklabels(chanlabels)
    xtickangle(90);
    title("PLI Right hand ALPHA");
    set(gca,'fontsize',16);
end
 
% PLI RIGHT HAND BETA
 
if display == 1
    figure(5);
    imagesc((meanRH_BETA(:,:)),scale);
    axis square;
    colorbar;
    xticks(1:1:EEG.nbchan);
    yticks(1:1:EEG.nbchan);
    xticklabels(chanlabels);
    yticklabels(chanlabels)
    xtickangle(90);
    title("PLI Right hand BETA");
    set(gca,'fontsize',16);
end

% PLI BOTH FEET ALPHA
 
if display == 1
    figure(7);
    imagesc((meanBF_ALPHA(:,:)),scale);
    axis square;
    colorbar;
    xticks(1:1:EEG.nbchan);
    yticks(1:1:EEG.nbchan);
    xticklabels(chanlabels);
    yticklabels(chanlabels)
    xtickangle(90);
    title("PLI Both feet ALPHA");
    set(gca,'fontsize',16);
end
 
% PLI BOTH FEET BETA

if display == 1
    figure(8);
    imagesc((meanBF_BETA(:,:)),scale);
    axis square;
    colorbar;
    xticks(1:1:EEG.nbchan);
    yticks(1:1:EEG.nbchan);
    xticklabels(chanlabels);
    yticklabels(chanlabels)
    xtickangle(90);
    title("PLI Both feet BETA");
    set(gca,'fontsize',16);
end

% PLI TONGUE ALPHA

if display == 1
    figure(10);
    imagesc((meanT_ALPHA(:,:)),scale);
    axis square;
    colorbar;
    xticks(1:1:EEG.nbchan);
    yticks(1:1:EEG.nbchan);
    xticklabels(chanlabels);
    yticklabels(chanlabels)
    xtickangle(90);
    title("PLI Tongue ALPHA");
    set(gca,'fontsize',16);
end

% PLI TONGUE BETA

if display == 1
    figure(11);
    imagesc((meanT_BETA(:,:)),scale);
    axis square;
    colorbar;
    xticks(1:1:EEG.nbchan);
    yticks(1:1:EEG.nbchan);
    xticklabels(chanlabels);
    yticklabels(chanlabels)
    xtickangle(90);
    title("PLI Tongue BETA");
    set(gca,'fontsize',16);
end

%% PLI BOXPLOT 

mask = ones([EEG.nbchan,EEG.nbchan]);
mask = triu(mask,1);

% loop for the 231 value above the diagonal
pli_lh= zeros([nepochs_LH,231]);
pli_lh_alpha= zeros([nepochs_LH,231]);
pli_lh_beta= zeros([nepochs_LH,231]);

pli_rh= zeros([nepochs_RH,231]);
pli_rh_alpha= zeros([nepochs_RH,231]);
pli_rh_beta= zeros([nepochs_RH,231]);

pli_bf= zeros([nepochs_BF,231]);
pli_bf_alpha= zeros([nepochs_BF,231]);
pli_bf_beta= zeros([nepochs_BF,231]);

pli_t= zeros([nepochs_T,231]);
pli_t_alpha= zeros([nepochs_T,231]);
pli_t_beta= zeros([nepochs_T,231]);

% loop for LH
for i = 1:nepochs_LH
    tmp =PLI_LH(:,:,i);
    tmp = tmp(logical(mask));
    pli_lh(i,:) = tmp';
    tmp =PLI_LH_ALPHA(:,:,i);
    tmp = tmp(logical(mask));
    pli_lh_alpha(i,:) = tmp';
    tmp =PLI_LH_BETA(:,:,i);
    tmp = tmp(logical(mask));
    pli_lh_beta(i,:) = tmp';
    
end

% loop for RH
for i = 1:nepochs_RH
    tmp =PLI_RH(:,:,i);
    tmp = tmp(logical(mask));
    pli_rh(i,:) = tmp';
    tmp =PLI_RH_ALPHA(:,:,i);
    tmp = tmp(logical(mask));
    pli_rh_alpha(i,:) = tmp';
    tmp =PLI_RH_BETA(:,:,i);
    tmp = tmp(logical(mask));
    pli_rh_beta(i,:) = tmp';
end

% loop for bf
for i = 1:nepochs_BF
    tmp =PLI_BF(:,:,i);
    tmp = tmp(logical(mask));
    pli_bf(i,:) = tmp';
    tmp =PLI_BF_ALPHA(:,:,i);
    tmp = tmp(logical(mask));
    pli_bf_alpha(i,:) = tmp';
    tmp =PLI_BF_BETA(:,:,i);
    tmp = tmp(logical(mask));
    pli_bf_beta(i,:) = tmp';
end

% loop for t
for i = 1:nepochs_T
    tmp =PLI_T(:,:,i);
    tmp = tmp(logical(mask));
    pli_t(i,:) = tmp';
    tmp =PLI_T_ALPHA(:,:,i);
    tmp = tmp(logical(mask));
    pli_t_alpha(i,:) = tmp';
    tmp =PLI_T_BETA(:,:,i);
    tmp = tmp(logical(mask));
    pli_t_beta(i,:) = tmp';
end


% boxplot for alpha band
if display == 1
    figure(1);
    boxplot(pli_lh_alpha(:,1:60),'colors','k','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI LEFT HAND for alpha band from 1 to 60");
    set(gca,'fontsize',16);
    
    figure(2);
    boxplot(pli_lh_alpha(:,61:120),'colors','k','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI LEFT HAND for alpha band from 61 to 120");
    set(gca,'fontsize',16);
    
    figure(3);
    boxplot(pli_lh_alpha(:,121:180),'colors','k','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI LEFT HAND for alpha band from 121 to 180");
    set(gca,'fontsize',16);
    
    figure(4);
    boxplot(pli_lh_alpha(:,181:231),'colors','k','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI LEFT HAND for alpha band from 181 to 231");
    set(gca,'fontsize',16);
end

if display == 1
    figure(1);
    boxplot(pli_rh_alpha(:,1:60),'colors','k','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI RIGHT HAND for alpha band from 1 to 60");
    set(gca,'fontsize',16);
    
    figure(2);
    boxplot(pli_rh_alpha(:,1:60),'colors','k','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI RIGHT HAND for alpha band from 61 to 120");
    set(gca,'fontsize',16);
    
    figure(3);
    boxplot(pli_rh_alpha(:,1:60),'colors','k','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI RIGHT HAND for alpha band from 121 to 180");
    set(gca,'fontsize',16);
    
    figure(4);
    boxplot(pli_rh_alpha(:,1:60),'colors','k','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI RIGHT HAND for alpha band from 181 to 231");
    set(gca,'fontsize',16);
end

if display == 1
    figure(1);
    boxplot(pli_bf_alpha(:,1:60),'colors','k','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI BOTH FEET for alpha band from 1 to 60");
    set(gca,'fontsize',16);
    
    figure(2);
    boxplot(pli_bf_alpha(:,61:120),'colors','k','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI BOTH FEET for alpha band from 61 to 120");
    set(gca,'fontsize',16);
    
    figure(3);
    boxplot(pli_bf_alpha(:,121:180),'colors','k','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI BOTH FEET for alpha band from 121 to 180");
    set(gca,'fontsize',16);
    
    figure(4);
    boxplot(pli_bf_alpha(:,181:231),'colors','k','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI BOTH FEET for alpha band from 181 to 231");
    set(gca,'fontsize',16);
end

if display == 1
    figure(1);
    boxplot(pli_t_alpha(:,1:60),'colors','k','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI TONGUE for alpha band from 1 to 60");
    set(gca,'fontsize',16); 
    
    figure(2);
    boxplot(pli_t_alpha(:,61:120),'colors','k','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI TONGUE for alpha band from 61 to 120");
    set(gca,'fontsize',16);
    
    figure(3);
    boxplot(pli_t_alpha(:,121:180),'colors','k','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI TONGUE for alpha band from 121 to 180");
    set(gca,'fontsize',16);
    
    figure(4);
    boxplot(pli_t_alpha(:,181:231),'colors','k','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI TONGUE for alpha band from 181 to 231");
    set(gca,'fontsize',16);
end

% boxplot for beta band
if display == 1
    figure(1);
    boxplot(pli_lh_beta(:,1:60),'colors','b','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI LEFT HAND for beta band from 1 to 60");
    set(gca,'fontsize',16);
    
    figure(2);
    boxplot(pli_lh_beta(:,61:120),'colors','b','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI LEFT HAND for beta band from 61 to 120");
    set(gca,'fontsize',16);
    
    figure(3);
    boxplot(pli_lh_beta(:,121:180),'colors','b','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI LEFT HAND for beta band from 121 to 180");
    set(gca,'fontsize',16);
    
    figure(4);
    boxplot(pli_lh_beta(:,181:231),'colors','b','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI LEFT HAND for beta band from 181 to 231");
    set(gca,'fontsize',16);
end
 
if display == 1
    figure(1);
    boxplot(pli_rh_beta(:,1:60),'colors','b','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI RIGHT HAND for beta band from 1 to 60");
    set(gca,'fontsize',16);
    
    figure(2);
    boxplot(pli_rh_beta(:,61:120),'colors','b','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI RIGHT HAND for beta band from 61 to 120");
    set(gca,'fontsize',16);
    
    figure(3);
    boxplot(pli_rh_beta(:,121:180),'colors','b','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI RIGHT HAND for beta band from 121 to 180");
    set(gca,'fontsize',16);
    
    figure(4);
    boxplot(pli_rh_beta(:,181:231),'colors','b','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI RIGHT HAND for beta band from 181 to 231");
    set(gca,'fontsize',16);
end

if display == 1
    figure(1);
    boxplot(pli_bf_beta(:,1:60),'colors','b','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI BOTH FEET for beta band from 1 to 60");
    set(gca,'fontsize',16);
    
    figure(2);
    boxplot(pli_bf_beta(:,61:120),'colors','b','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI BOTH FEET for beta band from 61 to 120");
    set(gca,'fontsize',16);
    
    figure(3);
    boxplot(pli_bf_beta(:,121:180),'colors','b','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI BOTH FEET for beta band from 121 to 180");
    set(gca,'fontsize',16);
    
    figure(4);
    boxplot(pli_bf_beta(:,181:231),'colors','b','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI BOTH FEET for beta band from 181 to 231");
    set(gca,'fontsize',16);
end

if display == 1
    figure(1);
    boxplot(pli_t_beta(:,1:60),'colors','b','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI TONGUE for beta band from 1 to 60");
    set(gca,'fontsize',16);
    
    figure(2);
    boxplot(pli_t_beta(:,61:120),'colors','b','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI TONGUE for beta band from 61 to 120");
    set(gca,'fontsize',16);
    
    figure(3);
    boxplot(pli_t_beta(:,121:180),'colors','b','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI TONGUE for beta band from 121 to 180");
    set(gca,'fontsize',16);
    
    figure(4);
    boxplot(pli_t_beta(:,181:231),'colors','b','medianstyle','target', 'outliersize',7, 'symbol', 'ro');
    xlabel("Pairs of channels");
    ylabel("Values");
    title("Values of PLI TONGUE for beta band from 181 to 231");
    set(gca,'fontsize',16);
end

%% Save the variables
save(strcat(output_path, 'features_', subject, output_extension), ...
    'pli_lh_alpha', 'pli_rh_alpha', 'pli_bf_alpha', 'pli_t_alpha', ...
    'pli_lh_beta', 'pli_rh_beta', 'pli_bf_beta', 'pli_t_beta');

clear all; close all; clc;

%{ 
Script for preprocessing the EEG training samples of the first 
subject of the BCI Competition IV (2008), Dataset 2a.

Giulia Doro
Tesi di laurea
%} 

%% 0. Initialization
%{
Instantiation of variables containing filenames and initialization 
of the eeglab environment.
%}

% Path to the folder containing the recorded training samples 
input_path = 'Samples_persone/Samples/Training/';

% Filename for the first subject
subject = 'A01T';

% File extension for input
input_extension = '.gdf';

% Filename of the input file
input_filename = strcat(input_path, subject, input_extension);

% Path to the folder which will contain the output 
output_path = 'Preprocessed/Training/';

% Filename for the output corresponding to the first subject
output_filename = strcat('processed_', subject);

% File extension for output 
output_extension = '.mat';

% EEGLAB initialization
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab('nogui');

%% 1. Startup
%{
Loading and first manupulation of the eeg data, and visualization 
of the raw signal.
%}

% Load the eeg data from file in a dedicated structure
% At the first usage, EEGLAB could ask you to install BioSig:
% please, give your consent!
EEG = pop_biosig(char(input_filename));

% Discard the channels corresponding to the three monopolar EOG 
% channels
EEG = pop_select(EEG, 'nochannel', [23, 24, 25]); 

% Update the field dedicated to channels using the file .locs
chanlocs22 = readlocs('chanlocs22.locs');
EEG.chanlocs = chanlocs22;

% Store the current EEG data
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);

% Variable initialization to define whether displaying 
% the graphs of intermediate steps (yes - 1; no - otherwise)
display = 1;

% Number of eeg recording samples to visualize in the graph
winlength = 25;

% Graph lines color
color = {'k'};

% Display the raw eeg signal
if display == 1
    eegplot(EEG.data, 'title', 'Raw EEG', 'srate', EEG.srate ,...
        'eloc_file', EEG.chanlocs, 'events', EEG.event,...
        'winlength', winlength, 'color', color, 'spacing', 100);
end


%% 2. Baseline removal 
%{
First step of eeg signal preprocessing consisting in the removal
of the baseline for standardization purposes.
%}

% Calculate the mean of the recorded eeg signal for each channel
baseline = mean(EEG.data, 2);
% Remove the baseline from data 
EEG.data = EEG.data - baseline;

% Create a new EEG copy
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,...
    'setname', 'EEG_BAS');

%% 3. Data filtering
%{
Eeg signal filtering in order to obtain data in a frequency 
comprised between 8 and 30 Hz. 
%}

EEG.data = cast(EEG.data, 'double');

% Butterworth filter zero-phase

% HP butterworth filter
Fs = 250;
Fc = 8/125; %cutoff freq
Ft = 7/125; %stopband freq
Pr = 1; %passband ripple
Att = 5; %stopband attenuation
[n, Wn] = buttord(Fc, Ft, Pr, Att);
[b, a] = butter(n, Wn, 'high');
%forward-backward
for i = 1:EEG.nbchan
    EEG.data(i, :) = filtfilt(b, a, EEG.data(i, :));
end

% LP butterworth filter
Fc = 30/125; %cutoff freq
Ft = 31/125; %stopband freq
[n, Wn] = buttord(Fc, Ft, Pr, Att);
[b, a] = butter(n, Wn, 'low');
%forward-backward
for i = 1:EEG.nbchan
    EEG.data(i, :) = filtfilt(b, a, EEG.data(i, :));
end

if display == 0
    eegplot(EEG.data, 'title', 'Filtered EEG', 'srate',...
        EEG.srate, 'eloc_file', EEG.chanlocs, 'events',...
        EEG.event, 'winlength', winlength, 'color', color,...
        'spacing', 100);
end
%%  filter: ALPHA BAND 8-12

% Butterworth filter zero-phase

% HP butterworth filter
Fs = 250;
Fc = 8/125; %cutoff freq
Ft = 7/125; %stopband freq
Pr = 1; %passband ripple
Att = 5; %stopband attenuation
[n, Wn] = buttord(Fc, Ft, Pr, Att);
[b, a] = butter(n, Wn, 'high');
%forward-backward
for i = 1:EEG.nbchan
    EEG.alpha(i, :) = filtfilt(b, a, EEG.data(i, :));
end

% LP butterworth filter
Fc = 12/125; %cutoff freq
Ft = 13/125; %stopband freq
[n, Wn] = buttord(Fc, Ft, Pr, Att);
[b, a] = butter(n, Wn, 'low');
%forward-backward
for i = 1:EEG.nbchan
    EEG.alpha(i, :) = filtfilt(b, a, EEG.data(i, :));
end

if display == 1
    eegplot(EEG.alpha, 'title', 'Filtered ALPHA EEG', 'srate',...
        EEG.srate, 'eloc_file', EEG.chanlocs, 'events',...
        EEG.event, 'winlength', winlength, 'color', color,...
        'spacing', 100);
end
%% filter: BETA BAND 13-30
% Butterworth filter zero-phase

% HP butterworth filter
Fs = 250;
Fc = 13/125; %cutoff freq
Ft = 12/125; %stopband freq
Pr = 1; %passband ripple
Att = 5; %stopband attenuation
[n, Wn] = buttord(Fc, Ft, Pr, Att);
[b, a] = butter(n, Wn, 'high');
%forward-backward
for i = 1:EEG.nbchan
    EEG.beta(i, :) = filtfilt(b, a, EEG.data(i, :));
end

% LP butterworth filter
Fc = 30/125; %cutoff freq
Ft = 31/125; %stopband freq
[n, Wn] = buttord(Fc, Ft, Pr, Att);
[b, a] = butter(n, Wn, 'low');
%forward-backward
for i = 1:EEG.nbchan
    EEG.beta(i, :) = filtfilt(b, a, EEG.data(i, :));
end

if display == 1
    eegplot(EEG.beta, 'title', 'Filtered BETA EEG', 'srate',...
        EEG.srate, 'eloc_file', EEG.chanlocs, 'events',...
        EEG.event, 'winlength', winlength, 'color', color,...
        'spacing', 100);
end
%% Signals comparison
L = 1;
Fs = 250;
samples = L*Fs;
start = 1000;
End = start+samples;
endF = End/Fs;
channel = 12;
window =ALLEEG(2).data(channel, start:start+samples-1);
window_filt = ALLEEG(2).data(channel, start:start+samples-1);
t = (start/Fs):1/Fs:endF-(1/Fs);



%% 4. Re-reference
%{
Re-reference of the data with respect to average reference for
standardization purpose
%}

% Re-reference the data with respect to the average reference
EEG = pop_reref(EEG, []);

% Create a new EEG copy
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,...
    'setname', 'EEG_BAS_FIL_REF');

%% 5. Events re-organization
%{
Re-naming of the events and calculation of a new latency and total
duration for each one in order to extract the interesting epochs.
%}

% type remove: 1023
lat = 0;
dur = 0;
to_remove = 0;
i = 1;
while (i <= length(EEG.event))
     
    if (EEG.event(i).edftype == 1023)
       % 
       lat = EEG.event(i).latency;
       dur = EEG.event(i).duration;
       to_remove = lat + dur;
       
       % remove all the data from latency to "to_remove" (7,5s) 
       if(EEG.event(i).latency >= lat && EEG.event(i).latency <= to_remove)
           % remove the event: previus, next and the event with the type: 1023
           EEG.event(i) = []; 
           EEG.event(i-1) = [];
           EEG.event(i-1) = []; 
           % go back of 3 because EEG.event refreshes immediately
           i = i -3;
       else
           to_remove = 0;
       end
    end
    
    i = i + 1;
end   

% While loop for the events re-organization (stop = all the events 
% have been read)
i = 1;
while (i <= length(EEG.event))

    % In the case that there is not any edftype (id for the task), 
    % assign the value 1 to it
    if isempty(EEG.event(i).edftype)
        EEG.event(i).edftype = 1; 
    end

    % Re-naming and duration and latency calculation based on 
    % edftype
    switch EEG.event(i).edftype
        % Time of pure task is 2 sec
        case 769
            EEG.event(i).type = "Left_Hand"; 
            EEG.event(i).latency = EEG.event(i).latency + EEG.srate*2; 
            EEG.event(i).duration = EEG.srate*2;
       
        case 770
            EEG.event(i).type = "Right_Hand"; 
            EEG.event(i).latency = EEG.event(i).latency + EEG.srate*2; 
            EEG.event(i).duration = EEG.srate*2;
            
        case 771
            EEG.event(i).type = "Both_Feet"; 
            EEG.event(i).latency = EEG.event(i).latency + EEG.srate*2; 
            EEG.event(i).duration = EEG.srate*2;
           
        case 772
            EEG.event(i).type = "Tongue"; 
            EEG.event(i).latency = EEG.event(i).latency + EEG.srate*2; 
            EEG.event(i).duration = EEG.srate*2;
            
        % The following edftypes correspond to task different from 
        % motor imagery (e.g. eye movements); in this case, remove 
        % the event and decrement the counter i 
        case {276, 277, 768, 783, 1072, 32766, 1}
            EEG.event(i) = []; 
            i = i - 1;
    end

    i = i + 1;

end


%% 6. Dataset creation
%{
Creation of a field epoch in the EEG data structure, which will 
contain the eeg signal data corresponding to the previously 
retained events of interest. The data in this field will be ordered 
by event type instead of depending from recording time.
%}

% Add an empty field type to the field epoch in the EEG structure 
% (Left Hand, Right Hand, Both Feet, Tongue)
EEG.epoch.type = [];
% Counter of types 
ind = 1;
% For loop cycling on the event field of the EEG data structure
for i = 1:length(EEG.event)
    % If it is the first time that the EEG event type in object is 
    % found, then add a row to the type field of EEG.epoch with 
    % the specific type name and a corresponding empty field data
    if (~any(strcmp([EEG.epoch.type], string(EEG.event(i).type)))) == 1
        EEG.epoch(ind).type = string(EEG.event(i).type);
        EEG.epoch(ind).data = [];
        EEG.epoch(ind).alpha = [];
        EEG.epoch(ind).beta = [];
        ind = ind+1;
    end
end

% Collect the interesting eeg signal data samples in EEG.epoch.data
% for each event type
for i = 1:length(EEG.event)
    ind = strcmp(EEG.event(i).type, [EEG.epoch.type]);
    % Take the data samples corresponding only to the effective 
    % task

    EEG.epoch(ind).data = cat(3, EEG.epoch(ind).data, ...
        EEG.data(:,EEG.event(i).latency:(EEG.event(i).latency + EEG.event(i).duration - 1)));
    EEG.epoch(ind).alpha = cat(3, EEG.epoch(ind).alpha, ... 
        EEG.alpha(:, EEG.event(i).latency:(EEG.event(i).latency + EEG.event(i).duration - 1)));
    EEG.epoch(ind).beta = cat(3, EEG.epoch(ind).beta, ... 
        EEG.beta(:, EEG.event(i).latency:(EEG.event(i).latency + EEG.event(i).duration - 1)));
end

%% SAVE THE VARIABLES
save(strcat(output_path, output_filename, output_extension), 'ALLEEG', 'EEG');

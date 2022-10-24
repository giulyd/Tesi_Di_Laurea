% CALCOLO PLI PER LE QUATTRO CLASSI

function[pli, mean_PLI] = PLI_calculation(nchannel, epoch)

subMatrixEpoch = struct;

% recovery the value of "nepochs"
nepochs = size(epoch,3);

for trial = 1: nepochs
   subMatrixEpoch(trial).trial = epoch(:,:,trial)';
end

% calculate the hilbert transform
hilbert_transform = struct;
fase = struct;

for trial_hilb = 1: nepochs
    
    hilbert_transform(trial_hilb).trial = hilbert(subMatrixEpoch(trial_hilb).trial);                                
    fase(trial_hilb).trial_angle = angle(hilbert_transform(trial_hilb).trial);
    
end

% phase difference : "diff"
PLI = struct;
PLI_event = zeros(22,22);

% calculation of PLI
for i = 1:nepochs
    for canale1 = 1 : nchannel
        for canale2 = 1 : nchannel
           
            difference = fase(i).trial_angle(:, canale1) - fase(i).trial_angle(:, canale2);
            PLI_event(canale1, canale2) = abs(mean(sign(sin(difference))));       
                
        end
    end
    PLI(i).pli = PLI_event;
end

% mean for visualization purpose
pli = cat(3,PLI.pli);

mean_PLI =mean(pli,3);


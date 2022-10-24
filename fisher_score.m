% TIROCINIO - TESI BRAIN COMPUTER INTERFACE

function [idx, scores, events] = fisher_score(features, labels)
    % Array initialization
    fs_score = zeros([2, size(features, 2)]);
    events = unique(labels);
    
    % Struct initialization
    event_class = struct;
    for i = 1 : length(events)
        event_class(i).idx = [];
        event_class(i).feats = [];
        event_class(i).mu = 0;
        event_class(i).sum = 0;
    end
    
    for i = 1 : length(events)
        event_class(i).idx = labels == events(i);
    end 
    
    % Ciclo tutti i canali
    for i = 1 : size(features, 2)
        % Calcolo la media dei canale i-esimo
        mu_feat = mean(features(:, i));
        numer = 0;
        %denom_1 = 0;
        denom_2 = 0;

        % Ciclo tutte le classi
        for j = 1 : length(events)
            N_J = sum(event_class(j).idx);

            % Valori della classe in quel canale
            event_class(j).feats = features(event_class(j).idx, i);
         
            % Media della classe in quel canale
            event_class(j).mu = mean(event_class(j).feats);
          
            numer = numer + (event_class(j).mu - mu_feat)^2;
            %denom_1 = denom_1 + (1 / (N_J - 1));
            %denom_1 = 1 / (N_J - 1);

            tmp = event_class(j).feats;
            for k = 1 : N_J
                denom_2 = denom_2 + ((tmp(k) - event_class(j).mu)^2 / (N_J - 1));               
            end
        end
        
        %fs_score(1, i) = numer / (denom_1 * denom_2);
        fs_score(1, i) = numer / denom_2;
        fs_score(2, i) = i; 
    end
    [scores, fs_score(2, :)] = sort(fs_score(1, :), 'descend');
    idx = fs_score(2, :); 
end

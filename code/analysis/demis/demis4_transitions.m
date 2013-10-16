%{
    demis compression
    = ONLY WITH ONE SUBJECT
    = ONLY WITH ONE MAP
    = WORKS WITH GOD RESULTS
%}

clc
clear all
close all

filename = 'demis4_transitions';

% load god file -----------------------------------------------------------
fprintf([filename,': load god file\n']);
f = main_file();
f.set_interface('god');
d = f.tree_read(1);

% load paths --------------------------------------------------------------
fprintf([filename,': load paths\n']);
nb_trials = length(unique(d.data.trial));
nb_stations = max(d.data.in_station);

% store paths
paths = {};
for i = 1:nb_trials;
    paths{i} = d.data.in_station(d.data.trial==i);
end

% TRANSITION MATRIX *******************************************************
fprintf([filename,': transition matrix\n']);

% count
transitions = zeros(nb_stations,nb_stations,nb_stations);
for i_trial = 1:nb_trials
    for i_stop = 1:(length(paths{i_trial})-2)
        station_t = paths{i_trial}(i_stop);
        station_t1 = paths{i_trial}(i_stop+1);
        station_t2 = paths{i_trial}(i_stop+2);
        transitions(station_t,station_t1,station_t2) = transitions(station_t,station_t1,station_t2) + 1;
    end
end

% probability scaling
probability = zeros(nb_stations,nb_stations,nb_stations);
for i1 = 1:nb_stations
    for i2 = 1:nb_stations
        % sum
        sum_transitions = sum(transitions(i1,i2,:));
        if ~sum_transitions
            sum_transitions = 1;
        end
        probability(i1,i2,:) = transitions(i1,i2,:)/sum_transitions;
    end
end

% ENTROPY *****************************************************************
fprintf([filename,': entropy\n']);

% information
information = -log(probability);
information(~probability) = 0;

% entropy
entropy = sum(probability.*information,3);
mean_entropy = squeeze(mean(entropy,1));
%{
    demis compression
    = ONLY WITH ONE SUBJECT
    = ONLY WITH ONE MAP
    = WORKS WITH GOD RESULTS
%}

clc
clear all
close all

filename = 'demis3_transitions';

% load god file -----------------------------------------------------------
fprintf([filename,': load god file\n']);
f = main_file();
f.set_interface('god');
d = f.tree_read(1);

% load paths --------------------------------------------------------------
fprintf([filename,': load paths\n']);
nb_trials = length(unique(d.data.trial));
stations = unique(d.data.in_station);
nb_stations = max(stations);
unused_stations = ones(1,nb_stations);
unused_stations(stations) = 0;

% store paths
paths = {};
for i = 1:nb_trials;
    paths{i} = d.data.in_station(d.data.trial==i);
end

% TRANSITION MATRIX *******************************************************
fprintf([filename,': transition matrix\n']);

% count
transitions = zeros(nb_stations,nb_stations);
for i_trial = 1:nb_trials
    for i_stop = 1:(length(paths{i_trial})-1)
        station_t = paths{i_trial}(i_stop);
        station_t1 = paths{i_trial}(i_stop+1);
        transitions(station_t,station_t1) = transitions(station_t,station_t1) + 1;
    end
end
% probability scaling
sum_transitions = sum(transitions,2);
sum_transitions(~sum_transitions) = 1;
sc_transitions = sum_transitions*ones(1,nb_stations);
probability = transitions./sc_transitions;


% ENTROPY *****************************************************************
fprintf([filename,': entropy\n']);

% information
information = -log(probability);
information(~probability) = 0;

% entropy
entropy = sum(probability.*information,2);
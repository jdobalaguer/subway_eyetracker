%{
    demis compression
    = ONLY WITH ONE SUBJECT
    = ONLY WITH ONE MAP
    = WORKS WITH GOD RESULTS
%}

clc
clear all
close all

% load god file -----------------------------------------------------------
f = main_file();
f.set_interface('god');
d = f.tree_read(1);

% load paths --------------------------------------------------------------
nb_trials = 100;  % 100 trials
paths = {};
% store paths
for i = 1:nb_trials;
    paths{i} = d.data.in_station(d.data.trial==i);
end

% symbol variables
path_symbol = {paths};
dict_symbol = {};
size_symbol = [];
leng_symbol = [];
freq_symbol = [];

new_symbol = 0;
max_length = inf;
while max_length>1
    new_symbol = new_symbol - 1;
    fprintf(['new symbol: ',num2str(new_symbol),'\n']);
    
    % look for the max length of a symbol ---------------------------------
    min_length = inf;
    max_length =0;
    for i = 1:nb_trials;
        % min length
        if length(paths{i}) < min_length
            min_length = length(paths{i});
        end
        % max length
        if length(paths{i}) > max_length
            max_length = length(paths{i});
        end
    end
    
    % look for the best cluster -------------------------------------------
    clusters = {[]};
    flusters = [0];
    llusters = [0];
    for l_cluster = 2:max_length
        % declare variables
        dict_clusters = {};
        freq_clusters = [];
        wher_clusters = {};
        % calculate frequencies
        for i_trial = 1:length(paths)
            for i_station = 1:(length(paths{i_trial})-l_cluster+1)
                % sample?
                sample = paths{i_trial}(i_station:(i_station+l_cluster-1));
                % is there a cluster which matches the sample?
                m_sample = 0;
                for i_cluster = 1:length(dict_clusters)
                    if all(sample==dict_clusters{i_cluster})
                        m_sample = i_cluster;
                        % if yes, increment
                        freq_clusters(i_cluster) = freq_clusters(i_cluster)+1;
                        wher_clusters{i_cluster} = [wher_clusters{i_cluster} ; i_trial,i_station];
                    end
                end
                % if not, create a new cluster
                if ~m_sample
                    dict_clusters{end+1} = sample;
                    freq_clusters(end+1) = 1;
                    wher_clusters{end+1} = [i_trial,i_station];
                end
            end
        end
        % return the most frequent cluster
        [~,i_maxcluster] = max(freq_clusters);
        clusters{l_cluster} = dict_clusters{i_maxcluster};
        flusters(l_cluster) = freq_clusters(i_maxcluster);
        llusters(l_cluster) = freq_clusters(i_maxcluster) * l_cluster;
        wlusters{l_cluster} = wher_clusters{i_maxcluster};
    end
    
    [~,l_maxcluster] = max(llusters);
    
    % replace it with a new symbol ----------------------------------------
    for i_wlusters = 1:size(wlusters{l_maxcluster},1)
        % get position
        i_trial   = wlusters{l_maxcluster}(i_wlusters,1);
        i_station = wlusters{l_maxcluster}(i_wlusters,2);
        % replace
        paths{i_trial}(i_station) = new_symbol;
        paths{i_trial}((i_station+1):(i_station+l_maxcluster-1)) = [];
    end

    % remember the symbol -------------------------------------------------
    path_symbol{end+1} = paths;
    dict_symbol{end+1} = clusters{l_maxcluster};
    size_symbol(end+1) = l_maxcluster;
    freq_symbol(end+1) = flusters(l_maxcluster);
    leng_symbol(end+1) = llusters(l_maxcluster);

end

% TODO : plot chunking in a map draw...
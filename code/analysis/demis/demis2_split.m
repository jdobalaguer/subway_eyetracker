%{
    demis compression
    = ONLY WITH ONE SUBJECT
    = ONLY WITH ONE MAP
    = WORKS WITH GOD RESULTS
%}

clc
clear all
close all

filename = 'demis2_split';
model    = 'forwardsoftmax';

% load god file -----------------------------------------------------------
fprintf([filename,': load ',model,' file\n']);
f = main_file();
f.tree_dir = 'entropies/data';
f.set_interface(model);
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

% CLUSTERIZE **************************************************************
fprintf([filename,': clusterize\n']);

% hierarchy variables
nb_layers = 15;
absdict_hier = cell(1,nb_layers); % cluster definition (with all stations included)
reldict_hier = cell(1,nb_layers); % cluster definition (relative to the previous layer clusters)
cluster_hier = cell(1,nb_layers); % station association (to a cluster)
compres_hier = cell(1,nb_layers); % compression

% for each level of the hierarchy (i.e., layer) ===========================
for i_layer = 1:nb_layers
    fprintf([filename,': clusterize: layer ',num2str(i_layer),'\n']);
    
    % initialize 'layer' variables
    absdict_layer = {};
    reldict_layer = {};
    cluster_layer = zeros(1,nb_stations);
    compres_layer = [];
    
    % cluster the whole map ===============================================
    i_cluster = 0;
    while ~all(cluster_layer | unused_stations)
        i_cluster = i_cluster+1;
        fprintf([filename,': clusterize: layer ',num2str(i_layer),': cluster ',num2str(i_cluster),'\n']);
        
        % find the best next cluster ======================================
        
        % look for the max length of clusters -----------------------------
        l_paths = zeros(1,nb_trials);
        for i_paths = 1:nb_trials;
            l_paths(i_paths) = length(paths{i_paths});
        end
        lmin_paths = min(l_paths);
        lmax_paths = max(l_paths);
        
        % initialize 'candidate' variables
        reldict_candidate = cell(1,lmax_paths); % candidate definition (relative to the previous layer clusters)
        compres_candidate = zeros(1,lmax_paths) - inf; % compression value
        
        % for each length of clusters
        for l_candidates = 1:2%lmax_paths
            fprintf([filename,': clusterize: layer ',num2str(i_layer),': cluster ',num2str(i_cluster),': candidate ',num2str(l_candidates),'\n']);
            
            % initialize 'subcands' variables (eq to candidates, but for fixed length)
            reldict_subcands = []; % subcandidates definition (relative to the previous layer clusters)
            compres_subcands = []; % compression value
            
            % find all possible clusters ----------------------------------
            % for each trial / stop
            for i_trial = 1:nb_trials
                for i_stop = 1:(l_paths(i_trial)-l_candidates+1)
                    % get sample
                    sample = unique(paths{i_trial}(i_stop:(i_stop+l_candidates-1)));
                    % if valid and new, add it
                    if all(sample>0) && ~ismember(sample,reldict_subcands,'rows')
                        reldict_subcands = [reldict_subcands ; sample];
                        compres_subcands(end+1) = -l_candidates; % (minus) number of station symbols in the dictionnary definition
                    end
                end
            end
            
            % evaluare all clusters ---------------------------------------
            nb_reldictsubcands = size(reldict_subcands,1);
            % for each subcandidate
            for i_subcands = 1:nb_reldictsubcands
                % for each trial
                for i_trial = 1:nb_trials
                    % for each stop
                    i_stop = 1;
                    while i_stop<=(length(paths{i_trial}))
                        % find maximum match
                        d_stop = 0;
                        while (i_stop+d_stop)<=length(paths{i_trial}) && ismember(paths{i_trial}(i_stop+d_stop),reldict_subcands(i_subcands,:))
                            d_stop = d_stop + 1;
                        end
                        % update the compression (in symbols)
                        if d_stop>0
                            compres_subcands(i_subcands) = compres_subcands(i_subcands) + d_stop - 1; % removed station symbols - one cluster symbol
                        end
                        % increment index
                        if d_stop>0
                            i_stop = i_stop + d_stop;
                        else
                            i_stop = i_stop + 1;
                        end
                    end
                end
            end
            
            % store the best cluster (for each length) --------------------
            if ~isempty(reldict_subcands)
                [~,b_subcand] = max(compres_subcands);
                reldict_candidate{l_candidates} = reldict_subcands(b_subcand,:);
                compres_candidate(l_candidates) = compres_subcands(b_subcand);
            else
                reldict_candidate{l_candidates} = [];
                compres_candidate(l_candidates) = -inf;
            end
        end
        

        % keep the cluster length with best compression
        [~,b_candidate] = max(compres_candidate);
        compres_layer(end+1) = compres_candidate(b_candidate);
        reldict_layer{end+1} = reldict_candidate{b_candidate};
        
        
        %reldict_candidate{b_candidate}
        %compres_candidate(b_candidate)


        % replace cluster in path
        for i_trial = 1:nb_trials
            i_stop = 1;
            while i_stop<=length(paths{i_trial})
                % find maximum match
                d_stop = 0;
                while (i_stop+d_stop)<=length(paths{i_trial}) && ismember(paths{i_trial}(i_stop+d_stop),reldict_candidate{b_candidate})
                    d_stop = d_stop+1;
                end
                % replace
                if d_stop>0
                    paths{i_trial}(i_stop) = -i_cluster;
                    paths{i_trial}((i_stop+1):(i_stop+d_stop-1)) = [];
                end
                % increment
                i_stop = i_stop + 1;
            end
        end
        
        % update absdict_layer
        if i_layer>1
            absdict_layer{i_cluster} = [];
            for i_reldict = 1:length(reldict_layer{i_cluster})
                absdict_layer{i_cluster} = [absdict_layer{i_cluster} , absdict_hier{i_layer-1}{reldict_layer{i_cluster}(i_reldict)}];
            end
        else
            absdict_layer{i_cluster} = reldict_layer{i_cluster};
        end
        % update cluster_layer
        if any(cluster_layer(absdict_layer{end})>0)
            error('eh! that station was already clustered!');
        end
        cluster_layer(absdict_layer{i_cluster}) = i_cluster;
        
    end

    % update hierarchies
    absdict_hier{i_layer} = absdict_layer;
    reldict_hier{i_layer} = reldict_layer;
    cluster_hier{i_layer} = cluster_layer;
    compres_hier{i_layer} = compres_layer;
    
    % flip paths
    for i_trial = 1:nb_trials
        paths{i_trial} = -paths{i_trial};
    end    
end

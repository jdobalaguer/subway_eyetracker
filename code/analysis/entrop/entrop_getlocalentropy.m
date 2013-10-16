function  entrop_getlocalentropy()

    invtemp = 0.1;

    entropy_player = 'forwardsoftmax';
    entropy_dir = 'entropies';
    entropy_valdir = 'values';
    entropy_subdir = 'localentropies';
    entropy_pldir  = entropy_player;
    entropy_prefile = 'ent_';
    
    % create folders ------------------------------------------------------
    if ~exist(entropy_dir,'dir')
        mkdir(entropy_dir);
    end
    if ~exist([entropy_dir,filesep,entropy_valdir],'dir')
        mkdir([entropy_dir,filesep,entropy_valdir]);
    end
    if ~exist([entropy_dir,filesep,entropy_valdir,filesep,entropy_subdir],'dir')
        mkdir([entropy_dir,filesep,entropy_valdir,filesep,entropy_subdir]);
    end
    if ~exist([entropy_dir,filesep,entropy_valdir,filesep,entropy_subdir,filesep,entropy_pldir],'dir')
        mkdir([entropy_dir,filesep,entropy_valdir,filesep,entropy_subdir,filesep,entropy_pldir]);
    end
    
    % create the agent ----------------------------------------------------
    p = player_forwardsoftmax();
    
    % create seq loader ---------------------------------------------------
    m = main();
    
    % run the agent -------------------------------------------------------
    for i_seq = 1:(m.seq_created()-1)
        % load seq
        m.seq_load(i_seq);
        for i_map = 1:length(m.seq_maps)
            fprintf(['                                        map ',num2str(m.seq_maps(i_map)),': calculating entropy of stations\n']);
            % load map
            m.mainmap_load(m.seq_maps(i_map));
            % reset variable
            nb_stations = length(m.main_map.main_stations);
            nb_trials = size(m.seq_postrials{i_map},1);
            localentropy = nan(nb_trials,nb_stations);
            
            for i_trial = 1:nb_trials
                % set avatar/target
                m.seqtrial_setpositions(m.seq_postrials{i_map}(i_trial,:));
                m.seqtrial_settime(m.seq_timetrials{i_map}(i_trial));
                % find paths
                [c_choosedmainstations,~,v_choosedtimings] = p.get_paths(m.main_map);
                % transitions matrix
                transitions = zeros(nb_stations,nb_stations,nb_stations);
                for i_cchoosedmainstations = 1:length(c_choosedmainstations)
                    for i_stop = 1:(length(c_choosedmainstations{i_cchoosedmainstations})-2)
                        station_t = c_choosedmainstations{i_cchoosedmainstations}(i_stop);
                        station_t1 = c_choosedmainstations{i_cchoosedmainstations}(i_stop+1);
                        station_t2 = c_choosedmainstations{i_cchoosedmainstations}(i_stop+2);
                        transitions(station_t,station_t1,station_t2) = transitions(station_t,station_t1,station_t2) + exp(-v_choosedtimings(i_cchoosedmainstations)*invtemp);
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
                % information
                information = -log(probability);
                information(~probability) = 0;
                % entropy
                this_localentropy = sum(probability.*information,3);
                this_localentropy = squeeze(mean(this_localentropy,1));
                % store in local_entropy
                localentropy(i_trial,:) = this_localentropy;
            end
            % save (for the map) - - - - - - - - - - - - - - - - - - - - - 
            fprintf(['                                        map ',num2str(m.seq_maps(i_map)),': saving in file\n']);
            save([entropy_dir,filesep,entropy_valdir,filesep,entropy_subdir,filesep,entropy_pldir,filesep,entropy_prefile,num2str(m.seq_maps(i_map))],'localentropy');
        end
    end
end
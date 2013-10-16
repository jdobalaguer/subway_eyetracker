function  entrop_getlocalbottleneck()

    invtemp = 0.1;

    entropy_player = 'forwardsoftmax';
    entropy_dir = 'entropies';
    entropy_valdir = 'values';
    entropy_subdir = 'localbottlenecks';
    entropy_pldir  = entropy_player;
    entropy_prefile = 'ent_';
    
    % create folders ------------------------------------------------------
    if ~exist(entropy_dir,'dir')
        mkdir(entropy_dir);
    end
    if ~exist([entropy_dir,filesep,entropy_subdir],'dir')
        mkdir([entropy_dir,filesep,entropy_subdir]);
    end
    
    % create the agent ----------------------------------------------------
    p = player_forwardsoftmax();
    
    % create seq loader ---------------------------------------------------
    m = main();
    
    % run the agent -------------------------------------------------------
    fprintf('entrop_entropy: running the agent\n');
    for i_seq = 1:(m.seq_created()-1)
        % load seq
        m.seq_load(i_seq);
        for i_map = 1:length(m.seq_maps)
            % load map
            m.mainmap_load(m.seq_maps(i_map));
            % reset variable
            nb_stations = length(m.main_map.main_stations);
            nb_trials = size(m.seq_postrials{i_map},1);
            localbottleneck = nan(nb_trials,nb_stations);
            
            for i_trial = 1:nb_trials
                % set avatar/target
                m.seqtrial_setpositions(m.seq_postrials{i_map}(i_trial,:));
                m.seqtrial_settime(m.seq_timetrials{i_map}(i_trial));
                % find paths
                [c_choosedmainstations,~,v_choosedtimings] = p.get_paths(m.main_map);
                % create (weighted) histogram
                this_localbottleneck = zeros(1,nb_stations);
                for i_cchoosedmainstations = 1:length(c_choosedmainstations)
                    i_stations = c_choosedmainstations{i_cchoosedmainstations};
                    this_localbottleneck(i_stations) = this_localbottleneck(i_stations) + exp(-v_choosedtimings(i_cchoosedmainstations)*invtemp);
                end
                this_localbottleneck = this_localbottleneck / length(c_choosedmainstations);
                % store in local_entropy
                localbottleneck(i_trial,:) = this_localbottleneck;
            end
            % save (for the map) - - - - - - - - - - - - - - - - - - - - - 
            fprintf(['                                        map ',num2str(m.seq_maps(i_map)),': saving in file\n']);
            save([entropy_dir,filesep,entropy_valdir,filesep,entropy_subdir,filesep,entropy_pldir,filesep,entropy_prefile,num2str(i_map)],'localbottleneck');
        end
    end
end
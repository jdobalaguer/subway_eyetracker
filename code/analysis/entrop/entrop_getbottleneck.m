function  entrop_getbottleneck()

    entropy_player = 'god';
    entropy_dir = 'entropies';
    entropy_valdir = 'values';
    entropy_subdir = 'bottlenecks';
    entropy_pldir  = entropy_player;
    entropy_prefile = 'ent_';

    % set main object -----------------------------------------------------
    m = main();
    m.run_maps      = 1;
    m.run_trainmaps = 0;
    m.run_trials    = 1000;
    m.seq_dir = [entropy_dir,filesep,'sequences'];
    m.set_player(entropy_player);
    m.file.set_interface(entropy_player);
    m.file.tree_dir = [entropy_dir,filesep,'data'];
    
    % create folders ------------------------------------------------------
    if ~exist(entropy_dir,'dir')
        mkdir(entropy_dir);
    end
    if ~exist([entropy_dir,filesep,entropy_subdir],'dir')
        mkdir([entropy_dir,filesep,entropy_subdir]);
    end
    if ~exist(m.seq_dir,'dir')
        mkdir(m.seq_dir);
    end
    if ~exist(m.file.tree_dir,'dir')
        mkdir(m.file.tree_dir);
    end
    
    % create random sequences ---------------------------------------------
    fprintf('entrop_entropy: creating sequences\n');
    for i_map = (m.seq_created()):(m.mainmap_created()-1)
        fprintf(['entrop_entropy: creating sequences: map ',num2str(i_map),'\n']);
        m.seq_randgenerate();
    end
    
    % run the optimal agent -----------------------------------------------
    fprintf('entrop_entropy: running the agent\n');
    for i_map = (m.file.tree_last()):(m.mainmap_created()-1)
        m.experiment([0,0,0])
    end
    
    % calculate entropies -------------------------------------------------
    fprintf('entrop_entropy: calculating entropies\n');
    for i_map = 101:110%1:(m.mainmap_created()-1)
        fprintf(['                                        map ',num2str(i_map),'\n']);
        
        % load log - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
        fprintf(['                                        map ',num2str(i_map),': loading log\n']);
        d = m.file.tree_read(i_map);
        nb_trials = length(unique(d.data.trial));
        nb_stations = max(d.data.in_station);
        % store paths
        paths = {};
        for i = 1:nb_trials;
            paths{i} = d.data.in_station(d.data.trial==i);
        end

        % calculate histogram - - - - - - - - - - - - - - - - - - 
        bottleneck = zeros(1,nb_stations);
        for i_trial = 1:nb_trials
            for i_stop = 1:(length(paths{i_trial}))
                i_station = paths{i_trial}(i_stop);
                bottleneck(i_station) = bottleneck(i_station)+1;
            end
        end
        
        % save - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
        fprintf(['                                        map ',num2str(i_map),': saving in file\n']);
        save([entropy_dir,filesep,entropy_valdir,filesep,entropy_subdir,filesep,entropy_pldir,filesep,entropy_prefile,num2str(i_map)],'bottleneck');
    end
end
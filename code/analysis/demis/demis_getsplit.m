function  demis_getsplit(maps)

    entropy_player  = 'forwardsoftmax';
    entropy_dir = 'entropies';
    entropy_subdir = ['splits',filesep,entropy_player];
    entropy_prefile = 'd_';

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
    
    % split the map -------------------------------------------------------
    fprintf('entrop_entropy: splitting maps\n');
    % all maps
    if ~exist('maps','var')
        maps = 1:(m.mainmap_created()-1);
    end
    % split maps
    for i_map = maps
        fprintf(['                                        map ',num2str(i_map),'\n']);

        % SOMETHING TO DO #################################################
        
        % save - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
        fprintf(['                                        map ',num2str(i_map),': saving in file\n']);
        save([entropy_dir,filesep,entropy_subdir,filesep,entropy_prefile,num2str(i_map)]);
    end
end
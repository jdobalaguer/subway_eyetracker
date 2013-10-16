function  entrop_getradius()

    entropy_player = 'god';
    entropy_dir = 'entropies';
    entropy_valdir = 'values';
    entropy_subdir = 'radius';
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
    if ~exist([entropy_dir,filesep,entropy_valdir],'dir')
        mkdir([entropy_dir,filesep,entropy_valdir]);
    end
    if ~exist([entropy_dir,filesep,entropy_valdir,filesep,entropy_subdir],'dir')
        mkdir([entropy_dir,filesep,entropy_valdir,filesep,entropy_subdir]);
    end
    if ~exist([entropy_dir,filesep,entropy_valdir,filesep,entropy_subdir,filesep,entropy_pldir],'dir')
        mkdir([entropy_dir,filesep,entropy_valdir,filesep,entropy_subdir,filesep,entropy_pldir]);
    end
    
    % calculate entropies -------------------------------------------------
    fprintf('entrop_getradius: calculating radius\n');
    
    m = main();
    for i_map = 1:(m.mainmap_created()-1)
        fprintf(['                                        map ',num2str(i_map),'\n']);
        
        % load map - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
        fprintf(['                                        map ',num2str(i_map),': loading map\n']);
        m.mainmap_load(i_map);
        nb_stations = length(m.main_map.main_stations);
        
        % calculate mean/std points - - - - - - - - - - - - - - - - - - - -
        x = nan(1,nb_stations);
        y = nan(1,nb_stations);
        for i_station = 1:nb_stations
            x(i_station) = m.main_map.main_stations(i_station).draw_position(1);
            y(i_station) = m.main_map.main_stations(i_station).draw_position(2);
        end
        mean_x = mean(x);
        std_x = std(x);
        mean_y = mean(y);
        std_y = std(y);

        % calculate centrality - - - - - - - - - - - - - - - - - - - - - - 
        radius = zeros(1,nb_stations);
        for i_station = 1:nb_stations
            station_x = m.main_map.main_stations(i_station).draw_position(1);
            station_y = m.main_map.main_stations(i_station).draw_position(2);
            d_x = station_x - mean_x;
            d_y = station_y - mean_y;
            r_x = tools_normpdf(2*d_x,0,std_x);
            r_y = tools_normpdf(2*d_y,0,std_y);
            radius(i_station) = sqrt(sum(power(r_x+r_y,2)));
        end
        
        % save - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
        fprintf(['                                        map ',num2str(i_map),': saving in file\n']);
        save([entropy_dir,filesep,entropy_valdir,filesep,entropy_subdir,filesep,entropy_pldir,filesep,entropy_prefile,num2str(i_map)],'radius');
    end
end
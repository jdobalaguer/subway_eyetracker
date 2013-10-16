function  entrop_getlocalradius()

    entropy_player = 'god';
    entropy_dir = 'entropies';
    entropy_valdir = 'values';
    entropy_subdir = 'localradius';
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
    for i_seq = 1:(m.seq_created()-1)
        % load seq
        m.seq_load(i_seq);
        for i_map = 1:length(m.seq_maps)
            fprintf(['                                        map ',num2str(m.seq_maps(i_map)),'\n']);
            m.seq_load(i_seq);
            % load map - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
            fprintf(['                                        map ',num2str(m.seq_maps(i_map)),': loading map\n']);
            m.mainmap_load(m.seq_maps(i_map));
            
            main_stations = m.main_map.main_stations;
            nb_stations = length(m.main_map.main_stations);

            nb_trials = size(m.seq_postrials{i_map},1);
            localradius = nan(nb_trials,nb_stations);
            
            for i_trial = 1:nb_trials

                % calculate mean/std points - - - - - - - - - - - - - - - - - - - -
                i_start = m.seq_postrials{i_map}(i_trial,1);
                i_goal  = m.seq_postrials{i_map}(i_trial,3);
                x = [main_stations(i_start).draw_position(1) , main_stations(i_goal).draw_position(1)];
                y = [main_stations(i_start).draw_position(2) , main_stations(i_goal).draw_position(2)];
                mean_x = mean(x);
                std_x = std(x);
                mean_y = mean(y);
                std_y = std(y);

                % calculate centrality - - - - - - - - - - - - - - - - - - - - - - 
                for i_station = 1:nb_stations
                    station_x = main_stations(i_station).draw_position(1);
                    station_y = main_stations(i_station).draw_position(2);
                    d_x = station_x - mean_x;
                    d_y = station_y - mean_y;
                    s = .5*(std_x+std_y);
                    r_x = tools_normpdf(2*d_x,0,s);
                    r_y = tools_normpdf(2*d_y,0,s);
                    localradius(i_trial,i_station) = sqrt(sum(power(r_x+r_y,2)));
                end
            end

            % save - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
            fprintf(['                                        map ',num2str(m.seq_maps(i_map)),': saving in file\n']);
            save([entropy_dir,filesep,entropy_valdir,filesep,entropy_subdir,filesep,entropy_pldir,filesep,entropy_prefile,num2str(m.seq_maps(i_map))],'localradius');
            
        end
    end
end
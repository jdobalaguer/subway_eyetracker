function e = eyelink_getpathprop(e,i_participants)
    % load path
    fprintf(['eyelink: loading paths...\n']);
    [path_stations,path_sublines]=e.eyelink_map.get_path(i_participants);
    % i_participants loop
    for i_participant = i_participants
        % load gaze
        p_stations = e.stations{i_participant};
        e.c_pathprop{i_participant} = {};
        % load sequence
        load(['sequences/seq_',num2str(i_participant),'.mat']);
        for i_map = 1:length(p_stations)
            fprintf(['eyelink: process participant ',num2str(i_participant),': map ',num2str(i_map),'\n']);
            e.c_pathprop{i_participant}{i_map} = {};
            % load map
            e.eyelink_map.load(seq_maps(i_map));
            e.eyelink_map.resize(e.screen_rect);
            for i_trial = 1:length(p_stations{i_map})
                e.c_pathprop{i_participant}{i_map}{i_trial} = {};
                for i_decision = 1:length(p_stations{i_map}{i_trial})
                    e.c_pathprop{i_participant}{i_map}{i_trial}{i_decision} = [];
                    stations = p_stations{i_map}{i_trial}{i_decision};
                    for i_station = 2:size(stations,1)
                        time    = stations(i_station,1) - stations(i_station-1,1);
                        station = stations(i_station,2);
                        if any(station==path_stations{i_participant}{i_map}{i_trial})
                            e.c_pathprop{i_participant}{i_map}{i_trial}{i_decision}(end+1) = 1;
                        else
                            e.c_pathprop{i_participant}{i_map}{i_trial}{i_decision}(end+1) = 0;
                        end
                    end
                    e.c_pathprop{i_participant}{i_map}{i_trial}{i_decision} = mean(e.c_pathprop{i_participant}{i_map}{i_trial}{i_decision});
                end
            end
        end
    end
end
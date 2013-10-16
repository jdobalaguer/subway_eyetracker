function e = eyelink_getstations(e,i_participants)
    % i_participants loop
    for i_participant = i_participants
        % load gaze
        p_gaze = e.gaze{i_participant};

        % load sequence
        load(['sequences/seq_',num2str(i_participant),'.mat']);

        e.stations{i_participant} = {};
        for i_map = 1:length(p_gaze)
            fprintf(['eyelink: process participant ',num2str(i_participant),': map ',num2str(i_map),'\n']);
            e.stations{i_participant}{i_map} = {};
            % load map
            e.eyelink_map.load(seq_maps(i_map));
            e.eyelink_map.resize(e.screen_rect);
            for i_trial = 1:length(p_gaze{i_map})
                e.stations{i_participant}{i_map}{i_trial} = {};
                for i_decision = 1:length(p_gaze{i_map}{i_trial})
                    e.stations{i_participant}{i_map}{i_trial}{i_decision} = [];
                    txyp = p_gaze{i_map}{i_trial}{i_decision};
                    for i_txyp = 1:size(txyp,1)
                        xy = txyp(i_txyp,[2,3]);
                        station = e.eyelink_map.get_station(xy);
                        if station
                            e.stations{i_participant}{i_map}{i_trial}{i_decision} = [e.stations{i_participant}{i_map}{i_trial}{i_decision} ; txyp(i_txyp,1),station,txyp(i_txyp,4)];
                        end
                    end
                end
            end
        end
    end
end

function e = eyelink_gettypeprop(e,i_participants)
    % all participants
    if ~exist('i_participants','var')
        i_participants = 1:e.participants_created();
    end
    % i_participants loop
    e.c_typeprop = {};
    for i_participant = i_participants
        % load sequence
        load(['sequences/seq_',num2str(i_participant),'.mat']);
        e.c_typeprop{i_participant} = {};
        for i_map = 2:length(e.stations{i_participant})
            fprintf(['eyelink: process participant ',num2str(i_participant),': map ',num2str(i_map),'\n']);
            e.c_typeprop{i_participant}{i_map} = {};
            % load map
            e.eyelink_map.load(seq_maps(i_map));
            e.eyelink_map.resize(e.screen_rect);
            for i_trial = 1:length(e.stations{i_participant}{i_map})
                fprintf(['eyelink: process participant ',num2str(i_participant),': map ',num2str(i_map),': trial ',num2str(i_trial),'\n']);
                e.c_typeprop{i_participant}{i_map}{i_trial} = {};
                for i_decision = 1:length(e.stations{i_participant}{i_map}{i_trial})
                    start = seq_postrials{i_map}(i_trial,1);
                    goal = seq_postrials{i_map}(i_trial,3);
                    e.c_typeprop{i_participant}{i_map}{i_trial}{i_decision} = {};
                    stations = e.stations{i_participant}{i_map}{i_trial}{i_decision};
                    ttime = 0; % time is roughly goes between [0 - 4000]. see i_time.
                    for i_station = 2:size(stations,1)
                        dtime   = stations(i_station,1) - stations(i_station-1,1);
                        if ~isnan(dtime)
                            ttime    = ttime + dtime;
                            i_time  = floor(ttime/800.) + 1; % we split the 4s in five.
                            % if new i_time
                            if length(e.c_typeprop{i_participant}{i_map}{i_trial}{i_decision})<i_time
                                %fprintf(['eyelink: process participant ',num2str(i_participant),': map ',num2str(i_map),': i_time: ',num2str(i_time),'\n']);
                                e.c_typeprop{i_participant}{i_map}{i_trial}{i_decision}{i_time} = zeros(1,4);
                            end
                            station = stations(i_station,2);
                            switch (station)
                                % starting point
                                case start
                                    e.c_typeprop{i_participant}{i_map}{i_trial}{i_decision}{i_time}(1) = e.c_typeprop{i_participant}{i_map}{i_trial}{i_decision}{i_time}(1)+dtime;
                                % goal point
                                case goal
                                e.c_typeprop{i_participant}{i_map}{i_trial}{i_decision}{i_time}(2) = e.c_typeprop{i_participant}{i_map}{i_trial}{i_decision}{i_time}(2)+dtime;
                                otherwise
                                    nb_lines = .5 * length(e.eyelink_map.main_map.main_stations(station).main_sublines);
                                    % cross station
                                    if nb_lines>1
                                        e.c_typeprop{i_participant}{i_map}{i_trial}{i_decision}{i_time}(3) = e.c_typeprop{i_participant}{i_map}{i_trial}{i_decision}{i_time}(3)+dtime;
                                    % regular station
                                    else
                                        e.c_typeprop{i_participant}{i_map}{i_trial}{i_decision}{i_time}(4) = e.c_typeprop{i_participant}{i_map}{i_trial}{i_decision}{i_time}(4)+dtime;
                                    end
                            end
                        end
                    end
                    for i_time = 1:length(e.c_typeprop{i_participant}{i_map}{i_trial}{i_decision})
                        e.c_typeprop{i_participant}{i_map}{i_trial}{i_decision}{i_time} = e.c_typeprop{i_participant}{i_map}{i_trial}{i_decision}{i_time} / sum(e.c_typeprop{i_participant}{i_map}{i_trial}{i_decision}{i_time});
                    end
                end
            end
        end
    end
end

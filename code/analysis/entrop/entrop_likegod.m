function get_likegod(ep)

    % human file interface
    human_file = main_file();
    human_file.set_interface('human');

    % god file interface
    god_file = main_file();
    god_file.set_interface('god');

    % number of participants
    nb_participants = min(human_file.tree_last(),god_file.tree_last())-1;

    for i_participant = 1:nb_participants;
        fprintf(['entrop: get_likegod: participant ',num2str(i_participant),'\n']);

        % load human data
        human_log = human_file.tree_read(i_participant);

        % load god data
        god_log = god_file.tree_read(i_participant);

        % number of map/trials
        nb_maps = god_log.header.maps;
        nb_trials = god_log.header.trials;

        % likegod variable
        this_likegod = nan(nb_maps,nb_trials);

        % compare
        for i_map = 1:nb_maps
            for i_trial = 1:nb_trials
                % find human stations
                ih_map   = (human_log.data.map   == i_map);
                ih_trial = (human_log.data.trial == i_trial);
                h_stations = unique(human_log.data.in_station(ih_map & ih_trial));
                % find god stations
                ig_map   = (god_log.data.map   == i_map);
                ig_trial = (god_log.data.trial == i_trial);
                g_stations = unique(god_log.data.in_station(ig_map & ig_trial));
                % compare
                if isempty(h_stations)
                    this_likegod(i_map,i_trial) = -1; % invalid trial
                elseif length(h_stations)==length(g_stations) && all(h_stations==g_stations)
                    this_likegod(i_map,i_trial) = +1; % same route
                else
                    this_likegod(i_map,i_trial) = 0;  % different route
                end
            end
        end

        ep.likegod{i_participant} = this_likegod;
    end
end
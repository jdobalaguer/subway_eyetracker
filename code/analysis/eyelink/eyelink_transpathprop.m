function e = eyelink_transpathprop(e)
    nb_participants = length(e.stations);
    nb_maps = length(e.stations{1});
    nb_trials = length(e.stations{1}{1});
    nb_decisions = length(e.stations{1}{1}{1});
    e.v_pathprop = zeros(nb_participants,nb_maps,nb_trials,nb_decisions);
    for i_participant = 1:nb_participants
        for i_map = 1:nb_maps
            for i_trial = 1:nb_trials
                for i_decision = 1:nb_decisions
                    e.v_pathprop(i_participant,i_map,i_trial,i_decision) = e.c_pathprop{i_participant}{i_map}{i_trial}{i_decision};
                end
            end
        end
    end
end
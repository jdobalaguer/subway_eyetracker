% 1 = starting point
% 2 = goal
% 3 = exchange station
% 4 = regular (no exchange) station
function e = eyelink_transtypeprop(e)
    nb_participants = length(e.c_typeprop);
    nb_maps         = length(e.c_typeprop{1});
    nb_trials       = length(e.c_typeprop{1}{2});
    nb_decisions    = length(e.c_typeprop{1}{2}{1});
    nb_times        = 5;
    nb_types        = 4;
    e.v_typeprop = nan(nb_participants,nb_maps,nb_trials,nb_decisions,nb_times,nb_types);
    for i_participant = 1:nb_participants
        for i_map = 2:nb_maps
            fprintf(['eyelink: process participant ',num2str(i_participant),': map ',num2str(i_map),'\n']);
            for i_trial = 1:nb_trials
                for i_decision = 1:nb_decisions
                    for i_time = 1:length(e.c_typeprop{i_participant}{i_map}{i_trial}{i_decision})
                        for i_type = 1:4
                            try
                                v = e.c_typeprop{i_participant}{i_map}{i_trial}{i_decision}{i_time};
                                if isempty(v)
                                    e.v_typeprop(i_participant,i_map,i_trial,i_decision,i_time,:) = NaN;
                                else
                                    e.v_typeprop(i_participant,i_map,i_trial,i_decision,i_time,:) = v;
                                end
                            catch err
                                fprintf(['eyelink_transtypeprop: error. (',num2str(i_participant),',',num2str(i_map),',',num2str(i_trial),',',num2str(i_decision),',',num2str(i_time),')']);
                                rethrow(err);
                            end
                        end
                    end
                end
            end
        end
    end
end
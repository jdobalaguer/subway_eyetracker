function eyelink_getdurations(e)
    % numbers
    nb_participants = length(e.clusters);
    nb_maps         = length(e.clusters{1});
    nb_trials       = length(e.clusters{1}{1});
    nb_decisions    = length(e.clusters{1}{1}{1});
    
    % initialize variable
    c_durations = nan(nb_participants,nb_maps,nb_trials,nb_decisions);
    mm_durations = nan(nb_participants,nb_maps,nb_trials,nb_decisions);
    
    for i_participant = 1:nb_participants
        fprintf(['eyelink_getdurations: participant ',num2str(i_participant),'\n']);
        for i_map = 1:nb_maps
            fprintf(['eyelink_getdurations: participant ',num2str(i_participant),', map ',num2str(i_map),'\n']);
            for i_trial = 1:nb_trials
                fprintf(['eyelink_getdurations: participant ',num2str(i_participant),', map ',num2str(i_map),', trial ',num2str(i_trial),'\n']);
                for i_decision = 1:nb_decisions
                    % get clusters
                    gaze      = e.gaze{i_participant}{i_map}{i_trial}{i_decision};
                    clusters  = e.clusters{i_participant}{i_map}{i_trial}{i_decision};
                    % check is not empty
                    if ~isempty(clusters)
                        c_durations(i_participant,i_map,i_trial,i_decision) = tools_nansum(clusters(:,2));
                        mm_durations(i_participant,i_map,i_trial,i_decision) = tools_nanmax(gaze(:,1))-tools_nanmin(gaze(:,1));
                    end
                end
            end
        end
    end
    
    % save variable
    e.c_durations = c_durations;
    e.mm_durations = mm_durations;
end
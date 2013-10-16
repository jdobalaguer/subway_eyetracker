function e = eyelink_getclusters(e,i_participants)
    % format cell
    if isempty(e.clusters)
        e.clusters = cell(1,e.participants_created());
    end
    % i_participants loop
    for i_participant = i_participants
        fprintf(['eyelink: get_clusters: processing participant ',num2str(i_participant),'\n']);
        for i_map = 1:length(e.gaze{i_participant})
            for i_trial = 1:length(e.gaze{i_participant}{i_map})
                for i_decision = 1:length(e.gaze{i_participant}{i_map}{i_trial})
                    e.clusters{i_participant}{i_map}{i_trial}{i_decision} = eyelink_process.eyelink_detfix(e.gaze{i_participant}{i_map}{i_trial}{i_decision});
                end
            end
        end
    end
end

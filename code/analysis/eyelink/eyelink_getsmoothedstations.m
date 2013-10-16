function e = eyelink_getsmoothedstations(e,i_participants)
    %min_var = 40;
    %pow_var = 0.5;
    min_var = 60;
    pow_var = 0.7;

    % load clusters
    clusters = e.clusters;
        
    % i_participants loop
    for i_participant = i_participants

        % load sequence
        load(['sequences/seq_',num2str(i_participant),'.mat']);
        
        % calculate station values
        e.smoothedstations{i_participant} = {};
        
        % for each map
        for i_map = 1:length(clusters{i_participant})
            fprintf(['eyelink: process participant ',num2str(i_participant),': map ',num2str(i_map),'\n']);
            e.smoothedstations{i_participant}{i_map} = {};
            % load map
            e.eyelink_map.load(seq_maps(i_map));
            e.eyelink_map.resize(e.screen_rect);
            nb_stations = length(e.eyelink_map.main_map.main_stations);
            
            % for each trial
            for i_trial = 1:length(clusters{i_participant}{i_map})
                e.smoothedstations{i_participant}{i_map}{i_trial} = {};
                
                % for each decision
                for i_decision = 1:length(clusters{i_participant}{i_map}{i_trial})
                    e.smoothedstations{i_participant}{i_map}{i_trial}{i_decision} = zeros(1,nb_stations);
                    
                    % for each cluster
                    cluster = clusters{i_participant}{i_map}{i_trial}{i_decision};
                    for i_cluster = 1:size(cluster,1)
                        
                        % for each station
                        max_t  =  max(cluster(:,2));
                        mean_t = mean(cluster(:,2));
                        for i_station = 1:nb_stations
                            cluster_xy = cluster(i_cluster,[4,5]);
                            station_xy = e.eyelink_map.main_map.main_stations(i_station).draw_position;
                            d_xy = tools_dist(cluster_xy,station_xy);
                            t_xy = cluster(i_cluster,2)/mean_t;
                            s_var = min_var * power(t_xy,-pow_var);
                            s_xy = tools_normpdf(d_xy,0,s_var); % station distance is ~95 px.
                            %s_xy = d_xy<100;
                            e.smoothedstations{i_participant}{i_map}{i_trial}{i_decision}(i_station) = e.smoothedstations{i_participant}{i_map}{i_trial}{i_decision}(i_station) + s_xy;
                        end
                    end
                end
            end
        end
    end
end
 
%{
    requires previous calculations...

    e = eyelink();
    e.get_gaze();
    e.get_clusters();
    e.get_smoothedstations();
    e.save();
%}

function entrop_plotlb()
    
    % load eyelink
    e = eyelink.load();
    
    % numbers
    nb_participants = length(e.smoothedstations);
    
    % initialize log
    log = cell(1,nb_participants);
    file = main_file();
    file.set_interface('human');
    
    figure;
    for i_participant = 1:nb_participants
        fprintf(['entrop_plotlb: participant ',num2str(i_participant),'\n']);
        
        % initialise values
        yg  = [];
        xlb = [];
        
        % load log
        log{i_participant} = file.tree_read(i_participant);
        
        % load seq
        load(['sequences/seq_',num2str(i_participant),'.mat']);
    
        % get values ------------------------------------------------------
        for i_map = 2:length(e.smoothedstations{i_participant})
            % load map
            e.eyelink_map.load(seq_maps(i_map));
            map = e.eyelink_map.main_map;
            nb_stations = length(map.main_stations);
            
            % load gaze
            unbiasedgaze_map = load(['entropies/values/unbiasedgaze/ent_',num2str(seq_maps(i_map)),'.mat']);
            unbiasedgaze_map = unbiasedgaze_map.unbiasedgaze;
            % load localbottleneck
            localbottleneck_map = load(['entropies/values/localbottlenecks/forwardsoftmax/ent_',num2str(seq_maps(i_map)),'.mat']);
            localbottleneck_map = localbottleneck_map.localbottleneck;
            
            % load crosses
            cross_map = zeros(1,nb_stations);
            for i_station = 1:nb_stations
                if length(map.main_stations(i_station).main_sublines)>2
                    cross_map(i_station) = 1;
                end
            end
            
            for i_trial = 1:length(e.smoothedstations{i_participant}{i_map})
                % route taken
                ii_map   = (log{i_participant}.data.map   == i_map);
                ii_trial = (log{i_participant}.data.trial == i_trial);
                in_stations = zeros(1,nb_stations);
                in_stations(unique(log{i_participant}.data.in_station(ii_map & ii_trial))) = 1;
                
                duration = e.mm_durations(i_participant,i_map,i_trial,1);
                duration_ok = duration>3900 && duration<4100;
                
                sum_crosstations = sum(in_stations & cross_map);
                
                % localbottleneck values
                gaze_path = unbiasedgaze_map(i_trial,in_stations & cross_map);
                if any(gaze_path)
                    gaze_path = gaze_path / mean(gaze_path);
                    ok = 1;
                else
                    ok = 0;
                    %fprintf(['entrop_getregression: nok: (',num2str(i_participant),';',num2str(i_map),';',num2str(i_trial),')\n']);
                end
                
                % localbottleneck values
                localbottleneck_path = localbottleneck_map(i_trial,in_stations & cross_map);
                if any(localbottleneck_path)
                    localbottleneck_path = localbottleneck_path / mean(localbottleneck_path);
                else
                    localbottleneck_path = ones(1,length(gaze_path));
                end
                
                % if we have all of the calues
                if ok && duration_ok
                    % rename values
                    yg  = [yg,gaze_path];
                    xlb = [xlb,localbottleneck_path];
                end
            end
        end
        
        subplot(1,nb_participants,i_participant);
        plot(xlb,yg,'.');
    end
end

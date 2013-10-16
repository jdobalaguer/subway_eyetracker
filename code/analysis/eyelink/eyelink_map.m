classdef eyelink_map < handle
    % class for the eyelink map
    
    properties
        % screen ----------------------------------------------------------
        % screen borders
        draw_bordertop
        draw_bordersides
        draw_borderbottom
        % map -------------------------------------------------------------
        % main map
        main_map
        % map files
        mainmap_prename
        mainmap_dir
        % stations --------------------------------------------------------
        d_min
        % draw ------------------------------------------------------------
        gaze_color
        gaze_thick
    end
    
    methods
        % constructor
        function obj = eyelink_map()
            % screen
            obj.draw_bordertop = 100;
            obj.draw_bordersides = 100;
            obj.draw_borderbottom = 100;
            % map
            obj.main_map = [];
            obj.mainmap_prename = 'map_';
            obj.mainmap_dir = 'maps';
            % stations
            obj.d_min = 0;
            % draw
            obj.gaze_color = [255,0,0];
            obj.gaze_thick = 5;

        end
        
        % map methods -----------------------------------------------------
        % set the main map
        function obj = set(obj, v_map)
            obj.main_map = v_map;
        end
        % remove the main map
        function obj = remove(obj)
            delete(obj.main_map);
            obj.main_map = [];
        end
        % number of main maps already generated, +1
        function nbmaps = mainmap_created(obj)
            nbmaps = 1;
            while exist([obj.mainmap_dir,'/',obj.mainmap_prename,num2str(nbmaps),'.mat'],'file')
                nbmaps = nbmaps+1;
            end
        end
        % load a main map
        function obj = load(obj, number)
            if exist([obj.mainmap_dir,'/',obj.mainmap_prename,num2str(number),'.mat'],'file')
                v_map = main_map.load([obj.mainmap_dir,'/',obj.mainmap_prename,num2str(number),'.mat']);
                obj.set(v_map);
            else
                fprintf(['eyelink_map: load: file ''',obj.mainmap_dir,'/',obj.mainmap_prename,num2str(number),'.mat','''doesn''t exist\n']);
                fprintf( '                    try with:\n');
                fprintf( '                    » m = main();\n');
                fprintf(['                    » m.generate_mainmaps(',num2str(1+number-obj.mainmap_created()),');\n']);
                
            end
        end
        % resize the map
        function obj = resize(obj,screen_rect)
            % map resize
            map_rect = [screen_rect(1)+obj.draw_bordersides, screen_rect(2)+obj.draw_bordertop, screen_rect(3)-obj.draw_bordersides, screen_rect(4)-obj.draw_borderbottom];
            obj.main_map.resize_map(1,map_rect);
            % minimum distance between stations
            nb_stations = length(obj.main_map.main_stations);
            obj.d_min = inf;
            for i_mainstation = 1:nb_stations
                for j_mainstation = 1:nb_stations
                    if i_mainstation~=j_mainstation
                        pos_i = obj.main_map.main_stations(i_mainstation).draw_position;
                        pos_j = obj.main_map.main_stations(j_mainstation).draw_position;
                        d_ij = sum(power(pos_i-pos_j,2));
                        if obj.d_min > d_ij
                            obj.d_min = d_ij;
                        end
                    end
                end
            end
        end
        
        % draw ------------------------------------------------------------
        % general function for drawing map + gaze
        %   flags(1): draw trajectories
        %   flags(2): draw fixation circles
        function obj = draw_gaze(obj,monitor,subgaze,subclusters,flags)
            %Screen('FillRect', monitor.screen_window,[0,0,0],monitor.screen_rect);
            if any(flags(3:end))
                % plot entropy
                obj.main_map.draw_options(monitor.screen_window,monitor.screen_rect);
            end
            % map
            obj.main_map.draw_map(monitor.screen_window,monitor.screen_rect);
            % avatar
            obj.main_map.main_avatar.draw(monitor.screen_window,monitor.screen_rect,obj.main_map.main_stations,obj.main_map.main_sublines);
            if flags(1)
                obj.draw_traj(monitor,subgaze);
            end
            if flags(2)
                obj.draw_fix(monitor,subclusters);
            end
            Screen(monitor.screen_window, 'Flip');
        end
        % draw trajectories
        function obj = draw_traj(obj,monitor,subgaze)
            l_subgaze = size(subgaze,1)-1;
            for i_subgaze = 1:l_subgaze
                if ~any(isnan([subgaze(i_subgaze,2),subgaze(i_subgaze,3),subgaze(i_subgaze+1,2),subgaze(i_subgaze+1,3)]))
                    Screen('DrawLine',monitor.screen_window,obj.gaze_color*i_subgaze/l_subgaze,subgaze(i_subgaze,2),subgaze(i_subgaze,3),subgaze(i_subgaze+1,2),subgaze(i_subgaze+1,3),obj.gaze_thick);
                end
                if ~any(isnan([subgaze(i_subgaze,2),subgaze(i_subgaze,3)]))
                    dot_rect = [subgaze(i_subgaze,2)-.5*obj.gaze_thick,subgaze(i_subgaze,3)-.5*obj.gaze_thick,subgaze(i_subgaze,2)+.5*obj.gaze_thick,subgaze(i_subgaze,3)+.5*obj.gaze_thick];
                    Screen('FillOval',monitor.screen_window,[0,0,0],dot_rect);
                end
            end
        end
        % draw trajectories
        function obj = draw_fix(obj,monitor,subclusters)
            l_clusters = size(subclusters,1);
            for i_clusters = 1:l_clusters
                clust_pos = subclusters(i_clusters,[4,5]);
                clust_r = 20;
                clust_rect = [clust_pos(1)-clust_r,clust_pos(2)-clust_r,clust_pos(1)+clust_r,clust_pos(2)+clust_r];
                clust_w = 15 * subclusters(i_clusters,2) / max(subclusters(:,2));
                Screen('FrameOval',monitor.screen_window,obj.gaze_color*i_clusters/l_clusters,clust_rect,clust_w);
            end
        end
        
        % show ------------------------------------------------------------
        % general function for showing gaze over maps
        function show_gaze(obj,screen_rect,e,flags)
            local_flag = 1;
            model_name = '';
            
            gaze = e.gaze;
            clusters = e.clusters;
            smoothedstations = e.smoothedstations;
            try
                monitor = main_monitor();
                monitor.monitor_open([1,0,0]);
                fprintf(     'eyelink_map: show_maps:\n');
                i_participant = 1;
                i_map = 2;
                i_trial = 1;
                i_decision = 1;
                i_stop = 1;
                % load seq
                load(['sequences/seq_',num2str(i_participant),'.mat']);
                % load data
                log = cell(1,length(gaze));
                file = main_file();
                file.set_interface('human');
                log{i_participant} = file.tree_read(i_participant);
                % load map
                obj.load(seq_maps(i_map));
                obj.resize(screen_rect);
                while i_map <= length(seq_maps)
                    % LOAD ------------------------------------------------
                    subgaze = gaze{i_participant}{i_map}{i_trial}{i_decision};
                    if isempty(clusters)
                        clusters = cell(1,length(gaze));
                    end
                    if isempty(clusters{i_participant})
                        clusters{i_participant} = cell(1,length(gaze{i_participant}));
                    end
                    if isempty(clusters{i_participant}{i_map})
                        clusters{i_participant}{i_map} = cell(1,length(gaze{i_participant}{i_map}));
                    end
                    if isempty(clusters{i_participant}{i_map}{i_trial})
                        clusters{i_participant}{i_map}{i_trial} = cell(1,length(gaze{i_participant}{i_map}{i_trial}));
                    end
                    if isempty(clusters{i_participant}{i_map}{i_trial}{i_decision})
                        clusters{i_participant}{i_map}{i_trial}{i_decision} = eyelink_process.eyelink_detfix(subgaze);
                        fprintf('eyelink_map: show_gaze: calculation fot clusters{%d}{%d}{%d}{%d}\n',i_participant,i_map,i_trial,i_decision);
                    end
                    subclusters = clusters{i_participant}{i_map}{i_trial}{i_decision};
                    % no data message
                    if isempty(subgaze) || all(all(isnan(subgaze(:,[2,3]))))
                        fprintf('eyelink_map: show_gaze: gaze{%d}{%d}{%d}{%d} is empty\n',i_participant,i_map,i_trial,i_decision);
                        DrawFormattedText(monitor.screen_window,'-- NO DATA !',0,30);
                    end
                    % LOG -------------------------------------------------
                    % read log (find in_station, in_subline, target_station)
                    tmpi_maps = find(log{i_participant}.data.map == i_map);
                    tmpi_trials = find(log{i_participant}.data.trial == i_trial);
                    tmpi_decisions = find(log{i_participant}.data.decision > 0);
                    tmpi_log = intersect(intersect(tmpi_maps,tmpi_trials),tmpi_decisions);
                    if ~isempty(tmpi_log) && i_stop<=length(tmpi_log)
                        % draw avatar and target (if possible)
                        in_mainstation = log{i_participant}.data.in_station(tmpi_log(i_stop));
                        in_mainsubline = log{i_participant}.data.in_subline(tmpi_log(i_stop));
                        target_mainstation = log{i_participant}.data.targetstation(tmpi_log(i_stop));
                        % set avatar/target
                        obj.main_map.set_avatartarget(in_mainstation,in_mainsubline,target_mainstation);
                        obj.main_map.main_avatar.set_draw(obj.main_map.main_stations,obj.main_map.main_sublines);
                    end
                    
                    % PLOT OPTIONS (entropy or smoothedstations) ----------
                    if any(flags(3:end))
                        if sum(flags(3:end))>1
                            error('eyelink_map: error: simultaneous exclusive flags!');
                        end
                        
                        switch model_name
                            case 'gaze'
                                % GAZE
                                value_stations = e.smoothedstations{i_participant}{i_map}{i_trial}{i_decision};
                            case 'unbiased gaze'
                                % UNBIASED GAZE
                                unbiasedgaze_map = load(['entropies/values/unbiasedgaze/ent_',num2str(seq_maps(i_map)),'.mat']);
                                value_stations = unbiasedgaze_map.unbiasedgaze(i_trial,:);
                            case 'entropy'
                                % ENTROPY
                                entropy_map = load(['entropies/values/entropies/god/ent_',num2str(seq_maps(i_map)),'.mat']);
                                value_stations = entropy_map.entropy;
                            case 'bottleneck'
                                % BOTTLENECK
                                bottleneck_map = load(['entropies/values/bottlenecks/god/ent_',num2str(seq_maps(i_map)),'.mat']);
                                value_stations = bottleneck_map.bottleneck;
                            case 'radius'
                                % RADIUS
                                radius_map = load(['entropies/values/radius/god/ent_',num2str(seq_maps(i_map)),'.mat']);
                                value_stations = radius_map.radius;
                            case 'local entropy'
                                % LOCAL ENTROPY
                                localentropy_map = load(['entropies/values/localentropies/forwardsoftmax/ent_',num2str(seq_maps(i_map)),'.mat']);
                                value_stations = localentropy_map.localentropy(i_trial,:);
                            case 'local bottleneck'
                                % LOCAL BOTTLENECK
                                localbottleneck_map = load(['entropies/values/localbottlenecks/forwardsoftmax/ent_',num2str(seq_maps(i_map)),'.mat']);
                                value_stations = localbottleneck_map.localbottleneck(i_trial,:);
                            case 'local radius'
                                % LOCAL RADIUS
                                localradius_map = load(['entropies/values/localradius/god/ent_',num2str(seq_maps(i_map)),'.mat']);
                                value_stations = localradius_map.localradius(i_trial,:);
                        end
                        
                        
                        nb_stations = length(value_stations);
                        
                        % local (participants' path) values
                        if local_flag
                            % get path map
                            ii_map   = (log{i_participant}.data.map   == i_map);
                            ii_trial = (log{i_participant}.data.trial == i_trial);
                            in_stations = zeros(1,nb_stations);
                            in_stations(unique(log{i_participant}.data.in_station(ii_map & ii_trial))) = 1;
                            % get cross map
                            cross_map = zeros(1,nb_stations);
                            for i_station = 1:nb_stations
                                if length(obj.main_map.main_stations(i_station).main_sublines)>2
                                    cross_map(i_station) = 1;
                                end
                            end
                            % set new value_stations
                            value_stations(~(in_stations & cross_map)) = 0;
                        end

                        % normalise
                        value_stations = value_stations/max(value_stations);

                        % grey map
                        for i_mainsubline = 1:length(obj.main_map.main_sublines)
                            obj.main_map.main_sublines(i_mainsubline).draw_color = [200,200,200];
                            obj.main_map.main_sublines(i_mainsubline).draw_thick = .004;
                        end
                        % set all main stations as options
                        obj.main_map.options_mainstation = [];
                        obj.main_map.options_mainsubline = [];
                        % set all main stations as options
                        obj.main_map.options_mainstation = [];
                        obj.main_map.options_mainsubline = [];
                        for i_mainsubline = 1:length(obj.main_map.main_sublines)
                            for i_mainstation = 2:length(obj.main_map.main_sublines(i_mainsubline).main_stations)
                                obj.main_map.options_mainstation(end+1) = obj.main_map.main_sublines(i_mainsubline).main_stations(i_mainstation);
                                obj.main_map.options_mainsubline(end+1) = i_mainsubline;
                            end
                        end
                        % set drawing of options (to show what are the symbols)
                        obj.main_map.set_drawoptions();
                        % for each station in the symbol
                        for i_mainstation = 1:nb_stations
                            obj.main_map.main_stations(i_mainstation).option_angles = 0;
                            obj.main_map.main_stations(i_mainstation).option_colors = (value_stations(i_mainstation))*[255,0,255];
                        end
                    end
                    
                    % DRAW ------------------------------------------------
                    % print index in top-left corner
                    DrawFormattedText(monitor.screen_window,num2str([i_participant,i_map,i_trial,i_decision,i_stop]),0,0);
                    DrawFormattedText(monitor.screen_window,model_name,0,10);
                    % draw map + gaze
                    obj.draw_gaze(monitor,subgaze,subclusters,flags);
                    % wait for keyboard -----------------------------------
                    while KbCheck; end
                    while ~KbCheck; end
                    % read
                    key_code = monitor.keymouse_read();
                    
                    % INDEX -----------------------------------------------
                    % i_participant++
                    if strcmp(KbName(key_code),'q')
                        if i_participant<length(gaze)
                            % index
                            i_participant = i_participant+1;
                            i_map = 2;
                            i_trial = 1;
                            i_decision = 1;
                            i_stop = 1;
                            % load seq
                            load(['sequences/seq_',num2str(i_participant),'.mat']);
                            % load data
                            if isempty(log{i_participant})
                                log{i_participant} = file.tree_read(i_participant);
                            end
                            % load map
                            obj.load(seq_maps(i_map));
                            obj.resize(screen_rect);
                        end
                    % i_participant--
                    elseif strcmp(KbName(key_code),'a')
                        if i_participant>1
                            % index
                            i_participant = i_participant-1;
                            i_map = 2;
                            i_trial = 1;
                            i_decision = 1;
                            i_stop = 1;
                            % load seq
                            load(['sequences/seq_',num2str(i_participant),'.mat']);
                            % load data
                            if isempty(log{i_participant})
                                log = file.tree_read(i_participant);
                            end
                            % load map
                            obj.load(seq_maps(i_map));
                            obj.resize(screen_rect);
                        end
                    % i_map++
                    elseif strcmp(KbName(key_code),'w')
                        if i_map<length(gaze{i_participant})
                            % index
                            i_map = i_map+1;
                            i_trial = 1;
                            i_decision = 1;
                            i_stop = 1;
                            % load map
                            obj.load(seq_maps(i_map));
                            obj.resize(screen_rect);
                        end
                    % i_map--
                    elseif strcmp(KbName(key_code),'s')
                        if i_map>2
                            % index
                            i_map = i_map-1;
                            i_trial = 1;
                            i_decision = 1;
                            i_stop = 1;
                            % load map
                            obj.load(seq_maps(i_map));
                            obj.resize(screen_rect);
                        end
                    % i_trial++
                    elseif strcmp(KbName(key_code),'e')
                        if i_trial<length(gaze{i_participant}{i_map})
                            % index
                            i_trial = i_trial+1;
                            i_decision = 1;
                        end
                    % i_trial--
                    elseif strcmp(KbName(key_code),'d')
                        if i_trial>1
                            % index
                            i_trial = i_trial-1;
                            i_decision = 1;
                            i_stop = 1;
                        end
                    % i_decision++
                    elseif strcmp(KbName(key_code),'r')
                        if i_decision<length(gaze{i_participant}{i_map}{i_trial})
                            % index
                            i_decision = i_decision+1;
                            i_stop = 1;
                        end
                    % i_decision++
                    elseif strcmp(KbName(key_code),'f')
                        if i_decision>1
                            % index
                            i_decision = i_decision-1;
                            i_stop = 1;
                        end
                    elseif strcmp(KbName(key_code),'t')
                        if i_stop<length(tmpi_log)
                            % index
                            i_stop = i_stop+1;
                        end
                    % i_decision++
                    elseif strcmp(KbName(key_code),'g')
                        if i_stop>1
                            % index
                            i_stop = i_stop-1;
                        end
                    % TOOLS
                    % mark map
                    elseif strcmp(KbName(key_code),'Down') || strcmp(KbName(key_code),'DownArrow')
                        fprintf(['                 map ',num2str(seq_maps(i_map)),' has been marked\n']);
                    % capture picture
                    elseif strcmp(KbName(key_code),'Up') || strcmp(KbName(key_code),'UpArrow')
                        imwrite(Screen('GetImage', monitor.screen_window, monitor.screen_rect), ['part_',num2str(i_participant),'_map_',num2str(i_map),'_trial_',num2str(i_trial),'.png']);
                    % FLAGS
                    % FLAGS - LOCAL/GLOBAL
                    elseif strcmp(KbName(key_code),'l')
                        local_flag = 1 - local_flag;
                    % FLAGS - EYE TRAJECTORIES
                    elseif strcmp(KbName(key_code),'1') || strcmp(KbName(key_code),'1!')
                        flags(1) = 1-flags(1);
                    % FLAGS - EYE FIXATION POINTS
                    elseif strcmp(KbName(key_code),'2') || strcmp(KbName(key_code),'2@')
                        flags(2) = 1-flags(2);
                    % FLAGS - GAZE
                    elseif strcmp(KbName(key_code),'3') || strcmp(KbName(key_code),'3#')
                        flags(3) = mod(flags(3)+1,3);
                        if ~flags(3)
                            % reload map
                            obj.load(seq_maps(i_map));
                            obj.resize(screen_rect);
                            model_name = '';
                        % mutual exclusivity between flags
                        else
                            switch flags(3)
                                case 1
                                    flags(3:end) = 0;
                                    flags(3) = 1;
                                    model_name = 'gaze';
                                case 2
                                    flags(3:end) = 0;
                                    flags(3) = 1;
                                    model_name = 'unbiased gaze';
                            end
                        end
                    % FLAGS - ENTROPY
                    elseif strcmp(KbName(key_code),'4') || strcmp(KbName(key_code),'4$')
                        flags(4) = 1-flags(4);
                        if ~flags(4)
                            % reload map
                            obj.load(seq_maps(i_map));
                            obj.resize(screen_rect);
                            model_name = '';
                        % mutual exclusivity between flags
                        else
                            flags(3:end) = 0;
                            flags(4) = 1;
                            model_name = 'entropy';
                        end
                    % FLAGS - BOTTLENECKS
                    elseif strcmp(KbName(key_code),'5') || strcmp(KbName(key_code),'5%')
                        flags(5) = 1-flags(5);
                        if ~flags(5)
                            % reload map
                            obj.load(seq_maps(i_map));
                            obj.resize(screen_rect);
                            model_name = '';
                        % mutual exclusivity between flags
                        else
                            flags(3:end) = 0;
                            flags(5) = 1;
                            model_name = 'bottleneck';
                        end
                    % FLAGS - RADIUS
                    elseif strcmp(KbName(key_code),'6') || strcmp(KbName(key_code),'6^')
                        flags(6) = 1-flags(6);
                        if ~flags(6)
                            % reload map
                            obj.load(seq_maps(i_map));
                            obj.resize(screen_rect);
                            model_name = '';
                        % mutual exclusivity between flags
                        else
                            flags(3:end) = 0;
                            flags(6) = 1;
                            model_name = 'radius';
                        end
                    % FLAGS - LOCAL ENTROPY
                    elseif strcmp(KbName(key_code),'7') || strcmp(KbName(key_code),'7&')
                        flags(7) = 1-flags(7);
                        if ~flags(7)
                            % reload map
                            obj.load(seq_maps(i_map));
                            obj.resize(screen_rect);
                            model_name = '';
                        % mutual exclusivity between flags
                        else
                            flags(3:end) = 0;
                            flags(7) = 1;
                            model_name = 'local entropy';
                        end
                    % FLAGS - LOCAL BOTTLENECKS
                    elseif strcmp(KbName(key_code),'8') || strcmp(KbName(key_code),'8*')
                        flags(8) = 1-flags(8);
                        if ~flags(8)
                            % reload map
                            obj.load(seq_maps(i_map));
                            obj.resize(screen_rect);
                            model_name = '';
                        % mutual exclusivity between flags
                        else
                            flags(3:end) = 0;
                            flags(8) = 1;
                            model_name = 'local bottleneck';
                        end
                    % FLAGS - LOCAL RADIUS
                    elseif strcmp(KbName(key_code),'9') || strcmp(KbName(key_code),'9(')
                        flags(9) = 1-flags(9);
                        if ~flags(9)
                            % reload map
                            obj.load(seq_maps(i_map));
                            obj.resize(screen_rect);
                            model_name = '';
                        % mutual exclusivity between flags
                        else
                            flags(3:end) = 0;
                            flags(9) = 1;
                            model_name = 'local radius';
                        end
                    % EXIT
                    elseif strcmp(KbName(key_code),'ESCAPE') || strcmp(KbName(key_code),'Escape')
                        break
                    else
                        fprintf(['                 ',KbName(key_code),' is unused\n']);
                    end
                end
                % close monitor
                monitor.monitor_close();
            catch err
                % close monitor
                monitor.monitor_close();
                rethrow(err);
            end
        end

        % station methods -------------------------------------------------
        % get the closer station to a certain position
        function min_station = get_station(obj,pos)
            nb_stations = length(obj.main_map.main_stations);
            distances = zeros(1,nb_stations);
            for i_mainstation = 1:nb_stations
                pos_station = obj.main_map.main_stations(i_mainstation).draw_position;
                distances(i_mainstation) = sum(power(pos_station-pos,2));
            end
            [min_distance,min_station] = min(distances);
            if min_distance > .5*obj.d_min
                min_station = 0;
            end
        end
        function [main_stations, main_sublines] = get_path(obj,participants)
            f = main_file();
            f.set_interface('human');
            main_stations = {};
            main_sublines = {};
            % for each participant
            for i_participant = 1:length(participants)
                participant = participants(i_participant);
                % read log file
                log = f.tree_read(participant);
                % variables
                main_stations{i_participant} = {};
                main_sublines{i_participant} = {};
                i_maps = unique(log.data.map);
                i_trials = unique(log.data.trial);
                % for each map
                for i_map = i_maps
                    main_stations{i_participant}{i_map} = {};
                    main_sublines{i_participant}{i_map} = {};
                    for i_trial = i_trials
                        main_stations{i_participant}{i_map}{i_trial} = unique(log.data.in_station(log.data.map==i_map & log.data.trial==i_trial));
                        main_sublines{i_participant}{i_map}{i_trial} = unique(log.data.in_subline(log.data.map==i_map & log.data.trial==i_trial));
                    end
                end
            end
        end
    end
end


classdef main_map < matlab.mixin.Copyable % handle + copyable
    % class controlling a map (including stations, sublines and the avatar)
    
    properties
        % general
        name
        % elements
        main_timebar
        main_avatar
        target_mainstation
        main_stations
        main_sublines
        % options
        options_mainstation
        options_mainsubline
        % topology
        topology
        ring_stations
        % draw
        draw_optionsize
        draw_optiontransparency
    end
    
    methods
        %constructor
        function obj = main_map()
            obj.name = 'map';
            
            obj.main_timebar = main_timebar();
            obj.main_avatar = main_avatar();
            obj.target_mainstation = 0;
            obj.main_stations = [];
            obj.main_sublines = [];
            
            obj.options_mainstation = [];
            obj.options_mainsubline = [];
            
            obj.ring_stations = [];
            
            obj.draw_optionsize = 25;
            obj.draw_optiontransparency = .85;
        end
        
        % structure design ------------------------------------------------
        % add a station
        function obj = add_mainstation(obj,main_station)
            obj.main_stations = [obj.main_stations main_station];
        end
        % create a new station
        function obj = create_mainstation(obj)
            obj.main_stations = [obj.main_stations main_station()];
        end
        % add a subline
        function obj = add_mainsubline(obj,main_subline)
            obj.main_sublines = [obj.main_sublines main_subline];
        end
        % create a new subline
        function obj = create_mainsubline(obj)
            obj.main_sublines = [obj.main_sublines main_subline()];
        end
        % duplication (a copy of the object, not the pointer)
        function new_obj = duplicate(obj)
            new_obj = main_map();
            new_obj.name = obj.name;
            if ~isempty(obj.main_avatar)
                new_obj.main_avatar = copy(obj.main_avatar);
            end
            new_obj.target_mainstation = obj.target_mainstation;
            if ~isempty(obj.main_stations)
                new_obj.main_stations = copy(obj.main_stations);
            end
            if ~isempty(obj.main_sublines)
                new_obj.main_sublines = copy(obj.main_sublines);
            end
            new_obj.options_mainstation = obj.options_mainstation;
            new_obj.options_mainsubline = obj.options_mainsubline;
            new_obj.draw_optionsize = obj.draw_optionsize;
            new_obj.draw_optiontransparency = obj.draw_optiontransparency;
        end
        function obj = link_stations(obj)
            nb_stations = length(obj.main_stations);
            nb_sublines = length(obj.main_sublines);
            for i_station = 1:nb_stations
                obj.main_stations(i_station).main_sublines = [];
                for i_subline = 1:nb_sublines
                    if ismember(i_station,obj.main_sublines(i_subline).main_stations)
                        obj.main_station(i_station).main_sublines(end+1) = i_subline;
                    end
                end
            end
        end
        % is the map coherent? take care with the subline/station redundance!
        function ok = coherent(obj)
            ok = 1;
            if length(obj.main_stations) < 2
                fprintf('map: coherent: error. not enough stations\n');
                ok = 0;
            end
            if length(obj.main_sublines) < 1
                fprintf('map: coherent: error. not enough sublines\n');
                ok = 0;
            end
            % stations : sublines include them?
            for i_station = 1 : length(obj.main_stations)        % a station
                main_station = obj.main_stations(i_station);
                for i_subline = main_station.main_sublines            % one of the sublines associated
                    if i_subline > length(obj.main_sublines)
                        fprintf(['map: coherent: error. station ',num2str(i_station),' ''',main_station.name,''' : subline ',num2str(i_subline),' doesn''t exist\n']);
                        ok = 0;
                    else
                        main_subline = obj.main_sublines(i_subline);
                        if ~any(main_subline.main_stations == i_station)  % has this station?
                            fprintf(['map: coherent: error. station ',num2str(i_station),' ''',main_station.name,''' : not included in subline ',num2str(i_subline),' ''',main_subline.name,''' \n']);
                            ok = 0;
                        end
                    end
                end
            end
            % sublines : stations include them?
            for i_subline = 1:length(obj.main_sublines)          % a subline
                main_subline = obj.main_sublines(i_subline);
                for i_station = main_subline.main_stations            % one of the stations associated
                    if i_station > length(obj.main_stations)
                        fprintf(['map: coherent: error. subline ',num2str(i_subline),' ''',main_subline.name,''' : station ',num2str(i_station),' doesn''t exist\n']);
                        ok = 0;
                    else
                        main_station = obj.main_stations(i_station);
                        if ~any(main_station.main_sublines == i_subline)  % has this subline?
                            fprintf(['map: coherent: error. subline ',num2str(i_subline),' ''',main_subline.name,''' : not included in station ',num2str(i_station),' ''',main_station.name,''' \n']);
                            ok = 0;
                        end
                    end
                end
            end
            % sublines : are coherent?
            for i_subline = 1:length(obj.main_sublines) 
                main_subline = obj.main_sublines(i_subline);
                if ~main_subline.coherent()
                    fprintf(['map: coherent: error. subline ',num2str(i_subline),' ''',main_subline.name,''' : is not coherent\n']);
                    ok = 0;
                end
            end
        end
        
        % draw ------------------------------------------------------------
        % resize the map to the rectangle dimensions
        function obj = resize_map(obj, keep_proportions, rectangle,timebar_rect)
            % calculate the transformation (ie. translation, scale vectors)
            station_positions = zeros(length(obj.main_stations),2);
            for i_station = 1:length(obj.main_stations)
                station_positions(i_station,:) = obj.main_stations(i_station).draw_position;
            end
            old_rect = [min(station_positions) max(station_positions)];
            old_center = .5*(old_rect(1:2)+old_rect(3:4));
            clear station_positions;
            scale = (rectangle(3:4)-rectangle(1:2))./(old_rect(3:4)-old_rect(1:2));
            if keep_proportions
                min_scale = min(scale);
                scale = [min_scale min_scale];
            end
            translation = .5*(rectangle(1:2)+rectangle(3:4))-.5*(old_rect(1:2)+old_rect(3:4));
            % center and scale
            for i_station = 1:length(obj.main_stations)
                position = obj.main_stations(i_station).draw_position;
                position = old_center + scale.*(position-old_center); % scale
                position = position + translation;                    % translate
                obj.main_stations(i_station).draw_position = position;
            end
            % rescale timebar
            if exist('timebar_rect','var')
                obj.main_timebar.draw_rectangle = timebar_rect;
            end
        end
        % draw the map
        function obj = draw_map(obj,screen_window, screen_rect)
            for i_subline = 1:length(obj.main_sublines)
                obj.main_sublines(i_subline).draw(screen_window, screen_rect, obj.main_stations);
            end
            for i_station = 1:length(obj.main_stations)
                obj.main_stations(i_station).draw(screen_window, screen_rect,i_station==obj.target_mainstation,obj.main_sublines);
            end
        end
        % draw the possible options
        function obj = draw_options(obj,screen_window,screen_rect)
            % for each station
            minsize = min(RectSize(screen_rect));
            for i_option = 1:length(obj.options_mainstation)
                obj.main_stations(obj.options_mainstation(i_option)).draw_option(screen_window,minsize);
            end
        end
        % draw the topology number
        function obj = draw_topology(obj,screen_window,screen_rect)
            DrawFormattedText(screen_window,num2str(obj.topology),mean(screen_rect([1,3])),mean(screen_rect([2,4])));
        end
        
        % initial conditions ----------------------------------------------
        % set the avatar station/subline and the target station
        function obj = set_avatartarget(obj,in_mainstation,in_mainsubline,target_mainstation)
            % random in_mainstation and in_mainsubline
            if ~exist('in_mainstation','var') || ~exist('in_mainsubline','var')
                in_mainstation = randi(length(obj.main_stations));
                station_sublines = obj.main_stations(in_mainstation).main_sublines;
                in_mainsubline = station_sublines(randi(length(station_sublines)));
            end
            % set avatar station and subline
            obj.main_avatar.in_mainstation = in_mainstation;
            obj.main_avatar.in_mainsubline = in_mainsubline;
            % check coherent in_mainstation and in_mainavatar
            if ~obj.main_avatar.coherent(obj.main_stations,obj.main_sublines)
                error('main_map: set_avatartarget: avatar not coherent\n');
            end
            % set target station
            if ~exist('target_mainstation','var')
                obj.target_mainstation = randi(length(obj.main_stations));
                while obj.target_mainstation == obj.main_avatar.in_mainstation
                    obj.target_mainstation = randi(length(obj.main_stations));
                end
            else
                obj.target_mainstation = target_mainstation;
            end
        end

        % simulation ------------------------------------------------------
        % time spent in a decision
        function travel_time = option_time(obj,average,choosed_mainsubline)
            travel_time = obj.main_sublines(choosed_mainsubline).get_traveltime(average,obj.main_avatar.in_mainstation);
        end
        % has the subject reached the target?
        function ret = subject_in_target(obj)
            if obj.main_avatar.in_mainstation == obj.target_mainstation
                ret = 1;
            else
                ret = 0;
            end
        end
        % build an array with mean timing of each subline
        function mainsublines_timings = build_mainsublinetimings(obj)
            mainsublines_timings = zeros(1,length(obj.main_sublines));
            for i_mainsubline = 1:length(obj.main_sublines)
                mainsublines_timings(i_mainsubline) = obj.main_sublines(i_mainsubline).travel_meantime(1);
            end 
        end
        % find shortest pathway from the avatar to the target (uses the main map)
        function [choosed_mainstations, choosed_mainsublines, time_cost] = find_pathway(obj)
            % build an array with mean timing of each subline
            mainsublines_timings = obj.build_mainsublinetimings();
            % run the dijkstra algorithm
            [choosed_mainstations, choosed_mainsublines, time_cost] = main_dijkstra(obj.main_stations,obj.main_sublines,mainsublines_timings,obj.main_avatar.in_mainstation,obj.main_avatar.in_mainsubline,obj.target_mainstation);
        end
        % set main stations as options
        function obj = set_options(obj)
            % ADD OPTIONS
            obj.options_mainstation = [];
            obj.options_mainsubline = [];
            % for each subline
            for i_subline = obj.main_stations(obj.main_avatar.in_mainstation).main_sublines;
                i_station = find(obj.main_avatar.in_mainstation == obj.main_sublines(i_subline).main_stations);
                % if not the last station
                if i_station < length(obj.main_sublines(i_subline).main_stations)
                    % find all next stations
                    i_target = find(obj.target_mainstation==obj.main_sublines(i_subline).main_stations);
                    if i_target > i_station
                        next_stations = obj.main_sublines(i_subline).main_stations(i_station+1:i_target);
                    else
                        next_stations = obj.main_sublines(i_subline).main_stations(i_station+1:end);
                    end
                    next_sublines = i_subline + zeros(1,length(next_stations));
                    % options
                    obj.options_mainstation = [obj.options_mainstation next_stations];
                    obj.options_mainsubline = [obj.options_mainsubline next_sublines];
                end
            end
            obj.set_drawoptions();
        end
        % set color and angle in mainstation options
        function obj = set_drawoptions(obj)
            % SET OPTIONS COLOR AND ANGLE
            % for each station
            for i_option = 1:length(obj.options_mainstation)
                option_mainstation = obj.options_mainstation(i_option);
                % if the station wasnt treated before
                if i_option==1 || ~any(option_mainstation==(obj.options_mainstation(1:i_option-1)))
                    option_sublines = [];
                    option_angles = [];
                    option_colors = [];
                    % for each subline
                    for option_mainsubline = obj.options_mainsubline(option_mainstation==obj.options_mainstation)
                        % option subline
                        option_sublines = [option_sublines option_mainsubline];
                        % option color
                        subline_color = obj.main_sublines(option_mainsubline).draw_color;
                        option_color = obj.draw_optiontransparency*mean(subline_color) + (1-obj.draw_optiontransparency)*subline_color;
                        option_color = option_color + obj.draw_optiontransparency*(255-max(option_color));
                        option_colors = [option_colors ; option_color];
                        % option angle
                        position_thisstation = obj.main_stations(option_mainstation).draw_position;
                        option_sublinestations = obj.main_sublines(option_mainsubline).main_stations;
                        i_laststation = option_sublinestations(find(option_sublinestations==option_mainstation)-1);
                        position_laststation = obj.main_stations(i_laststation).draw_position;
                        option_angle = atan((position_laststation(2)-position_thisstation(2))/(position_laststation(1)-position_thisstation(1)));
                        if position_laststation(1)-position_thisstation(1) < 0
                            option_angle = option_angle + pi;
                        end
                        option_angles = [option_angles option_angle];
                    end
                    obj.main_stations(obj.options_mainstation(i_option)).set_option(option_sublines,option_colors,option_angles);
                end
            end
        end
        
        % files -----------------------------------------------------------
        % save the map into a file
        function obj = save(obj,filepath)
            save(filepath,'obj');
        end
    end
    methods(Static)
        % load the map from a file
        function obj = load(filepath)
            load(filepath,'obj');
        end
    end
end

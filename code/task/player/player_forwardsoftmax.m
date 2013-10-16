classdef player_forwardsoftmax < handle
    % class controlling the random-not-going-backwards player

    properties
        % player
        model
        % map functions
        temperature % softmax
        connected   % station transition sublines
        timings     % subline timings
        target_mainstation
    end
    
    methods
        % constructor
        function obj = player_forwardsoftmax()
            obj.model = 'randforward';
            obj.temperature = 3;
            obj.connected = [];
            obj.timings = [];
            obj.target_mainstation = 0;
        end
        
        % map functions ===================================================
        % recursive function for clicking_do
        function [c_choosedmainstations, c_choosedmainsublines,v_choosedtimings,v_nbsteps] = get_subpaths(obj,choosed_mainstations,choosed_mainsublines,choosed_timing,nb_steps)
            % set where we are
            in_mainstation = choosed_mainstations(end);
            % look where we can go from there
            to_mainsublines = obj.connected(in_mainstation,:);
            to_mainstations = find(to_mainsublines);
            to_mainsublines(~to_mainsublines) = [];
            % remove the ones we've already visited
            new_tomainstations = [];
            new_tomainsublines = [];
            for i_tomainstations = 1:length(to_mainstations)
                if ~ismember(to_mainstations(i_tomainstations),choosed_mainstations)
                    new_tomainstations(end+1) = to_mainstations(i_tomainstations);
                    new_tomainsublines(end+1) = to_mainsublines(i_tomainstations);
                end
            end
            to_mainstations = new_tomainstations;
            to_mainsublines = new_tomainsublines;
            clear new_tomainstations;
            clear new_tomainsublines;
            % look for new paths taking that station
            c_choosedmainstations = {};
            c_choosedmainsublines = {};
            v_choosedtimings      = [];
            v_nbsteps             = [];
            for i_tomainstations = 1:length(to_mainstations)
                % create new step variables
                nv_choosedmainstations = [choosed_mainstations,to_mainstations(i_tomainstations)];
                nv_choosedmainsublines = [choosed_mainsublines,to_mainsublines(i_tomainstations)];
                n_choosedtimings       = choosed_timing + obj.timings(to_mainsublines(i_tomainstations));
                n_nbsteps              = nb_steps + 1;
                % target station (add)
                if to_mainstations(i_tomainstations)==obj.target_mainstation
                    c_choosedmainstations{end+1} = nv_choosedmainstations;
                    c_choosedmainsublines{end+1} = nv_choosedmainsublines;
                    v_choosedtimings(end+1)      = n_choosedtimings;
                    v_nbsteps                    = n_nbsteps;
                % next step (run recursively)
                else
                    [nc_choosedmainstations, nc_choosedmainsublines,nv_choosedtimings,nv_nbsteps] = obj.get_subpaths(nv_choosedmainstations,nv_choosedmainsublines,n_choosedtimings,n_nbsteps);
                    c_choosedmainstations = {c_choosedmainstations{:},nc_choosedmainstations{:}};
                    c_choosedmainsublines = {c_choosedmainsublines{:},nc_choosedmainsublines{:}};
                    v_choosedtimings      = [v_choosedtimings,nv_choosedtimings];
                    v_nbsteps             = [v_nbsteps,nv_nbsteps];
                end
            end
        end
        
        % get all possible paths from A to B that don't take twice the same station
        function [c_choosedmainstations, c_choosedmainsublines, v_choosedtimings] = get_paths(obj,main_map)
            % build an array with mean timing of each subline
            obj.timings = main_map.build_mainsublinetimings();
            
            % build a matrix of transitions
            nb_stations = length(main_map.main_stations);
            nb_sublines = length(main_map.main_sublines);
            obj.connected = zeros(nb_stations,nb_stations);
            for i_mainsubline = 1:nb_sublines
                for i_mainstation = 2:length(main_map.main_sublines(i_mainsubline).main_stations)
                    ms1 = main_map.main_sublines(i_mainsubline).main_stations(i_mainstation-1);
                    ms2 = main_map.main_sublines(i_mainsubline).main_stations(i_mainstation);
                    obj.connected(ms1,ms2) = i_mainsubline;
                end
            end
            
            % set avatar/flag
            in_mainstation = main_map.main_avatar.in_mainstation;
            obj.target_mainstation = main_map.target_mainstation;
            
            % build all possible paths
            [c_choosedmainstations, c_choosedmainsublines,v_choosedtimings] = obj.get_subpaths(in_mainstation,[],0,0);
            
            % sort paths (best to worst)
            [v_choosedtimings,i_paths] = sort(v_choosedtimings,'ascend');
            c_choosedmainstations = c_choosedmainstations(i_paths);
            c_choosedmainsublines = c_choosedmainsublines(i_paths);
        end
        
        % experiment functions ============================================
        % experiment ------------------------------------------------------
        % setup the interface with the new experiment
        function [age,name,sex,handed] = experiment_start(~,~,~,~,~,~)
            age = '0';
            name = 'randforward_player';
            sex = 'n';
            handed = 'n';
        end
        % conclude the interface for the experiment
        function obj = experiment_stop(obj,~)
        end
        
        % map -------------------------------------------------------------
        % setup the interface with new map loaded
        function obj = map_start(obj,~,~)
        end
        % conclude the interface for the map
        function obj = map_stop(obj,~,~)
        end
        
        % trial ----------------------------------------------------------
        % setup the interface for the new trial
        function obj = trial_start(obj,~,~,~,~,~)
        end
        % conclude the interface for the trial
        function obj = trial_stop(obj,~,~)
        end
        
        % planning --------------------------------------------------------
        function obj = planning_start(obj,~)
        end
        
        function obj = planning_do(obj,~,~)
        end
        
        function obj = planning_stop(obj,~)
        end
        
        % clicking --------------------------------------------------------
        function obj = clicking_start(obj,~)
        end
        
        function [choosed_mainstations, choosed_mainsublines] = clicking_do(obj,main_map,~)
            % get paths
            [c_choosedmainstations, c_choosedmainsublines, v_choosedtimings] = obj.get_paths(main_map);
            % pick up one (with a softmax rule)
            i_path = tools_softmax(v_choosedtimings,obj.temperature);
            choosed_mainstations = c_choosedmainstations{i_path}(2:end);
            choosed_mainsublines = c_choosedmainsublines{i_path};
            
        end
        
        function obj = clicking_stop(obj,~)
        end
        
        % moving ----------------------------------------------------------
        function obj = moving_start(obj,~)
        end
        function obj = moving_stop(obj,~)
        end
        
        % travel ----------------------------------------------------------
        % process your traveling times
        function obj = travel_process(obj,~,~)
        end
        
        % quest -----------------------------------------------------------
        % give an estimation of the lines
        function quest = lines_quest(~,main_map,~)
            % get speed of lines
            speed_lines = zeros(1,length(main_map.main_sublines));
            for i_subline = 1:length(main_map.main_sublines)
                speed_lines(i_subline) = main_map.main_sublines(i_subline).travel_meantime(1);
            end
            % take both ways as one
            speed_lines1 = speed_lines(1:2:end);
            speed_lines2 = speed_lines(2:2:end);
            speed_lines = .5*(speed_lines1+speed_lines2);
            nb_lines = length(speed_lines);
            % asign a value to each line
            [~,ii_speedlines] = sort(speed_lines,'ascend');
            speed_lines(ii_speedlines) = 1:nb_lines;
            % return
            quest = speed_lines;
        end
    end
end

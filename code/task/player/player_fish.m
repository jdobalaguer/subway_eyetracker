classdef player_diem < handle
    % class controlling the ideal observer player (without exploring)

    properties
        % player
        model
        % estimation
        subline_known
        subline_totaltiming
        subline_mintiming
        subline_maxtiming
        subline_meantiming
    end
    
    methods
        % constructor
        function obj = player_diem()
            obj.model = 'diem';
            obj.subline_known = [];
            obj.subline_totaltiming = [];
            obj.subline_mintiming = [];
            obj.subline_maxtiming = [];
            obj.subline_meantiming = []; % updated from the other results
        end
        
        % estimation ======================================================
        % update subline_meantiming
        function obj = update_sublinemeantiming(obj)
            % mean of means
            max_timing = obj.subline_totaltiming(2);
            min_timing = obj.subline_totaltiming(1);
            mean_timing = .5*(min_timing+max_timing);
            % build an array with mean timing of each subline
            obj.subline_meantiming = zeros(1,length(obj.subline_known));
            for i_mainsubline = 1:length(obj.subline_known)
                % we have an estimation of this line
                if obj.subline_known(i_mainsubline)
                    obj.subline_meantiming (i_mainsubline) = .5*(obj.subline_mintiming(i_mainsubline)+obj.subline_maxtiming(i_mainsubline));
                % if we don't have one we take the mean of the known
                else
                    obj.subline_meantiming (i_mainsubline) = mean_timing;
                end
            end
            
        end
        % find shortest pathway from the avatar to the target (uses the main map)
        function [choosed_mainstations, choosed_mainsublines, time_cost] = find_pathway(obj,main_map,in_mainstation,in_mainsubline)
            % run the dijkstra algorithm
            [choosed_mainstations, choosed_mainsublines, time_cost] = main_dijkstra(main_map.main_stations,main_map.main_sublines,obj.subline_meantiming,in_mainstation,in_mainsubline,main_map.target_mainstation);
        end
        
        % experiment functions ============================================
        % experiment ------------------------------------------------------
        % setup the interface with the new experiment
        function [age,name,sex,handed] = experiment_start(~,~,~,~,~,~)
            age = '0';
            name = 'diem_player';
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
        function obj = trial_start(obj,main_map,~,~,~,~)
            nb_sublines = length(main_map.main_sublines);
            % set new estimation map
            obj.subline_known = zeros(1,nb_sublines);
            obj.subline_mintiming = zeros(1,nb_sublines);
            obj.subline_maxtiming = zeros(1,nb_sublines);
            obj.subline_meantiming = ones(1,nb_sublines);
        end
        % conclude the interface for the trial
        function obj = trial_stop(obj,main_map,~)
            mainsublines_timings = main_map.build_mainsublinetimings();
            fprintf(['error = ',num2str(mean(abs((obj.subline_meantiming - mainsublines_timings) ./ mainsublines_timings))),'\n']);
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
            [choosed_mainstations, choosed_mainsublines, ~] = obj.find_pathway(main_map,main_map.main_avatar.in_mainstation,main_map.main_avatar.in_mainsubline);
            choosed_mainstations(1) = [];
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
        function obj = travel_process(obj,travel_time,in_subline)
            % find the subline going the opposite direction
            if mod(in_subline,2)
                reverse_subline = in_subline + 1;
            else
                reverse_subline = in_subline - 1;
            end
            % update the estimation of the line speed
            if ~obj.subline_known(in_subline)
                % known
                obj.subline_known(in_subline) = 1;
                obj.subline_known(reverse_subline) = 1;
                % min
                obj.subline_mintiming(in_subline) = travel_time;
                obj.subline_mintiming(reverse_subline) = travel_time;
                % max
                obj.subline_maxtiming(in_subline) = travel_time;
                obj.subline_maxtiming(reverse_subline) = travel_time;
            else
                % min
                if obj.subline_mintiming(in_subline) > travel_time
                    obj.subline_mintiming(in_subline) = travel_time;
                    obj.subline_mintiming(reverse_subline) = travel_time;
                end
                % max
                if obj.subline_maxtiming(in_subline) < travel_time
                    obj.subline_maxtiming(in_subline) = travel_time;
                    obj.subline_maxtiming(reverse_subline) = travel_time;
                end
            end
            
            % update the estimation of the max line speed across maps
            if isempty(obj.subline_totaltiming)
                    obj.subline_totaltiming = [travel_time travel_time];
            else
                % min
                if travel_time < obj.subline_totaltiming(1)
                    obj.subline_totaltiming(1) = travel_time;
                end
                % max
                if travel_time > obj.subline_totaltiming(2)
                    obj.subline_totaltiming(2) = travel_time;
                end
            end
            
            obj.update_sublinemeantiming();
        end
        
        % quest -----------------------------------------------------------
        % give an estimation of the lines
        function quest = lines_quest(obj,~,~)
            speed_lines = obj.subline_meantiming;
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

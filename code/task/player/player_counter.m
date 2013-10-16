classdef player_counter< handle
    % class controlling the player based on distance

    properties
        % player
        model
        % estimator
        subline_time
    end
    
    methods
        % constructor
        function obj = player_counter()
            obj.model = 'counter';
            obj.subline_time = [];
        end
        
        % estimation ======================================================
        % find shortest pathway from the avatar to the target (uses the main map)
        function [choosed_mainstations, choosed_mainsublines, time_cost] = find_pathway(obj,main_map)
            % run the dijkstra algorithm
            [choosed_mainstations, choosed_mainsublines, time_cost] = main_dijkstra(main_map.main_stations,main_map.main_sublines,obj.subline_time,main_map.main_avatar.in_mainstation,main_map.main_avatar.in_mainsubline,main_map.target_mainstation);
        end

        
        % experiment functions ============================================
        % experiment ------------------------------------------------------
        % setup the interface with the new experiment
        function [age,name,sex,handed] = experiment_start(~,~,~,~,~,~)
            age = '0';
            name = 'counter_player';
            sex = 'n';
            handed = 'n';
        end
        % conclude the interface for the experiment
        function obj = experiment_stop(obj,~)
        end
        
        % map -------------------------------------------------------------
        % setup the interface with new map loaded
        function obj = map_start(obj,main_map,~)
            obj.subline_time = ones(1,length(main_map.main_sublines));
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
            [choosed_mainstations, choosed_mainsublines, ~] = obj.find_pathway(main_map);
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
        function obj = travel_process(obj,~,~)
        end
        
        % quest -----------------------------------------------------------
        % give an estimation of the lines
        function quest = lines_quest(~,main_map,~)
            % return
            quest = ones(1,length(main_map.main_sublines)/2);
        end
    end
end

classdef player_god < handle
    % class controlling the god player

    properties
        % player
        model
    end
    
    methods
        % constructor
        function obj = player_god()
            obj.model = 'god';
        end
        
        % experiment functions ============================================
        % experiment ------------------------------------------------------
        % setup the interface with the new experiment
        function [age,name,sex,handed] = experiment_start(~,~,~,~,~,~)
            age = '0';
            name = 'god_player';
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
        
        function [choosed_mainstations, choosed_mainsublines] = clicking_do(~,main_map,~)
            [choosed_mainstations, choosed_mainsublines, ~] = main_map.find_pathway();
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

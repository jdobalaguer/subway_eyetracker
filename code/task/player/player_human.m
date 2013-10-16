classdef player_human < handle
    % class controlling the human player
    
    properties
        % player
        model
        % time
        planning_time
        planning_maxtime
        decision_time
        decision_maxtime
        clicking_time
        clicking_maxtime
    end
    
    methods
        % constructor
        function obj = player_human()
            obj.model = 'human';
            obj.planning_time = [];
            obj.planning_maxtime = 4;
            obj.clicking_time = [];
            obj.clicking_maxtime = 10;
            obj.decision_time = [];
            obj.decision_maxtime = 10;
        end
        
        % screen methods ==================================================
        % subject identification screen
        function [age,name,sex,handed] = screen_identification(obj,monitor,run_trainmaps)
            name = monitor.screen_interaction(0,1,'Name?');
            age = monitor.screen_interaction(1,0,'Age?');
            sex = monitor.screen_interaction(0,1,'Sex? (m/f)');
            handed = monitor.screen_interaction(0,1,'Handedness? (l/r)');
        end
        % instructions screen
        function obj = screen_instructions(obj,monitor,run_maps,run_trainmaps,run_trials)
            nx = 150;
            ny = 150;
            monitor.screen_text(0,0,{'Hello! Welcome to the experiment.'});
            monitor.screen_text(nx,ny,{ ...
                'In this experiment, you will have to navigate through a subway network' ...
                'to find your way to a destination station.' ...
                'On your way, there will be several points at which you can choose which line to take.' ...
                'Each line is different. Some lines are faster than others.' ...
                'Your task is to FINISH THE EXPERIMENT AS SOON AS POSSIBLE.' ...
                'To do this, you will need to find which lines will get you to your destination in the least time.' ...
                'We want you to complete all the journeys in the shortest amount of time.' ...
                });
            monitor.screen_text(nx,ny,{ ...
                ['You will have to learn about ',num2str(run_maps),' different maps.'] ...
                ['In the first ',num2str(run_trainmaps),' of them you will can train yourself.'] ...
                ['You will have ',num2str(run_trials),' consecutive journeys to learn about the different lines for each map.'] ...
                ['After these ',num2str(run_trials),' journeys, the whole map will change, including the speed of the lines.'] ...
                'This means you will need to learn about the lines all over again!' ...
                ' ' ...
                'If you spend too much time for a particular journey' ...
                'the journey will be canceled and you will start directly from the next one.' ...
                });
            monitor.screen_text(nx,ny,{ ...
                'Your position will be represented as a blinking circle.' ...
                'An arrow will show the direction of the subway line in which you are.' ...
                'The destination station will appear as a flag.' ...
                'To move along a line, use the mouse to click on the grey circles that will appear.' ...
                'You can only move to these points.' ...
                });
            monitor.screen_text(0,0,{ ...
                'Good luck!'
                });
        end
        % say thanks
        function obj = screen_thanks(obj,monitor)
            monitor.screen_text(0,0,{'Thank you for your participation!'});
        end
        
        % option methods ==================================================
        % translate the key_code to an option
        function [choosed_mainstation, choosed_mainsubline] = option_get(~,main_map,screen_rect,mouse_pos,allow_center)
            choosed_mainstation = 0;
            choosed_mainsubline = 0;
            minsize = min(RectSize(screen_rect));
            i = 1;
            while i <= length(main_map.options_mainstation)
                i_station = main_map.options_mainstation(i);
                %mouse_dist = dist(mouse_pos,main_map.main_stations(i_station).draw_position');
                mouse_dist = sqrt(sum(power(mouse_pos-main_map.main_stations(i_station).draw_position,2)));
                if  mouse_dist < main_map.main_stations(i_station).draw_optionradius*minsize
                    if length(main_map.main_stations(i_station).option_angles)==1 || allow_center || mouse_dist > main_map.main_stations(i_station).draw_outcrossradius*minsize
                        choosed_mainstation = main_map.options_mainstation(i);
                        choosed_mainsubline = main_map.main_stations(choosed_mainstation).select_option(mouse_pos);
                        break
                    end
                end
                i = i+1;
            end
        end
        
        % experiment functions ============================================
        % experiment ------------------------------------------------------
        % setup the interface with the new experiment
        function [age,name,sex,handed] = experiment_start(obj,monitor,run_maps,run_trainmaps,run_trials,~)
            % subject identification
            [age,name,sex,handed] = obj.screen_identification(monitor,run_trainmaps);
            % instructions
            obj.screen_instructions(monitor,run_maps,run_trainmaps,run_trials);
            % eyelink
            monitor.eyelink_start();
        end
        % conclude the interface for the experiment
        function obj = experiment_stop(obj,monitor)
            % say thanks
            obj.screen_thanks(monitor);
            % eyelink
            monitor.eyelink_stop();
            monitor.eyelink_file();
        end
        
        % map -------------------------------------------------------------
        % setup the interface with new map loaded
        function obj = map_start(obj,main_map,monitor)
            % eyelink
            monitor.map_eyelinkcheck(main_map);
            monitor.eyelink_msg('map start');
        end
        % conclude the interface for the map
        function obj = map_stop(obj,~,monitor)
            % eyelink
            monitor.eyelink_msg('map stop');
        end
        
        % quest -----------------------------------------------------------
        % give an estimation of the lines
        function quest = lines_quest(obj,main_map,monitor)
            % eyelink
            monitor.eyelink_msg('quest start');
            
            % variables
            max_quest = 4;
            quest = ones(1,length(main_map.main_sublines)/2);
            colors = zeros(.5*length(main_map.main_sublines),3);
            for i_mainsublines = 2:2:length(main_map.main_sublines)
                colors(.5*i_mainsublines,:) = main_map.main_sublines(i_mainsublines).draw_color;
            end
            
            % set all main stations as options
            main_map.options_mainstation = [];
            main_map.options_mainsubline = [];
            for i_mainsubline = 1:length(main_map.main_sublines)
                for i_mainstation = 2:length(main_map.main_sublines(i_mainsubline).main_stations)
                    main_map.options_mainstation(end+1) = main_map.main_sublines(i_mainsubline).main_stations(i_mainstation);
                    main_map.options_mainsubline(end+1) = i_mainsubline;
                end
            end
            main_map.set_drawoptions();
            
            % update colors
            for i_mainsublines = 1:length(main_map.main_sublines)
                i_quest = ceil(.5*i_mainsublines);
                main_map.main_sublines(i_mainsublines).draw_color = colors(i_quest,:)*quest(i_quest)/max_quest;
            end
            
            % quest screen
            out = 0;
            while ~out
                [key_code,mouse_pos,mouse_buttons] = monitor.keymouse_read();
                % out
                if any(find(key_code)==monitor.kb_return)
                    out = 1;
                end
                % draw
                monitor.map_optionsdraw(main_map);
                % change speeds
                if any(mouse_buttons([1,3]))
                    % select subline
                    [~,choosed_mainsubline] = obj.option_get(main_map,monitor.screen_rect,mouse_pos,1);
                    % if a subline is selected
                    if choosed_mainsubline
                        i_quest = ceil(.5*choosed_mainsubline);
                        % apply action
                        if mouse_buttons(1) && quest(i_quest)<max_quest
                            quest(i_quest) = quest(i_quest) + 1;
                        elseif mouse_buttons(3) && quest(i_quest)>1
                            quest(i_quest) = quest(i_quest) - 1;
                        end
                        % update colors
                        main_map.main_sublines(2*i_quest - 1).draw_color = colors(i_quest,:)*quest(i_quest)/max_quest;
                        main_map.main_sublines(2*i_quest    ).draw_color = colors(i_quest,:)*quest(i_quest)/max_quest;
                        
                        % release keymouse
                        while any(mouse_buttons)
                            [~,~,mouse_buttons] = monitor.keymouse_read();
                        end
                    end
                end
            end
            
            % eyelink
            monitor.eyelink_msg('quest stop');
        end
        
        % trial -----------------------------------------------------------
        % setup the interface for the new trial
        function obj = trial_start(obj,main_map,monitor,i_map,run_map,run_trial)
            % don't start until mouse is released
            mouse_buttons = 1;
            while mouse_buttons(1)
                [~,~,mouse_buttons] = monitor.keymouse_read();
            end
            % eyelink
            monitor.eyelink_msg('trial start');
        end
        % conclude the interface for the trial
        function obj = trial_stop(obj,~,monitor)
            % eyelink
            monitor.eyelink_msg('trial stop');
        end
        
        % planning --------------------------------------------------------
        function obj = planning_start(obj,monitor)
            % mouse
            HideCursor();
            % eyelink
            monitor.eyelink_msg('planning start');
        end
        function obj = planning_do(obj,main_map,monitor)
            monitor.map_timedraw(main_map,'planning');
            % wait for a planning_time seconds
            obj.planning_time = GetSecs;
            while (GetSecs()-obj.planning_time)<obj.planning_maxtime
                monitor.map_timedraw(main_map,'planning');
            end
        end
        function obj = planning_stop(obj,monitor)
            % mouse
            ShowCursor();
            % eyelink
            monitor.eyelink_msg('planning stop');
        end
        
        % clicking --------------------------------------------------------
        function obj = clicking_start(obj,monitor)
            % eyelink
            monitor.eyelink_msg('clicking start');
            % time limit
            obj.clicking_time = GetSecs();
        end
        function [choosed_mainstations, choosed_mainsublines] = clicking_do(obj,main_map,monitor)
            choosed_mainstations = [];
            choosed_mainsublines = [];
            while ~main_map.subject_in_target()
                % draw
                main_map.set_options();
                main_map.main_avatar.set_draw(main_map.main_stations,main_map.main_sublines);
                % decision start
                obj.decision_start(main_map,monitor);
                % decision do
                [choosed_mainstation,choosed_mainsubline] = obj.decision_do(main_map,monitor);
                % time limit
                if (GetSecs()-obj.clicking_time) > obj.clicking_maxtime
                    monitor.screen_noclicking();
                    choosed_mainstations = [];
                    choosed_mainsublines = [];
                    break
                end
                % check decision
                find_eqstations = find(choosed_mainstation==main_map.options_mainstation);
                find_eqsublines = find(choosed_mainsubline==main_map.options_mainsubline);
                if any(ismember(find_eqstations,find_eqsublines))
                    choosed_mainstations(end+1) = choosed_mainstation;
                    choosed_mainsublines(end+1) = choosed_mainsubline;
                end
                % decision stop
                obj.decision_stop(main_map,monitor);
                % set avatar (and keep target station in same place)
                main_map.set_avatartarget(choosed_mainstation,choosed_mainsubline,main_map.target_mainstation);
            end
        end
        function obj = clicking_stop(obj,monitor)
            % eyelink
            monitor.eyelink_msg('clicking stop');
        end
        % decision --------------------------------------------------------
        function obj = decision_start(obj,main_map,monitor)
            % eyelink
            monitor.eyelink_msg(['decision start ',num2str(main_map.main_avatar.in_mainstation)]);
        end
        function [choosed_mainstation, choosed_mainsubline] = decision_do(obj, main_map, monitor)
            % decision loop
            not_end = 1;
            while not_end
                % screen refresh
                monitor.map_timeoptionsdraw(main_map,'clicking');
                %read keyboard and mouse state
                [~,mouse_pos,mouse_buttons] = monitor.keymouse_read();
                % set the option
                if mouse_buttons(1)
                    % translate the key_code to an option
                    [choosed_mainstation, choosed_mainsubline] = obj.option_get(main_map, monitor.screen_rect, mouse_pos,0);
                    if choosed_mainstation
                        not_end = 0;
                    end
                end
                % time end
                if (GetSecs()-obj.decision_time) > obj.decision_maxtime
                    choosed_mainstation = 0;
                    choosed_mainsubline = 0;
                    not_end = 0;
                end
            end
        end
        function obj = decision_stop(obj,main_map,monitor)
            % eyelink
            monitor.eyelink_msg(['decision stop ',num2str(main_map.main_avatar.in_mainstation)]);
        end
        % moving ----------------------------------------------------------
        function obj = moving_start(obj,monitor)
            % eyelink
            monitor.eyelink_msg('moving start');
        end
        function obj = moving_stop(obj,monitor)
            % eyelink
            monitor.eyelink_msg('moving stop');
        end
        
        % travel ----------------------------------------------------------
        % process your traveling times
        function obj = travel_process(obj,~,~)
        end
    end
end

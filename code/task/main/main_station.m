classdef main_station < matlab.mixin.Copyable % handle + copyable
    % class controlling a station
    
    properties
        % general
        name
        main_sublines
        % draw
        draw_position
        draw_targetradius    % target station
        draw_targetcolor1
        draw_targetcolor2
        draw_outcrossradius     % cross stations
        draw_incrossradius
        draw_outcrosscolor
        draw_incrosscolor
        draw_defaultradius      % default stations
        draw_optionradius       % option disk
        % options
        option_sublines
        option_colors
        option_angles
        
    end
    
    methods
        %constructor
        function obj = main_station()
            obj.name = 'station';
            obj.draw_position = [0 0];
            obj.main_sublines = [];
            
            obj.draw_targetradius = 0.02;
            obj.draw_targetcolor1 = [200 200 200];
            obj.draw_targetcolor2 = [100 100 100];
            
            obj.draw_outcrossradius = 0.015;
            obj.draw_incrossradius = 0.008;
            obj.draw_outcrosscolor = [0 0 0];
            obj.draw_incrosscolor = [255 255 255];

            obj.draw_defaultradius = 0.008;
            obj.draw_optionradius = .03;
            
            obj.option_sublines = [];
            obj.option_colors = [];
            obj.option_angles = [];
        end
        
        % structure design ------------------------------------------------
        % add a subline
        function obj = add_mainsubline(obj,new_mainsubline)
            obj.main_sublines = [obj.main_sublines new_mainsubline];
        end
        
        % draw ------------------------------------------------------------
        % draw the options on the screen
        function obj = draw_option(obj,screen_window,minsize)
            if length(obj.option_angles) == 1
                Screen('FillOval',screen_window,obj.option_colors(1,:), [obj.draw_position(1)-(obj.draw_optionradius*minsize), obj.draw_position(2)-(obj.draw_optionradius*minsize), obj.draw_position(1)+(obj.draw_optionradius*minsize), obj.draw_position(2)+(obj.draw_optionradius*minsize)]);
            else
                % the first subline
                a_angle = obj.option_angles(end-1)-360;
                b_angle = obj.option_angles(1);
                c_angle = obj.option_angles(2);
                start_angle = mean([a_angle,b_angle]);
                end_angle = mean([b_angle,c_angle]);
                Screen('FillArc',screen_window,obj.option_colors(1,:), [obj.draw_position(1)-(obj.draw_optionradius*minsize), obj.draw_position(2)-(obj.draw_optionradius*minsize), obj.draw_position(1)+(obj.draw_optionradius*minsize), obj.draw_position(2)+(obj.draw_optionradius*minsize)],start_angle,end_angle-start_angle);
                % all but the first
                for i_option = 2:length(obj.option_angles)-1
                    b_angle = obj.option_angles(i_option);
                    c_angle = obj.option_angles(i_option+1);
                    start_angle = end_angle;
                    end_angle = mean([b_angle,c_angle]);
                    Screen('FillArc',screen_window,obj.option_colors(i_option,:), [obj.draw_position(1)-(obj.draw_optionradius*minsize), obj.draw_position(2)-(obj.draw_optionradius*minsize), obj.draw_position(1)+(obj.draw_optionradius*minsize), obj.draw_position(2)+(obj.draw_optionradius*minsize)],start_angle,end_angle-start_angle);
                end
            end
        end
        % draw the station on the screen
        function obj = draw(obj,screen_window,screen_rect,is_target,sublines)
            minsize = min(RectSize(screen_rect));
            if is_target
                Screen('FillRect',screen_window,obj.draw_targetcolor1,  [obj.draw_position(1)-(obj.draw_targetradius*minsize), obj.draw_position(2)-(obj.draw_targetradius*minsize), obj.draw_position(1),                                 obj.draw_position(2)]);
                Screen('FillRect',screen_window,obj.draw_targetcolor2,  [obj.draw_position(1),                                 obj.draw_position(2)-(obj.draw_targetradius*minsize), obj.draw_position(1)+(obj.draw_targetradius*minsize), obj.draw_position(2)]);
                Screen('FillRect',screen_window,obj.draw_targetcolor2,  [obj.draw_position(1)-(obj.draw_targetradius*minsize), obj.draw_position(2),                                 obj.draw_position(1),                                 obj.draw_position(2)+(obj.draw_targetradius*minsize)]);
                Screen('FillRect',screen_window,obj.draw_targetcolor1,  [obj.draw_position(1),                                 obj.draw_position(2),                                 obj.draw_position(1)+(obj.draw_targetradius*minsize), obj.draw_position(2)+(obj.draw_targetradius*minsize)]);
            else
                if length(obj.main_sublines)>2
                    % cross
                    Screen('FillOval',screen_window,obj.draw_outcrosscolor, [obj.draw_position(1)-(obj.draw_outcrossradius*minsize), obj.draw_position(2)-(obj.draw_outcrossradius*minsize), obj.draw_position(1)+(obj.draw_outcrossradius*minsize), obj.draw_position(2)+(obj.draw_outcrossradius*minsize)]);
                    Screen('FillOval',screen_window,obj.draw_incrosscolor , [obj.draw_position(1)-(obj.draw_incrossradius*minsize),  obj.draw_position(2)-(obj.draw_incrossradius*minsize),  obj.draw_position(1)+(obj.draw_incrossradius*minsize),  obj.draw_position(2)+(obj.draw_incrossradius*minsize)]);
                else
                    % normal station
                    Screen('FillOval',screen_window,sublines(obj.main_sublines(1)).draw_color, [obj.draw_position(1)-(obj.draw_defaultradius*minsize), obj.draw_position(2)-(obj.draw_defaultradius*minsize), obj.draw_position(1)+(obj.draw_defaultradius*minsize), obj.draw_position(2)+(obj.draw_defaultradius*minsize)]);
                end
            end
        end
        
        % simulation ------------------------------------------------------
        % we add the colors and angles for the option drawing
        function obj = set_option(obj,option_sublines,option_colors,option_angles)
            if length(option_angles) == 1
                obj.option_sublines = option_sublines;
                obj.option_angles = mod(90 + 180*option_angles/pi,360);
                obj.option_colors = option_colors;
            else
                % if more than one, we sort by angles
                option_angles = mod(90 + 180*option_angles/pi,360);
                [option_angles index_sort] = sort(option_angles);
                % save the result
                obj.option_sublines = option_sublines(index_sort);
                obj.option_angles = [option_angles option_angles(1)+360];
                obj.option_colors = option_colors(index_sort,:);
            end
        end
        % select subline
        function i_subline = select_option(obj,mouse_pos)
            if length(obj.option_angles) == 1
                i_subline = obj.option_sublines;
            else
                % mouse angle
                mouse_angle = 90 + 180*atan((mouse_pos(2)-obj.draw_position(2))/(mouse_pos(1)-obj.draw_position(1)))/pi;
                if mouse_pos(1)-obj.draw_position(1) < 0
                    mouse_angle = mouse_angle + 180;
                end
                mouse_angle = mod(mouse_angle,360);
                % the first subline
                a_angle = obj.option_angles(end-1)-360;
                b_angle = obj.option_angles(1);
                c_angle = obj.option_angles(2);
                start_angle = mean([a_angle,b_angle]);
                end_angle = mean([b_angle,c_angle]);
                if mouse_angle>=start_angle+360 || mouse_angle<end_angle
                    i_subline = obj.option_sublines(1);
                else
                    % all but the first
                    for i_option = 2:length(obj.option_angles)-1
                        b_angle = obj.option_angles(i_option);
                        c_angle = obj.option_angles(i_option+1);
                        start_angle = end_angle;
                        end_angle = mean([b_angle,c_angle]);
                        if mouse_angle>=start_angle && mouse_angle<end_angle
                            i_subline = obj.option_sublines(i_option);
                            break
                        end
                    end
                end
            end
        end
    end
end

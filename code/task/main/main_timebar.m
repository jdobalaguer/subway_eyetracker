classdef main_timebar < handle
    % class controlling the virtual-time bar
    
    properties
        % general
        resetvalue
        maxvalue
        values
        colors
        % draw
        draw_rectangle
        draw_barscale
        draw_borderthick % relative value, take care.
        draw_bordercolor
        draw_halflarge
        draw_valuecolor
        draw_textcolor
        draw_spentcolor
        draw_textsize
    end
    
    methods
        % constructor
        function obj = main_timebar()
            obj.resetvalue = 0;
            obj.maxvalue = 0;
            obj.values = 0;
            obj.colors = obj.draw_valuecolor;
            
            obj.draw_rectangle = [0 0 0 0];
            obj.draw_barscale = [.5, .3];
            obj.draw_borderthick = .15;
            obj.draw_bordercolor = [0 0 0];
            obj.draw_halflarge = .15;
            obj.draw_valuecolor = [200 200 200];
            obj.draw_textcolor = [0 0 0];
            obj.draw_spentcolor = [100 100 100];
            obj.draw_textsize = 18;
        end
        
        % draw ------------------------------------------------------------
        % draw the time bar
        function obj = draw(obj, screen_window)
            bar_center = .5*(obj.draw_rectangle(1:2)+obj.draw_rectangle(3:4));
            bar_size = .5*(obj.draw_rectangle(3:4)-obj.draw_rectangle(1:2));
            bar_rect = [bar_center-obj.draw_barscale.*bar_size , bar_center+obj.draw_barscale.*bar_size];

            % left time bar
            Screen('FillRect',screen_window, obj.draw_valuecolor, bar_rect);
            % values bars
            x_pos2 = bar_rect(3);
            for i_values = 1:length(obj.values)
                dx_pos = (obj.values(i_values)/obj.maxvalue)*(bar_rect(3)-bar_rect(1));
                x_pos1 = x_pos2 - dx_pos;
                value_rect = [x_pos1, bar_rect(2), x_pos2, bar_rect(4)];
                Screen('FillRect',screen_window, obj.colors(i_values,:), value_rect);
                x_pos2 = x_pos1;
            end
            % values lines
            x_pos1 = bar_rect(3);
            for i_values = 1:length(obj.values)
                dx_pos = (obj.values(i_values)/obj.maxvalue)*(bar_rect(3)-bar_rect(1));
                x_pos1 = x_pos1 - dx_pos;
                Screen('DrawLine',screen_window, [0,0,0], x_pos1,bar_rect(2),x_pos1,bar_rect(4));
            end
            % text
            Screen('TextSize', screen_window , obj.draw_textsize);
            Screen('DrawText', screen_window, num2str(ceil(obj.maxvalue-sum(obj.values))), bar_center(1)-.6*obj.draw_textsize, bar_center(2)-.37*obj.draw_textsize, obj.draw_textcolor);
            % border
            d_toblank = 0.708*(bar_rect(4)-bar_rect(2));
            % blank the bar coins
            Screen('FrameArc',screen_window,255,[bar_rect(1)-d_toblank bar_rect(2)-d_toblank bar_rect(1)+bar_rect(4)-bar_rect(2)+d_toblank bar_rect(4)+d_toblank],180,180,d_toblank);
            Screen('FrameArc',screen_window,255,[bar_rect(3)+bar_rect(2)-bar_rect(4)-d_toblank bar_rect(2)-d_toblank bar_rect(3)+d_toblank bar_rect(4)+d_toblank],  0,180,d_toblank);
            % draw side arcs
            abs_borderthick = obj.draw_borderthick*(bar_rect(4)-bar_rect(2));
            Screen('FrameArc',screen_window,obj.draw_bordercolor,[bar_rect(1) bar_rect(2) bar_rect(1)+bar_rect(4)-bar_rect(2) bar_rect(4)],180,180,abs_borderthick);
            Screen('FrameArc',screen_window,obj.draw_bordercolor,[bar_rect(3)+bar_rect(2)-bar_rect(4) bar_rect(2) bar_rect(3) bar_rect(4)],  0,180,abs_borderthick);
            % draw top/bottom rectangles
            Screen('FillRect',screen_window,obj.draw_bordercolor, [bar_rect(1)+.5*(bar_rect(4)-bar_rect(2)) bar_rect(2) bar_rect(3)+.5*(bar_rect(2)-bar_rect(4)) bar_rect(2)+abs_borderthick]);
            Screen('FillRect',screen_window,obj.draw_bordercolor, [bar_rect(1)+.5*(bar_rect(4)-bar_rect(2)) bar_rect(4)-abs_borderthick bar_rect(3)+.5*(bar_rect(2)-bar_rect(4)) bar_rect(4)]);
        end
        
        % simulation ------------------------------------------------------
        % add a value
        function obj = add_value(obj,value,color)
            obj.values(end+1) = value;
            obj.colors = [obj.colors ; color];
        end
        % set the last value
        function obj = set_last(obj,value)
            obj.values(end) = value;
        end
        % set the max value
        function obj = set_max(obj,maxvalue)
            obj.maxvalue = maxvalue;
            obj.values = 0;
            obj.colors = obj.draw_spentcolor;
        end
        % set the resetvalue
        function obj = set_reset(obj,resetvalue)
            if resetvalue > obj.maxvalue
                %error(['main_timebar: set_reset: reset(',num2str(resetvalue),') > max(',num2str(obj.maxvalue),')\n']);
                obj.maxvalue = obj.resetvalue;
            end
            obj.resetvalue = resetvalue;
            obj.values = obj.maxvalue - obj.resetvalue;
            obj.colors = obj.draw_spentcolor;
        end
        % reset the value
        function obj = reset(obj,value)
            if ~exist('value','var')
                fprintf('main_timebar: reset: warning. reset value not specified, set to maxvalue.\n');
                value = obj.resetvalue;
            end
            obj.values = obj.maxvalue - value; % value = time left
            obj.colors = obj.draw_valuecolor;
        end
    end
end

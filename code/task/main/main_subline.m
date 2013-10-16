classdef main_subline < matlab.mixin.Copyable % handle + copyable
    % class controlling a subway line
    
    properties
        % general
        name
        main_stations
        % time
        travel_meantime
        travel_devtime
        travel_spantime
        % draw
        draw_color
        draw_thick
    end
    
    methods
        % constructor
        function obj = main_subline()
            obj.name = 'subline';
            obj.main_stations = [];
            
            obj.travel_meantime = [];
            obj.travel_devtime = [];
            obj.travel_spantime = [];
            
            obj.draw_color = [0 0 0];
            obj.draw_thick = .006;
        end
        
        % structure design ------------------------------------------------
        % add a station
        function obj = add_mainstation(obj, new_mainstation)
            obj.main_stations = [obj.main_stations new_mainstation];
        end
        % set the travel_time
        function obj = set_traveltime(obj, mean, dev, span)
            if length(mean)==1 && length(dev)==1
                obj.travel_meantime = mean*ones(1,length(obj.main_stations)-1);
                obj.travel_devtime = dev*ones(1,length(obj.main_stations)-1);
                if any(mean<dev*sqrt(3))
                    fprintf('subline: set_traveltime: warning. can have negative values\n');
                end
                obj.travel_spantime = span*ones(1,length(obj.main_stations)-1);
            elseif length(mean)==length(obj.main_stations)-1 && length(dev)==length(obj.main_stations)-1
                obj.travel_meantime = mean;
                obj.travel_devtime = dev;
                if any(mean<dev*sqrt(3))
                    fprintf('subline: set_traveltime: warning. can have negative values\n');
                end
                obj.travel_spantime = span;
            else
                fprintf('subline: set_traveltime: error. bad inputs\n');
            end
        end
        % are the subline properties coherent?
        function ok = coherent(obj)
            if length(obj.travel_meantime)==length(obj.main_stations)-1 && length(obj.travel_devtime)==length(obj.main_stations)-1
                ok = 1;
            else
                ok = 0;
            end
        end
        
        % draw ------------------------------------------------------------
        % draw the subline on the screen
        function obj = draw(obj, screen_window, screen_rect, stations)
            minsize = min(RectSize(screen_rect));
            for i_station = 1:length(obj.main_stations)-1
                % v perp
                v_perp = stations(obj.main_stations(i_station+1)).draw_position - stations(obj.main_stations(i_station)).draw_position;
                v_perp = .5*[v_perp(2),-v_perp(1)]/norm(v_perp);
                % to
                to = stations(obj.main_stations(i_station+1)).draw_position;
                to1 = stations(obj.main_stations(i_station+1)).draw_position - v_perp*obj.draw_thick*minsize;
                to2 = stations(obj.main_stations(i_station+1)).draw_position + v_perp*obj.draw_thick*minsize;
                % from
                from = stations(obj.main_stations(i_station)).draw_position;
                from1 = stations(obj.main_stations(i_station)).draw_position - v_perp*obj.draw_thick*minsize;
                from2 = stations(obj.main_stations(i_station)).draw_position + v_perp*obj.draw_thick*minsize;
                % draw
                Screen('FillPoly',screen_window,obj.draw_color,[from1;to1;to2;from2]);
                
            end
        end
        
        % simulation ------------------------------------------------------
        % get travel (between one nb_station and the next) time
        function time = get_traveltime(obj, average, nb_station)
            % uniform
            i_station = find(obj.main_stations==nb_station);
            mean_time = obj.travel_meantime(i_station);
            if average
                % average
                dev_time = 0;
            else
                % random uniform noise
                %{
                half_range = obj.travel_devtime(i_station)*sqrt(3);
                dev_time = random('unif',-half_range,half_range);
                %}
                % discrete
                x = obj.travel_devtime(i_station)/sqrt(obj.travel_spantime(i_station));
                p = 2 * rand() - 1;
                if p > 1-x
                    dev_time = obj.travel_spantime(i_station);
                elseif p < x-1
                    dev_time = -obj.travel_spantime(i_station);
                else
                    dev_time = 0;
                end
            end
            % time
            time = mean_time + dev_time;
        end
    end
end

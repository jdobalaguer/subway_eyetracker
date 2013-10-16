classdef main_avatar < matlab.mixin.Copyable % handle + copyable
    % class controlling an avatar representing the subject
    
    properties
        % general
        in_mainstation
        in_mainsubline
        % draw
        draw_position
        draw_outradius
        draw_inradius
        draw_outcolor1
        draw_outcolor2
        draw_incolor1
        draw_incolor2
        draw_colorfreq
        draw_colorangle
        draw_arrowsize
        draw_arrowcolor
        draw_arrowangle
        draw_arrowthick
        % animation
        anim_timespeed
        % pitch
        pitch_squarefreq
        pitch_tonefreq
        pitch_samplesfreq
        % time
        traveltime_interval
    end
    
    methods
        % constructor
        function obj = main_avatar()
            obj.in_mainstation = 0;
            obj.in_mainsubline = 0;
            
            obj.draw_position = [0 0];
            obj.draw_outradius = 0.015;
            obj.draw_inradius = 0.007;
            obj.draw_outcolor1 = [0 191 0];
            obj.draw_outcolor2 = [0 0 0];
            obj.draw_incolor1 = [255 255 255];
            obj.draw_incolor2 = [255 255 255];
            obj.draw_colorfreq = 0.03;
            obj.draw_colorangle = 0;
            obj.draw_arrowsize = .9*obj.draw_inradius;
            obj.draw_arrowcolor = [0 0 0];
            obj.draw_arrowangle = 2*pi/3;
            obj.draw_arrowthick = .014;
            
            obj.anim_timespeed = .5;
            
            obj.pitch_samplesfreq = 44000;
            obj.pitch_tonefreq = [400 1000];
            obj.pitch_squarefreq = [1 10];
            
            obj.traveltime_interval = [0 0];
        end
        
        % structure design ------------------------------------------------
        % are the avatar properties coherent
        function ok = coherent(obj, stations, sublines)
            ok = 1;
            % player is in a station
            if obj.in_mainstation < 1 || obj.in_mainstation > length(stations)
                fprintf('avatar : error. not in a valid station\n');
                ok = 0;
            end
            % player is in a subline
            if obj.in_mainsubline < 1 || obj.in_mainsubline > length(sublines)
                fprintf('avatar : error. not in a valid subline\n');
                ok = 0;
            end
            % player_subline contains player_station
            if ok && ~any(obj.in_mainstation == sublines(obj.in_mainsubline).main_stations)
                fprintf('avatar : error. avatar subline doesn''t contain avatar station\n');
                ok = 0;
            end
        end
        
        % draw ------------------------------------------------------------
        % set position and color values of the avatar
        function obj = set_draw(obj, main_stations, main_sublines)
            obj.draw_position = main_stations(obj.in_mainstation).draw_position;
            obj.draw_outcolor1 = main_sublines(obj.in_mainsubline).draw_color;
        end
        % draw the avatar
        function obj = draw(obj,screen_window,screen_rect,main_stations,main_sublines)
            % computing colors
            obj.draw_colorangle = obj.draw_colorangle + 2*pi*obj.draw_colorfreq;
            if obj.draw_colorangle>2*pi
                obj.draw_colorangle=obj.draw_colorangle-2*pi;
            end
            draw_colorpercent = .5*(1+sin(obj.draw_colorangle));
            draw_outcolor = (draw_colorpercent)*obj.draw_outcolor1 + (1-draw_colorpercent)*obj.draw_outcolor2;
            draw_incolor = (draw_colorpercent)*obj.draw_incolor1 + (1-draw_colorpercent)*obj.draw_incolor2;
            % draw circles
            minsize = min(RectSize(screen_rect));
            Screen('FillOval',screen_window,draw_outcolor, [obj.draw_position(1)-(obj.draw_outradius*minsize), obj.draw_position(2)-(obj.draw_outradius*minsize), obj.draw_position(1)+(obj.draw_outradius*minsize), obj.draw_position(2)+(obj.draw_outradius*minsize)]);
            Screen('FillOval',screen_window,draw_incolor, [obj.draw_position(1)-(obj.draw_inradius*minsize), obj.draw_position(2)-(obj.draw_inradius*minsize), obj.draw_position(1)+(obj.draw_inradius*minsize), obj.draw_position(2)+(obj.draw_inradius*minsize)]);
            % draw arrow
            % if we are not on the last station
            i_sublinestation = find(main_sublines(obj.in_mainsubline).main_stations == obj.in_mainstation);
            if i_sublinestation < length(main_sublines(obj.in_mainsubline).main_stations)
                % 1 find the position of the stations
                position_thisstation = main_stations(obj.in_mainstation).draw_position;
                position_nextstation = main_stations(main_sublines(obj.in_mainsubline).main_stations(i_sublinestation+1)).draw_position;
                % 2 find the angle between this and next stations
                if position_nextstation(1)==position_thisstation(1)
                    if position_nextstation(2)>position_thisstation(2)
                        avatar_angle = pi/2;
                    else
                        avatar_angle = -pi/2;
                    end
                else
                    avatar_angle = atan((position_nextstation(2)-position_thisstation(2))/(position_nextstation(1)-position_thisstation(1)));
                    if position_nextstation(1)-position_thisstation(1) < 0
                        avatar_angle = avatar_angle + pi;
                    end
                end
                % 3 find coordinates of the triangle
                obj.draw_arrowthick = 0.007;
                arrow_cpoint1 = obj.draw_arrowsize*[cos(avatar_angle) sin(avatar_angle)];
                arrow_cpoint1 = arrow_cpoint1*minsize + obj.draw_position;
                arrow_cpoint2 = (obj.draw_arrowsize - obj.draw_arrowthick)*[cos(avatar_angle) sin(avatar_angle)];
                arrow_cpoint2 = arrow_cpoint2*minsize + obj.draw_position;
                
                arrow_lpoint1 = obj.draw_arrowsize*[cos(avatar_angle-obj.draw_arrowangle) sin(avatar_angle-obj.draw_arrowangle)];
                arrow_lpoint1 = arrow_lpoint1*minsize + obj.draw_position;
                arrow_lpoint2 = (obj.draw_arrowsize - obj.draw_arrowthick)*[cos(avatar_angle-obj.draw_arrowangle) sin(avatar_angle-obj.draw_arrowangle)];
                arrow_lpoint2 = arrow_lpoint2*minsize + obj.draw_position;
                
                arrow_rpoint1 = obj.draw_arrowsize*[cos(avatar_angle+obj.draw_arrowangle) sin(avatar_angle+obj.draw_arrowangle)];
                arrow_rpoint1 = arrow_rpoint1*minsize + obj.draw_position;
                arrow_rpoint2 = (obj.draw_arrowsize - obj.draw_arrowthick)*[cos(avatar_angle+obj.draw_arrowangle) sin(avatar_angle+obj.draw_arrowangle)];
                arrow_rpoint2 = arrow_rpoint2*minsize + obj.draw_position;
                % 4 draw the arrow lines
                Screen('FillPoly',screen_window,obj.draw_arrowcolor,[arrow_lpoint1;arrow_cpoint1;arrow_rpoint1;arrow_rpoint2;arrow_cpoint2;arrow_lpoint2]);
            % if it's the last station, draw nothing
            end
        end
        
        % audio -----------------------------------------------------------
        % start a pitch
        function obj = start_pitch(obj,audioport,pitch_time,travel_time)
            % proportional tone frequency
            tone_freq = (obj.pitch_tonefreq(2)-obj.pitch_tonefreq(1))*(obj.traveltime_interval(2) - travel_time)/(obj.traveltime_interval(2)-obj.traveltime_interval(1)) + obj.pitch_tonefreq(1);
            % create pitch array
            i_ymax = round(pitch_time*obj.pitch_samplesfreq);
            y = sin(linspace(0,pitch_time*tone_freq*2*pi,i_ymax));
            % apply the square intermitence
            square_freq = (obj.pitch_squarefreq(2)-obj.pitch_squarefreq(1))*(obj.traveltime_interval(2) - travel_time)/(obj.traveltime_interval(2)-obj.traveltime_interval(1)) + obj.pitch_squarefreq(1);
            square_samples = ceil(obj.pitch_samplesfreq/square_freq);
            i_y = 1;
            while i_y < i_ymax
                if i_y <i_ymax - 2*square_samples
                    y(i_y+square_samples : i_y+(2*square_samples)) = 0;
                elseif i_y < i_ymax - square_samples
                    y(i_y+square_samples : end) = 0;
                end
                i_y = i_y + 2*square_samples;
            end
            % start the audioport
            PsychPortAudio('FillBuffer', audioport, y);
            PsychPortAudio('Start', audioport);
        end
        % stop the pitch
        function obj = stop_pitch(obj,audioport)
            PsychPortAudio('Stop', audioport);
        end
        
        % simulation ------------------------------------------------------
        % apply the option choosed (and draw it)
        function [left_time, travel_time] = move(obj,use_file,use_log,monitor,file,player,main_map,choosed_mainstation,choosed_mainsubline,next_mainstation,next_mainsubline,left_time,next_times)
            % map variables
            main_stations = main_map.main_stations;
            main_sublines = main_map.main_sublines;
            
            choosed = 1;
            
            % update in_mainsubline
            obj.in_mainsubline = next_mainsubline;
            % update color
            obj.draw_outcolor1 = main_sublines(obj.in_mainsubline).draw_color;

            i = 0;
            while obj.in_mainstation~=next_mainstation  && obj.in_mainstation~=main_map.target_mainstation 
                % increase index
                i = i+1;
                
                % time costs
                average = 0;
                if use_log
                    travel_time = next_times(i);
                else
                    travel_time = main_map.option_time(average,next_mainsubline);
                end
                
                % next station
                mainsubline_mainstations = main_sublines(obj.in_mainsubline).main_stations;
                to_mainstation = mainsubline_mainstations(find(mainsubline_mainstations == obj.in_mainstation)+1);
                
                % player_file write
                if use_file
                    travel_meantime = main_map.option_time(1,next_mainsubline);
                end
                
                % travel animation
                if travel_time
                    steps = travel_time/obj.anim_timespeed;
                    from_position = main_stations(obj.in_mainstation).draw_position;
                    to_position = main_stations(to_mainstation).draw_position;
                    if monitor.use(1)
                        % time bar
                        main_map.main_timebar.add_value(0,main_sublines(obj.in_mainsubline).draw_color);
                        if monitor.use(2)
                            % screen framerate
                            framerate = Screen('FrameRate',monitor.screen_window);
                            % start pitch
                            obj.start_pitch(monitor.audioport,steps/framerate,travel_time);
                        end
                        spent_time = 0;
                        if monitor.use(3)
                            monitor.eyelink_msg(['avatar start ',num2str(obj.in_mainstation)]);
                        end
                        for step = 1:steps
                            % new position
                            obj.draw_position = (step/steps)*(to_position - from_position) + from_position;
                            % timebar
                            main_map.main_timebar.set_last(travel_time*step/steps);
                            % eyetracker
                            if monitor.use(3)
                                monitor.eyelink_msg(['avatar in ',num2str(obj.draw_position)]);
                            end
                            % draw the interface
                            monitor.map_timedraw(main_map);
                            % decrease left_time
                            spent_time = spent_time + (travel_time/steps);
                            if left_time < spent_time
                                break;
                            end
                        end
                        if monitor.use(3)
                            monitor.eyelink_msg(['avatar stop ',num2str(to_mainstation)]);
                        end
                    end
                    left_time = left_time - travel_time;
                else
                    % update position
                    obj.draw_position = main_stations(obj.in_mainstation).draw_position;
                end

                if monitor.use(2)
                    % stop pitch
                    obj.stop_pitch(monitor.audioport);
                end

                if left_time
                    % save into file
                    if use_file
                        file.write_datavalues(obj.in_mainstation,obj.in_mainsubline,choosed,choosed_mainstation,choosed_mainsubline,left_time,travel_time,travel_meantime);
                        choosed = 0;
                    end
                end
                
                % process the result
                if use_file
                    player.travel_process(travel_time,obj.in_mainsubline);
                end

                % update in_mainstation
                i_station = find(obj.in_mainstation == main_sublines(obj.in_mainsubline).main_stations);
                obj.in_mainstation = main_sublines(obj.in_mainsubline).main_stations(i_station+1);
            end
        end
    end
end

%{
    demis_map:
    = REQUIRES RUNNING demis_compression FIRST
%}

% monitor
monitor = main_monitor();

% map
map = load('maps/map_1.mat');
map = map.obj;

nb_hierarchies = length(cluster_hier);
i_hierarchy = 1;

try
    % set map
    monitor.monitor_open([1,0,0]);
    monitor.map_resize(map);
    
    % black/white map
    for i_mainsubline = 1:length(map.main_sublines)
        map.main_sublines(i_mainsubline).draw_color = [0,0,0];
        map.main_sublines(i_mainsubline).draw_thick = .004;
    end
    
    restart_colour = true;
            
    while true
        nb_symbols = length(cluster_hier{i_hierarchy});
        
        % colour symbols --------------------------------------------------
        % define colour
        if restart_colour
            color_symbols = round(255*rand(nb_symbols,3));
            restart_colour = false;
        end
        
        % set all main stations as options
        map.options_mainstation = [];
        map.options_mainsubline = [];
        for i_symbol = 1:nb_symbols
            for i_station = 1:length(cluster_hier{i_hierarchy})
                if i_station>1
                    map.options_mainstation(end+1) = i_station;
                    map.options_mainsubline(end+1) = map.main_stations(i_station).main_sublines(1);
                end
            end
        end
        % set drawing of options (to show what are the symbols)
        map.set_drawoptions();
            
        
        % change the color for each symbol
        for i_symbol = 1:nb_symbols
            % for each station in the symbol
            for i_station = 1:length(cluster_hier{i_hierarchy})
                % mark it as an option
                if cluster_hier{i_hierarchy}(i_station)>0
                    %map.options_mainstation(end+1) = i_station;
                    %map.options_mainsubline(end+1) = map.main_stations(i_station).main_sublines(1);
                    map.main_stations(i_station).option_angles = 0;
                    map.main_stations(i_station).option_colors = color_symbols(cluster_hier{i_hierarchy}(i_station),:);
                end
            end
        end
        
        % draw ------------------------------------------------------------
        % draw index
        DrawFormattedText(monitor.screen_window,num2str(i_hierarchy),0,0);
        % draw map
        monitor.map_optionsdraw(map);
        
        % keyboard --------------------------------------------------------
        % wait until
        while KbCheck; end
        while ~KbCheck; end
        % read
        key_code = monitor.keymouse_read();
        % key codes
        switch(KbName(key_code))
            % hierarchy++
            case 'w'
                if i_hierarchy<nb_hierarchies
                    i_hierarchy = i_hierarchy+1;
                end
            % hierarchy--
            case 's'
                if i_hierarchy>1
                    i_hierarchy = i_hierarchy-1;
                end
            % restart colour
            case 'space'
                restart_colour = true;
            % screenshot
            case 'Return'
                imwrite(Screen('GetImage', monitor.screen_window, monitor.screen_rect), ['demis2_',num2str(i_hierarchy),'.png']);
            % exit
            case 'Escape'
                break
            case 'ESCAPE'
                break
            otherwise
                fprintf(['demis_map: key ',KbName(key_code),' not being used\n']);
        end
    end
                        
    % close monitor
    monitor.monitor_close();
catch err
    % close monitor
    monitor.monitor_close();
    rethrow(err);
end

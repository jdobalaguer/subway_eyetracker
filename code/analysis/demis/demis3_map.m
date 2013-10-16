%{
    demis_map:
    = REQUIRES RUNNING demis_compression FIRST
%}

% monitor
monitor = main_monitor();

% map
map = load('maps/map_1.mat');
map = map.obj;

% normalize entropy
entropy = entropy./max(entropy);

try
    % set map
    monitor.monitor_open([1,0,0]);
    monitor.map_resize(map);
    
    % black/white map
    for i_mainsubline = 1:length(map.main_sublines)
       %map.main_sublines(i_mainsubline).draw_color = [0,0,0];
        %map.main_sublines(i_mainsubline).draw_thick = .004;
    end
    
    
    % set all main stations as options
    map.options_mainstation = [];
    map.options_mainsubline = [];
    for i_station = 1:nb_stations
        if i_station>1
            map.options_mainstation(end+1) = i_station;
            map.options_mainsubline(end+1) = map.main_stations(i_station).main_sublines(1);
        end
    end
    % set drawing of options (to show what are the symbols)
    map.set_drawoptions();


    % for each station in the symbol
    for i_station = 1:nb_stations
        map.main_stations(i_station).option_angles = 0;
        map.main_stations(i_station).option_colors = entropy(i_station)*[255,0,0];
    end
    
    % draw ------------------------------------------------------------
    % draw map
    monitor.map_optionsdraw(map);

    % keyboard --------------------------------------------------------
    % wait until
    while KbCheck; end
    while ~KbCheck; end
    
    imwrite(Screen('GetImage', monitor.screen_window, monitor.screen_rect),'demis3.png');
                        
    % close monitor
    monitor.monitor_close();
catch err
    % close monitor
    monitor.monitor_close();
    rethrow(err);
end

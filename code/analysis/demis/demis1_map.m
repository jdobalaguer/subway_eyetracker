%{
    demis_map:
    = REQUIRES RUNNING demis_compression FIRST
%}

% monitor
monitor = main_monitor();

% map
map = load('maps/map_1.mat');
map = map.obj;

i_symbol = 1;
nb_symbols = length(path_symbol)-1;

try
    % set map
    monitor.monitor_open([1,0,0]);
    monitor.map_resize(map);
    
    % black/white map
    for i_mainsubline = 1:length(map.main_sublines)
        map.main_sublines(i_mainsubline).draw_color = [0,0,0];
        map.main_sublines(i_mainsubline).draw_thick = .004;
    end
            
    while true
        % colour symbols --------------------------------------------------
        % set all main stations as options
        map.options_mainstation = [];
        map.options_mainsubline = [];
        
        % if any symbol
        if i_symbol>1
            % for each station in the symbol
            i_stations = demis_stations(i_symbol-1,dict_symbol);
            for i_station = i_stations
                % if it's not a (lower) symbol already
                if i_station>1
                    % mark it as an option
                    map.options_mainstation(end+1) = i_station;
                    map.options_mainsubline(end+1) = map.main_stations(i_station).main_sublines(1);
                end
            end
        end
        
        % draw ------------------------------------------------------------
        % set drawing of options (to show what are the symbols)
        map.set_drawoptions();
        % draw index
        DrawFormattedText(monitor.screen_window,num2str(i_symbol),0,0);
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
            % symbol++
            case 'w'
                if i_symbol<nb_symbols
                    i_symbol = i_symbol+1;
                end
            % symbol--
            case 's'
                if i_symbol>1
                    i_symbol = i_symbol-1;
                end
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

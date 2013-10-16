function [stations] = demis_stations(symbol,dict_symbol)
    % stations
    stations = [];
    
    % for each station in the symbol
    for i_station = dict_symbol{symbol}
        % if it's not a (lower) symbol already
        if i_station>0
            stations(end+1) = i_station;
        % else do it again
        else
            stations = [stations , demis_stations(-i_station,dict_symbol)];
        end
    end
    % remove repeated stations (though it shouldn't happen?)
    stations = unique(stations);
end
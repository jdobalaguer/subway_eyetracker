% function implementing the dijkstra algorithm (used by the computer interface to move inside the map)
%{

modified from http://www.mathworks.com/matlabcentral/fileexchange/5550-dijkstra-shortest-path-routing

% inputs ------------------------------------------------------------------
main_stations = main station array
main_sublines_connectivity = main sublines array (used for connectivity)
main_sublines_timing = main sublines array (used for timing) % this dichomoty is useful for working with timing estimations
average = work with average timing?
is_mainstation = source node index
is_mainsubline = source subline index
it_mainstation = target node index

% outputs -----------------------------------------------------------------
path_mainstation = the list of main stations in the path from source to destination
path_mainsubline = the list of main sublines in the path from source to destination
time_cost = timing for travelling the path

%}

% dijkstra algorithm for a main map ---------------------------------------
function [path_mainstation,path_mainsubline,time_cost,distance] = main_dijkstra(main_stations, main_sublines_connectivity, main_sublines_timing, is_mainstation, is_mainsubline, it_mainstation)
    % declarations
    n = length(main_stations);
    visited(1:n) = 0;
    distance(1:n) = inf;
    distance(is_mainstation) = 0;
    parent_mainstation(1:n) = 0;
    parent_mainsubline(1:n) = 0;
    
    % n-1 nodes visited at most
    for i = 1:(n-1),
        % find the nearest node to the source not visited yet
        temp = zeros(1,n);
        for h = 1:n
            if visited(h) == 0
                temp(h) = distance(h);
            else
                temp(h) = inf;
            end
        end
        [t, u] = min(temp);
        % update distance for each node if found a better path is found
        % update parent to that node needed for this shortest path
        visited(u) = 1;
        for v = 1:n
            % look for main sublines going from u to v
            uv_mainsublines = intersect(main_stations(u).main_sublines, main_stations(v).main_sublines);
            iuv_mainsubline = 1;
            while iuv_mainsubline <= length(uv_mainsublines)
                if find(u==main_sublines_connectivity(uv_mainsublines(iuv_mainsubline)).main_stations) + 1 ~= find(v==main_sublines_connectivity(uv_mainsublines(iuv_mainsubline)).main_stations)
                    uv_mainsublines(iuv_mainsubline) = []; % remove main sublines going the wrong way
                else
                    iuv_mainsubline = iuv_mainsubline + 1;
                end
            end

            % calculate the cost for each possible subline
            if ~isempty(uv_mainsublines)
                % calculate costs for each subline
                costs = zeros(1,length(uv_mainsublines));
                for iuv_mainsubline = 1:length(uv_mainsublines)
                    % travel time
                    costs(iuv_mainsubline) = costs(iuv_mainsubline) + main_sublines_timing(uv_mainsublines(iuv_mainsubline));
                end
                % take the best subline
                [cost, iuv_mainsubline] = min(costs);
                in_subline = uv_mainsublines(iuv_mainsubline);
            else
                % if no possible main sublines, infinite cost
                cost = Inf;
            end

            % update values
            if cost + distance(u) < distance(v)
                distance(v) = distance(u) + cost;
                parent_mainstation(v) = u;
                parent_mainsubline(v) = in_subline;
            end
        end
    end
    
    % deduce the path (if exists) and its average time cost
    path_mainsubline = [];
    path_mainstation = it_mainstation;
    time_cost = distance(it_mainstation);
    if parent_mainstation(it_mainstation) ~= 0
        ii_mainstation = it_mainstation;
        % until you find the source main station
        while ii_mainstation ~= is_mainstation
            path_mainstation = [parent_mainstation(ii_mainstation) path_mainstation];
            path_mainsubline = [parent_mainsubline(ii_mainstation) path_mainsubline];
            ii_mainstation = parent_mainstation(ii_mainstation);
            %todo: increase time
        end
    end
end
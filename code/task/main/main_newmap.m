function [ok,this_mainmap] = main_newmap(topology,grid_size,mainsublines_nbstations,mainsublines_crosses,mainsublines_meantraveltimes,mainsublines_devtraveltimes,mainsublines_spantraveltimes)
    % function to create a new map

    % inputs
    %{
        topology                            = topology number of the graph (number of rings)
        grid_size                           = size of the grid [rows,cols]
        mainsublines_nbstations             = array with the number of main stations per main subline
        mainsublines_crosses                = array with the number of crosses for each sublines (array)
        mainsublines_meantraveltimes        = array with the mean travel time for each main subline
        mainsublines_devtraveltimes         = array with the dev travel time for each main subline
    %}
    
    % outputs
    %{
        ok                  = the map has been succesfully created
        this_mainmap            = map object
    %}
    
    % check inputs
    

    % util variables
    movements = [0 1;1 0;0 -1; -1 0];
    colors = 255*[ 1  1  0 ;  1 0  1 ; 0  1  1 ; 1  0  0 ; 0  1 0 ;  0 0  1 ; ...
                  .5 .5  0 ; .5 0 .5 ; 0 .5 .5 ; 0  0 .5 ; 0 .5 0 ; .5 0  0 ];

    ok = 1;
    if isempty(mainsublines_nbstations)
        fprintf('create_map: error: isempty(mainsublines_nbstations)\n');
        ok = 0;
    end
    if length(mainsublines_nbstations)>length(colors)
        fprintf('create_map: error: length(mainsublines_nbstations)>6\n');
        ok = 0;
    end
    if length(mainsublines_nbstations) ~= length(mainsublines_crosses)
        fprintf('create_map: error: length(mainsublines_nbstations) ~= length(mainsublines_crosses)\n');
        ok = 0;
    end
    if length(mainsublines_nbstations) ~= length(mainsublines_meantraveltimes)
        fprintf('create_map: error: length(mainsublines_nbstations) ~= length(mainsublines_meantraveltimes)\n');
        ok = 0;
    end
    if length(mainsublines_nbstations) ~= length(mainsublines_devtraveltimes)
        fprintf('create_map: error: length(mainsublines_nbstations) ~= length(mainsublines_devtraveltimes)\n');
        ok = 0;
    end
    if any(mainsublines_nbstations<2)
        fprintf('create_map: error: any(mainsublines_nbstations<2)\n');
        ok = 0;
    end
    if ~ok
        this_mainmap = [];
        return;
    end
    
    
    % MAP
    ok = 0;
    map_tries = 0;
    while ~ok
        map_tries = map_tries+1;
        
        %reset the topology
        this_accessmainsublines = eye(2*length(mainsublines_nbstations));
        i_accesssublines1 = 1:2:2*length(mainsublines_nbstations);
        i_accesssublines2 = 2:2:2*length(mainsublines_nbstations);
        for i = 1:length(mainsublines_nbstations);
            this_accessmainsublines(i_accesssublines1(i),i_accesssublines2(i)) = inf;
            this_accessmainsublines(i_accesssublines2(i),i_accesssublines1(i)) = inf;
        end
        this_topology = 0;
        this_ringmainstations = [];

        % create map
        this_mainmap = main_map();
        this_grid = zeros(grid_size);

        % SUBLINE
        subline_tries = 0;
        i_mainsubline = 1;
        while i_mainsubline <= length(mainsublines_nbstations)
            subline_tries = subline_tries+1;
            % NEW SUBLINE
            % create a subline
            this_mainsubline = main_subline();
            % create tmp variables
            tmp_grid = this_grid;
            tmp_mainmap = this_mainmap.duplicate();
            tmp_topology = this_topology;
            tmp_accessmainsublines = this_accessmainsublines;
            tmp_ringmainstations = this_ringmainstations;

            % FIRST STATION
            i_mainstation = 1;
            if isempty(tmp_mainmap.main_stations)
                % random first station
                this_pos = [randi(grid_size(1)),randi(grid_size(2))];
            else
                % first station has to exist
                this_pos = tmp_mainmap.main_stations(randi(length(tmp_mainmap.main_stations))).draw_position;
                if ~ismember(tmp_grid(this_pos(1),this_pos(2)),tmp_ringmainstations)
                    % add it to ring_mainstations
                    tmp_ringmainstations(end+1) = tmp_grid(this_pos(1),this_pos(2));
                end
            end
            if ~tmp_grid(this_pos(1),this_pos(2))
                % create a new station
                tmp_mainmap.create_mainstation();
                tmp_grid(this_pos(1),this_pos(2)) = length(tmp_mainmap.main_stations);
            else
                % topology
                % sublines we can access from this station
                i_accesssublines = tmp_mainmap.main_stations(tmp_grid(this_pos(1),this_pos(2))).main_sublines;
                % update the subline access matrix
                % (it's the first station for this subline, so first cross too)
                for i_accesssubline = i_accesssublines
                    i_accessaccesssublines = find(tmp_accessmainsublines(i_accesssubline,:));
                    tmp_accessmainsublines(i_accessaccesssublines,2*i_mainsubline-1) = tmp_grid(this_pos(1),this_pos(2));
                    tmp_accessmainsublines(2*i_mainsubline-1,i_accessaccesssublines) = tmp_grid(this_pos(1),this_pos(2));
                    tmp_accessmainsublines(i_accessaccesssublines,2*i_mainsubline  ) = tmp_grid(this_pos(1),this_pos(2));
                    tmp_accessmainsublines(2*i_mainsubline,  i_accessaccesssublines) = tmp_grid(this_pos(1),this_pos(2));
                end
            end
            this_mainsubline.add_mainstation(tmp_grid(this_pos(1),this_pos(2)));                    % subline station
            tmp_mainmap.main_stations(tmp_grid(this_pos(1),this_pos(2))).add_mainsubline(2*i_mainsubline-1); % station subline (first way)
            tmp_mainmap.main_stations(tmp_grid(this_pos(1),this_pos(2))).add_mainsubline(2*i_mainsubline);   % station subline (second way)
            tmp_mainmap.main_stations(tmp_grid(this_pos(1),this_pos(2))).draw_position = this_pos;   % station position

            % OTHER STATION
            i_mainstation = 2;
            move_done = 0;
            bad_subline = 0;
            while i_mainstation <= mainsublines_nbstations(i_mainsubline) && ~bad_subline
                options = 1:4;
                % take out the direction opposite to the last one!
                if move_done
                    rem_opt = mod(move_done+2,4);
                    if ~rem_opt
                        rem_opt = 4;
                    end
                    options(options==rem_opt) = [];
                end
                % find a good direction for the next station
                ok = 0;
                while ~ok
                    % choose a random direction
                    opt = options(randi(length(options)));
                    move_dir = movements(opt,:);
                    next_pos = this_pos + move_dir;
                    % check it
                    %   c1. inside grid boundaries
                    if next_pos(1)>0 && next_pos(1)<=grid_size(1) && next_pos(2)>0 && next_pos(2)<=grid_size(2)
                        %   c2. is a new station, then ok!
                        if ~tmp_grid(next_pos(1),next_pos(2))
                            ok = 1;
                            move_done = opt;
                            
                            % create a new station
                            tmp_mainmap.create_mainstation();
                            tmp_grid(next_pos(1),next_pos(2)) = length(tmp_mainmap.main_stations);
                        %   c3. there are no common sublines yet, then ok, and it's a cross
                        elseif ~any(ismember(tmp_mainmap.main_stations(tmp_grid(this_pos(1),this_pos(2))).main_sublines, ...
                                             tmp_mainmap.main_stations(tmp_grid(next_pos(1),next_pos(2))).main_sublines)) ...
                                && ...
                                ~any(ismember(tmp_mainmap.main_stations(tmp_grid(next_pos(1),next_pos(2))).main_sublines, ...
                                             tmp_mainmap.main_stations(tmp_grid(this_pos(1),this_pos(2))).main_sublines))
                            ok = 1;
                            move_done = opt;
                            
                            % topology
                            % sublines we can access from this station
                            i_accesssublines = tmp_mainmap.main_stations(tmp_grid(next_pos(1),next_pos(2))).main_sublines;
                            % if already have access, it's a ring. we increase the topology number.
                            if any(tmp_accessmainsublines(i_accesssublines,2*i_mainsubline))
                                tmp_topology = tmp_topology+1;
                                if ~any(tmp_ringmainstations == tmp_grid(next_pos(1),next_pos(2)))
                                    tmp_ringmainstations = [tmp_ringmainstations,tmp_grid(next_pos(1),next_pos(2))];
                                end
                            end
                            % update the subline access matrix
                            for i_accesssubline = i_accesssublines
                                i_accessaccesssublines = find(tmp_accessmainsublines(i_accesssubline,:));
                                tmp_accessmainsublines(i_accessaccesssublines,2*i_mainsubline-1) = tmp_grid(next_pos(1),next_pos(2));
                                tmp_accessmainsublines(2*i_mainsubline-1,i_accessaccesssublines) = tmp_grid(next_pos(1),next_pos(2));
                                tmp_accessmainsublines(i_accessaccesssublines,2*i_mainsubline  ) = tmp_grid(next_pos(1),next_pos(2));
                                tmp_accessmainsublines(2*i_mainsubline,  i_accessaccesssublines) = tmp_grid(next_pos(1),next_pos(2));
                            end
                        else
                            % bad direction
                            options(options==opt) = [];
                            if isempty(options);
                                bad_subline = 1;
                                break
                            end
                        end
                    else
                        % bad direction
                        options(options==opt) = [];
                        if isempty(options);
                            break
                        end
                    end
                end

                % if the subline can still be ok. if not we'll retry to create the same subline.
                if ok
                    % apply the movement
                    this_pos = next_pos;
                    
                    this_mainsubline.add_mainstation(tmp_grid(this_pos(1),this_pos(2)));                    % subline station
                    tmp_mainmap.main_stations(tmp_grid(this_pos(1),this_pos(2))).add_mainsubline(2*i_mainsubline-1); % station subline (first way)
                    tmp_mainmap.main_stations(tmp_grid(this_pos(1),this_pos(2))).add_mainsubline(2*i_mainsubline);   % station subline (second way)
                    tmp_mainmap.main_stations(tmp_grid(this_pos(1),this_pos(2))).draw_position = this_pos;   % station position
                    
                    % increment
                    i_mainstation = i_mainstation + 1;
                end
            end
            
            if ok
                % SAVE THE SUBLINE
                % updating the results
                this_grid = tmp_grid;
                this_mainmap = tmp_mainmap;
                this_accessmainsublines = tmp_accessmainsublines;
                this_topology = tmp_topology;
                this_ringmainstations = tmp_ringmainstations;
                % first way
                this_mainsubline.draw_color = colors(i_mainsubline,:);
                this_mainmap.add_mainsubline(this_mainsubline);
                % second way
                second_mainsubline = main_subline();
                second_mainsubline.main_stations = flipdim(this_mainsubline.main_stations,2);
                second_mainsubline.draw_color = colors(i_mainsubline,:);
                this_mainmap.add_mainsubline(second_mainsubline);

                % increment
                i_mainsubline = i_mainsubline + 1;
            end
        end

        % CROSSES
        % look for the number of crosses. if not, try another map.
        if ok
            crosses = zeros(1,length(mainsublines_nbstations));
            for i_mainsubline = 1:length(mainsublines_nbstations)
                for i_mainstation = 1:length(this_mainmap.main_sublines(2*i_mainsubline).main_stations)
                    if length(this_mainmap.main_stations(this_mainmap.main_sublines(2*i_mainsubline).main_stations(i_mainstation)).main_sublines)>2 % > 2, because of both ways!
                        crosses(i_mainsubline) = crosses(i_mainsubline)+1;
                    end
                end
            end
            % check the number of crosses per subline
            if any(crosses < mainsublines_crosses)
                ok = 0;
            end
        end
        
        % CONNECTIVITY
        % look if you can move from any station to any other. if not, try another map.
        if ok
            % we take the last station from each subline in the map
            last_stations = zeros(1,length(this_mainmap.main_sublines));
            for i_mainsubline = 1:length(this_mainmap.main_sublines)
                last_stations(i_mainsubline) = this_mainmap.main_sublines(i_mainsubline).main_stations(end);
            end
            % for each last stations
            for i_laststation = last_stations
                % we reset the reaching of each station
                stations_reached = zeros(1,length(this_mainmap.main_stations));
                stations_reached(i_laststation) = 1;
                % we set the sublines we can take from this station
                subline_todo = [];
                for i_mainsubline = this_mainmap.main_stations(i_laststation).main_sublines
                    subline_todo = [subline_todo ; i_mainsubline, find(this_mainmap.main_sublines(i_mainsubline).main_stations == i_laststation)];
                end
                % we move through the "sublines to do"
                % we always work with the first row!
                while ~isempty(subline_todo)
                    % stations we can reach with this subline
                    stations_toreach = this_mainmap.main_sublines(subline_todo(1,1)).main_stations(subline_todo(1,2):end);
                    % for each station not reached yet, we include its sublines on the todo list
                    for i_mainstation = stations_toreach(~stations_reached(stations_toreach))
                        for i_mainsubline = this_mainmap.main_stations(i_mainstation).main_sublines
                            % if the subline is not the same
                            if i_mainsubline ~= subline_todo(1,1)
                                subline_todo = [subline_todo ; i_mainsubline, find(this_mainmap.main_sublines(i_mainsubline).main_stations == i_mainstation)];
                            end
                        end
                    end
                    % we reach all stations in the subline
                    stations_reached(stations_toreach) = 1;
                    % we remove the row
                    subline_todo(1,:) = [];
                end
                % if not all stations have been reached, there's no complete connectivity
                if any(~stations_reached)
                    ok = 0;
                end
            end
        end
        
        % TOPOLOGY
        % look if the map has the good topology class number
        if this_topology < topology
            ok = 0;
        end
    end
    
    if ~ok
        % send nothing
        this_mainmap = [];
    else
        % set station name and time
        for i_mainstation = 1:length(this_mainmap.main_stations)
            % set name
            this_mainmap.main_stations(i_mainstation).name = ['station ',num2str(i_mainstation)];
        end
        % set subline name and times
        for i_mainsubline = 1:(.5*length(this_mainmap.main_sublines))
            % set name
            this_mainmap.main_sublines(2*i_mainsubline-1).name = ['subline ',num2str(i_mainsubline)];
            this_mainmap.main_sublines(2*i_mainsubline  ).name = ['subline ',num2str(i_mainsubline)];
            % set travel time between stations
            this_mainmap.main_sublines(2*i_mainsubline-1).set_traveltime(mainsublines_meantraveltimes(i_mainsubline), mainsublines_devtraveltimes(i_mainsubline), mainsublines_spantraveltimes(i_mainsubline));
            this_mainmap.main_sublines(2*i_mainsubline  ).set_traveltime(mainsublines_meantraveltimes(i_mainsubline), mainsublines_devtraveltimes(i_mainsubline), mainsublines_spantraveltimes(i_mainsubline));
        end
        % set avatar times
        % uniform timing
        %{
            max_traveltime = max(mainsublines_meantraveltimes) + sqrt(3)*max(mainsublines_devtraveltimes);
            min_traveltime = min(mainsublines_meantraveltimes) - sqrt(3)*min(mainsublines_devtraveltimes);
        %}
        % discrete timing
        max_traveltime = max(mainsublines_meantraveltimes) + max(mainsublines_spantraveltimes);
        min_traveltime = min(mainsublines_meantraveltimes) - min(mainsublines_spantraveltimes);
        this_mainmap.main_avatar.traveltime_interval = [min_traveltime max_traveltime];
        % topology
        this_mainmap.topology = this_topology;
        % set map ring (cross) stations array.
        % that is an array of indexes of the stations that form rings in the map (so, dificult decision points)
        % it will be used for checking the complexity of the solution at the randomization of the start positions
        this_mainmap.ring_stations = this_ringmainstations;
    end
end 

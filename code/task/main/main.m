classdef main < handle
    % class controlling the complete experiment
    %{
        includes
        - map manager
        - sequence manager
        - player selection
        - experiment run
        - task display
    %}
    
    % properties ##########################################################
    properties
        % interfaces ----------------------------------------------------------
        % player interface
        player_name
        player
        % screen and audio interface
        monitor
        % file interface
        file
        
        % map -------------------------------------------------------------
        % main map
        main_map
        % map files
        mainmap_prename
        mainmap_dir
        % map complexity
        mainmap_topology
        mainmap_sublines   % attention: both used for generation and quest description (log file)
        mainmap_minsublinestations
        mainmap_maxsublinestations
        mainmap_mincrosses
        mainmap_gridsize
        % trial complexity
        trial_minstations  % minimum of stations to pass in the optimal solution
        min_harddecisions  % minimum of ring_stations to pass in the optimal solution
        optimal_proportion % initial time left
        min_timecost       % minimum of time cost (per trial)
        max_timecost       % maximum of time cost (per trial)
        
        % runs ------------------------------------------------------------
        % number of runs
        run_trainmaps;
        run_maps
        run_trials
        % sequence
        seq_maps
        seq_postrials
        seq_timetrials
        % sequence files
        seq_prename
        seq_dir
        
        % time ------------------------------------------------------------
        % trial time
        trial_lefttime
        trial_maxtime
        % sublines travel time
        mainmap_minmeantraveltime
        mainmap_maxmeantraveltime
        mainmap_devtraveltime
        % map util variables (recalculated from map complexity/timing)
        mainmap_sublinesstations
        mainmap_sublinescrosses
        mainmap_sublinesmeantraveltimes
        mainmap_sublinesspantraveltimes
        mainmap_sublinesdevtraveltimes
        
        % virtualize ------------------------------------------------------
        virtual_name
        virtual_log
        virtual_index
    end
    
    % methods #############################################################
    methods
        % constructor =====================================================
        function obj = main()
            % interface ---------------------------------------------------
            % player interface
            obj.player_name = '';
            obj.player = [];
            % screen and audio interface
            obj.monitor = main_monitor();
            % file interface
            obj.file = main_file();
            % map ---------------------------------------------------------
            % main map
            obj.main_map = [];
            obj.mainmap_prename = 'map_';
            obj.mainmap_dir = 'maps';
            % map complexity
            obj.mainmap_topology = 6;           % minimum of rings in each map generated
            obj.mainmap_sublines = 4;           % number of main_sublines
            obj.mainmap_minsublinestations = 10; % number of main_stations per main_subline
            obj.mainmap_maxsublinestations = 14;
            obj.mainmap_mincrosses = 4;         % minimum of crosses on each main_subline
            obj.mainmap_gridsize = [8,8];
            % trial complexity
            obj.trial_minstations = 5;          % minimum of stations per trial
            obj.min_harddecisions = 3;          % minimum of cross stations per trial
            obj.optimal_proportion = 1.2;       % proportion between optimal time and maximum time allowed
            obj.min_timecost = 25;              % minimum of time cost (per trial)
            obj.max_timecost = 35;              % maximum of time cost (per trial)
            % number of runs
            obj.run_maps = 10;
            obj.run_trainmaps = 1;
            obj.run_trials = 12;
            % sequence
            obj.seq_maps = [];
            obj.seq_postrials = {};
            obj.seq_timetrials = {};
            % sequence files
            obj.seq_prename = 'seq_';
            obj.seq_dir = 'sequences';
            % sublines travel time
            obj.mainmap_minmeantraveltime = 10;
            obj.mainmap_maxmeantraveltime = 25;
            obj.mainmap_devtraveltime = 0; % doesn't work, see: main.mainmap_resetsublinetraveltimes()
            % map util variables
            obj.mainmap_sublinesstations = obj.mainmap_minsublinestations-1+randi(obj.mainmap_maxsublinestations-obj.mainmap_minsublinestations+1,[1,obj.mainmap_sublines]);
            obj.mainmap_sublinescrosses = obj.mainmap_mincrosses*ones(1,obj.mainmap_sublines);
            
            % virtualize ------------------------------------------------------
            obj.virtual_name = '';
            obj.virtual_log = struct();
            obj.virtual_index = 0;
        end
        
        % interfaces ======================================================
        % set a new player
        function set_player(obj,player_name)
            if exist(['player_',player_name,'.m'],'file')
                obj.player_name = player_name;
                obj.player = eval(['player_',player_name,'()']);
            else
                error(['main: set_player: player_',player_name,'.m doesn''t exist']);
            end
        end

        % virtualize ======================================================
        % set virtual
        function set_virtual(obj,virtual_name)
            if  exist(['player_',virtual_name,'.m'],'file')
                obj.virtual_name = virtual_name;
            else
                error(['main: set_virtual: player_',virtual_name,'.m doesn''t exist']);
            end
        end

        % maps ============================================================
        % reset times for sublines
        function obj = mainmap_resetsublinetraveltimes(obj)
            % uniform
            %{
                obj.mainmap_sublinesmeantraveltimes = random('unif',obj.mainmap_minmeantraveltime,obj.mainmap_maxmeantraveltime,[1,obj.mainmap_sublines]);
                obj.mainmap_sublinesdevtraveltimes = ones(1,obj.mainmap_sublines)*obj.mainmap_devtraveltime;
            %}
            % mean
                obj.mainmap_sublinesmeantraveltimes = [...
                                                        3,...
                                                        4.3,...
                                                        5.7,...
                                                        7 ...
                                                    ];
                obj.mainmap_sublinesmeantraveltimes = obj.mainmap_sublinesmeantraveltimes(randperm(obj.mainmap_sublines));
                span = 2; % what was this for?
                obj.mainmap_sublinesspantraveltimes = span*ones(1,obj.mainmap_sublines);
                obj.mainmap_sublinesdevtraveltimes = [...
                                                        0,...
                                                        0,...
                                                        0,...
                                                        0 ...
                                                    ];
                obj.mainmap_sublinesdevtraveltimes = obj.mainmap_sublinesdevtraveltimes(randperm(obj.mainmap_sublines));
            % mean+dev
            %{
                obj.mainmap_sublinesmeantraveltimes = [...
                                                        3,...
                                                        3,...
                                                        7,...
                                                        7 ...
                                                    ];
                obj.mainmap_sublinesmeantraveltimes = obj.mainmap_sublinesmeantraveltimes(randperm(obj.mainmap_sublines));
                span = 2;
                obj.mainmap_sublinesspantraveltimes = span*ones(1,obj.mainmap_sublines);
                obj.mainmap_sublinesdevtraveltimes = [...
                                                        0,...
                                                        0,...
                                                        (1/2)*sqrt(span),...
                                                        (1/2)*sqrt(span) ...
                                                    ];
                obj.mainmap_sublinesdevtraveltimes = obj.mainmap_sublinesdevtraveltimes(randperm(obj.mainmap_sublines));
            %}

        end
        % create a main map
        function v_map = mainmap_create(obj)
            % reset times for sublines
            obj.mainmap_resetsublinetraveltimes();
            % create the map
            ok_map = 0;
            while ~ok_map
                [ok_map, v_map] = main_newmap(obj.mainmap_topology,obj.mainmap_gridsize,obj.mainmap_sublinesstations,obj.mainmap_sublinescrosses,obj.mainmap_sublinesmeantraveltimes,obj.mainmap_sublinesdevtraveltimes,obj.mainmap_sublinesspantraveltimes);
            end
            v_map.main_timebar.set_max(obj.max_timecost * obj.optimal_proportion);
        end
        % save a main map
        function obj = mainmap_save(obj,map,number)
            map.save([obj.mainmap_dir,'/',obj.mainmap_prename,num2str(number),'.mat']);
        end
        % number of main maps already generated, +1
        function nbmaps = mainmap_created(obj)
            nbmaps = 1;
            while exist([obj.mainmap_dir,'/',obj.mainmap_prename,num2str(nbmaps),'.mat'],'file')
                nbmaps = nbmaps+1;
            end
        end
        % generate maps
        function mainmap_generate(obj,number)
            % generate [number] maps
            fprintf(     'main: mainmap_generate:\n');
            for i_map = 1:number
                fprintf(['                  creating map ',num2str(i_map),' of ',num2str(number),'\n']);
                v_map = obj.mainmap_create();
                nbmap = obj.mainmap_created();
                obj.mainmap_save(v_map,nbmap);
                fprintf(['                  saved on file ''',obj.mainmap_dir,'/',obj.mainmap_prename,num2str(nbmap),'.mat''\n\n']);
            end
        end
        % set the main map
        function obj = mainmap_set(obj, v_map)
            obj.main_map = v_map;
        end
        % remove the main map
        function obj = mainmap_remove(obj)
            delete(obj.main_map);
            obj.main_map = [];
        end
        % load a main map
        function obj = mainmap_load(obj, number)
            if exist([obj.mainmap_dir,'/',obj.mainmap_prename,num2str(number),'.mat'],'file')
                v_map = main_map.load([obj.mainmap_dir,'/',obj.mainmap_prename,num2str(number),'.mat']);
                obj.mainmap_set(v_map);
                obj.main_map.main_avatar.traveltime_interval = [obj.mainmap_minmeantraveltime - sqrt(3)*obj.mainmap_devtraveltime,obj.mainmap_maxmeantraveltime + sqrt(3)*obj.mainmap_devtraveltime];
            else
                fprintf(['main: mainmap_load: file ''',obj.mainmap_dir,'/',obj.mainmap_prename,num2str(number),'.mat','''doesn''t exist\n']);
                fprintf( '                    try with:\n');
                fprintf( '                    » m = main();\n');
                fprintf(['                    » m.generate_mainmaps(',num2str(1+number-obj.mainmap_created()),');\n']);
            end
        end
        
        % sequences =======================================================
        % save sequence variables
        function obj = seq_save(obj)
            seq_maps = obj.seq_maps;
            seq_postrials = obj.seq_postrials;
            seq_timetrials = obj.seq_timetrials;
            seq_number = obj.seq_created();
            seq_path = [obj.seq_dir,'/',obj.seq_prename,num2str(seq_number),'.mat'];
            save(seq_path,'seq_maps','seq_postrials','seq_timetrials');
            fprintf(['main: seq_save: saved sequence ',num2str(seq_number),'\n']);
            fprintf(['                file: ''',seq_path,'''\n']);
        end
        % generate all sequence variables
        function obj = seq_generate(obj)
            % sequence of maps
            first_map = obj.run_maps*(obj.seq_created()-1) + 1;
            last_map =  obj.run_maps*(obj.seq_created()-1) + obj.run_maps;
            obj.seq_maps = first_map:last_map;
            % random permutation of the sequence of maps
            %obj.seq_maps = obj.seq_maps(randperm(length(obj.seq_maps)));

            % check maps generated
            if last_map >= obj.mainmap_created()
                fprintf( 'main: seq_generate: not enough maps have been generated\n');
                fprintf( '                    try with:\n');
                fprintf( '                    » m = main();\n');
                fprintf(['                    » m.mainmap_generate(',num2str(1+last_map-obj.mainmap_created()),');\n']);
                fprintf( '                    » m.seq_generate();\n');
                return
            end
            
            % positions and times for each map
            obj.seq_postrials = {};
            obj.seq_timetrials = {};
            fprintf(         '    main: seq_generate:\n');
            for i_runmap = 1:obj.run_maps
                fprintf([    '              map ',num2str(i_runmap),' of ',num2str(obj.run_maps),'\n']);
                obj.mainmap_load(obj.seq_maps(i_runmap));
                positions = [];
                times = [];
                for run_trial = 1:obj.run_trials
                    fprintf(['                  trial ',num2str(run_trial),' of ',num2str(obj.run_trials),'\n']);
                    % select a configuration
                    choosed_stations = [];
                    hard_decisions = 0;
                    new_position = [0 0 0];
                    while length(choosed_stations)<obj.trial_minstations || ... minimum of stations
                            hard_decisions<obj.min_harddecisions || ...         minimum of hard decisions (ring stations)
                            time_cost<obj.min_timecost || ...                   minimum of time cost
                            time_cost>obj.max_timecost || ...                   maximum of time cost   
                            ismember(new_position,positions,'rows') ...         don't repeat the journey
                        
                        obj.main_map.set_avatartarget();
                        [choosed_stations, ~, time_cost] = obj.main_map.find_pathway();
                        hard_decisions = sum(ismember(choosed_stations,obj.main_map.ring_stations));
                        new_position = [obj.main_map.main_avatar.in_mainstation , obj.main_map.main_avatar.in_mainsubline , obj.main_map.target_mainstation];
                    end
                    % sequence of positions in trials
                    positions = [positions ; new_position];
                    % sequence of time in trials
                    times = [times time_cost];
                end
                obj.seq_postrials = {obj.seq_postrials{:} positions};
                obj.seq_timetrials = {obj.seq_timetrials{:} times};
            end
            obj.seq_save();
        end
        % generate all sequence variables (with random positions!)
        function obj = seq_randgenerate(obj)
            % sequence of maps
            first_map = obj.run_maps*(obj.seq_created()-1) + 1;
            last_map =  obj.run_maps*(obj.seq_created()-1) + obj.run_maps;
            obj.seq_maps = first_map:last_map;
            % random permutation of the sequence of maps
            %obj.seq_maps = obj.seq_maps(randperm(length(obj.seq_maps)));

            % check maps generated
            if last_map >= obj.mainmap_created()
                fprintf( 'main: seq_generate: not enough maps have been generated\n');
                fprintf( '                    try with:\n');
                fprintf( '                    » m = main();\n');
                fprintf(['                    » m.mainmap_generate(',num2str(1+last_map-obj.mainmap_created()),');\n']);
                fprintf( '                    » m.seq_generate();\n');
                return
            end
            
            % positions and times for each map
            obj.seq_postrials = {};
            obj.seq_timetrials = {};
            fprintf(         '    main: seq_generate:\n');
            for i_runmap = 1:obj.run_maps
                fprintf([    '              map ',num2str(i_runmap),' of ',num2str(obj.run_maps),'\n']);
                obj.mainmap_load(obj.seq_maps(i_runmap));
                positions = [];
                times = [];
                for run_trial = 1:obj.run_trials
                    fprintf(['                  trial ',num2str(run_trial),' of ',num2str(obj.run_trials),'\n']);
                    % select a configuration
                    new_position = [0 0 0];
                    while new_position(1)==new_position(3)
                        obj.main_map.set_avatartarget();
                        [~, ~, time_cost] = obj.main_map.find_pathway();
                        new_position = [obj.main_map.main_avatar.in_mainstation , obj.main_map.main_avatar.in_mainsubline , obj.main_map.target_mainstation];
                    end
                    % sequence of positions in trials
                    positions = [positions ; new_position];
                    % sequence of time in trials
                    times = [times time_cost];
                end
                obj.seq_postrials = {obj.seq_postrials{:} positions};
                obj.seq_timetrials = {obj.seq_timetrials{:} times};
            end
            obj.seq_save();
        end
        % number of sequence already generated, + 1
        function nbseqs = seq_created(obj)
            nbseqs = 1;
            while exist([obj.seq_dir,'/',obj.seq_prename,num2str(nbseqs),'.mat'],'file')
                nbseqs = nbseqs+1;
            end
        end
        % load sequence variables
        function obj = seq_load(obj,number)
            load([obj.seq_dir,'/',obj.seq_prename,num2str(number),'.mat']);
            obj.seq_maps = seq_maps;
            obj.seq_postrials = seq_postrials;
            obj.seq_timetrials = seq_timetrials;
        end
        % set the max time in trial
        function obj = seqtrial_settime(obj,optimal_time)
            % timings
            obj.trial_maxtime = optimal_time * obj.optimal_proportion;
            obj.trial_lefttime = optimal_time * obj.optimal_proportion;
            % time bar
            obj.main_map.main_timebar.set_reset(optimal_time * obj.optimal_proportion);
        end
        % set avatar and target positions
        function obj = seqtrial_setpositions(obj,positions)
            obj.main_map.main_avatar.in_mainstation = positions(1);
            obj.main_map.main_avatar.in_mainsubline = positions(2);
            obj.main_map.target_mainstation = positions(3);
        end
        
        % show ============================================================
        % show maps
        function show_map(obj,map)
            try
                obj.monitor.monitor_open([1,0,0]);
                % load map
                obj.main_map = map;
                obj.monitor.map_resize(obj.main_map);
                obj.main_map.set_avatartarget();
                obj.main_map.main_avatar.set_draw(obj.main_map.main_stations,obj.main_map.main_sublines);
                % draw map
                obj.monitor.map_topologydraw(obj.main_map);
                % wait until
                while KbCheck; end
                while ~KbCheck; end
                obj.monitor.monitor_close();
            catch err
                % close monitor
                obj.monitor.monitor_close();
                rethrow(err);
            end
        end
        % show maps
        function show_maps(obj,maps)
            try
                if ~exist('maps','var') || isempty(maps)
                    maps = 1:(obj.mainmap_created()-1);
                end
                obj.monitor.monitor_open([1,0,0]);
                fprintf(     'main: show_maps:\n');
                i_map = 1;
                % load map
                obj.mainmap_load(maps(i_map));
                obj.monitor.map_resize(obj.main_map);
                obj.main_map.set_avatartarget();
                obj.main_map.main_avatar.set_draw(obj.main_map.main_stations,obj.main_map.main_sublines);
                while i_map <= length(maps)
                    % draw map
                    obj.monitor.map_topologydraw(obj.main_map);
                    % wait until
                    while KbCheck; end
                    while ~KbCheck; end
                    % read
                    key_code = obj.monitor.keymouse_read();
                    if strcmp(KbName(key_code),'Left') && i_map>1
                        % index
                        i_map = i_map - 1;
                        % load map
                        obj.mainmap_load(maps(i_map));
                        obj.monitor.map_resize(obj.main_map);
                        obj.main_map.set_avatartarget();
                        obj.main_map.main_avatar.set_draw(obj.main_map.main_stations,obj.main_map.main_sublines);
                    elseif strcmp(KbName(key_code),'Right')
                        % index
                        i_map = i_map + 1;
                        % load map
                        obj.mainmap_load(maps(i_map));
                        obj.monitor.map_resize(obj.main_map);
                        obj.main_map.set_avatartarget();
                        obj.main_map.main_avatar.set_draw(obj.main_map.main_stations,obj.main_map.main_sublines);
                    elseif strcmp(KbName(key_code),'Down')
                        fprintf(['                 map ',num2str(maps(i_map)),' has been marked\n']);
                    elseif strcmp(KbName(key_code),'Up')
                        imwrite(Screen('GetImage', obj.monitor.screen_window, obj.monitor.screen_rect), ['map_',num2str(i_map),'.png']);
                    elseif strcmp(KbName(key_code),'space')
                        obj.main_map.set_avatartarget();
                        obj.main_map.main_avatar.set_draw(obj.main_map.main_stations,obj.main_map.main_sublines);
                    elseif strcmp(KbName(key_code),'Escape')
                        break
                    else
                        fprintf(['                 ',KbName(key_code),' is unused\n']);
                    end
                end
                obj.monitor.monitor_close();
            catch err
                % close monitor
                obj.monitor.monitor_close();
                rethrow(err);
            end
        end
        
        % simulation ======================================================
        % run the experiment
        function experiment(obj,use,i_subject)
            % use does not exist
            if ~exist('use','var')
                fprintf( 'main: experiment: bad arguments\n');
                fprintf( '                  try with:\n');
                fprintf( '                  » m.experiment([0,0,0]);\n');
                return
            end
            
            % check syntax
            if ~exist('use','var') || length(use)~=3
                fprintf( 'main: experiment: bad syntax\n');
                fprintf( '                  experiment([use_screen, use_sound, use_eyelink]);\n');
                return
            end
            
            % set interface
            if ~isempty(obj.player_name)
                if ~isempty(obj.virtual_name)
                    obj.file.set_interface([obj.virtual_name,'_',obj.player_name]);
                else
                    obj.file.tree_interface = obj.player_name;
                end
            end
            
            % check maps generated
            if obj.run_maps*obj.file.tree_last() >= obj.mainmap_created()
                fprintf( 'main: experiment: not enough maps have been generated\n');
                fprintf( '                  try with:\n');
                fprintf( '                  » m = main();\n');
                fprintf(['                  » m.mainmap_generate(',num2str(1+obj.run_maps*obj.file.tree_last()-obj.mainmap_created()),');\n']);
                return
            end
            % check sequence generated
            if obj.seq_created() <= obj.file.tree_last()
                fprintf( 'main: experiment: not enough sequences have been generated\n');
                fprintf( '                  try (again) with:\n');
                fprintf( '                  » m = main();\n');
                fprintf( '                  » m.seq_generate();\n');
                return
            end
            
            % 'human' player always uses screen
            if ~use(1) && ~isempty(obj.player) && strcmp(obj.player.model,'human')
                use(1) = 1;
                fprintf('main: experiment: warning. human player. use(1) has to be 1\n');
            end
            % sound or eyelink only with screen
            if ~use(1) && (use(2) || use(3))
                if use(2)
                    use(2) = 0;
                    fprintf('main: experiment: warning. sound enabled without screen. disabling sound\n');
                end
                if use(3)
                    use(3) = 0;
                    fprintf('main: experiment: warning. eyelink enabled without screen. disabling eyelink\n');
                end
            end
            % eyelink cannot in virtual mode
            if use(3) && ~isempty(obj.virtual_name)
                use(3) = 0;
                fprintf('main: experiment: warning. eyelink enabled in a virtual mode. disabling eyelink\n');
            end
            % eyelink only with human
            if use(3) && (isempty(obj.player) || ~strcmp(obj.player.model,'human'))
                use(3) = 0;
                fprintf('main: experiment: warning. eyelink only with human player. disabling eyelink\n');
            end
            
            % wait
            WaitSecs(0.5);
            
            % virtualize
            if ~isempty(obj.virtual_name)
                % use_log
                use_log = 1;
                
                % replay a log
                if isempty(obj.player)
                    % use_file
                    use_file = 0;
                    if ~use(1)
                        use(1) = 1;
                        fprintf('main: experiment: ''replay'', since player has not been set. use(1) has to be 1\n');
                    end
                    % check if i_subject has been specified
                    if ~exist('i_subject','var')
                        error('main: experiment: ''replay'', since player has not been set. i_subject has not been specified\n');
                    end
                    
                % play from log
                else
                    % use_file
                    use_file = 1;
                    % select the sequence
                    i_subject = obj.file.tree_last();
                end
                
                % load log
                virtual_file = main_file();
                virtual_file.set_interface(obj.virtual_name);
                obj.virtual_log = virtual_file.tree_read(i_subject).data;
                obj.virtual_index = 1;

            % don't virtualize
            else
                % use_log, use_file
                use_log = 0;
                use_file = 1;
                % select the sequence
                obj.file.set_interface(obj.player_name);
                i_subject = obj.file.tree_last();
                % check a player has been selected
                if isempty(obj.player)
                    fprintf( 'main: experiment: player not selected. virtual not selected.\n');
                    fprintf( '                  try with:\n');
                    fprintf( '                  » m = main();\n');
                    fprintf( '                  » m.set_player(player_string)\n');
                    fprintf( '                  » m.set_virtual(virtual_string)\n');
                    fprintf(['                  » m.experiment([',num2str(use(1)),',',num2str(use(2)),',',num2str(use(3)),']);\n']);
                    return
                end
            end
            
            try
                % set and open monitor
                obj.monitor.monitor_open(use,i_subject);
                obj.monitor.set_runs(obj.run_maps,obj.run_trainmaps,obj.run_trials);

                % load the sequence
                obj.seq_load(i_subject);
                
                % not replay mode
                if use_file
                    % start experiment
                    [age,name,sex,handed] = obj.player.experiment_start(obj.monitor,obj.run_maps,obj.run_trainmaps,obj.run_trials,i_subject);
                    
                    % create a new file
                    obj.file.tree_create();
                    
                    % add descriptors
                    obj.file.write_headerdescriptor();
                    obj.file.write_datadescriptor();
                    obj.file.write_questdescriptor(obj.mainmap_sublines);
                    obj.file.write_line();

                    % add the header and the data description to the file
                    obj.file.write_headervalues(obj.monitor,name,age,sex,handed,obj.run_maps,obj.run_trainmaps,obj.run_trials);
                end
                
                % for each map
                fprintf(         'main: experiment:\n');
                for i_seqmaps = 1:obj.run_maps
                    fprintf([    '                  map ',num2str(obj.seq_maps(i_seqmaps)),'\n']);
                    % load map
                    obj.mainmap_load(obj.seq_maps(i_seqmaps));
                    % monitor
                    if use(1)
                        if i_seqmaps <= obj.run_trainmaps
                            if i_seqmaps == 1
                                obj.monitor.screen_pretrain();
                            end
                            obj.monitor.screen_pretrainmap(i_seqmaps);
                        else
                            if i_seqmaps == obj.run_trainmaps + 1
                                obj.monitor.screen_posttrain();
                            end
                            obj.monitor.screen_premap(i_seqmaps-obj.run_trainmaps);
                        end
                        obj.monitor.map_resize(obj.main_map);
                    end
                    % process the map
                    if use_file
                        obj.player.map_start(obj.main_map,obj.monitor);
                    end
                    % for each trial
                    seq_times = obj.seq_timetrials{i_seqmaps};
                    seq_pos = obj.seq_postrials{i_seqmaps};
                    for i_seqtrial = 1:obj.run_trials
                        fprintf(['                      trial ',num2str(i_seqtrial),'\n']);
                        
                        % PRE-TRIAL .......................................
                        if use(1)
                            % monitor
                            obj.monitor.screen_pretrial(i_seqmaps-obj.run_trainmaps,i_seqtrial);
                        end
                        % set avatar and target
                        obj.seqtrial_setpositions(seq_pos(i_seqtrial,:));
                        % set avatar draw
                        if use(1)
                            obj.main_map.main_avatar.set_draw(obj.main_map.main_stations,obj.main_map.main_sublines);
                        end
                        if use_file
                            % trial start
                            obj.player.trial_start(obj.main_map,obj.monitor,i_seqmaps,obj.seq_maps(i_seqmaps),i_seqtrial);
                            % setting the file interface
                            obj.file.set_trial(i_seqmaps,obj.seq_maps(i_seqmaps),i_seqtrial);
                            obj.file.set_targetstation(obj.main_map.target_mainstation);
                        end
                        
                        % set max time
                        obj.seqtrial_settime(seq_times(i_seqtrial));
                        
                        if use_file && obj.file.writing()
                        % PHASE I   : PLANNING ............................
                            obj.player.planning_start(obj.monitor);
                            obj.player.planning_do(obj.main_map,obj.monitor);
                            obj.player.planning_stop(obj.monitor);
                                
                        % PHASE II  : CLICKING ............................
                        % clicking start
                            obj.player.clicking_start(obj.monitor);
                        % clicking do
                            [choosed_mainstations, choosed_mainsublines] = obj.player.clicking_do(obj.main_map,obj.monitor);
                        % clicking stop
                            obj.player.clicking_stop(obj.monitor);
                        end
                        
                        if ~isempty(choosed_mainstations) && length(choosed_mainstations)==length(choosed_mainsublines)
                            % PHASE III : MOVING...............................
                            % set avatar and target (again)
                            obj.seqtrial_setpositions(seq_pos(i_seqtrial,:));

                            % moving start
                            obj.player.moving_start(obj.monitor);
                            % max time or target reached
                            for i_stop = 1:length(choosed_mainstations)
                                % out of time?
                                if obj.trial_lefttime<=0
                                    break
                                end

                                % update options before checks
                                obj.main_map.set_options();

                                % if not replay mode (normal or virtual modes)
                                % make a decision. set choosed_mainstation/choosed_mainsubline
                                if use_file
                                    choosed_mainstation = choosed_mainstations(i_stop);
                                    choosed_mainsubline = choosed_mainsublines(i_stop);
                                    % check if it's coherent
                                    find_eqstations = find(choosed_mainstation==obj.main_map.options_mainstation);
                                    find_eqsublines = find(choosed_mainsubline==obj.main_map.options_mainsubline);
                                    if ~any(ismember(find_eqstations,find_eqsublines))
                                        error('main: experiment: error. player, incorrect decision\n');
                                    end
                                % replay mode. wait for mouse/keyboard event
                                else
                                    choosed_mainstation = 0;
                                    choosed_mainsubline = 0;
                                end
                                % if virtualization
                                if use_log
                                    % read next station
                                    next_mainstation = obj.virtual_log.next_station(obj.virtual_index);
                                    next_mainsubline = obj.virtual_log.next_subline(obj.virtual_index);
                                    % check if it's coherent
                                    find_eqstations = find(next_mainstation==obj.main_map.options_mainstation);
                                    find_eqsublines = find(next_mainsubline==obj.main_map.options_mainsubline);
                                    if ~any(ismember(find_eqstations,find_eqsublines))
                                        error('main: experiment: error. virtual, incorrect decision\n');
                                    end
                                    % index to next decision
                                    i_decisions = find(obj.virtual_log.decision==1);
                                    virtual_lastindex = obj.virtual_index;
                                    ii_decisions = find(i_decisions==obj.virtual_index);
                                    if ii_decisions < length(i_decisions)
                                        obj.virtual_index = i_decisions(ii_decisions+1);
                                        % time travel log
                                        next_times = obj.virtual_log.traveltime(virtual_lastindex : (obj.virtual_index-1));
                                    else
                                        % time travel log
                                        next_times = obj.virtual_log.traveltime(virtual_lastindex : end);
                                    end
                                % don't use virtualization
                                else
                                    next_mainstation = choosed_mainstation;
                                    next_mainsubline = choosed_mainsubline;
                                    next_times = [];
                                end
                                % apply the option in the main map
                                [obj.trial_lefttime, ~] = obj.main_map.main_avatar.move(use_file,use_log,obj.monitor,obj.file,obj.player,obj.main_map,choosed_mainstation,choosed_mainsubline,next_mainstation,next_mainsubline,obj.trial_lefttime,next_times);
                                
                            end

                            if use_file
                                % moving stop
                                obj.player.moving_stop(obj.monitor);
                            end
                            
                            % wait until key pressed
                            if use(1)
                                % keymouse in rest state
                                [key_code,~,mouse_buttons] = obj.monitor.keymouse_read();
                                while any(key_code) || any(mouse_buttons)
                                    [key_code,~,mouse_buttons] = obj.monitor.keymouse_read();
                                end
                                % wait for a keymouse event
                                while ~any(key_code) && ~any(mouse_buttons)
                                    [key_code,~,mouse_buttons] = obj.monitor.keymouse_read();
                                    obj.monitor.map_timedraw(obj.main_map,'stop');
                                end
                                % keymouse in rest state
                                [key_code,~,mouse_buttons] = obj.monitor.keymouse_read();
                                while any(key_code) || any(mouse_buttons)
                                    [key_code,~,mouse_buttons] = obj.monitor.keymouse_read();
                                end

                                % no left time
                                if obj.trial_lefttime <= 0
                                    obj.monitor.screen_notime();
                                end
                            end
                        end

                        % POST-TRIAL ......................................
                        % trial stop
                        if use_file
                            obj.player.trial_stop(obj.main_map,obj.monitor);
                        end
                    end
                    % stop map
                    if use_file
                        obj.player.map_stop(obj.main_map,obj.monitor);
                        if use(1)
                            obj.monitor.screen_quest();
                        end
                        quest = obj.player.lines_quest(obj.main_map,obj.monitor);
                        obj.file.write_questvalues(quest);
                    end
                end
                if use_file
                    % save end time
                    obj.file.write_time();
                    % close the file
                    obj.file.close();
                    % terminate the experiment
                    obj.player.experiment_stop(obj.monitor);
                end
                % close monitor
                obj.monitor.monitor_close();
            catch err
                % close monitor
                obj.monitor.monitor_close();
                rethrow(err);
            end
        end
    end
end

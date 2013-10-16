classdef eyelink_file < handle
    % class for managing eyelink files
    
    properties
        % file
        path
        mode
        file
        % eyelink
        max_movement
    end
    
    methods
        % constructor
        function obj = eyelink_file()
            obj.path = '';
            obj.mode = '';
            obj.file = [];
            obj.max_movement = 200;
        end
        
        % read methods ----------------------------------------------------
        % reading mode?
        function rmode = reading(obj)
            rmode = strcmp(obj.mode,'r');
        end
        % open a file (read permissions)
        function obj = open(obj,new_path)
           if ~isempty(obj.file)
               fprintf(['main_file: open: error. file ''',obj.path,''' is still opened. close it first\n']);
           elseif exist(new_path,'file')
                obj.path = new_path;
                obj.mode = 'r';
                obj.file = fopen(obj.path,obj.mode);
           else
               fprintf(['main_file: open: error. file ''',new_path,''' doesn''t exist\n']);
           end
        end
        % read a line
        function string = read_line(obj)
            string = fgets(obj.file);
        end
        % parse a line
        function string = parse_line(~,string)
            string = regexp(string,'\s','split');
        end
        % is it the end of the file?
        function endfile = end(obj)
            if isempty(obj.file)
                fprintf('main_file: end: error. file not opened\n');
                endfile = 1;
            elseif ~strcmp(obj.mode,'r')
                fprintf('main_file: end: error. file opened without writing permissions\n');
                endfile = 1;
            else
                endfile = feof(obj.file);
            end
        end
        % read file
        function gaze = read_file(obj,screen_rect,path)
            % already reading
            if obj.reading()
                error('eyelink_file: read_file: already reading\n');
            end
            % open file
            obj.open(path);
            % read loop
            load = 0;
            gaze = {};
            i_map = 0;
            i_trial = 0;
            i_decision = 0;
            while ~obj.end()
                % read line
                s = obj.parse_line(obj.read_line());
                % remove empty fields
                news = {};
                for i_s = 1:length(s)
                    if ~isempty(s{i_s})
                        news{end+1} = s{i_s};
                    end
                end
                s = news;
                clear news;
                % do something
                if ~isempty(s)
                    % triggers
                    if strcmp(s{1},'MSG')
                        if length(s)>3
                            % stop
                            if strcmp(s{4},'stop')
                                load = 0;
                                % add the last timestep if not done yet
                                % (to have an estimation of the duration)
                                if ~added
                                    gaze{i_map}{i_trial}{i_decision} = [gaze{i_map}{i_trial}{i_decision} ; t,NaN,NaN,NaN];
                                    added = 1;
                                end
                            % start
                            elseif strcmp(s{4},'start')
                                added = 1;
                                % map
                                if strcmp(s{3},'map')
                                    i_map = i_map+1;
                                    i_trial = 0;
                                    i_decision = 0;
                                    gaze{i_map} = {};
                                % trial
                                elseif strcmp(s{3},'trial')
                                    i_trial = i_trial+1;
                                    i_decision = 0;
                                    gaze{i_map}{i_trial} = {};
                                % planning
                                elseif strcmp(s{3},'planning')
                                    load = 1;
                                    i_decision = i_decision+1;
                                    gaze{i_map}{i_trial}{i_decision} = [];
                                % clicking
                                elseif strcmp(s{3},'clicking')
                                    load = 1;
                                    i_decision = i_decision+1;
                                    gaze{i_map}{i_trial}{i_decision} = [];
                                end
                                fprintf(['eyelink_file: read_file: gaze{',num2str(i_map),'}{',num2str(i_trial),'}{',num2str(i_decision),'}\n']);
                            end
                        end
                    % gaze position
                    elseif load
                        t = str2double(s{1});
                        if ~isnan(t)
                            x = str2double(s{2});
                            y = str2double(s{3});
                            p = str2double(s{4});
                            % remove frames without detection
                            if ...
                                    ~isnan(x) && ...                                                                % if detected and
                                    ~isnan(y) && ...
                                    p         && ...
                                    ( ...
                                        isempty(gaze{i_map}{i_trial}{i_decision}) || ...                            % (first gaze or
                                        ( ...
                                            gaze{i_map}{i_trial}{i_decision}(end,2) <= screen_rect(3) && ...        % (in screen and
                                            gaze{i_map}{i_trial}{i_decision}(end,3) <= screen_rect(4) && ...
                                            ( ...                                                                   % last wasnt a nan or there's big gap))
                                                isequalwithequalnans(gaze{i_map}{i_trial}{i_decision}(end,2:end),[NaN,NaN,NaN]) || ... 
                                                sum(pow2([x,y] - gaze{i_map}{i_trial}{i_decision}(end,[2,3]))) < pow2(obj.max_movement) ...
                                            ) ...
                                        ) ...
                                    )
                                gaze{i_map}{i_trial}{i_decision} = [gaze{i_map}{i_trial}{i_decision} ; t,x,y,p];            % add the gaze
                                added = 1;
                                
                            elseif ...                                                                              % if not detected and
                                    isempty(gaze{i_map}{i_trial}{i_decision}) || ...                                % last is not a nan alrady
                                    ~isequalwithequalnans(gaze{i_map}{i_trial}{i_decision}(end,2:end),[NaN,NaN,NaN])
                                gaze{i_map}{i_trial}{i_decision} = [gaze{i_map}{i_trial}{i_decision} ; t,NaN,NaN,NaN];          % add nans
                                added = 1;
                            else
                                added = 0;
                            end
                        end
                    end
                end
            end
            obj.close();
        end
        
        % general methods -------------------------------------------------
        % is open?
        function opened = is_open(obj)
            opened = ~isempty(obj.file);
        end
        % close
        function obj = close(obj)
            if obj.is_open()
                obj.path = '';
                obj.mode = '';
                fclose(obj.file);
                obj.file = [];
            end
        end
    end
    methods(Static)
        % file exists?
        function file_exists = exist_file(file_path)
            file_exists = exist(file_path,'file');
        end
        % dir exists?
        function dir_exists = exist_dir(dir_path)
            dir_exists = exist(dir_path,'dir');
        end
    end
end


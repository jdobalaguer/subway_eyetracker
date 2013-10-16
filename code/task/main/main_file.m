classdef main_file < handle
    % file interface class
    %{
        file structure:
    
        - header
            includes field {'start' [strdate] [strtime]}
            any other field is {[str_field] [str_value]}
        - empty line
        - data
            descriptors in first line {[strfield_1] [strfield_2] [strfield_3] ... }
            values {[strval_1] [strval_2] [strval_3] ... }
        - empty line
        - end of experiment
            field {'end' [strdate] [strtime]}
            
    %}
    
    properties
        % file
        path
        mode
        file
        % tree
        tree_dir
        tree_interface
        tree_prename
        tree_extension
        tree_digits
        % data
        data_participant
        data_map
        data_mapnumber
        data_trial
        data_stop
        data_targetstation
    end
    
    methods
        % constructor
        function obj = main_file()
            obj.path = '';
            obj.mode = '';
            obj.file = [];
            
            obj.tree_dir = 'data';
            obj.tree_interface = '';
            obj.tree_prename = 'subject_';
            obj.tree_extension = '.ods';
            obj.tree_digits = 3;
            
            obj.data_participant = 0;
            obj.data_map = 0;
            obj.data_mapnumber = 0;
            obj.data_trial = 0;
            obj.data_stop = 0;
            obj.data_targetstation = 0;
        end
        
        % write methods ---------------------------------------------------
        % writing mode?
        function wmode = writing(obj)
            wmode = strcmp(obj.mode,'w');
        end
        % create (write permissions)
        function obj = create(obj,new_path)
           if ~isempty(obj.file)
               fprintf(['main_file: create: error. file ''',obj.path,''' is still opened. close it first\n'])
           elseif exist(new_path,'file')
               fprintf(['main_file: create: error. file ''',new_path,''' already exists\n']);
           else
                obj.path = new_path;
                obj.mode = 'w';
                obj.file = fopen(obj.path,obj.mode);
           end
        end
        % write a number
        function obj = write_number(obj,numbers)
            if isempty(obj.file)
                fprintf('main_file: write_number: error. file not opened\n');
            elseif ~strcmp(obj.mode,'w')
                fprintf('main_file: write_number: error. file opened without writing permissions\n');
            else
                for number = numbers
                    fprintf(obj.file,[num2str(number),'\t']);
                end
            end
        end
        % write a string
        function obj = write_string(obj,string)
            if isempty(obj.file)
                fprintf('main_file: write_string: error. file not opened\n');
            elseif ~strcmp(obj.mode,'w')
                fprintf('main_file: write_string: error. file opened without writing permissions\n');
            else
                fprintf(obj.file,[string,'\t']);
            end
        end
        % start a new line
        function obj = write_line(obj)
            if isempty(obj.file)
                fprintf('main_file: write_line: error. file not opened\n');
            elseif ~strcmp(obj.mode,'w')
                fprintf('main_file: write_line: error. file opened without writing permissions\n');
            else
                fprintf(obj.file,'\n');
            end
        end
        % save the file (close and open it again)
        function obj = save(obj)
            if isempty(obj.file)
                fprintf('main_file: save: error. file not opened\n')
            elseif ~strcmp(obj.mode,'w')
                fprintf('main_file: save: error. file opened without writing permissions\n');
            else
                fclose(obj.file);
                obj.file = fopen(obj.path,'a');
            end
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
        % read a number
        function number = read_number(obj)
            number = str2double(fscanf(obj.file,'%s',1));
        end
        % read a string
        function string = read_string(obj)
            string = fscanf(obj.file,'%s',1);
        end
        % read a line
        function string = read_line(obj)
            string = fgets(obj.file);
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
        
        % tree methods ----------------------------------------------------
        % finds the first position to write a file
        function last = tree_last(obj)
            last = 1; 
            while obj.exist_file([obj.tree_dir,'/',obj.tree_interface,'/',obj.tree_prename,obj.tree_formatnumber(last),obj.tree_extension])
                last = last+1;
            end
        end
        % format the number of the file position (add so many 0 as needed)
        function string = tree_formatnumber(obj,number)
            string = sprintf(['%.',num2str(obj.tree_digits),'i'],number);
        end
        % create a new subject file
        function obj = tree_create(obj)
            last = obj.tree_last();
            obj.data_participant = last;
            if ~exist([obj.tree_dir,'/',obj.tree_interface],'dir')
                mkdir([obj.tree_dir,'/',obj.tree_interface]);
            end
            obj.create([obj.tree_dir,'/',obj.tree_interface,'/',obj.tree_prename,obj.tree_formatnumber(last),obj.tree_extension]);
        end
        function obj = tree_open(obj,number)
            obj.open([obj.tree_dir,'/',obj.tree_interface,'/',obj.tree_prename,obj.tree_formatnumber(number),obj.tree_extension]);
        end
        function file_struct = tree_fields(obj)
            % open file
            obj.tree_open(1);
            file_struct = struct();
            if obj.reading()
                % create struct (header)
                strline = obj.read_line();
                file_struct.header = struct();
                % create struct (generic)
                strline = obj.read_line();
                while length(strline)>1
                    strline = regexp(strline,'\s','split');
                    file_struct.(strline{1}) = struct();
                    file_struct.(strline{1}).keys = strline; % store keys in a cell
                    for i_field = 2:length(strline)
                        if ~isempty(strline{i_field})
                            file_struct.(strline{1}).(strline{i_field}) = [];
                        end
                    end
                    strline = obj.read_line();
                end
            end
        end
        function file_struct = tree_read(obj,number)
            % open file
            obj.tree_open(number);
            file_struct = struct();
            if obj.reading()
                % create struct (header)
                strline = obj.read_line();
                file_struct.header = struct();
                % create struct (generic)
                strline = obj.read_line();
                while length(strline)>1
                    strline = regexp(strline,'\s','split');
                    file_struct.(strline{1}) = struct();
                    file_struct.(strline{1}).keys = strline; % store keys in a cell
                    for i_field = 2:length(strline)
                        if ~isempty(strline{i_field})
                            file_struct.(strline{1}).(strline{i_field}) = [];
                        end
                    end
                    strline = obj.read_line();
                end
                
                % read
                strline = obj.read_line();
                while length(strline) > 1
                    strline = regexp(strline,'\s','split');
                    switch strline{1}
                        case 'header'
                            % read header
                            if strcmp(strline{2},'data')
                                fprintf('main_file: tree_read: warning. ''data'' field was used in the header\n')
                            elseif strcmp(strline{2},'header')
                                fprintf('main_file: tree_read: warning. ''header'' field was used in the header\n')
                            else
                                if strcmp(strline{2},'start')
                                    file_struct.header.start =[strline{3},' ',strline{4}];
                                else
                                    [num,is_numeric] = str2num(strline{3});
                                    if is_numeric
                                        file_struct.header.(strline{2})=num;
                                    else
                                        file_struct.header.(strline{2})=strline{3};
                                    end
                                end
                            end
                        otherwise
                            % read generic line
                            for i_field = 2:length(strline)
                                if ~isempty(strline{i_field})
                                    key = file_struct.(strline{1}).keys{i_field};
                                    file_struct.(strline{1}).(key)(end+1) = str2double(strline{i_field});
                                end
                            end
                    end
                    strline = obj.read_line();
                end
                
                % close the file
                obj.close();
            end
        end
        
        % set -------------------------------------------------------------
        % set trial
        function obj = set_trial(obj,data_map,data_mapnumber,data_trial)
            obj.data_map = data_map;
            obj.data_mapnumber = data_mapnumber;
            obj.data_trial = data_trial;
            obj.data_stop = 1;
        end
        
        % set target station
        function obj = set_targetstation(obj,data_targetstation)
            obj.data_targetstation = data_targetstation;
        end
        
        % field methods: header -------------------------------------------
        % header descriptor
        function obj = write_headerdescriptor(obj)
            if isempty(obj.file)
                fprintf('main_file: write_headerdescriptor: error. file not opened\n');
            elseif ~strcmp(obj.mode,'w')
                fprintf('main_file: write_headerdescriptor: error. file opened without writing permissions\n');
            else
                obj.write_string('header');
                obj.write_line();
                obj.save();
            end
        end
        % header field + value
        function obj = write_headervalues(obj,monitor,head_name,head_age,head_sex,head_handed,head_maps,head_trainmaps,head_trials)
            if isempty(obj.file)
                fprintf('main_file: write_headervalues: error. file not opened\n');
            elseif ~strcmp(obj.mode,'w')
                fprintf('main_file: write_headervalues: error. file opened without writing permissions\n');
            else
                
                obj.write_string('header');    obj.write_string('start');          obj.write_string(datestr(clock()));      obj.write_line();
                obj.write_string('header');    obj.write_string('use_sound');      obj.write_number(monitor.use(2));        obj.write_line();
                obj.write_string('header');    obj.write_string('screen_rect');    obj.write_number(monitor.screen_rect);   obj.write_line();
                obj.write_string('header');    obj.write_string('border_top');     obj.write_number(monitor.draw_bordertop); obj.write_line();
                obj.write_string('header');    obj.write_string('border_sides');   obj.write_number(monitor.draw_bordersides); obj.write_line();
                obj.write_string('header');    obj.write_string('border_bottom');  obj.write_number(monitor.draw_borderbottom); obj.write_line();
                obj.write_string('header');    obj.write_string('name');           obj.write_string(head_name);             obj.write_line();
                obj.write_string('header');    obj.write_string('age');            obj.write_string(head_age);              obj.write_line();
                obj.write_string('header');    obj.write_string('sex');            obj.write_string(head_sex);              obj.write_line();
                obj.write_string('header');    obj.write_string('handed');         obj.write_string(head_handed);           obj.write_line();
                obj.write_string('header');    obj.write_string('maps');           obj.write_number(head_maps);             obj.write_line();
                obj.write_string('header');    obj.write_string('train_maps');     obj.write_number(head_trainmaps);        obj.write_line();
                obj.write_string('header');    obj.write_string('trials');         obj.write_number(head_trials);           obj.write_line();
                obj.save();
            end
        end
        % write time (mainly for the end of the experiment)
        function obj = write_time(obj)
            if isempty(obj.file)
                fprintf('main_file: write_time: error. file not opened\n');
            elseif ~strcmp(obj.mode,'w')
                fprintf('main_file: write_time: error. file opened without writing permissions\n');
            else
                % save the end of the experiment
                obj.write_string('header');    obj.write_string('stop');     obj.write_string(datestr(clock()));        obj.write_line();
            end
        end
        
        % field methods: data ---------------------------------------------
        % data descriptor
        function obj = write_datadescriptor(obj)
            if isempty(obj.file)
                fprintf('main_file: write_datadescriptor: error. file not opened\n');
            elseif ~strcmp(obj.mode,'w')
                fprintf('main_file: write_datadescriptor: error. file opened without writing permissions\n');
            else
                obj.write_string('data');
                obj.write_string('subject');
                obj.write_string('map');
                obj.write_string('map_number');
                obj.write_string('trial');
                obj.write_string('stop');
                obj.write_string('targetstation');
                obj.write_string('in_station');
                obj.write_string('in_subline');
                obj.write_string('decision');
                obj.write_string('next_station');
                obj.write_string('next_subline');
                obj.write_string('lefttime');
                obj.write_string('traveltime');
                obj.write_string('meantraveltime');
                obj.write_line();
                obj.save();
            end
        end
        
        % data values
        function obj = write_datavalues(obj,data_instation,data_insubline,data_decision,data_nextstation,data_nextsubline,data_lefttime,data_traveltime,data_travelmeantime)
            if isempty(obj.file)
                fprintf('main_file: write_datavalues: error. file not opened\n');
            elseif ~strcmp(obj.mode,'w')
                fprintf('main_file: write_datavalues: error. file opened without writing permissions\n');
            else
                % field
                obj.write_string('data');
                % subject and trial
                obj.write_number(obj.data_participant);
                obj.write_number(obj.data_map);
                obj.write_number(obj.data_mapnumber);
                obj.write_number(obj.data_trial);
                obj.write_number(obj.data_stop);
                obj.write_number(obj.data_targetstation);
                % station/subline from
                obj.write_number(data_instation);
                obj.write_number(data_insubline);
                % station/subline to
                obj.write_number(data_decision);
                obj.write_number(data_nextstation);
                obj.write_number(data_nextsubline);
                % left time
                obj.write_number(data_lefttime);
                % travel time costs
                obj.write_number(data_traveltime);
                obj.write_number(data_travelmeantime);
                % new line, save
                obj.write_line();
                obj.save();
            end
            %increment the decision number
            obj.data_stop = obj.data_stop + 1;
        end
        
        % field methods: quest --------------------------------------------
        % quest descriptor
        function obj = write_questdescriptor(obj,n)
            if isempty(obj.file)
                fprintf('main_file: write_questdescriptor: error. file not opened\n');
            elseif ~strcmp(obj.mode,'w')
                fprintf('main_file: write_questdescriptor: error. file opened without writing permissions\n');
            else
                % field
                obj.write_string('quest');
                % descriptors
                for i = 1:n
                    obj.write_string(['subline_',num2str(i)]);
                end
                obj.write_line();
                obj.save();
            end
        end
        % quest values
        function obj = write_questvalues(obj,quest)
            if isempty(obj.file)
                fprintf('main_file: write_questvalues: error. file not opened\n');
            elseif ~strcmp(obj.mode,'w')
                fprintf('main_file: write_questvalues: error. file opened without writing permissions\n');
            else
                % field
                obj.write_string('quest');
                % values
                for i = quest
                    obj.write_number(i);
                end
                obj.write_line();
                obj.save();
            end
        end
        
        % general methods -------------------------------------------------
        % find interfaces
        function ifnames = find_interfaces(obj)
            ifnames = dir(obj.tree_dir);
            ifnames = { ifnames.name };
            ifnames([1,2]) = [];
        end
        % set interface
        function obj = set_interface(obj,tree_interface)
            obj.tree_interface = tree_interface;
        end
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
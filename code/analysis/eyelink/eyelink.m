classdef eyelink < handle
    % class for the analysis of eyelink data
    
    properties
        % eyelink file
        % gaze files
        prepath
        postpath
        % interfaces
        eyelink_file
        eyelink_map
        % screen
        screen_rect
        % variables
        gaze
        clusters
        c_durations
        mm_durations
        stations
        smoothedstations
        c_typeprop
        v_typeprop
        c_pathprop
        v_pathprop
    end
    
    methods
        % constructor
        function obj = eyelink()
            % gaze files
            obj.prepath = 'gaze/subway';
            obj.postpath = '.asc';
            % interfaces
            obj.eyelink_file = eyelink_file();
            obj.eyelink_map = eyelink_map();
            % screen
            obj.screen_rect = [0,0,1024,768];
            % variables
            obj.gaze = {};
            obj.clusters = {};
            obj.stations = {};
            obj.c_typeprop = {};
            obj.v_typeprop = [];
            obj.c_pathprop = {};
            obj.v_pathprop = [];
        end
        
        % files -----------------------------------------------------------
        % number of participants
        function i_participant = participants_created(obj)
            i_participant = 1;
            path = [obj.prepath,num2str(i_participant),obj.postpath];
            while exist(path,'file')
                i_participant = i_participant + 1;
                path = [obj.prepath,num2str(i_participant),obj.postpath];
            end
            i_participant = i_participant - 1;
        end
        % read files
        function obj = get_gaze(obj,i_participants)
            % all participants
            if ~exist('i_participants','var')
                i_participants = 1:obj.participants_created();
            end
            % format cell
            if isempty(obj.gaze)
                obj.gaze = cell(1,obj.participants_created());
            end
            % i_participants loop
            for i_participant = i_participants
                path = [obj.prepath,num2str(i_participant),obj.postpath];
                fprintf(['eyelink: read_gaze: reading participant ',num2str(i_participant),'\n']);
                obj.gaze{i_participant} = obj.eyelink_file.read_file(obj.screen_rect,path);
            end
        end
        
        % process ---------------------------------------------------------
        % detect clusters from gaze
        function obj = get_clusters(obj,i_participants)
            % all participants
            if ~exist('i_participants','var')
                i_participants = 1:obj.participants_created();
            end
            obj = eyelink_getclusters(obj,i_participants);
        end
        function obj = get_durations(obj)
            eyelink_getdurations(obj);
        end
        % detect nearest station in grid (if any)
        function obj = get_stations(obj,i_participants)
            % all participants
            if ~exist('i_participants','var')
                i_participants = 1:obj.participants_created();
            end
            obj = eyelink_getstations(obj,i_participants);
        end
        
        % calculate smoothed-gaze values for each station
        function obj = get_smoothedstations(obj,i_participants)
            % all participants
            if ~exist('i_participants','var')
                i_participants = 1:obj.participants_created();
            end
            obj = eyelink_getsmoothedstations(obj,i_participants);
        end
        
        % look how much do we stare at each kind of station
        % (type-of-station proportion)
        function obj = get_typeprop(obj,i_participants)
            % all participants
            if ~exist('i_participants','var')
                i_participants = 1:obj.participants_created();
            end
            obj = eyelink_gettypeprop(obj,i_participants);
        end
        % transform cell c_typeprop to a vector v_typeprop
        function obj = transtypeprop(obj)
            obj = eyelink_transtypeprop(obj);
        end
        % look how much do we stare at stations we're taking
        % (path-we-take proportion)
        function obj = get_pathprop(obj,i_participants)
            % all participants
            if ~exist('i_participants','var')
                i_participants = 1:obj.participants_created();
            end
            obj = eyelink_getpathprop(obj,i_participants);
        end
        % transform cell c_pathprop to a vector v_pathprop
        function obj = transpathprop(obj)
            obj = eyelink_transpathprop(obj);
        end
        
        % draw ------------------------------------------------------------
        % draw gaze fixation
        function obj =  show_gaze(obj,flags)
            if ~exist('flags','var')
                flags = [1,1,0,0,0,0,0,0,0];
            end
            obj.eyelink_map.show_gaze(obj.screen_rect,obj,flags);
        end
    
    % save/load -----------------------------------------------------------
        % save the map into a file
        function obj = save(obj)
            e = obj;
            save(eyelink.savefile(),'e');
        end
    end
    methods(Static)
        % load the map from a file
        function e = load()
            load(eyelink.savefile(),'e');
        end
        
        % give the path where to save
        function f = savefile()
            f = 'analysis_files/eyelink.mat';
        end

    end
end


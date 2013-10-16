classdef demis < handle
    % class for the entropy analysis
    
    properties
    end
    
    methods
        % constructor
        function obj = demis()
        end
        
        % split all maps
        function get_split(~)
            demis_getsplit();
        end
        
        % show maps
        function show_map(~)
            demis_showmap();
        end
        
    % save/load -----------------------------------------------------------
        % save the map into a file
        function obj = save(obj)
            d = obj;
            save(entrop.savefile(),'d');
        end
    end
    methods(Static)
        % load the map from a file
        function d = load()
            load(entrop.savefile(),'d');
        end
        
        % give the path where to save
        function f = savefile()
            f = 'analysis_files/demis.mat';
        end
    end
end
    

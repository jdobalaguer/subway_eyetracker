classdef analysis_equation < handle
    % class for analysis equations
    
    properties
        name
        expressions
        values
    end
    
    methods
        % constructor
        function obj = analysis_equation()
            obj.name = '';
            obj.expressions = {};
            obj.values = {};
        end
    end
    
end


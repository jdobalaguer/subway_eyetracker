classdef analysis_meta
    % class for meta variables
    
    %{
    notes:
    
    analysis_meta is both used for calculating expressions and keeping variables
        - calculating an expression involves one only participant.
          doesn't track variables
          thus:
            name = {}
            expression = {}
            index_name{i_index}
            index_value{i_index}
            value
            variables = {};
        - keeping variables involves all participants
          tracks for other variables using this instance
          thus:
            index_name{i_index}
            index_value{i_participant}{i_index}
            value{i_participant}
            variables{i_variables};
    %}
    
    properties
        name
        expression
        index_name
        index_value
        value
        variables
    end
    
    methods
        % constructor
        function obj = analysis_meta(nb_participants)
            obj.name = 'new';
            obj.expression = '';
            obj.index_name = {};
            obj.index_value = cell(1,nb_participants);
            obj.value = cell(1,nb_participants);
            obj.variables = {};
        end
    end
end


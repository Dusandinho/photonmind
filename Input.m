classdef Input < handle
    properties
        structure
        parameter
        range
    end
    methods
        function obj = Input(structure, parameter, range)
            obj.structure = structure;
            obj.parameter = parameter;
            obj.range = range;
        end
    end
end

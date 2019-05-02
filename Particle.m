classdef Particle < handle
    properties
        parameters = struct('structure', {}, 'parameter', {}, 'range', {})
        position
        best_position
        FOM
        best_FOM = 0
        velocity
    end
    methods
        function obj = Particle
            for n = 1:length(obj.parameters)
                obj.position(end + 1) = obj.parameters(n).range(1) + (obj.parameters(n).range(2) - obj.parameters(n).range(1))*rand;
            end
            obj.best_position = obj.position;
            obj.velocity = zeros(size(obj.position));
        end

        function add_parameter(obj, structure, parameter, range)
            obj.parameters(end + 1) = struct('structure', {structure}, 'parameter', {parameter}, 'range', {range});
        end

        function remove_parameters(obj, index)
            obj.parameters(index) = [];
        end
    end
end

classdef Particle < handle
    properties
        inputs = struct('structure', {}, 'parameter', {}, 'range', {})
        position
        best_position
        FOM
        best_FOM = 0
        velocity
    end
    methods
        function obj = Particle
            % for the lack of a better method for now, manually enter inputs here
            obj.inputs(end + 1) = struct('structure', {''}, 'parameter', {''}, 'range', {[0 0]});
            
            for n = 1:length(obj.inputs)
                obj.position(end + 1) = obj.inputs(n).range(1) + (obj.inputs(n).range(2) - obj.inputs(n).range(1))*rand;
            end
            obj.best_position = obj.position;
            obj.velocity = zeros(size(obj.position));
        end
    end
end

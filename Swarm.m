classdef Swarm < handle
    properties
        particles
        best_position
        best_FOM = 0
        stag_FOM = 0
        intertia = 0.7
        c1 = 2
        c2 = 2
    end
    methods
        function obj = Swarm(num_particles)
            obj.particles = Particle;
            for n = 2:num_particles
                obj.particles(end + 1) = Particle;
            end
            obj.best_position = obj.particles(1).best_position;
        end

        function swarm_regroup(obj, threshold)
            obj.stag_FOM = obj.stag_FOM + 1;
            if obj.stag_FOM >= threshold
                obj.stag_FOM = 0;
                for n = 1:length(obj.particles)
                    for nn = 1:length(obj.particles(n).inputs)
                        obj.particles(n).position(nn)...
                            = obj.particles(n).inputs(nn).range(1)...
                            + (obj.particles(n).inputs(nn).range(2)...
                            - obj.particles(n).inputs(nn).range(1))*rand;
                    end
                    obj.particles(n).best_position...
                        = obj.particles(n).position;
                    obj.particles(n).velocity...
                        = zeros(size(obj.particles(n).position));
                    obj.particles(n).FOM = 0;
                    obj.particles(n).best_FOM = 0;
                end
                obj.best_position = obj.particles(n).position;
                obj.best_FOM = 0;
            end
        end
    end
end

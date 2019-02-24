classdef PSO < handle
    properties
        num_particles
        particles
        best_position
        best_FOM = 0
        intertia = 1.1
        c1 = 2
        c2 = 2
        get_data = true;
    end
    methods
        function obj = PSO(num_particles)
            obj.num_particles = num_particles;
            obj.particles = Particle;
            for n = 2:num_particles
                obj.particles(end + 1) = Particle;
            end
            obj.best_position = obj.particles(1).best_position;
        end
        
        function run(obj, num_iterations, data)
            figure(1);
            switch nargin
                case 2
                    obj.get_data = true;
            end
            
%             path(path, 'C:\Program Files\Lumerical\device\api\matlab');
%             h = appopen('device');
%             path(path, 'C:\Program Files\Lumerical\mode\api\matlab');
%             r = appopen('mode');

            path(path, 'C:\Program Files\Lumerical\fdtd\api\matlab');
            h = appopen('fdtd');
            
            v = waitbar(0, 'Running PSO...');
            count = 0;
            for k = 1:num_iterations
                for m = 1:length(obj.particles)
                    waitbar(count/(num_iterations*length(obj.particles)));
%                     code = strcat('load("H:/photonmind-master/Devices/disk_zipper_junc.ldev");',...
%                         'switchtolayout;');
                    code = strcat('load("H:/photonmind-master/Devices/grating_coupler_2D_TM.fsp");',...
                        'switchtolayout;');
                    appevalscript(h, code);
                    
                    for n = 1:length(obj.particles(m).inputs)
                        code = strcat('select("',char(obj.particles(m).inputs(n).structure),'");',...
                            'set("',char(obj.particles(m).inputs(n).parameter),'", ',num2str(obj.particles(m).position(n)),');');
                        appevalscript(h, code);
                    end
                    
                    code = strcat('run;');
                    appevalscript(h, code);
                    
%                     code = strcat('load("H:/photonmind-master/Devices/disk_FDE.lms");',...
%                         'switchtolayout;',...
%                         'select("np density");',...
%                         'set("V_anode_index", 1);',...
%                         'importdataset("disk_zipper_junc.mat");',...
%                         'findmodes;',...
%                         'a = getdata("mode1", "neff");',...
%                         'loss = imag(a);',...
%                         'switchtolayout;',...
%                         'select("np density");',...
%                         'set("V_anode_index", 3);',...
%                         'findmodes;',...
%                         'b = getdata("mode1", "neff");',...
%                         'del_neff = abs(a - b);',...
%                         'fom = del_neff/loss;');
                    code = strcat('port = getresult("FDTD::ports::port 2", "T");',...
                        'T = port.T;',...
                        'T_min = abs(min(T));');
                    appevalscript(h, code);
                    obj.particles(m).FOM = appgetvar(h, 'T_min')';
                    
                    if obj.particles(m).FOM >= obj.best_FOM
                        obj.best_FOM = obj.particles(m).FOM;
                        obj.best_position = obj.particles(m).position;
                    end
                    
                    if obj.particles(m).FOM >= obj.particles(m).best_FOM
                        obj.particles(m).best_FOM = obj.particles(m).FOM;
                        obj.particles(m).best_position = obj.particles(m).position;
                    end
                    
                    data.examples(end + 1).features = obj.particles(m).position;
                    data.examples(end).labels = obj.particles(m).FOM;
%                     clrs=['r','g','b','c','m','y','k'];
                    scatter(obj.particles(m).position(1), obj.particles(m).position(2));
                    ylim([0.1 0.9]);  xlim([2e-8 2e-7]);
                    hold on;
                    
                    obj.particles(m).velocity = obj.intertia*obj.particles(m).velocity...
                        + obj.c1*rand*(obj.particles(m).best_position - obj.particles(m).position)...
                        + obj.c2*rand*(obj.best_position - obj.particles(m).position);
                    obj.particles(m).position = obj.particles(m).position + obj.particles(m).velocity;
                    
                    for n = 1:length(obj.particles(m).inputs)
                        if obj.particles(m).position(n) > obj.particles(m).inputs(n).range(2)
                            obj.particles(m).position(n) = obj.particles(m).inputs(n).range(2);
%                             obj.particles(m).position(n) = obj.particles(m).inputs(n).range(1) + (obj.particles(m).inputs(n).range(2) - obj.particles(m).inputs(n).range(1))*rand;
%                             obj.particles(m).position = obj.best_position;
                        elseif obj.particles(m).position(n) < obj.particles(m).inputs(n).range(1)
                            obj.particles(m).position(n) = obj.particles(m).inputs(n).range(1);
%                             obj.particles(m).position(n) = obj.particles(m).inputs(n).range(1) + (obj.particles(m).inputs(n).range(2) - obj.particles(m).inputs(n).range(1))*rand;
%                             obj.particles(m).position = obj.best_position;
                        end
                    end
                    count = count + 1;
                end
            end
            close(v);
        end
    end
end

classdef PSO < handle
    properties
        particles
        best_position
        best_FOM = 0
        intertia = 1.1
        c1 = 2
        c2 = 2
        data
        get_data
    end
    methods
        function obj = PSO(num_particles, data)
            obj.particles = Particle;
            for n = 2:num_particles
                obj.particles(end + 1) = Particle;
            end
            obj.best_position = obj.particles(1).best_position;
            switch nargin
                case 1
                    obj.get_data = false;
                case 2
                    obj.data = data;
                    obj.get_data = true;
            end
        end
        
        function run(obj, num_iterations, plot_data)
            switch nargin
                case 2
                    plot_data = false;
                case 3
                    figure(1);
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
                    
                    % update structure parameters
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

                    % get FOM
                    code = strcat('port = getresult("FDTD::ports::port 2", "T");',...
                        'T = port.T;',...
                        'T_min = abs(min(T));');
                    appevalscript(h, code);
                    obj.particles(m).FOM = appgetvar(h, 'T_min')';
                    
                    % update global bests
                    if obj.particles(m).FOM >= obj.best_FOM
                        obj.best_FOM = obj.particles(m).FOM;
                        obj.best_position = obj.particles(m).position;
                    end
                    
                    % update particle bests
                    if obj.particles(m).FOM >= obj.particles(m).best_FOM
                        obj.particles(m).best_FOM = obj.particles(m).FOM;
                        obj.particles(m).best_position = obj.particles(m).position;
                    end
                    
                    % add example to dataset
                    if obj.get_data == true
                        obj.data.examples(end + 1).features = obj.particles(m).position;
                        obj.data.examples(end).labels = obj.particles(m).FOM;
                    end
                    
                    % plot data
                    if plot_data == true
                        scatter(obj.particles(m).position(1), obj.particles(m).position(2));
                        ylim([0.1 0.9]);  xlim([2e-8 2e-7]);
                        hold on;
                    end
                    
                    % update velocity and position of particle
                    obj.particles(m).velocity = obj.intertia*obj.particles(m).velocity...
                        + obj.c1*rand*(obj.particles(m).best_position - obj.particles(m).position)...
                        + obj.c2*rand*(obj.best_position - obj.particles(m).position);
                    obj.particles(m).position = obj.particles(m).position + obj.particles(m).velocity;
                    
                    % boundary condition
                    for n = 1:length(obj.particles(m).inputs)
                        if obj.particles(m).position(n) > obj.particles(m).inputs(n).range(2)
                            obj.particles(m).position(n) = obj.particles(m).inputs(n).range(2);
                        elseif obj.particles(m).position(n) < obj.particles(m).inputs(n).range(1)
                            obj.particles(m).position(n) = obj.particles(m).inputs(n).range(1);
                        end
                    end
                    
                    count = count + 1;
                end
            end
            close(v);
        end
    end
end

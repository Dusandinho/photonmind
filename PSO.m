classdef PSO < handle
    properties
        swarms
        file_name
        data
        get_data
        outputs = struct('monitor', {}, 'attribute', {})
    end
    methods
        function obj = NNPSO(file_name, num_swarms, num_particles, data)
            switch nargin
                case 3
                    obj.get_data = false;
                case 4
                    obj.data = data;
                    obj.get_data = true;
            end

            obj.file_name = file_name;
            obj.swarms = Swarm(num_particles);
            for n = 2:num_swarms
                obj.swarms(end + 1) = Swarm(num_particles);
            end
            obj.outputs = data.outputs;
        end

        function run(obj, num_iterations, plot_data)
            switch nargin
                case 2
                    plot_data = false;
                case 3
                    figure(1);
            end

            path(path, 'C:\Program Files\Lumerical\fdtd\api\matlab');
            h = appopen('fdtd');

            v = waitbar(0, 'Running PSO...');
            count = 0;
            for k = 1:num_iterations
                for j = 1:length(obj.swarms)
                    for m = 1:length(obj.swarms(j).particles)
                        waitbar(count/(num_iterations*length(obj.swarms)...
                            *length(obj.swarms(j).particles)));
                        code = strcat('load("',char(obj.file_name),'");',...
                            'switchtolayout;');
                        appevalscript(h, code);

                        % update structure parameters
                        for n = 1:length(obj.swarms(j).particles(m).parameters)
                            code = strcat('select("',...
                                char(obj.swarms(j).particles(m)...
                                .parameters(n).structure),'");',...
                                'set("',char(...
                                obj.swarms(j).particles(m)...
                                .parameters(n).parameter),...
                                '", ',num2str(obj.swarms(j)...
                                .particles(m).position(n)),');');
                            appevalscript(h, code);
                        end

                        % RUN!
                        code = strcat('run;');
                        appevalscript(h, code);

                        % get FOM
                        % for now, this will be custom-written
                        % for example,
                        % code = strcat(...
                        %     'port = getresult("FDTD::ports::port1", "T");',...
                        %     'FOM = min(port.T);');

                        labels = [];
                        for n = 1:length(obj.outputs)
                            code = strcat('monitor = getresult("',...
                                char(obj.outputs(n).monitor),'");',...
                                'labels = ',char(obj.outputs(n).attribute),';');
                            appevalscript(h, code);
                            labels = cat(2, labels, appgetvar(h, 'labels')');
                        end
                        obj.swarms(j).particles(m).FOM = max(labels);

                        % update global bests
                        if obj.swarms(j).particles(m).FOM...
                                >= obj.swarms(j).best_FOM
                            obj.swarms(j).best_FOM...
                                = obj.swarms(j).particles(m).FOM;
                            obj.swarms(j).best_position...
                                = obj.swarms(j).particles(m).position;
                            obj.swarms(j).stag_FOM = 0;
                        end

                        % update particle bests
                        if obj.swarms(j).particles(m).FOM...
                                >= obj.swarms(j).particles(m).best_FOM
                            obj.swarms(j).particles(m).best_FOM...
                                = obj.swarms(j).particles(m).FOM;
                            obj.swarms(j).particles(m).best_position...
                                = obj.swarms(j).particles(m).position;
                        end

                        % add example to dataset (if applicable)
                        if obj.get_data == true
                            obj.data.examples(end + 1).features...
                                = obj.swarms(j).particles(m).position;
                            obj.data.examples(end).labels = labels;
                        end

                        % plot data
                        if plot_data == true
                            scatter(obj.swarms(j).particles(m).position(1),...
                                obj.swarms(j).particles(m).position(2));
                            ylim(obj.swarms(j).particles(1)...
                                .parameters(2).range);
                            xlim(obj.swarms(j).particles(1)...
                                .parameters(1).range);
                            hold on;
                        end

                        % update velocity and position of particle
                        obj.swarms(j).particles(m).velocity...
                            = obj.swarms(j).intertia*obj.swarms(j)...
                            .particles(m).velocity...
                            + obj.swarms(j).c1*rand*(obj.swarms(j)...
                            .particles(m).best_position...
                            - obj.swarms(j).particles(m).position)...
                            + obj.swarms(j).c2*rand...
                            *(obj.swarms(j).best_position...
                            - obj.swarms(j).particles(m).position);
                        obj.swarms(j).particles(m).position...
                            = obj.swarms(j).particles(m).position...
                            + obj.swarms(j).particles(m).velocity;

                        % boundary condition NEED A SMARTER METHOD for now, the
                        % particle is moved to the boundary it tries to cross
                        for n = 1:length(obj.swarms(j).particles(m).parameters)
                            if obj.swarms(j).particles(m).position(n)...
                                    > obj.swarms(j).particles(m)...
                                    .parameters(n).range(2)
                                obj.swarms(j).particles(m).position(n)...
                                    = obj.swarms(j).particles(m)...
                                    .parameters(n).range(2);
                            elseif obj.swarms(j).particles(m).position(n)...
                                    < obj.swarms(j).particles(m)...
                                    .parameters(n).range(1)
                                obj.swarms(j).particles(m).position(n)...
                                    = obj.swarms(j).particles(m)...
                                    .parameters(n).range(1);
                            end
                        end
                        count = count + 1;
                    end
                end
            end
            close(v);
        end
    end
end

classdef Data < handle
    properties
        file_name
        inputs = struct('structure', {}, 'parameter', {}, 'range', {})
        outputs = struct('monitor', {}, 'attribute', {})
        examples = struct('features', {}, 'labels', {})
    end
    methods
        function obj = Data(file_name)
            obj.file_name = file_name;
        end

        function add_input(obj, structure, parameter, range)
            obj.inputs(end + 1) = struct('structure', {structure},...
                'parameter', {parameter}, 'range', {range});
        end

        function add_output(obj, monitor, attribute)
            obj.outputs(end + 1) = struct('monitor', {monitor},...
                'attribute', {attribute});
        end

        function get_examples_random(obj, num_sim)
            path(path, 'C:\Program Files\Lumerical\fdtd\api\matlab');
            h = appopen('fdtd');

            % create a list of randomized features
            featureset = zeros(num_sim, length(obj.inputs));
            for m = 1:num_sim
                for n = 1:length(obj.inputs)
                    featureset(m, n) = obj.inputs(n).range(1)...
                        + diff(obj.inputs(n).range)*rand;
                end
            end

            % simulate each entry in featureset
            % store with results as a new example
            v = waitbar(0, 'Acquiring data...');
            for m = 1:size(featureset, 1)
                waitbar(m/size(featureset, 1));
                labels = obj.get_labels(featureset(m, :), h);
                obj.examples(end + 1).features = featureset(m, :);
                obj.examples(end).labels = labels;
            end
            close(v);
        end

        function get_examples_uniform(obj, resolution)
            featureset = zeros(length(obj.inputs),...
                resolution^length(obj.inputs));
            if input(sprintf('This will run %d simulations. Proceed? Y/N: ',...
                    size(featureset, 2)), 's') ~= 'y'
                return;
            end

            path(path, 'C:\Program Files\Lumerical\device\api\matlab');
            h = appopen('fdtd');

            % create a list of uniformly swept features
            for m = 1:length(obj.inputs)
                sequence = linspace(obj.inputs(m).range(1),...
                    obj.inputs(m).range(2), resolution);
                sequence = repmat(sequence,...
                    [resolution^(length(obj.inputs) - m), 1]);
                featureset(m, :) = repmat(sequence(:)',...
                    [1, resolution^(m - 1)]);
            end
            featureset = featureset';

            % simulate each entry in featureset
            % store with results as a new example
            v = waitbar(0, 'Acquiring data...');
            for m = 1:size(featureset, 1)
                labels = obj.get_labels(featureset(m, :), h);
                obj.examples(end + 1).features = featureset(m, :);
                obj.examples(end).labels = labels;
                waitbar(m/size(featureset, 1));
            end
            close(v);
        end

        function check_single(obj, features)
            path(path, 'C:\Program Files\Lumerical\fdtd\api\matlab');
            h = appopen('fdtd');
            obj.get_labels(features, h);
        end

        function labels = get_labels(obj, features, h)
            % open file and switch to layout (for changes)
            code = strcat('load("',char(obj.file_name),'");',...
                'switchtolayout;');
            appevalscript(h, code);

            % automatically change the features (based on the input struct)
            % THIS MAY BE REWRITTEN FOR CUSTOM NEEDS
            for n = 1:length(obj.inputs)
                code = strcat('select("',char(obj.inputs(n).structure),'");',...
                    'set("',char(obj.inputs(n).parameter),'", ',...
                    num2str(features(n)),');');
                appevalscript(h, code);
            end

            % RUN!
            code = strcat('run;');
            appevalscript(h, code);

            % automatically extract the labels (based on the output struct)
            % THIS MAY BE REWRITTEN FOR CUSTOM NEEDS
            labels = [];
            for n = 1:length(obj.outputs)
                code = strcat('monitor = getresult("',...
                    char(obj.outputs(n).monitor),'");',...
                    'labels = ',char(obj.outputs(n).attribute),';');
                appevalscript(h, code);
                labels = cat(2, labels, appgetvar(h, 'labels')');
            end
        end

        function shuffle(obj)
            obj.examples = obj.examples(randperm(length(obj.examples)));
        end
    end
end

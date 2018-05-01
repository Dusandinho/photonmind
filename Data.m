classdef Data < handle
    properties
        file_name
        inputs = struct('structure', {}, 'parameter', {}, 'range', {})
        outputs = struct('port', {}, 'attribute', {})
        examples = struct('features', {}, 'labels', {})
        wavelengths = [1.4e-6, 1.7e-6]
    end
    methods
        function obj = Data
            obj.file_name = input('Enter the FDTD file path: ', 's');

            while length(obj.inputs) < 1 || input('Add another input? Y/N: ', 's') == 'y'
                obj.inputs(end + 1).structure = input('Enter the structure name: ', 's');
                obj.inputs(end).parameter = input('Enter the parameter name: ', 's');
                user_range = input('Enter the parameter range as a 1x2 matrix: ');
                obj.inputs(end).range = [(user_range(1) - 0.1*diff(user_range)),...
                    (user_range(2) + 0.1*diff(user_range))];
            end

            while length(obj.outputs) < 1 || input('Add another output? Y/N: ', 's') == 'y'
                obj.outputs(end + 1).port = input('Enter the port name: ', 's');
                obj.outputs(end).attribute = input('Enter the port attribute: ', 's');
            end
        end

        function get_examples_random(obj, num_sim)
            path(path, 'C:\Program Files\Lumerical\FDTD\api\matlab');
            h = appopen('fdtd');

            featureset = zeros(num_sim, length(obj.inputs));
            for m = 1:num_sim
                for n = 1:length(obj.inputs)
                    featureset(m, n) = obj.inputs(n).range(1) + diff(obj.inputs(n).range)*rand;
                end
            end

            for m = 1:size(featureset, 1)
                labels = obj.simulate(featureset(m, :), h);
                obj.examples(end + 1).features = featureset(m, :);
                obj.examples(end).labels = labels;
            end
        end

        function get_examples_uniform(obj, resolution)
            path(path, 'C:\Program Files\Lumerical\FDTD\api\matlab');
            h = appopen('fdtd');

            featureset = zeros(length(obj.inputs), resolution^length(obj.inputs));
            for m = 1:length(obj.inputs)
                sequence = linspace(obj.inputs(m).range(1), obj.inputs(m).range(2), resolution);
                sequence = repmat(sequence, [resolution^(length(obj.inputs) - m), 1]);
                featureset(m, :) = repmat(sequence(:)', [1, resolution^(m - 1)]);
            end

            for m = 1:size(featureset, 1)
                labels = obj.simulate(featureset(m, :), h);
                obj.examples(end + 1).features = featureset(m, :);
                obj.examples(end).labels = labels;
            end
        end

        function labels = simulate(obj, features, h)
            code = strcat('load("',char(obj.file_name),'");',...
                'switchtolayout;',...
                'setglobalsource("wavelength start", ',chat(obj.wavelengths(1)),');',...
                'setglobalsource("wavelength stop", ',chat(obj.wavelengths(2)),');');
            appevalscript(h, code);

            for n = 1:length(obj.inputs)
                code = strcat('select("',char(obj.inputs(n).structure),'");',...
                    'set("',char(obj.inputs(n).parameter),'", ',num2str(features(n)),');');
                appevalscript(h, code);
            end

            code = strcat('run;');
            appevalscript(h, code);

            labels = [];
            for n = 1:length(obj.outputs)
                code = strcat('port = getresult("FDTD::ports::',char(obj.outputs(n).port),'","T");',...
                    'T = port.T;',...
                    'lam = port.lambda;',...
                    'T_min = min(port.T);',...
                    'T_max = max(port.T);',...
                    'lam_T_min = port.lambda(find(port.T, min(port.T)));',...
                    'lam_T_max = port.lambda(find(port.T, max(port.T)));');
                appevalscript(h, code);
                labels = cat(2, labels, fliplr(appgetvar(h, char(obj.outputs(n).attribute))'));
            end
        end

        function remove_edge_minimums(obj)
            ind = find(strcmp({obj.outputs.attribute}, 'lam_T_min') == 1);
            m = 1;
            while m < length(obj.examples)
                if obj.examples(m).labels(ind) == obj.wavelengths(1)...
                    || obj.examples(m).labels(ind) == obj.wavelengths(2)
                    obj.examples(m) = [];
                    m = m - 1;
                end
                m = m + 1;
            end
        end

        function remove_bad_spectrums(obj, T_min)
            m = 1;
            while m < length(obj.examples)
                if abs(min(obj.examples(m).labels)) < abs(T_min)
                    obj.examples(m) = [];
                    m = m - 1;
                end
                m = m + 1;
            end
        end
    end
end

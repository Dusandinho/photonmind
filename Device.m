classdef Device < handle
    properties
        model
        constants
        conditions
        features
    end
    methods
        function obj = Device(model)
            obj.model = model;
        end

        function add_constant(obj, index, constant)
            obj.constants(index).value = constant;
        end

        function remove_constant(obj, index)
            obj.constants(index).value = [];
        end

        function add_condition(obj, index, value, tolerance)
            obj.conditions(index).value = value;
            obj.conditions(index).tolerance = tolerance;
        end

        function remove_condition(obj, index)
            obj.conditions(index).value = [];
            obj.conditions(index).tolerance = [];
        end

        function solve(obj, resolution)
            v = waitbar(0, 'Solving...');

            featureset = obj.get_uniform_featureset(resolution);

            for n = 1:length(featureset)
                waitbar(n/length(featureset));
                features = featureset(n, :);
                labels = obj.model.infer(features);
                if obj.check_conditions(labels), obj.print_device(features, labels); end
            end

            close(v);
        end

        function y = get_uniform_featureset(obj, resolution)
            for n = 1:length(obj.model.data.inputs)
                sequence = linspace(obj.model.data.inputs(n).range(1),...
                    obj.model.data.inputs(n).range(2), resolution);
                sequence = repmat(sequence, [resolution^(length(obj.model.data.inputs) - n), 1]);
                featureset(n, :) = repmat(sequence(:), [resolution^(n - 1), 1]);
            end

            for n = 1:length(obj.constants)
                if ~isempty(obj.constants(n).value)
                    featureset(n, :) = obj.constants(n).value;
                end
            end
            y = unique(featureset', 'rows');
        end

        function y = check_conditions(obj, labels)
            y = true;
            for n = 1:length(obj.conditions)
                if abs(labels(n) - obj.conditions(n).value) > abs(obj.conditions(n).tolerance)
                    y = false;
                end
            end
        end

        function print_device(obj, features, labels)
            for n = 1:length(obj.model.data.inputs)
                disp([obj.model.data.inputs(n).parameter, ' = ', num2str(features(n))]);
            end

            for n = 1:length(obj.model.data.outputs)
                disp([obj.model.data.outputs(n).attribute, ' = ', num2str(labels(n))]);
            end

            fprintf('\n');
        end
    end
end

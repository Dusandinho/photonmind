classdef Device < handle
    properties
        model
        features
    end
    methods
        function obj = Device(model)
            obj.model = model;
        end

        function parameter_sweep(obj, resolution, range)
            v = waitbar(0, 'Optimizing...');
            featureset = zeros(length(obj.model.data.inputs), resolution^length(obj.model.data.inputs));
            for i = 1:length(obj.model.data.inputs)
                sequence = linspace(obj.model.data.inputs(i).range(1), obj.model.data.inputs(i).range(2), resolution);
                sequence = repmat(sequence, [resolution^(length(obj.model.data.inputs) - i), 1]);
                featureset(i, :) = repmat(sequence(:)', [1, resolution^(i - 1)]);
            end

            best = 0;
            for i = 1:length(featureset)
                waitbar(i/length(featureset));
                labels = obj.model.infer(featureset(:, i)');
                condition = labels(2) > range(1) && labels(2) < range(2);
                if condition && labels(1) < best
                    best = labels(1);
                    obj.features = featureset(:, i)';
                    featureset(:, i)'
                end
            end
            % disp(['T = ', num2str(best)]);
            close(v);
        end
    end
end

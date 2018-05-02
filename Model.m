classdef Model < handle
    properties
        inputs
        outputs
        weights
        biases
        activation_functions
        feature_ranges
        label_ranges
    end
    methods
        function obj = Model(inputs, outputs, weights, biases, activation_functions, feature_ranges, label_ranges)
            obj.inputs = inputs;
            obj.outputs = outputs;
            obj.weights = weights;
            obj.biases = biases;
            obj.activation_functions = activation_functions;
            obj.feature_ranges = feature_ranges;
            obj.label_ranges = label_ranges;
        end

        function y = infer(obj, features)
            y = obj.scale(features);
            for n = 1:length(obj.weights)
                y = y*obj.weights{n} + obj.biases{n};
                y = obj.ACT(y, obj.activation_functions{n + 1});
            end
            y = obj.descale(y);
        end

        function y = ACT(obj, x, activation_function)
            switch activation_function
                case 'sig'
                    y = 1./(1 + exp(-x));
                case 'relu'
                    y = max(0, x);
                case 'tanh'
                    y = tanh(x);
                case 'none'
                    y = x;
            end
        end

        function y = scale(obj, x)
            y = (x - obj.feature_ranges(1, :))./(obj.feature_ranges(2, :) - obj.feature_ranges(1, :));
        end

        function y = descale(obj, x)
            y = obj.label_ranges(1, :) + x.*(obj.label_ranges(2, :) - obj.label_ranges(1, :));
        end
    end
end

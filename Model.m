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
    end
end

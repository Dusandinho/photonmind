classdef Layer < handle
    properties
        type
        num_neurons
        activation_function
        net
        out
        dw
        db
    end
    methods
        function obj = Layer(type, num_neurons, activation_function)
            obj.type = type;
            obj.num_neurons = num_neurons;
            switch nargin
                case 2
                    obj.activation_function = 'relu';
                case 3
                    obj.activation_function = activation_function;
            end
        end

        function feed(obj, prev_layer, weights, biases)
            obj.net = prev_layer.out*weights + biases;
            obj.out = obj.ACT(obj.net);
        end

        function y = ACT(obj, x)
            switch obj.activation_function
                case 'sig'
                    y = 1./(1 + exp(-x));
                case 'relu'
                    y = max(0, x);
                case 'lrelu'
                    if x > 0
                        y = x;
                    else
                        y = 0.01*x;
                    end
                case 'elu'
                    if x > 0
                        y = x;
                    else
                        y = exp(x) - 1;
                    end
                case 'tanh'
                    y = tanh(x);
                case 'none'
                    y = x;
            end
        end

        function y = dACT(obj, x)
            switch obj.activation_function
                case 'sig'
                    y = obj.ACT(x).*(1 - obj.ACT(x));
                case 'relu'
                    y = double(heaviside(x));
                case 'lrelu'
                    if x > 0
                        y = ones(size(x));
                    else
                        y = 0.01*ones(size(x));
                    end
                case 'elu'
                    if x > 0
                        y = ones(size(x));
                    else
                        y = exp(x);
                    end
                case 'tanh'
                    y = 1 - obj.ACT(x).^2;
                case 'none'
                    y = 1;
            end
        end
    end
end

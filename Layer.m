classdef Layer
    properties
        type
        num_neurons
        activation_function
    end
    methods
        function obj = Layer(type, num_neurons, activation_function)
            obj.type = type;
            switch nargin
                case 1
                    obj.num_neurons = input('Enter the number of neurons in this layer: ');
                    obj.activation_function = input('Enter the activation function for this layer: ', 's');
                case 3
                    obj.num_neurons = num_neurons;
                    obj.activation_function = activation_function;
            end
        end

        function y = ACT(obj, x)
            switch obj.activation_function
                case 'sig'
                    y = 1./(1 + exp(-x));
                case 'relu'
                    y = max(0, x);
                case 'tanh'
                    y = tanh(x);
            end
        end

        function y = dACT(obj, x)
            switch obj.activation_function
                case 'sig'
                    y = obj.ACT(x).*(1 - obj.ACT(x));
                case 'relu'
                    y = heaviside(x);
                case 'tanh'
                    y = 1 - obj.ACT(x).^2;
            end
        end
    end
end

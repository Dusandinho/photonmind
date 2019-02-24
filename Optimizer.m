classdef Optimizer < handle
    properties
        type
        learning_rate = 1e-4
        momentum = 0.9
        beta1 = 0.9
        beta2 = 0.999
        epsilon = 1e-8
        
        vt_weights
        vt_biases
        mt_weights
        mt_biases
    end
    methods
        function obj = Optimizer(type, mind)
            switch type
                case 'SGD'
                    obj.type = 'SGD';
                    for n = 1:(length(mind.layers) - 1)
                        obj.vt_weights{n} = zeros(mind.layers(n).num_neurons, mind.layers(n + 1).num_neurons);
                        obj.vt_biases{n} = zeros(1, mind.layers(n + 1).num_neurons);
                    end
                case 'Adam'
                    obj.type = 'Adam';
                    for n = 1:(length(mind.layers) - 1)
                        obj.vt_weights{n} = zeros(mind.layers(n).num_neurons, mind.layers(n + 1).num_neurons);
                        obj.vt_biases{n} = zeros(1, mind.layers(n + 1).num_neurons);
                        obj.mt_weights{n} = zeros(mind.layers(n).num_neurons, mind.layers(n + 1).num_neurons);
                        obj.mt_biases{n} = zeros(1, mind.layers(n + 1).num_neurons);
                    end
            end
        end
        
        function optimize(obj, mind)
            switch obj.type
                case 'SGD'
                    obj.SGD(mind);
                case 'Adam'
                    obj.Adam(mind);
            end
        end
        
        function SGD(obj, mind)
            for n = 1:length(mind.weights)
                mind.weights{n} = mind.weights{n} - obj.learning_rate*mind.layers(n + 1).dw - obj.momentum*obj.vt_weights{n};
                mind.biases{n} = mind.biases{n} - obj.learning_rate*mind.layers(n + 1).db - obj.momentum*obj.vt_biases{n};
                
                obj.vt_weights{n} = obj.learning_rate*mind.layers(n + 1).dw + obj.momentum*obj.vt_weights{n};
                obj.vt_biases{n} = obj.learning_rate*mind.layers(n + 1).db + obj.momentum*obj.vt_biases{n};
            end
        end
        
        function Adam(obj, mind)
            for n = 2:length(mind.weights)
                obj.vt_weights{n} = obj.beta2*obj.vt_weights{n} + (1 - obj.beta2)*(mind.layers(n + 1).dw).*(mind.layers(n + 1).dw);
                obj.vt_biases{n} = obj.beta2*obj.vt_biases{n} + (1 - obj.beta2)*(mind.layers(n + 1).db).*(mind.layers(n + 1).db);
                obj.mt_weights{n} = obj.beta1*obj.mt_weights{n} + (1 - obj.beta1)*mind.layers(n + 1).dw;
                obj.mt_biases{n} = obj.beta1*obj.mt_biases{n} + (1 - obj.beta1)*mind.layers(n + 1).db;
                
                mind.weights{n} = mind.weights{n} - obj.learning_rate*obj.mt_weights{n}/(1 - obj.beta1)...
                    ./(sqrt(obj.vt_weights{n}/(1 - obj.beta2)) + obj.epsilon);
                mind.biases{n} = mind.biases{n} - obj.learning_rate*obj.mt_biases{n}/(1 - obj.beta1)...
                    ./(sqrt(obj.vt_biases{n}/(1 - obj.beta2)) + obj.epsilon);
            end
        end
    end
end

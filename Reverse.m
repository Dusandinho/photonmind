classdef Mind < Model
    properties
        model
        features
        preference
    end
    methods
        function obj = Mind(model)
            obj@Model(model.data);
            obj.model = model;

            for n = 1:length(obj.examples.train)
                tmp = obj.examples.train(n).features;
                obj.examples.train(n).features = obj.examples.train(n).labels;
                obj.examples.train(n).labels = tmp;
            end

            for n = 1:length(obj.examples.validate)
                tmp = obj.examples.validate(n).features;
                obj.examples.validate(n).features = obj.examples.validate(n).labels;
                obj.examples.validate(n).labels = tmp;
            end

            for n = 1:length(obj.examples.test)
                tmp = obj.examples.test(n).features;
                obj.examples.test(n).features = obj.examples.test(n).labels;
                obj.examples.test(n).labels = tmp;
            end

            obj.feature_ranges = obj.model.label_ranges;
            obj.label_ranges = obj.model.feature_ranges;

            obj.weights{1} = obj.model.weights{2}';
            obj.weights{2} = obj.model.weights{1}';

            obj.biases{1} = obj.model.biases{1};
            obj.biases{2} = normrnd(0, 1, [1, size(obj.weights{2}, 2)])/size(obj.weights{2}, 1);

            % obj.weights{1} = obj.model.weights{3}';
            % obj.weights{2} = obj.model.weights{2}';
            % obj.weights{3} = obj.model.weights{1}';
            %
            % obj.biases{1} = obj.model.biases{2};
            % obj.biases{2} = obj.model.biases{1};
            % obj.biases{3} = normrnd(0, 1, [1, size(obj.weights{3}, 2)])/size(obj.weights{3}, 1);
        end

        function solve(obj, labels)
            obj.features = obj.infer(labels);
        end
    end
end

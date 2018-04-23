classdef Mind < Model
    properties
        model
        features
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
        end

        function train(obj, num_epochs)
            v = waitbar(0, 'Training...');
            error_list_train = zeros(1, num_epochs);
            error_list_validate = zeros(1, num_epochs);

            features = reshape([obj.examples.train.features],...
                [length(obj.examples.train(1).features) length(obj.examples.train)])';
            labels = reshape([obj.examples.train.labels],...
                [length(obj.examples.train(1).labels) length(obj.examples.train)])';

            dw1_prev = 0; dw2_prev = 0; db1_prev = 0; db2_prev = 0;
            for i = 1:num_epochs
                waitbar(i/num_epochs);

                X = obj.scale(features, 'f')*obj.weights{1} + obj.biases{1};
                S = obj.layers(2).ACT(X);
                Y = S*obj.weights{2} + obj.biases{2};
                Z = Y;

                error = mean(mean(abs(obj.scale(labels, 'l') - Z)));

                dEo = Z - obj.scale(labels, 'l');
                dZ = ones(size(Y));
                dY = S;
                dw2 = dY'*(dEo.*dZ);
                db2 = ones(length(features), 1)'*(dEo.*dZ);

                dEh = dEo*obj.weights{2}';
                dS = obj.layers(2).dACT(X);
                dX = obj.scale(features, 'f');
                dw1 = dX'*(dEh.*dS);
                db1 = ones(length(features), 1)'*(dEh.*dS);

                obj.weights{1} = obj.weights{1} - obj.learning_rate*dw1 - obj.momentum*dw1_prev;
                obj.weights{2} = obj.weights{2} - obj.learning_rate*dw2 - obj.momentum*dw2_prev;
                obj.biases{1} = obj.biases{1} - obj.learning_rate*db1 - obj.momentum*db1_prev;
                obj.biases{2} = obj.biases{2} - obj.learning_rate*db2 - obj.momentum*db2_prev;

                dw1_prev = obj.learning_rate*dw1;
                dw2_prev = obj.learning_rate*dw2;
                db1_prev = obj.learning_rate*db1;
                db2_prev = obj.learning_rate*db2;

                error_list_train(i) = error;
                error_list_validate(i) = obj.validate;
            end
            figure; hold on;
            plot(error_list_train);
            plot(error_list_validate, 'r');
            close(v);
        end

        function find_features(obj, labels)
            obj.features = obj.infer(labels);
        end
    end
end

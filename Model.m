classdef Model < handle
    properties
        data
        examples
        layers
        weights
        biases
        learning_rate = 0.001
        momentum = 0.5
        feature_ranges
        label_ranges
    end
    methods
        function obj = Model(data, invert)
            obj.data = data;
            obj.split_dataset;
            obj.get_data_ranges;
            obj.init_ANN;
        end

        function split_dataset(obj, ratio)
            switch nargin
                case 1
                    ratio = [0.7, 0.15, 0.15];
            end
            obj.examples = struct('train', {}, 'validate', {}, 'test', {});
            obj.examples(end + 1).train = obj.data.examples(1:round(ratio(1)*end));
            obj.examples(end).validate = obj.data.examples((round(ratio(1)*end) + 1):round((ratio(1) + ratio(2))*end));
            obj.examples(end).test = obj.data.examples(round(((ratio(1) + ratio(2))*end) + 1):end);
        end

        function init_ANN(obj)
            obj.layers = Layer('input', length(obj.data.examples(1).features), 'none');

            while length(obj.layers) < 2 || input('Add another hidden layer? Y/N: ', 's') == 'y'
                obj.layers(end + 1) = Layer('hidden');
                obj.weights{length(obj.layers) - 1} = normrnd(0, 1,...
                    [obj.layers(length(obj.layers) - 1).num_neurons, obj.layers(length(obj.layers)).num_neurons])...
                    /obj.layers(length(obj.layers) - 1).num_neurons;
                obj.biases{length(obj.layers) - 1} = normrnd(0, 1,...
                    [1, obj.layers(length(obj.layers)).num_neurons])...
                    /obj.layers(length(obj.layers) - 1).num_neurons;
            end

            obj.layers(end + 1) = Layer('output', length(obj.data.examples(1).labels), 'none');
            obj.weights{length(obj.layers) - 1} = normrnd(0, 1,...
                [obj.layers(length(obj.layers) - 1).num_neurons, obj.layers(length(obj.layers)).num_neurons])...
                /obj.layers(length(obj.layers) - 1).num_neurons;
            obj.biases{length(obj.layers) - 1} = normrnd(0, 1,...
                [1, obj.layers(length(obj.layers)).num_neurons])...
                /obj.layers(length(obj.layers) - 1).num_neurons;
        end

        function train(obj, num_epochs, batch_size)
            v = waitbar(0, 'Training...');
            error_list_train = zeros(1, num_epochs);
            error_list_validate = zeros(1, num_epochs);

            sample_size = length(obj.examples.train);
            features = reshape([obj.examples.train(1:sample_size).features],...
                [length(obj.examples.train(1).features) sample_size])';
            labels = reshape([obj.examples.train(1:sample_size).labels],...
                [length(obj.examples.train(1).labels) sample_size])';

            switch nargin
                case 2
                    batch_size = sample_size;
            end

            for i = 1:num_epochs
                waitbar(i/num_epochs);

                obj.layers(1).net = obj.scale(features, 'f');
                obj.layers(1).out = obj.layers(1).net;
                for n = 2:length(obj.layers)
                    obj.layers(n).feed(obj.layers(n - 1), obj.weights{n - 1}, obj.biases{n - 1});
                end

                error = mean(mean(abs(obj.scale(labels, 'l') - obj.layers(end).out)));

                derr = obj.layers(end).out - obj.scale(labels, 'l');
                dout = ones(size(obj.layers(end).out));
                dnet = obj.layers(end - 1).out;
                obj.layers(end).dw = dnet'*(derr.*dout);
                obj.layers(end).db = ones(length(features), 1)'*(derr.*dout);

                for n = (length(obj.layers) - 1):-1:2
                    derr = derr*obj.weights{n}';
                    dout = obj.layers(n).dACT(obj.layers(n).net);
                    dnet = obj.layers(n - 1).out;
                    obj.layers(n).dw = dnet'*(derr.*dout);
                    obj.layers(n).db = ones(length(features), 1)'*(derr.*dout);
                end

                for n = 1:length(obj.weights)
                    obj.weights{n} = obj.weights{n} - obj.learning_rate*obj.layers(n + 1).dw;
                    obj.biases{n} = obj.biases{n} - obj.learning_rate*obj.layers(n + 1).db;

                    % obj.layers(n + 1).dw_prev = obj.learning_rate*obj.layers(n).dw;
                    % obj.layers(n + 1).db_prev = obj.learning_rate*obj.layers(n).db;
                end

                error_list_train(i) = error;
                error_list_validate(i) = obj.validate;
            end
            figure; hold on;
            plot(error_list_train);
            plot(error_list_validate, 'r');
            close(v);
        end

        function validation_error = validate(obj)
            validation_error = mean(mean(abs(obj.scale(reshape([obj.examples.validate.labels],...
                [length(obj.examples.validate(1).labels) length(obj.examples.validate)])', 'l')...
                - obj.infer(reshape([obj.examples.validate.features],...
                [length(obj.examples.validate(1).features) length(obj.examples.validate)])', false))));
        end

        function test_error = test(obj)
            test_error = mean(mean(abs(obj.scale(reshape([obj.examples.test.labels],...
                [length(obj.examples.test(1).labels) length(obj.examples.test)])', 'l')...
                - obj.infer(reshape([obj.examples.test.features],...
                [length(obj.examples.test(1).features) length(obj.examples.test)])', false))));
        end

        function y = infer(obj, features, descale)
            switch nargin
                case 2
                    descale = true;
            end

            obj.layers(1).net = obj.scale(features, 'f');
            obj.layers(1).out = obj.layers(1).net;
            for n = 2:length(obj.layers)
                obj.layers(n).feed(obj.layers(n - 1), obj.weights{n - 1}, obj.biases{n - 1});
            end
            y = obj.layers(end).out;
            if descale == true, y = obj.descale(y); end
        end

        function reset_weights(obj)
            for n = 1:length(obj.weights)
                obj.weights{n} = normrnd(0, 1, [obj.layers(n).num_neurons, obj.layers(n + 1).num_neurons])...
                /obj.layers(n).num_neurons;
                obj.biases{n} = normrnd(0, 1, [1, obj.layers(n + 1).num_neurons])...
                /obj.layers(n).num_neurons;
            end
        end

        function get_data_ranges(obj)
            features = reshape([obj.data.examples.features],...
                [length(obj.data.examples(1).features) length(obj.data.examples)])';
            labels = reshape([obj.data.examples.labels],...
                [length(obj.data.examples(1).labels) length(obj.data.examples)])';
            obj.feature_ranges = [min(features, [], 1); max(features, [], 1)];
            obj.label_ranges = [min(labels, [], 1); max(labels, [], 1)];
        end

        function y = scale(obj, values, type)
            switch type
                case 'f'
                    y = (values - obj.feature_ranges(1, :))./(obj.feature_ranges(2, :) - obj.feature_ranges(1, :));
                case 'l'
                    y = (values - obj.label_ranges(1, :))./(obj.label_ranges(2, :) - obj.label_ranges(1, :));
            end
        end

        function y = descale(obj, values)
            y = obj.label_ranges(1, :) + values.*(obj.label_ranges(2, :) - obj.label_ranges(1, :));
        end

        function test_transmission(obj, subset, example)
            figure; hold on;
            x = linspace(obj.data.wavelengths(1), obj.data.wavelengths(2), length(subset(example).labels));
            plot(x, obj.infer(subset(example).features));
            plot(x, subset(example).labels);
            legend('Model', 'Simulation');
        end
    end
end

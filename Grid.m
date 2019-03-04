classdef Grid < handle
    properties
        data
        mind
        examples
    end
    methods
        function obj = Grid(data, mind)
            obj.data = data;
            obj.mind = mind;
            obj.examples = data.examples;
            [obj.examples(:).predictions] = deal(0);
            [obj.examples(:).accuracy] = deal(0);
            
            for n = 1:length(obj.examples)
                obj.examples(n).predictions = obj.mind.infer(obj.examples(n).features);
                obj.examples(n).accuracy = abs(obj.examples(n).predictions - obj.examples(n).labels)/obj.examples(n).labels;
            end
        end
        
        function obj = add_mind(obj, mind)
            obj.mind = mind;
            for n = 1:length(obj.examples)
                obj.examples(n).predictions = obj.mind.infer(obj.examples(n).features);
                obj.examples(n).accuracy = abs(obj.examples(n).predictions - obj.examples(n).labels)/obj.examples(n).labels;
            end
        end
        
        function map_data(obj)
            features = reshape([obj.examples.features], [length(obj.examples(1).features) length(obj.examples)])';
            labels = reshape([obj.examples.labels], [sqrt(length(obj.examples)) sqrt(length(obj.examples))]);
            h = heatmap(round(unique(features(:, 1))*1e9, 3, 'significant'),...
                round(flipud(unique(features(:, 2))), 2), flipud(labels));
        end
        
        function map_mind(obj)
            predictions = reshape([obj.examples.predictions], [sqrt(length(obj.examples)) sqrt(length(obj.examples))]);
            features = reshape([obj.examples.features], [length(obj.examples(1).features) length(obj.examples)])';
            h = heatmap(round(unique(features(:, 1))*1e9, 3, 'significant'),...
                round(flipud(unique(features(:, 2))), 2), flipud(predictions));
        end
        
        function map_mind_accuracy(obj)
            accuracy = reshape([obj.examples.accuracy], [sqrt(length(obj.examples)) sqrt(length(obj.examples))]);
            features = reshape([obj.examples.features], [length(obj.examples(1).features) length(obj.examples)])';
            h = heatmap(round(unique(features(:, 1))*1e9, 3, 'significant'),...
                round(flipud(unique(features(:, 2))), 2), flipud(accuracy));
        end
    end
end

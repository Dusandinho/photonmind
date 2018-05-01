classdef Circuit < handle
    properties
        source
        devices
    end
    methods
        function obj = Circuit(source, device)
            obj.source = source;
            obj.devices = device;
        end

        function add_device(obj, device)
            obj.devices(end + 1) = device;
        end

        function remove_device(obj, index)
            obj.devices(index) = [];
        end

        function run(obj)
            y = obj.source.amplitude;
            for n = 1:length(obj.devices)
                y = y.*obj.devices(n).model.infer(obj.devices(n).features);
            end
            plot(y);
        end
    end
end

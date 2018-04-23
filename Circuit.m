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

        function add(obj, device)
            obj.devices(end + 1) = device;
        end

        function remove(obj, index)
            obj.devices(index) = [];
        end

        function run(obj)
            y = obj.source.amplitude;
            for n = 1:length(obj.devices)
                device_output = abs(obj.devices(n).model.infer(obj.devices(n).features));
                y = y.*device_output;
            end
            plot(y);
        end
    end
end

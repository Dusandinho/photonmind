classdef Source < handle
    properties
        amplitude = 1
        mode = 0
        wavelength = 1550e-9
    end
    methods
        function obj = Source(amplitude, mode, wavelength)
            obj.amplitude = amplitude;
            obj.mode = mode;
            obj.wavelength = wavelength;
        end
    end
end

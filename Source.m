classdef Source < handle
    properties
        amplitude
        wavelength
    end
    methods
        function obj = Source(amplitude, wavelength)
            obj.amplitude = amplitude;
            obj.wavelength = wavelength;
        end
    end
end

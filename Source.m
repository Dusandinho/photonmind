classdef Source < handle
    properties
        amplitude
        mode
        wavelength
        broadband = false
    end
    methods
        function obj = Source(amplitude, mode, wavelength)
            obj.amplitude = amplitude;
            obj.mode = mode;
            obj.wavelength = wavelength;
            if length(wavelength) > 1, obj.broadband = true; end
        end
    end
end

classdef niimrs < handle
    % Standardized Processing Library Class
    %   Victor Han
    %   Georg Oeltzschner

    properties
        hdr
        ext
        img
    end

    methods
        function obj = niimrs(inputFile)
            % NIIMRS Loads the NIfTI-MRS file 'inputFile' 
            %   Detailed explanation goes here
            temp = nii_tool('load', inputFile);

            obj.hdr = temp.hdr;
            obj.ext = temp.ext;
            obj.img = temp.img;
        end

        function obj = applyZeroPhase(obj, rads)
            % applyZeroPhase Applies a zero-order phase shift of 'rads'
            % radians.
            
            phaseShift = exp(1i*rads);
            phaseShiftTerm = repmat(phaseShift, size(obj.img));
            obj.img = obj.img .* phaseShiftTerm;

        end

        function obj = applyAmpScale(obj, scaleFac)
            % applyAmpScale scales the FID by the factor 'scaleFac'
            
            obj.img = obj.img .* scaleFac;

        end

        function plotAxis = plotSpec(obj)

            % PLOTSPEC
            %   Detailed explanation goes here

            % Get FID
            fid = squeeze(obj.img);

            % Get spectral width
            sw = 1/obj.hdr.pixdim(5);

            % Decode the JSON header extension string
            header_extension = jsondecode(obj.ext.edata_decoded);

            % Extract F0 and number of samples
            f0 = header_extension.SpectrometerFrequency;
            npts = obj.hdr.dim(5);

            % Create frequency axis
            f = [(-sw/2)+(sw/(2*npts)):sw/(npts):(sw/2)-(sw/(2*npts))];

            % Convert to ppm
            ppm = -f/f0;
            ppm = ppm + 4.68;

            % Calculate and plot the frequency domain spectrum
            spec = fftshift(fft(fid));
            plotAxis = plot(ppm, real(spec));
            hold on;
            plot(ppm, imag(spec));
            set(gca, 'xdir', 'reverse', 'xlim', [0 5]);
            xlabel('Chemical shift (ppm)');
            legend('real', 'imag');
            hold off;

            
        end
    end
end
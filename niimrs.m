classdef niimrs < handle
    % Standardized Processing Library Class
    %   Peter Truong
    %   Morteza Esmaeili
    %   Victor Han
    %   Georg Oeltzschner

    properties
        hdr % NIfTI-2 header
        ext % NIfTI-MRS header extension
        img % max-7D complex time-domain data array 
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
            
            phaseShift = exp(-1i*rads);
            phaseShiftTerm = repmat(phaseShift, size(obj.img));
            obj.img = obj.img .* phaseShiftTerm;

        end

        function obj = applyFirstPhase(obj, rads, pivot)
            % applyFirstPhase Applies a first-order phase shift of 'rads'
            % radians per ppm with pivot point 'pivot' in ppm
            
            if nargin<3
                pivot = returnCenterPPM(obj);
            end

            %%%% Calculate the spectrum
            % Get FID
            fid = squeeze(obj.img);

            % Get ppm axis
            ppm = returnPPM(obj);

            % Calculate and plot the frequency domain spectrum
            spec = fftshift(fft(fid));
            %%%% Done calculating spectrum

            spec = spec.' .* exp(-1i*rads*(ppm-pivot));

            obj.img = reshape(ifft(ifftshift(spec)), size(obj.img));

        end

        function obj = applyAmpScale(obj, scaleFac)
            % applyAmpScale scales the FID by the factor 'scaleFac'
            
            obj.img = obj.img .* scaleFac;

        end

        function obj = addNoise(obj, stddev)
            % adds complex gaussian noise with standard deviation 'stddev'
            
            obj.img = obj.img + stddev .* randn(size(obj.img));

        end

        function obj = applyFreqShift(obj, freqShift)
            % applyAmpScale shifts the FID by 'freqShift' Hz.
            
            % Get time vector
            t = returnTime(obj);
           
            % Determine dimensions:
            dims = size(obj.img);
            dims_temp = dims;
            dims_temp(4) = 1;

            tArray = repmat(t, dims_temp);
            tArray = reshape(tArray, dims);

            freqShiftFactor = exp(1i*2*pi*tArray*freqShift);
            obj.img = obj.img .* freqShiftFactor;

        end

        function obj = applyExpLB(obj, lorLB)
            % applyExpLB applies exponential linebroadening of 'lorLB' Hz.

            % Intercept zero input to avoid division by zero.
            if lorLB == 0
                return;
            else
                t2 = 1/(pi*lorLB);
            end

            % Get time vector
            t = returnTime(obj);

            % Determine dimensions:
            dims = size(obj.img);
            dims_temp = dims;
            dims_temp(4) = 1;

            tArray = repmat(t, dims_temp);
            tArray = reshape(tArray, dims);

            expLBFactor = exp(-tArray/t2);
            obj.img = obj.img .* expLBFactor;

        end


        function obj = applyZeroFill(obj, factor)
            % Adds zeros to end of FID data to extend data by 'factor'

            if factor < 1
                error("Factor must be at least 1")
            end

            dims = size(obj.img);
            dims_temp = dims;
            dims_temp(4) = dims(4) * factor;
            obj.hdr.dim(5) = dims_temp(4);
            tempArray = zeros(dims_temp);
            tempArray(:,:,:,1:dims(4),:,:,:) = obj.img;
            obj.img = tempArray;
        end
        
        function plotAxis = plotFID(obj)
            % PLOTFID
            %   For when you want to see the FID
            
            % Get FID
            fid = squeeze(obj.img);
            
            % Get time vector
            t = returnTime(obj);
            
            plotAxis = plot(t, real(fid));
            hold on;
            plot(time, imag(fid));
            xlabel('Time (s)');
            legend('real', 'imag');
            hold off;
            
        end

        function plotAxis = plotSpec(obj)

            % PLOTSPEC
            %   Detailed explanation goes here

            % Get FID
            fid = squeeze(obj.img);

            % Get ppm axis
            ppm = returnPPM(obj);

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

        function centerPPM = returnCenterPPM(obj)

            % centerPPM returns the ppm value assigned to the center of a
            % spectrum depending on the nucleus.

            % Decode the JSON header extension string
            header_extension = jsondecode(obj.ext.edata_decoded);
            nucleus = header_extension.ResonantNucleus;

            if iscell(nucleus)              % Is cell
                nucleus = nucleus{1};       % Get first entry
            end

            switch strtrim(nucleus)         % Switch nucleus string
                case '1H'
                    centerPPM = 4.68;
                case '2H'
                    centerPPM = 4.68;
                case '31P'
                    centerPPM = 0;
                otherwise
                    error('Nucleus %s not supported yet.', nucleus);
            end

        end
        
        function t = returnTime(obj)
            % returnTime returns the time vector (in seconds)
            
            % Get dwell time and number of points
            dt = obj.hdr.pixdim(5);
            npts = obj.hdr.dim(5);

            % Construct time vector
            t = 0:dt:dt*(npts-1);
            
        end
        
        function ppm = returnPPM(obj)
            % Get spectral width
            sw = 1/obj.hdr.pixdim(5);

            % Decode the JSON header extension string
            header_extension = jsondecode(obj.ext.edata_decoded);

            % Extract F0 and number of samples
            f0 = header_extension.SpectrometerFrequency;
            npts = obj.hdr.dim(5);

            % Create frequency axis
            f = (-sw/2)+(sw/(2*npts)):sw/(npts):(sw/2)-(sw/(2*npts));

            % Convert to ppm
            ppm = -f/f0;
            ppm = ppm + obj.returnCenterPPM;
            
        end
        
        function gamma = returnGyromagRatio(obj)

            % returnGyromagRatio returns the gyromagnetic ratio [MHz/T] 
            % for a given nucleus.

            % Decode the JSON header extension string
            header_extension = jsondecode(obj.ext.edata_decoded);
            nucleus = header_extension.ResonantNucleus;

            if iscell(nucleus)              % Is cell
                nucleus = nucleus{1};       % Get first entry
            end

            switch strtrim(nucleus)             % Switch nucleus string
                case '1H'
                    gamma = 42.577478518;
                case '2H'
                    gamma = 6.536;
                case '13C'
                    gamma = 10.7084;
                case '19F'
                    gamma = 40.078;
                case '31P'
                    gamma = 17.235;
                otherwise
                    error('Nucleus %s not supported yet.', nucleus);
            end

        end

    end
end

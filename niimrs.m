classdef niimrs
    % Standardized Processing Library Class
    %   Detailed explanation goes here

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

        function plotAxis = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end
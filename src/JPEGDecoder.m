classdef JPEGDecoder < handle
%JPEGDECODER Summary of this class goes here
%   Detailed explanation goes here
%
% Copyright 2011, Stephen Ierodiaconou, University of Bristol.


    properties (SetObservable)
        input
    end
    
    properties (SetObservable, SetAccess='private')
        imageMatrix
        imageStruct
        
        qualityFactor
        chromaSamplingMode
        
        luminanceScaledQuantisationTable
        chromaScaledQuantisationTable

        yCoefficients
        yQuantisedCoefficients
        yOrderedCoefficients
        yZerosRunLengthCodedOrderedCoefficients
        
        cbCoefficients
        cbQuantisedCoefficients
        cbOrderedCoefficients
        cbZerosRunLengthCodedOrderedCoefficients
        
        crCoefficients
        crQuantisedCoefficients
        crOrderedCoefficients
        crZerosRunLengthCodedOrderedCoefficients
        
        output
    end

    methods
        function obj = JPEGDecoder(source)
            if exist('source','var')
                obj.input(source);
            end
        end

        function set.input(obj, data)
            %if source is a string read file, if its a vector is logical
            %bit stream
            if isa(data, 'char')
                obj.input = Utilities.readBinaryFileToLogicalArray(data);
            elseif isa(data, 'logical')
                obj.data = data;
            else
                throw(MException('JPEGDecoder:input', 'The input image data must be either a string file name to read, or a bistream in the form of a logical matrix of bits .')); 
            end
        end
        
        function outputImage = decode(obj)

            % decode bitstream
            
            obj.imageStruct = ;
            
            % ETC ETC ETC
            obj.output = struct('image', obj.imageStruct, 'PSNR', 123); 
            obj.imageMatrix = Subsampling.subsampledToYCbCrImage(obj.imageStruct);
            outputImage = obj.imageMatrix;
        end
   end
end 

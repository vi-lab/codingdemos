classdef DemoJPEGEncoder < handle
%DEMOJPEGENCODER Summary of this class goes here
%Detailed explanation goes here
% DemoJPEGEncoder Properties:
%   inputImageData - first property
%   inputData - first property
% DemoJPEGEncoder Methods:
%   DemoJPEGEncoder - Constructor takes optional source parameter

    properties (SetObservable)
        inputImageData
        
        qualityFactor
        chromaSamplingMode
    end
    
    properties (SetObservable, SetAccess='private')
        inputData
        
        quantisationParameter 
        
        coefficients
    end

    methods
        function obj = DemoJPEGEncoder(source)
            if exist('source','var')
                obj.inputImageData(source);
            end
            
            % set parameter defaults
            obj.qualityFactor = 60;
            obj.chromaSamplingMode = '4:2:0';
        end

        function set.inputImageData(obj, data)
            %if source is a string read file, if its a matrix is image, if struct is struct image
            if isa(data, 'char')
                obj.inputImageData = struct('fileName', data);
                obj.inputData = rgb2ycbcr(imread(data));
            elseif isa(data, 'struct')
                obj.inputImageData = data;
                obj.inputData = Subsampling.subsampledToYCbCrImage(data);
            elseif isa(data, 'numeric')
                obj.inputImageData = struct('matrix', data);
                obj.inputData = data;
            else
                throw(MException('DemoJPEGEncoder:inputImageData', 'The input image data must be either a struct with y, cb and cr fields corresponding to the 3 channels, a string file name to read, or a ycbcr image matrix.')); 
            end
            % TODO: START CODING??? maybe optionally
        end
        
        function setCodingParameters(obj, varargin)
            for k=1:size(varargin,2) 
                switch lower(varargin{k})
                    case 'quality'
                        k = k + 1;
                        if isa(varargin{k}, 'numeric')
                            obj.qualityFactor = varargin{k};
                        else
                            throw(MException('DemoJPEGEncoder:setCodingParameters', 'The quality factor should be a numeric value.')); 
                        end
                    case 'subsampling'
                        k = k + 1;
                        if isa(varargin{k}, 'char')
                            obj.chromaSamplingMode = varargin{k};
                        else
                            throw(MException('DemoJPEGEncoder:setCodingParameters', 'The chroma sampling mode should be a string value. To see supported modes run ''Subsampling.supportedModes''.')); 
                        end
                end
            end
        end
        
        function encode(obj)
            % check if input data is set
            
            obj.quantisationParameter = TransformCoding.convertQualityFactorToQuantisationParameter(obj.qualityFactor);
        end
    end
end 

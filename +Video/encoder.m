classdef encoder < JPEG.encoder
%VIDEO.ENCODER Summary of this class goes here
%   Detailed explanation goes here
%
% Copyright 2011, Stephen Ierodiaconou, University of Bristol.

    properties (SetObservable)
        structureOfGOPString
    end

    properties (SetObservable, SetAccess='protected')
        structureOfGOP
        
        GOPs
    end

    properties (Constant = true)
        I_FRAME = 0;
        P_FRAME = 1;
    end

    methods
        function obj = encoder(source, varargin)
            % call parent constructor
            obj = obj@JPEG.encoder();
            obj.setParameterDefaultValues;
            % Can set parameters on encoder
            if ~isempty(varargin)
                obj.setCodingParameters(varargin{:});
            end
            % Construct object setting defaults
            if exist('source','var')
                obj.readInput(source);
            end
        end

        function readInput(obj, data)
            % Override JPEG one
            
            if isa(data, 'char')
                % either jpeg range or AVI file
                % split at : if 3 of them its image range, else avi file and range, if one only if start frame for video, else if none then assume video
                parts = regexp(data, ':', 'split');
                switch length(parts) 
                    case 1
                        obj.input = struct('inputType', 'videorange', 'filePaths', parts{1}, ...
                                            'startFrame', 1, 'endFrame', Inf);
                    case 2
                        obj.input = struct('inputType', 'videorange', 'filePaths', parts{1}, ...
                                            'startFrame', str2double(parts{2}), 'endFrame', Inf);
                    case 3
                        obj.input = struct('inputType', 'videorange', 'filePaths', parts{1}, ...
                                            'startFrame', str2double(parts{2}), 'endFrame', str2double(parts{3}));
                    case 4
                        obj.input = struct('inputType', 'imagerange', 'filePaths', [], ...
                                            'startFrame', str2double(parts{2}), 'endFrame', str2double(parts{3}));
                        for i=obj.input.startFrame:obj.input.endFrame
                            obj.input.filePaths{i-str2double(parts{2})+1} = [parts{1} num2str(i, ['%0' num2str(length(parts{3})) 'd']) parts{4}];
                        end
                    otherwise
                        throw(MException('Video.encoder:input', 'String inputs must follow the following format: an image path prefix and range of frames of sequential group (e.g. /path/to/images/i:01:99:.jpg for images named images ''i01.jpg'' to ''i99.jpg''), or a path to an AVI file and the frame range to load (e.g. /path/to/test.avi:10:20)'));
                end
                switch obj.input.inputType
                    case 'videorange'
                        if obj.verbose; disp(['Read Video data from ''' obj.input.filePaths ''', frames: ' num2str(obj.input.startFrame) ' to ' num2str(obj.input.endFrame)]); end
                        obj.input.videoData = mmreader(obj.input.filePaths);
                        obj.imageMatrix = read(obj.input.videoData, [obj.input.startFrame obj.input.endFrame]);
                        for i=1:size(obj.imageMatrix,4)
                            obj.imageMatrix(:,:,:,i) = rgb2ycbcr(obj.imageMatrix(:,:,:,i));
                        end
                    case 'imagerange'
                        if obj.verbose; disp(['Read image sequence from ''' obj.input.filePaths{1} ''' to ''' obj.input.filePaths{end} '''']); end
                        for i=1:length(obj.input.filePaths)
                            obj.imageMatrix = cat(4, obj.imageMatrix, rgb2ycbcr(imread(obj.input.filePaths{i})));
                        end
                end
                
            elseif isa(data, 'cell')
                % cell array of frames, either subsampled or not
                % *************************
                
            elseif isa(data, 'numeric')
                
                % check is 4D ?
                
                obj.inputMatrix = data;
            else
                throw(MException('Video.encoder:input', 'Input can be: 4d matrix, a string image path prefix and range of frames of sequential group (e.g. /path/to/images/i:01:99:.jpg for images named images ''i01.jpg'' to ''i99.jpg''), a cell array of images or a path to an AVI file and the frame range to load (e.g. /path/to/test.avi:10:20)'));
            end
        end
        
        function set.structureOfGOPString(obj, data)
            % decode structure string 'ipppp'
            if isa(data, 'char')
                obj.structureOfGOPString = data;
                obj.structureOfGOP = ones(1, length(data)) .* obj.I_FRAME;
                if ~strcmpi(data(1), 'i')
                    throw(MException('Video.encoder:structureOfGOPString', 'The GOP structure must start with an I frame.'));
                end
                obj.structureOfGOP(lower(data) == 'p') = obj.P_FRAME;

                if obj.verbose; disp(['GOP structure: ' upper(data) ', (' num2str(nnz(lower(data) == 'p')) ' P frames)']); end
            else
                throw(MException('Video.encoder:structureOfGOPString', 'The input image data must be a string of the form ''ippppp''.'));
            end

        end

        function setCodingParameters(obj, varargin)
            % call JPEG parents
            obj.setCodingParameters@JPEG.encoder(varargin{:});

            for k=1:2:size(varargin,2)
                switch lower(varargin{k})
                    case 'gop'
                        obj.structureOfGOPString = varargin{k+1};
                end
            end
        end

        function setParameterDefaultValues(obj)
            
            % WILL CALL TO SETCODING BE ON PARENT THO?
            obj.setParameterDefaultValues@JPEG.encoder();
            
            % CALL SETCODING with defaults for extra params
            obj.setCodingParameters('gop', 'ippp');
        end

        function stream = encode(obj, varargin)

            stream = [];

            obj.setCodingParameters(varargin{:});

            if obj.isEnabledStage.entropyCoding; isCoding = 'on'; else isCoding = 'off'; end
            if obj.doReconstruction; isRec = 'on'; else isRec = 'off'; end
            if obj.verbose; disp(['Start encoding: (entropy coding: ' isCoding ', reconstruction: ' isRec ') -- Quality Factor: ' num2str(obj.qualityFactor) ', chroma sampling mode: ' obj.chromaSamplingMode]); end

            % Generate pixel data quantisation tables from Quality
            obj.luminanceScaledQuantisationTable = TransformCoding.qualityFactorToQuantisationTable(TransformCoding.luminanceQuantisationTable, obj.qualityFactor);
            obj.chromaScaledQuantisationTable = TransformCoding.qualityFactorToQuantisationTable(TransformCoding.chromaQuantisationTable, obj.qualityFactor);

            % start encoding of video
            % for each frame in input call encode process for frametype
            obj.doReconstruction = true;

            for timeMatrixIndex = 1:size(obj.imageMatrix, 4)
                GOPIndex = ceil(timeMatrixIndex/length(obj.structureOfGOP));
                frameIndex = timeMatrixIndex - ((GOPIndex-1)*length(obj.structureOfGOP));
                frameType = obj.structureOfGOP(frameIndex);
                
                if obj.verbose; if frameType == obj.I_FRAME; frameTypeText = 'I'; else; frameTypeText = 'P'; end; disp(['Start encoding frame ' num2str(frameIndex) ' of GOP ' num2str(GOPIndex) ' as ' frameTypeText ' frame.']); end
                
                % 1) do subsampling
                obj.imageStruct = Subsampling.ycbcrImageToSubsampled( obj.imageMatrix(:,:,:,timeMatrixIndex), 'Mode', obj.chromaSamplingMode );
                % 2) if I frame do coding as per JPEG (call methods on
                % parent)
                if frameType == obj.I_FRAME
                    obj.transformCode();
                    obj.GOPs{GOPIndex, frameIndex} = obj.reconstruction;
                else
                end

                % 3) if P frame start MEC

            end
            
            % Construct bitstream if desired
            if obj.isEnabledStage.entropyCoding
                
            end
        end
    end

    methods (Access='private')
        
    end       
end 

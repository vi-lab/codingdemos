classdef encoder < JPEG.encoder
%VIDEO.ENCODER Summary of this class goes here
%   Detailed explanation goes here
%
% Copyright 2011, Stephen Ierodiaconou, University of Bristol.

    properties (SetObservable, SetAccess='protected')
        structureOfGOPString
        frameRate
        GOPs

        % Support algorithms:
        %{
            From http://en.wikipedia.org/wiki/Block-matching_algorithm
            Cross Search Algorithm (CSA)
            Full Search Algorithm (FSA)
            Spiral Search
            Three Step Search
            Two Dimensional Logarithmic Search (TDL)
            Binary Search (BS)
            Four Step Search (FSS)
            Orthogonal Search Algorithm (OSA)
            Hierarchical Search Algorithm (HSA)
            Diamond Search (DS)
        %}
        % A struct containing algorithm and parameters
        blockMatching
        referenceFrameBuffer

        frameData
        motionVectors

        predictionErrorFrame
        reconstructedPredictionErrorFrame

        frameStatistics

        reconstructedVideo
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
                obj.imageMatrix = [];
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

        function setCodingParameters(obj, varargin)
            % call JPEG parents
            obj.setCodingParameters@JPEG.encoder(varargin{:});

            for k=1:2:size(varargin,2)
                switch lower(varargin{k})
                    case 'gop'
                        obj.structureOfGOPString = lower(varargin{k+1});
                    case 'framerate'
                        obj.frameRate = varargin{k+1};
                    case 'blockmatching'
                        obj.blockMatching.algorithm = varargin{k+1};
                    case 'blockmatchingsearchdistance'
                        obj.blockMatching.maximumSearchDistance = varargin{k+1};
                    case 'macroblocksize'
                        obj.blockMatching.blockSize = varargin{k+1};
                    case 'blockmatchingverbose'
                        obj.blockMatching.verbose = varargin{k+1};
                    case 'blockmatchingdifferencecalculation'
                        obj.blockMatching.differenceCalculation = varargin{k+1};
                end
            end
        end

        function setParameterDefaultValues(obj)
            % WILL CALL TO SETCODING BE ON PARENT THO?
            obj.setParameterDefaultValues@JPEG.encoder();
            % CALL SETCODING with defaults for extra params
            obj.setCodingParameters('GOP', 'ippp', 'FrameRate', 5, ...
                'BlockMatching', 'FSA', 'BlockMatchingSearchDistance', 8, ...
                'MacroBlockSize', 16, 'BlockMatchingVerbose', false, 'BlockMatchingDifferenceCalculation', 'SAD');
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

            % Reconstruction is made as this is the closed loop nature of
            % modern video codecs
            obj.doReconstruction = true;
            obj.reconstructedVideo = uint8(zeros(size(obj.imageMatrix)));

            % GOP/Frame info
            obj.GOPs.totalNumberOfFramesInVideo = size(obj.imageMatrix, 4);
            obj.GOPs.numberOfFramesPerGOP = length(obj.structureOfGOPString);
            obj.GOPs.count = ceil(obj.GOPs.totalNumberOfFramesInVideo/obj.GOPs.numberOfFramesPerGOP);
            obj.GOPs.length(1:obj.GOPs.count) = obj.GOPs.numberOfFramesPerGOP;
            remFrames = rem(obj.GOPs.totalNumberOfFramesInVideo, obj.GOPs.numberOfFramesPerGOP);
            if remFrames
                obj.GOPs.length(end) = remFrames;
            end
            if obj.verbose; disp(['Number of frames: ' num2str(size(obj.imageMatrix, 4)) ', in ' num2str(obj.GOPs.count) ' GOPs with ' num2str(obj.GOPs.numberOfFramesPerGOP) ' frames per GOP']); end

            obj.motionVectors = cell(obj.GOPs.count,obj.GOPs.numberOfFramesPerGOP);
            obj.predictionErrorFrame = cell(obj.GOPs.count,obj.GOPs.numberOfFramesPerGOP);

            for timeMatrixIndex = 1:obj.GOPs.totalNumberOfFramesInVideo
                [GOPIndex frameIndex frameType] = obj.getGOPAndFrameIndex(timeMatrixIndex);

                if obj.verbose; disp(['Start encoding frame ' num2str(frameIndex) ' of GOP ' num2str(GOPIndex) ' as ' upper(frameType) ' frame.']); end

                % 1) do subsampling
                obj.imageStruct = Subsampling.ycbcrImageToSubsampled( obj.imageMatrix(:,:,:,timeMatrixIndex), 'Mode', obj.chromaSamplingMode );

                if strcmp(frameType,'i')
                    % 2) if I frame do coding as per JPEG (call methods on
                    % parent)
                    obj.transformAndEntropyCode();

                    % Store frame data
                    obj.frameData{GOPIndex, frameIndex}.encodedDCCellArray = obj.encodedDCCellArray;
                    obj.frameData{GOPIndex, frameIndex}.encodedACCellArray = obj.encodedACCellArray;

                    obj.referenceFrameBuffer = obj.reconstruction;

                    %obj.reconstructedVideo{GOPIndex, frameIndex} = obj.reconstruction;
                    obj.reconstructedVideo(:,:,:, timeMatrixIndex) = Subsampling.subsampledToYCbCrImage(obj.reconstruction);
                    %obj.GOPs{GOPIndex, frameIndex} =
                else
                    % 3) if P frame start MEC
                    [obj.motionVectors{GOPIndex, frameIndex} obj.predictionErrorFrame{GOPIndex, frameIndex}] = ...
                            MotionEstimation.createMotionVectorsAndPredictionError(  obj.imageStruct, ...
                                                                                obj.referenceFrameBuffer, ...
                                                                                obj.blockMatching);

                    % get DFD into range HEAVY QUANT!
                    obj.predictionErrorFrame{GOPIndex, frameIndex} = (obj.predictionErrorFrame{GOPIndex, frameIndex}+255)/2;
                    obj.imageStruct = Subsampling.ycbcrImageToSubsampled(obj.predictionErrorFrame{GOPIndex, frameIndex}, 'Mode', obj.chromaSamplingMode );

                    obj.transformAndEntropyCode();

                    % Store frame data
                    obj.frameData{GOPIndex, frameIndex}.encodedDCCellArray = obj.encodedDCCellArray;
                    obj.frameData{GOPIndex, frameIndex}.encodedACCellArray = obj.encodedACCellArray;

                    % Reconstruct frame
                    obj.reconstructedPredictionErrorFrame{GOPIndex, frameIndex} = obj.reconstruction;

                    obj.reconstruction = MotionEstimation.reconstructFrame(obj.motionVectors{GOPIndex, frameIndex}, ...
                                                                            obj.reconstructedPredictionErrorFrame{GOPIndex, frameIndex}, ...
                                                                            obj.referenceFrameBuffer, obj.blockMatching);

                    obj.referenceFrameBuffer = obj.reconstruction;

                    obj.reconstructedVideo(:,:,:, timeMatrixIndex) = Subsampling.subsampledToYCbCrImage(obj.reconstruction);
                end
                % Stats
                obj.frameStatistics{timeMatrixIndex}.psnr = Utilities.peakSignalToNoiseRatio(obj.reconstructedVideo(:,:,1, timeMatrixIndex), obj.imageMatrix(:,:,1, timeMatrixIndex));
                if obj.verbose; disp(['PSNR for frame ' num2str(timeMatrixIndex) ': ' num2str(obj.frameStatistics{timeMatrixIndex}.psnr)]); end
            end

            if obj.isEnabledStage.entropyCoding
                % *********************************************************
                % *********************************************************
                % ************************** CODE MVS
            end
            
            % Construct bitstream if desired
            if obj.isEnabledStage.createBitStream
                stream = obj.createBitStream();
            end
        end

        function playVideo(obj, matrix, varargin)
            % matrix can be a char, either 'in' or 'out'
            if isa(matrix, 'char')
                switch lower(matrix)
                    case 'in'
                        matrix = obj.imageMatrix;
                    case 'out'
                        matrix = obj.reconstructedVideo;
                end
            end

            % FIXME: check types
            for k=1:2:size(varargin,2)
                switch lower(varargin{k})
                    case 'parent'
                        parent = varargin{k+1};
                    case 'title'
                        title = varargin{k+1};
                    case 'framerate'
                        frameRate = varargin{k+1};
                    case 'showresidual'
                        showResidual = varargin{k+1};
                    case {'showmotionvectors', 'showmvs', 'showmv'}
                        showMotionVectors = varargin{k+1};
                    case 'manualcontrol'
                        manualControl = varargin{k+1};
                end
            end
            if ~exist('title', 'var')
                title = 'Movie Player';
            end
            %mov = immovie(rgbmovie);
            if ~exist('parent', 'var')
                parent = figure('Name', title, 'Position', [150 150 size(matrix, 2) size(matrix, 1)]);
                % display 1st frame to create axes
                imshow(ycbcr2rgb(matrix(:,:,:,1)));
            end
            if ~exist('frameRate', 'var')
                frameRate = obj.frameRate;
            end
            if ~exist('showMotionVectors', 'var')
                showMotionVectors = false;
            end
            if ~exist('showResidual', 'var')
                showResidual = false;
            end
            if ~exist('manualControl', 'var')
                manualControl = false;
            end

            if showMotionVectors
                disp('When showing with motion vectors the UI will lock up as movie is displayed with for-loop.');

                for timeMatrixIndex=1:size(matrix, 4)
                    [GOPIndex frameIndex frameType] = obj.getGOPAndFrameIndex(timeMatrixIndex);

                    if showResidual && size(obj.reconstructedPredictionErrorFrame, 1) >= GOPIndex && size(obj.reconstructedPredictionErrorFrame, 2) >= frameIndex && ...
                            ~isempty(obj.reconstructedPredictionErrorFrame{GOPIndex, frameIndex})
                        Subsampling.subsampledImageShow(obj.reconstructedPredictionErrorFrame{GOPIndex, frameIndex}, ...
                                'Parent', get(parent, 'CurrentAxes')); %, 'Channel', 'y');
                    else
                        imshow(ycbcr2rgb(matrix(:,:,:,timeMatrixIndex)), 'Parent', get(parent, 'CurrentAxes'));
                    end
                    hold on;
                    mVs = obj.motionVectors{GOPIndex, frameIndex};
                    bs = obj.blockMatching.blockSize;
                    inputW = size(mVs,1)*bs;
                    inputH = size(mVs,2)*bs;
                    [X, Y] = meshgrid(1:bs:inputW, 1:bs:inputH);
                    nX = numel(X);
                    x = zeros(nX,1); y = zeros(nX,1); u = zeros(nX,1); v = zeros(nX,1);
                    for blockIndex = 1:nX
                        x(blockIndex) = X(blockIndex);
                        y(blockIndex) = Y(blockIndex);
                        bx = ceil(x(blockIndex)/bs);
                        by = ceil(y(blockIndex)/bs);
                        mv = mVs(bx,by,:);
                        u(blockIndex) = mv(1);
                        v(blockIndex) = mv(2);
                    end
                    infoText = ['Frame: ' num2str(timeMatrixIndex) ' (GOP: ' num2str(GOPIndex) ', frame: ' num2str(frameIndex) ') - ' upper(obj.structureOfGOPString(frameIndex)) ' frame.'];
                    set(parent, 'Name', [title ' - ' infoText]);
                    %text(1, 1, infoText, 'Parent', get(parent, 'CurrentAxes'),'FontSize', 18, 'Color', [1 1 1], 'FontWeight', 'bold', 'BackgroundColor', [0.3 0.3 0.3]);
                    quiver(get(parent, 'CurrentAxes'), x, y, u, v);
                    hold off;
                    if manualControl
                        pause
                    else
                        pause(1/frameRate);
                    end
                end
            elseif showResidual
                for timeMatrixIndex=1:size(matrix, 4)
                    [GOPIndex frameIndex frameType] = obj.getGOPAndFrameIndex(timeMatrixIndex);

                    if ~isempty(obj.reconstructedPredictionErrorFrame{GOPIndex, frameIndex})
                        %Subsampling.subsampledImageShow(obj.reconstructedPredictionErrorFrame{GOPIndex, frameIndex}, 'Parent', get(parent, 'CurrentAxes'), 'Channel', 'y');
                        mov(timeMatrixIndex).cdata = ycbcr2rgb(Subsampling.subsampledToYCbCrImage(obj.reconstructedPredictionErrorFrame{GOPIndex, frameIndex}));
                    else
                        mov(timeMatrixIndex).cdata = ycbcr2rgb(matrix(:,:,:,k));
                    end
                    mov(timeMatrixIndex).colormap = [];
                end
                movie(parent, mov, 1, frameRate);
            else
                for k = 1 : size(matrix, 4)
                    mov(k).cdata = ycbcr2rgb(matrix(:,:,:,k));
                    mov(k).colormap = [];
                end
                movie(parent, mov, 1, frameRate);
            end
        end
    end

    methods (Access='protected')

        function [GOPIndex frameIndex frameType] = getGOPAndFrameIndex(obj, timeMatrixIndex)
            GOPIndex = ceil(timeMatrixIndex/obj.GOPs.numberOfFramesPerGOP);
            frameIndex = timeMatrixIndex - ((GOPIndex-1)*obj.GOPs.numberOfFramesPerGOP);
            frameType = obj.structureOfGOPString(frameIndex);
        end

        function stream = createBitStream(obj)
            % Stream format
            %{
                VideoHeader:
                    Start of Video Marker
                    GOP structure (1 byte) P per gop (assumed 1 I frame first)
                    FPS (1 byte)
                    Motion Vectors Huffman Table
                    JPEG FRAME HEADER (includes width/height/number of channels/tables)
                GOP Header:
                    Start of GOP Marker
                I Frame:
                    Start of I-Frame Marker
                    JPEG SCAN SEGMENT Y
                    JPEG SCAN SEGMENT Cb
                    JPEG SCAN SEGMENT Cr
                {P-Frame:}
                    Start of P-Frame Marker
                    JPEG SCAN SEGMENT Y
                    JPEG SCAN SEGMENT Cb
                    JPEG SCAN SEGMENT Cr
                    Motion Vectors Segment:
                        MV Segment Marker
                        Length in bytes (2 bytes)
                        Entropy coded Data
            
                End of Video Marker
            %}

            videoHeader         = obj.createBitStreamForVideoHeader();

            % ************* padArray
            mvTableBits         = obj.createBitStreamForMotionVectorHuffmanTable();

            mvTableLength       = Utilities.decimalToShort(length(ceil(mvTableBits/8)));

            % JPEG Frame header
            % All frames in the video use the same info from here about
            % number of channels, subsampling mode and tables for channel
            jpegFrameHeader     = obj.createBitStreamForFrameHeader();
            quantisationTables = obj.createBitStreamForQuantisationTables();
            huffmanTables = obj.createBitStreamForHuffmanTables();

            frameBits           = obj.createBitStreamForFrames();

            endOfVideoMarker    = Utilities.hexToShort('FFBF'); % Use a JPEG reserved marker

            stream = cat(2, ...
                videoHeader, ...
                mvTableLength, ...
                mvTableBits, ...
                jpegFrameHeader, ...
                quantisationTables, ...
                huffmanTables, ...
                frameBits,...
                endOfVideoMarker ...
                );
            
        end

        function bits = createBitStreamForMotionVectorHuffmanTable(obj)
            bits = logical([]);
        end

        function bits = createBitStreamForVideoHeader(obj)
            markerStartOfVideo  = Utilities.hexToShort('FFB0'); % Use a JPEG reserved marker

            gopStructure        = Utilities.decimalToShort(nnz(obj.structureOfGOPString == 'p'));

            fpsValue            = Utilities.decimalToByte(obj.frameRate);

            bits = cat(2, ...
                markerStartOfVideo, ...
                gopStructure, ...
                fpsValue ...
                );
        end

        function bits = createBitStreamForFrames(obj)
            bits = logical([]);
            for GOPIndex=1:obj.GOPs.count
                startOfGOPMarker     = Utilities.hexToShort('FFB1');
                gopBits = logical([]);
                for frameIndex=1:obj.GOPs.length(GOPIndex)
                    % restore data for encoding
                    obj.encodedACCellArray = obj.frameData{GOPIndex, frameIndex}.encodedACCellArray;
                    obj.encodedDCCellArray = obj.frameData{GOPIndex, frameIndex}.encodedDCCellArray;

                    frameBits = obj.createBitStreamForPixelData();

                    if obj.structureOfGOPString(frameIndex) == 'i'
                        startOfFrameMarker      = Utilities.hexToShort('FFB2');
                        gopBits = cat(2, gopBits, ...
                            startOfFrameMarker, ...
                            frameBits ...
                            );
                    else
                        startOfFrameMarker      = Utilities.hexToShort('FFB3');
                        
                        mvBits = obj.createBitStreamForMotionVectorsForFrame(GOPIndex, frameIndex);
                        mvSegmentMarker         = Utilities.hexToShort('FFB4'); 
                        mvSegmentLength         = Utilities.decimalToByte(ceil(length(mvBits)/8));
                        gopBits = cat(2, gopBits, ...
                            startOfFrameMarker, ...
                            frameBits, ...
                            mvSegmentMarker, ...
                            mvSegmentLength, ...
                            mvBits ...
                            );
                    end
                end
                bits = cat(2, bits, ...
                    startOfGOPMarker, ...
                    gopBits ...
                    );
            end
        end

        function mvBits = createBitStreamForMotionVectorsForFrame(obj, GOPIndex, frameIndex)
            %obj.motionVectors{GOPIndex, frameIndex}
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            mvBits = logical([1 1 1]);
        end
    end       
end 

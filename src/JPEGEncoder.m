classdef JPEGEncoder < handle
%DEMOJPEGENCODER Summary of this class goes here
%Detailed explanation goes here
% DemoJPEGEncoder Properties:
%   inputImageData - first property
%   imageMatrix - first property
% DemoJPEGEncoder Methods:
%   DemoJPEGEncoder - Constructor takes optional source parameter
%
% Copyright 2011, Stephen Ierodiaconou, University of Bristol.

    properties (SetObservable)
        input
        
        qualityFactor
        chromaSamplingMode
    end
    
    properties (SetObservable, SetAccess='private')
        imageMatrix
        imageStruct
        
        luminanceScaledQuantisationTable
        chromaScaledQuantisationTable
        
        % Getters for these to parse data into format that is more readable
        % ???????
        yCoefficients
        yQuantisedCoefficients
        yOrderedCoefficients
        yZerosRunLengthCodedOrderedACCoefficients
        yDCCoefficients
        yDifferentialDCCoefficients
        yEncodedDCCellArray
        yEncodedACCellArray
        
        cbCoefficients
        cbQuantisedCoefficients
        cbOrderedCoefficients
        cbZerosRunLengthCodedOrderedACCoefficients
        cbDCCoefficients
        cbDifferentialDCCoefficients
        cbEncodedDCCellArray
        cbEncodedACCellArray
        
        crCoefficients
        crQuantisedCoefficients
        crOrderedCoefficients
        crZerosRunLengthCodedOrderedACCoefficients
        crDCCoefficients
        crDifferentialDCCoefficients
        crEncodedDCCellArray
        crEncodedACCellArray
        
        %{
        luminanceDCHuffmanCodeCountPerCodeLength    % BITS
        luminanceDCHuffmanSymbolValuesPerCode   % HUFFVAL
        chromaDCHuffmanCodeCountPerCodeLength    % BITS
        chromaDCHuffmanSymbolValuesPerCode   % HUFFVAL

        luminanceACHuffmanCodeCountPerCodeLength    % BITS
        luminanceACHuffmanSymbolValuesPerCode   % HUFFVAL
        chromaACHuffmanCodeCountPerCodeLength    % BITS
        chromaACHuffmanSymbolValuesPerCode   % HUFFVAL
        %}
        output
    end

    methods
        function obj = JPEGEncoder(source)
            if exist('source','var')
                obj.input(source);
            end
            obj.setParameterDefaultValues;
        end

        function set.input(obj, data)
            if exist('data', 'var') && ~isempty(data)
                %if source is a string read file, if its a matrix is image, if struct is struct image
                if isa(data, 'char')
                    obj.input = struct('fileName', data);
                    obj.imageMatrix = rgb2ycbcr(imread(data));
                    obj.imageStruct = struct('y', obj.imageMatrix(:,:,1),'cb', obj.imageMatrix(:,:,2),'cr', obj.imageMatrix(:,:,3), 'mode', '4:4:4');
                elseif isa(data, 'struct')
                    obj.input = data;
                    obj.imageMatrix = Subsampling.subsampledToYCbCrImage(data);
                    obj.imageStruct = data;
                elseif isa(data, 'numeric')
                    obj.input = struct('matrix', data);
                    obj.imageMatrix = data;
                    obj.imageStruct = struct('y', obj.imageMatrix(:,:,1),'cb', obj.imageMatrix(:,:,2),'cr', obj.imageMatrix(:,:,3), 'mode', '4:4:4');
                else
                    throw(MException('JPEGEncoder:input', 'The input image data must be either a struct with y, cb and cr fields corresponding to the 3 channels, a string file name to read, or a ycbcr image matrix.')); 
                end
            end
        end
        
        function set.qualityFactor(obj, data)
            obj.qualityFactor = data;
            
            % TODO: UPDATE ENCODING
        end
       
        function set.chromaSamplingMode(obj, data)
            obj.chromaSamplingMode = data;
            
            % TODO: UPDATE ENCODING
        end
        
        function setParameterDefaultValues(obj)
            obj.setCodingParameters('quality', 60, 'subsampling', '4:2:0');
        end

        function setCodingParameters(obj, varargin)
            for k=1:size(varargin,2) 
                switch lower(varargin{k})
                    case 'quality'
                        k = k + 1;
                        if isa(varargin{k}, 'numeric')
                            obj.qualityFactor = varargin{k};
                        else
                            throw(MException('JPEGEncoder:setCodingParameters', 'The quality factor should be a numeric value.')); 
                        end
                    case 'subsampling'
                        k = k + 1;
                        if isa(varargin{k}, 'char')
                            obj.chromaSamplingMode = varargin{k};
                        else
                            throw(MException('JPEGEncoder:setCodingParameters', 'The chroma sampling mode should be a string value. To see supported modes run ''Subsampling.supportedModes''.')); 
                        end
                end
            end
        end
        
        function reset(obj)
            % Reset everything thus clearing up memory as well
            % Use introspection to get all properties on class and reset
            % them
            metaClassObject = metaclass(obj);
            for i=1:length(metaClassObject.Properties)
                obj.(metaClassObject.Properties{i}.Name) = [];
            end
            
            obj.setParameterDefaultValues;
        end
        
        function success = encodeToFile(obj, fileName)
            % ------------------------------------------
            % Encode Baseline DCT JPEG and write to file
            % ------------------------------------------
            % Refs: 
            %
            % Parameters:
            %
            % Returns:
            %
            
            success = Utilities.writeBinaryFileFromArray( fileName, Utilities.logicalArrayToUnsignedNumericArray(obj.encode()));
        end

        function stream = encode(obj)
            % ------------------------
            % Encode Baseline DCT JPEG
            % ------------------------
            % Refs: 
            % Baseline process: CCITT Rec. T.81 (1992 E) p.87
            %
            % Parameters:
            %
            % Returns:
            %
            
            % If subsampling is necessary make sure it has been performed
            if isa(obj.imageStruct, 'struct') 
                % For each colour channel 
                if ~isfield(obj.imageStruct, 'y')
                    throw(MException('JPEGEncoder:encode', 'No ''y'' channel was found on the source image.')); 
                end
                if ~isfield(obj.imageStruct, 'cb')
                    throw(MException('JPEGEncoder:encode', 'No ''cb'' channel was found on the source image.')); 
                end
                if ~isfield(obj.imageStruct, 'cr')
                    throw(MException('JPEGEncoder:encode', 'No ''cr'' channel was found on the source image.')); 
                end

                if isfield(obj.imageStruct, 'mode')
                    if strcmp(obj.imageStruct.mode, obj.chromaSamplingMode)
                        % already ok
                    else
                        % convert
                        obj.imageStruct = Subsampling.ycbcrImageToSubsampled(Subsampling.subsampledToYCbCrImage(obj.imageStruct), obj.chromaSamplingMode );
                    end
                else
                    % struct but no mode
                    throw(MException('JPEGEncoder:encode', 'No ''mode'' was found on the source image.')); 
                end
            else
                % no struct so create from matrix
                obj.imageStruct = Subsampling.ycbcrImageToSubsampled( obj.imageMatrix, obj.chromaSamplingMode );
            end

            obj.luminanceScaledQuantisationTable = TransformCoding.qualityFactorToQuantisationTable(TransformCoding.luminanceQuantisationTable, obj.qualityFactor);
            obj.chromaScaledQuantisationTable = TransformCoding.qualityFactorToQuantisationTable(TransformCoding.chromaQuantisationTable, obj.qualityFactor);
      
            % Perform the level shift
            obj.levelShiftInputImage();
            
            % Perform DCT and quant, blkproc handles image extension for
            % edge blocks smaller than 8x8
            obj.yCoefficients = blkproc(obj.imageStruct.yLevelShifted, [8 8], @dct2);
            obj.yQuantisedCoefficients = blkproc(obj.yCoefficients, [8 8], @(block)obj.quantiseLuminanceCoefficients(block));
            
            obj.cbCoefficients = blkproc(obj.imageStruct.cbLevelShifted, [8 8], @dct2);
            obj.cbQuantisedCoefficients = blkproc(obj.cbCoefficients, [8 8], @(block)obj.quantiseChromaCoefficients(block));
            
            obj.crCoefficients = blkproc(obj.imageStruct.crLevelShifted, [8 8], @dct2);
            obj.crQuantisedCoefficients = blkproc(obj.crCoefficients, [8 8], @(block)obj.quantiseChromaCoefficients(block));
            
            % Zigzag
            obj.yOrderedCoefficients    = blkproc(obj.yQuantisedCoefficients, [8 8], @TransformCoding.coefficientOrdering);
            obj.cbOrderedCoefficients   = blkproc(obj.cbQuantisedCoefficients, [8 8], @TransformCoding.coefficientOrdering);
            obj.crOrderedCoefficients   = blkproc(obj.crQuantisedCoefficients, [8 8], @TransformCoding.coefficientOrdering);
            
            % RLE
            % blkproc can only return numeric array data of equal size for
            % each block. Hence zerosRunLengthCoding returns the zeroLength
            % and values in a concatenated 126 values array, with -1s
            % padding the unused values (lengths:values)
            obj.yZerosRunLengthCodedOrderedACCoefficients   = blkproc(obj.yOrderedCoefficients, [1 64], @TransformCoding.zerosRunLengthCoding);
            obj.cbZerosRunLengthCodedOrderedACCoefficients  = blkproc(obj.cbOrderedCoefficients, [1 64], @TransformCoding.zerosRunLengthCoding);
            obj.crZerosRunLengthCodedOrderedACCoefficients  = blkproc(obj.crOrderedCoefficients, [1 64], @TransformCoding.zerosRunLengthCoding);
            
            % DC coefficient lists
            obj.yDCCoefficients     = blkproc(obj.yOrderedCoefficients, [1 64], @TransformCoding.returnDCCoefficient);
            obj.cbDCCoefficients    = blkproc(obj.cbOrderedCoefficients, [1 64], @TransformCoding.returnDCCoefficient);
            obj.crDCCoefficients    = blkproc(obj.crOrderedCoefficients, [1 64], @TransformCoding.returnDCCoefficient);
              
            % Differentially code DC 
            obj.yDifferentialDCCoefficients     = TransformCoding.differentiallyCodeDC(obj.yDCCoefficients);
            obj.cbDifferentialDCCoefficients    = TransformCoding.differentiallyCodeDC(obj.cbDCCoefficients);
            obj.crDifferentialDCCoefficients    = TransformCoding.differentiallyCodeDC(obj.crDCCoefficients);
            
            % Huffman Code DC Values
            % Ref: CCITT Rec. T.81 (1992 E) p.88
            %
            % The following generates the table of Huffman codes which
            % represent the 12 luminance DC difference categories (or
            % ranges). The codes are generated so that there is no chance
            % of a code consisting only of 1s.
            codeLengths = EntropyCoding.LuminanceDCHuffmanCodeCountPerCodeLength;
            symbolValues = EntropyCoding.LuminanceDCHuffmanSymbolValuesPerCode;
            huffmanCodesForDCLuminanceCellArray = obj.createHuffmanCodes(codeLengths, symbolValues);
            
            % The DC value for each block in raster order
            obj.yEncodedDCCellArray = arrayfun(@(x)(EntropyCoding.encodeDCValue(x, huffmanCodesForDCLuminanceCellArray)), obj.yDifferentialDCCoefficients, 'UniformOutput', false);
            
            % The Chroma DC Huffman code table for the 12 categories 
            codeLengths = EntropyCoding.ChromaDCHuffmanCodeCountPerCodeLength;
            symbolValues = EntropyCoding.ChromaDCHuffmanSymbolValuesPerCode;
            huffmanCodesForDCChromaCellArray = obj.createHuffmanCodes(codeLengths, symbolValues);
            
            % The DC value for each block in raster order
            obj.cbEncodedDCCellArray = arrayfun(@(x)(EntropyCoding.encodeDCValue(x, huffmanCodesForDCChromaCellArray)), obj.cbDifferentialDCCoefficients, 'UniformOutput', false);
            % The DC value for each block in raster order
            obj.crEncodedDCCellArray = arrayfun(@(x)(EntropyCoding.encodeDCValue(x, huffmanCodesForDCChromaCellArray)), obj.crDifferentialDCCoefficients, 'UniformOutput', false);

            % Huffman Code AC Values
            % Ref: CCITT Rec. T.81 (1992 E) p.89
            %   Luminance
            codeLengths = EntropyCoding.LuminanceACHuffmanCodeCountPerCodeLength;
            symbolValues = EntropyCoding.LuminanceACHuffmanSymbolValuesPerCode;
            huffmanCodesForACLuminanceCellArray = obj.createHuffmanCodes(codeLengths, symbolValues);
            %   Chroma
            codeLengths = EntropyCoding.ChromaACHuffmanCodeCountPerCodeLength;
            symbolValues = EntropyCoding.ChromaACHuffmanSymbolValuesPerCode;
            huffmanCodesForACChromaCellArray = obj.createHuffmanCodes(codeLengths, symbolValues);
            
            % Note, at this point the zerosRunLengthCoding has already
            % handled the special RS value cases, so the entries need
            % simply encoding (-1 values are to be ignored)
            
            % y
            % first find -1s
            %[x,y] = meshgrid(1:size(obj.yZerosRunLengthCodedOrderedACCoefficients,1), 1:size(obj.yZerosRunLengthCodedOrderedACCoefficients,2));
            flatCoeffs = reshape(obj.yZerosRunLengthCodedOrderedACCoefficients.', [1 size(obj.yZerosRunLengthCodedOrderedACCoefficients, 1)*size(obj.yZerosRunLengthCodedOrderedACCoefficients,2)]);
            blockStartIndexes = 1:126:length(flatCoeffs);
            for i = 1:length(blockStartIndexes)
                % For each block (raster order)
                idx = blockStartIndexes(i);
                lengths = flatCoeffs(idx:idx+62);
                values = flatCoeffs(idx+63:idx+125);
                lastIndex = find( lengths == -1, 1);
                lengths = lengths(1:lastIndex - 1);
                values = values(1:lastIndex - 1);
                obj.yEncodedACCellArray{i} = arrayfun(@(runLength, value)(EntropyCoding.encodeACZerosRunLengthValue(runLength, value, huffmanCodesForACLuminanceCellArray)), ...
                                                lengths, ... % lengths
                                                values, ... % values
                                                'UniformOutput', false);
            end
            
            clear flatCoeffs;
            
            % cb
            %obj.cbEncodedACCellArray = arrayfun(@(x)(EntropyCoding.encodeACValue(x, huffmanCodesForACChromaCellArray)), obj.cbZerosRunLengthCodedOrderedACCoefficients, 'UniformOutput', false);
            flatCoeffs = reshape(obj.cbZerosRunLengthCodedOrderedACCoefficients.', [1 size(obj.cbZerosRunLengthCodedOrderedACCoefficients, 1)*size(obj.cbZerosRunLengthCodedOrderedACCoefficients,2)]);
            blockStartIndexes = 1:126:length(flatCoeffs);
            for i = 1:length(blockStartIndexes)
                % For each block (raster order)
                idx = blockStartIndexes(i);
                lengths = flatCoeffs(idx:idx+62);
                values = flatCoeffs(idx+63:idx+125);
                lastIndex = find( lengths == -1, 1);
                lengths = lengths(1:lastIndex - 1);
                values = values(1:lastIndex - 1);
                obj.cbEncodedACCellArray{i} = arrayfun(@(runLength, value)(EntropyCoding.encodeACZerosRunLengthValue(runLength, value, huffmanCodesForACChromaCellArray)), ...
                                                lengths, ... % lengths
                                                values, ... % values
                                                'UniformOutput', false);
            end
            
            clear flatCoeffs;
            
            % cr
            %obj.crEncodedACCellArray = arrayfun(@(x)(EntropyCoding.encodeACValue(x, huffmanCodesForACChromaCellArray)), obj.crZerosRunLengthCodedOrderedACCoefficients, 'UniformOutput', false);
            flatCoeffs = reshape(obj.crZerosRunLengthCodedOrderedACCoefficients.', [1 size(obj.crZerosRunLengthCodedOrderedACCoefficients, 1)*size(obj.crZerosRunLengthCodedOrderedACCoefficients,2)]);
            blockStartIndexes = 1:126:length(flatCoeffs);
            for i = 1:length(blockStartIndexes)
                % For each block (raster order)
                idx = blockStartIndexes(i);
                lengths = flatCoeffs(idx:idx+62);
                values = flatCoeffs(idx+63:idx+125);
                lastIndex = find( lengths == -1, 1);
                lengths = lengths(1:lastIndex - 1);
                values = values(1:lastIndex - 1);
                obj.crEncodedACCellArray{i} = arrayfun(@(runLength, value)(EntropyCoding.encodeACZerosRunLengthValue(runLength, value, huffmanCodesForACChromaCellArray)), ...
                                                lengths, ... % lengths
                                                values, ... % values
                                                'UniformOutput', false);
            end
            
            clear flatCoeffs;
            
            % Create the output bitstream
            stream = obj.createBitStream();
        end
        
        % Helper Methods
        function levelShiftInputImage(obj)
            % -----------
            % Level Shift
            % -----------
            % By adjusting the range of the input data from 0-255 to
            % -128-127 the DCT DC value range is changed to be in a similar
            % integer range to that of the AC values making implementations
            % simpler on particular integer types. The AC values should be
            % level shift independant
            % Ref:
            % http://compgroups.net/comp.compression/Level-Shift-in-JPEG-optional-or-mandatory
            
            %%%%% After a non-differential frame decoding process computes
            %%%%% the IDCT and produces a block of reconstructed image samples, an inverse level shift shall restore the samples to the unsigned representation by adding 2P ? 1 and clamping the results to the range 0 to 2P ? 1.
            obj.imageStruct.yLevelShifted   = int8(double(obj.imageStruct.y) - 128);
            obj.imageStruct.cbLevelShifted  = int8(double(obj.imageStruct.cb) - 128);
            obj.imageStruct.crLevelShifted  = int8(double(obj.imageStruct.cr) - 128);
        end
        
        function coeffs = quantiseLuminanceCoefficients(obj, block)
            coeffs = TransformCoding.luminanceQuantisation(block, obj.luminanceScaledQuantisationTable);
        end
        
        function coeffs = quantiseChromaCoefficients(obj, block)
            coeffs = TransformCoding.chromaQuantisation(block, obj.chromaScaledQuantisationTable);
        end
        
        function huffmanCodesCellArray = createHuffmanCodes(obj, bits, huffvals)
            [huffsize, lastk] = EntropyCoding.generateTableOfHuffmanCodeSizes(bits);
            huffcode = EntropyCoding.generateTableOfHuffmanCodes(huffsize);
            [ehufco, ehufsi] = EntropyCoding.generateEncodingProcedureCodeTables( huffvals, huffcode, huffsize, lastk );
            huffmanCodesCellArray = arrayfun(@Utilities.decimalToLogical, ehufco, ehufsi, 'UniformOutput', false);
        end
        
        function stream = createBitStream(obj)
            % ----------------
            % Create bitstream
            % ----------------
            % Ref: CCITT Rec. T.81 (1992 E)
            %
            % Note Baseline DCT mode JPEG (SOF0) is the only supported mode
            % in this application.
            %
            % The following describes the hierarchy of the JPEG bitstream
            % created here. This is essentially the minimum requirements.
            %
            % A JPEG bitstream is as follows:
            % 1) Start of image marker (SOI)
            % 2) [FRAME]
            % 3) End of image marker (EOI)
            %
            % A [FRAME] is as follows:
            % 1) [TABLES]
            % 2) [FRAMEHEADER]
            % 3) [SCAN]
            % 4) <[SCAN>] <- optionally more scans containing channels
            % 5) ...
            %
            % Note: all channels can be interleaved into 1 SCAN or they can
            % be kept non-interleaved with 1 SCAN segment per channel.
            %
            % A [FRAMEHEADER] is composed of:
            % 1) A Start of Frame Marker defining the mode (SOFx)
            % 2) 8 bytes of frame info, layed out as: Header length (Lf, 2
            % bytes), data precision (P, 1 bytes), frame height (Y, 2
            % bytes), frame width (X, 2 bytes), number of channels in image
            % (Nf, 1 byte) and then for each channel 3 bytes, the first an
            % ID for the channel (Cx, 1 byte), the second the sampling
            % factors for the channel in both the horizontal and vertical
            % directions (Hx:Vx both 4 bits packed into 1 byte) and an ID
            % of the Quantisation table to use for the channel (Tqx, 1
            % byte).
            %
            % A [SCAN] is composed of:
            % 1) <[TABLES]> optional
            % 2) [SCANHEADER]
            % 3) [Entropy coded segment ECS]
            %
            % A [SCANHEADER] is composed of:
            % 1) A Start of Scan marker (SOS)
            % 2) 6 + (2*3) bytes (for 3 channels) comprising of: Header length
            % (Ls, 2 bytes), number of channels in scan (Ns, 1 byte), a 2
            % byte sequence for each colour channel: the ID (Csi 1 byte),
            % then 2 packed nibbles of the DC entropy coding table ID & the
            % AC entropy coding table ID (Tdi:Tai, 1 byte). These are
            % followed by the Start of predictor ID (Ss, 1 byte), the End
            % of predictor ID (Se, 1 byte) and then 1 packed byte
            % comprising of Successive approximation bit position high and
            % the Successive approximation bit position low (Ah:Al, 1
            % byte). Note for Sequential Baseline DCT JPEG, Ss = 0, Se =
            % 63, Ah = 0 and Al = 0
            %
            % An [ECS] (entropy coded segment) is as follows:
            % 1) 
            %
            % The [TABLES] for quantisation and Huffman coding are as
            % follows:
            % * Quantisation Tables:
            %   1) Define Quantisation Table marker (DQT)
            %   2) Segment length (Lq, 2 bytes) followed, for each table to
            %      be specified, by: 1 packed byte where the high four bits
            %      are the Precision of entries, (0 for 8 bit, 1 for 
            %      16bit) and the low 4 bits are the ID of the table
            %      (Pq:Tq, 1 byte), followed by the 64 quantisation table
            %      entries in zig-zag order (64 bytes (or 128 if 16bit Pq))
            %
            % * Huffman Tables:
            %   1) Define Huffman Table marker (DHT)
            %   2) Segment length (Lh, 2 bytes) followed, for each table to
            %      be specified: 1 packed byte with top 4 bits specifying
            %      the type of table (0 for DC, 1 for AC) and lower 4 bits
            %      are the table ID (Tc:Th, 1 bytes), 16 bytes specifying
            %      the number of Huffman codes per code length Li (Li, i =
            %      1:16, 16 bytes), then come the values associated with
            %      each Huffman code. The V{i,j} value is the value for the
            %      j'th code of length i. The values are grouped in length
            %      order.
            %
            % Since a number of segments are not used in the implementation
            % they are not discussed further. Please refer to the standards
            % documentation for more. Markers: DNL, DRI, RST, COM, APP ETC
            
            % Ref: CCITT Rec. T.81 (1992 E)	p. 32
            % SOI : Marks start of a JPEG image
            markerStartOfImage          = Utilities.hexToShort('FFD8');
            % EOI : Marks the end of the JPEG file
            markerEndOfImage            = Utilities.hexToShort('FFD9');
            
            frameHeader = obj.createBitStreamForFrameHeader();
            quantisationTables = obj.createBitStreamForQuantisationTables();
            huffmanTables = obj.createBitStreamForHuffmanTables();
                        
            scanHeaderY = obj.createBitStreamForScanHeaderForSingleChannel('y');
            entropyCodedSegmentY = obj.createBitStreamForEntropyCodedDataForSingleChannel('y');
            
            scanHeaderCb = obj.createBitStreamForScanHeaderForSingleChannel('cb');
            entropyCodedSegmentCb = obj.createBitStreamForEntropyCodedDataForSingleChannel('cb');
            
            scanHeaderCr = obj.createBitStreamForScanHeaderForSingleChannel('cr');
            entropyCodedSegmentCr = obj.createBitStreamForEntropyCodedDataForSingleChannel('cr');
            
            stream = cat(2, markerStartOfImage, ... % SOI
                quantisationTables, ... % Tables for this image
                huffmanTables, ...
                frameHeader, ...
                scanHeaderY,...
                entropyCodedSegmentY, ...
                scanHeaderCb,...
                entropyCodedSegmentCb, ...
                scanHeaderCr,...
                entropyCodedSegmentCr, ...
            markerEndOfImage);  % EOI

            obj.output = stream;
        end
        
        function bits = createBitStreamForEntropyCodedDataForSingleChannel(obj, type)
            % -----------
            % Entropy Coded Segment
            % -----------
            
            bits = [];
            
            switch type
                case 'y'
                    dcCell = obj.yEncodedDCCellArray;
                    acCell = obj.yEncodedACCellArray;
                case 'cb'
                    dcCell = obj.cbEncodedDCCellArray;
                    acCell = obj.cbEncodedACCellArray;
                case 'cr'
                    dcCell = obj.crEncodedDCCellArray;
                    acCell = obj.crEncodedACCellArray;
            end
            
            for i=1:length(dcCell)
                bits = cat(2, bits, dcCell{i}, cell2mat(acCell{i}));
            end

            bits = Utilities.padLogicalArray(bits, 8, 1);
            bits = Utilities.byteStuffing(bits, 8);

        end
        
        function bits = createBitStreamForScanHeaderForSingleChannel(obj, type)
            % -----------
            % Scan Header
            % -----------
            % Ref: CCITT Rec. T.81 (1992 E)	p.37
            
            % From real JPEG image using 4:2:0
            % FF DA 00 0C 03 01 00 02 11 03 11 00 3F 00
            % SOS, Ls(12), Ns(3), Cs1(1=Y), Td1(0):Ta1(0), Cs2(2=Cb), Td2(1):Ta2(1), Cs3(3=Cr), Td3(1):Ta3(1), Ss(0), Se(3F), Ah(0):Al(0)
            
            % SOS marker
            markerStartOfScan       = Utilities.hexToShort('FFDA');
            
            % Ls    (2 bytes)
            segmentLength       = Utilities.decimalToShort(6 + (2*1));
            % Ns    (1 byte)
            componentCount      = Utilities.decimalToByte(1);
            switch type
                case 'y'
                    % Cs1   (1 byte)
                    channelID          = Utilities.decimalToByte(1);
                    % Td1:Ta1 (1 byte)
                    channelTableIDs    = Utilities.decimalNibblesToByte(0, 0);
                case 'cb'
                    % Cs2   (1 byte)
                    channelID         = Utilities.decimalToByte(2);
                    % Td2:Ta2 (1 byte)
                    channelTableIDs   = Utilities.decimalNibblesToByte(1, 1);
                case 'cr'
                    % Cs3   (1 byte)
                    channelID         = Utilities.decimalToByte(3);
                    % Td3:Ta3 (1 byte)
                    channelTableIDs   = Utilities.decimalNibblesToByte(1, 1);
            end
            % Ss    (1 byte)
            startPredictorID    = Utilities.decimalToByte(0);
            % Se    (1 byte)
            endPredictorID      = Utilities.decimalToByte(63);
            % Ah:Al (1 byte)
            successiveApproximationBitPosition = Utilities.decimalNibblesToByte(0, 0);
            
            bits = cat(2, ...
                markerStartOfScan, ...
                segmentLength, ...
                componentCount, ...
                channelID, ...
                channelTableIDs, ...
                startPredictorID, ...
                endPredictorID, ...
                successiveApproximationBitPosition ...
                );

            %{
            % Ls    (2 bytes)
            segmentLength       = Utilities.decimalToShort(6 + (2*3));
            % Ns    (1 byte)
            componentCount      = Utilities.decimalToByte(3);
            % Cs1   (1 byte)
            yChannelID          = Utilities.decimalToByte(1);
            % Td1:Ta1 (1 byte)
            yChannelTableIDs    = Utilities.decimalNibblesToByte(0, 0);
            % Cs2   (1 byte)
            cbChannelID         = Utilities.decimalToByte(2);
            % Td2:Ta2 (1 byte)
            cbChannelTableIDs   = Utilities.decimalNibblesToByte(1, 1);
            % Cs3   (1 byte)
            crChannelID         = Utilities.decimalToByte(3);
            % Td3:Ta3 (1 byte)
            crChannelTableIDs   = Utilities.decimalNibblesToByte(1, 1);
            % Ss    (1 byte)
            startPredictorID    = Utilities.decimalToByte(0);
            % Se    (1 byte)
            endPredictorID      = Utilities.decimalToByte(63);
            % Ah:Al (1 byte)
            successiveApproximationBitPosition = Utilities.decimalNibblesToByte(0, 0);
            
            bits = cat(2, ...
                markerStartOfScan, ...
                segmentLength, ...
                componentCount, ...
                yChannelID, ...
                yChannelTableIDs, ...
                cbChannelID, ...
                cbChannelTableIDs, ...
                crChannelID, ...
                crChannelTableIDs, ...
                startPredictorID, ...
                endPredictorID, ...
                successiveApproximationBitPosition ...
                );
            %}
        end
        
        function bits = createBitStreamForFrameHeader(obj)
            % -------------------
            % Frame Header Format
            % -------------------
            % Ref: CCITT Rec. T.81 (1992 E)	p. 35
            % and
            % http://en.wikibooks.org/wiki/JPEG_-_Idea_and_Practice/The_header_part
            
            % SOF0 : Marks that this is a Baseline DCT mode JPEG
            markerStartOfFrame_Mode0    = Utilities.hexToShort('FFC0');
            
            % Here is a header from a real JPEG using 4:2:2
            % FF C0, 00 11, 08, 01 90, 02 80, 03, 01, 21, 00, 02, 11, 01, 03, 11, 01
            % Using the notation of the T.81:
            % SOF0, Lf(17), P(8), Y(400), X(640), Nf(3), Ci(1=Y), Hi(2):Vi(1), Tqi(0), Ci(2=Cb), Hi(1):Vi(1), Tqi(1), Ci(3=Cr), Hi(1):Vi(1), Tqi(1)
            % followed by the huffman tables
            
            % From a real JPEG using 4:4:4 then Hi = 1 Vi = 1 for all
            % From a real JPEG using 4:2:0 then Hi = 2 Vi = 2 for Y and 1,1
            % for chroma. For a more detailed explaination see the comments
            % in the following method:
            [yHi yVi cbHi cbVi crHi crVi] = Subsampling.modeToHorizontalAndVerticalSamplingFactors(obj.imageStruct.mode);
            
            % Lf    (2 bytes)
            segmentSOFLength            = Utilities.decimalToShort(8 + 3 * (3));%dec2bin(8 + 3 * (3), 16); % includes the 2 bytes needed for the length itself
            % P     (1 byte)
            dataByteSize                = Utilities.decimalToByte(8);%dec2bin(8,8); % 8 bit bytes , would be 12 in extended mode but im not supporting it
            % Y     (2 byte)
            imageHeight                 = Utilities.decimalToShort(size(obj.imageStruct.y,1));%dec2bin(size(obj.imageStruct.y,1),16);
            % X     (2 byte)
            imageWidth                  = Utilities.decimalToShort(size(obj.imageStruct.y,2));%dec2bin(size(obj.imageStruct.y,2),16);
            % Nf    (1 byte)
            numberOfChannels            = Utilities.decimalToByte(3);%dec2bin(3, 8);
            
            % Ci1   (1 byte)
            yComponentIdentifier        = Utilities.decimalToByte(1);%dec2bin(1,8);
            % Hi1   (1 nibble)
            % Vi1   (1 nibble)
            yHorizontalVerticalSamplingFactor       = Utilities.decimalNibblesToByte(yHi, yVi);
            % Tqi1  (1 byte)
            yQuantisationTableDestinationSelector   = Utilities.decimalToByte(0);%dec2bin(0,8); %Table0 for Y 
            
            % Ci2   (1 byte)
            cbComponentIdentifier       = Utilities.decimalToByte(2);%dec2bin(2,8);
            % Hi2   (1 nibble)
            % Vi2   (1 nibble)
            cbHorizontalVerticalSamplingFactor      = Utilities.decimalNibblesToByte(cbHi, cbVi);
            % Tqi2  (1 byte)
            cbQuantisationTableDestinationSelector  = Utilities.decimalToByte(1);%dec2bin(1,8); %Table1 for chroma
            
            % Ci3   (1 byte)
            crComponentIdentifier       = Utilities.decimalToByte(3);%dec2bin(3,8);
            % Hi3   (1 nibble)
            % Vi3   (1 nibble)
            crHorizontalVerticalSamplingFactor      = Utilities.decimalNibblesToByte(crHi, crVi);
            % Tqi3  (1 byte)
            crQuantisationTableDestinationSelector  = Utilities.decimalToByte(1);%dec2bin(1,8);

            bits = cat(2,markerStartOfFrame_Mode0, ...% SOF: start frame header
                segmentSOFLength, ...
                dataByteSize, ...
                imageHeight, ...
                imageWidth, ...
                numberOfChannels, ...
                yComponentIdentifier, ... %yHorizontalSamplingFactor, yVerticalSamplingFactor, ...
                yHorizontalVerticalSamplingFactor, ...
                yQuantisationTableDestinationSelector, ...
                cbComponentIdentifier, ... %cbHorizontalSamplingFactor, cbVerticalSamplingFactor, ...
                cbHorizontalVerticalSamplingFactor, ...
                cbQuantisationTableDestinationSelector, ...
                crComponentIdentifier, ... %crHorizontalSamplingFactor, crVerticalSamplingFactor, ...
                crHorizontalVerticalSamplingFactor, ...
                crQuantisationTableDestinationSelector);
        end
        
        function bits = createBitStreamForQuantisationTables(obj)
            % --------------------------
            % Quantisation Table entries
            % --------------------------
            % Ref: CCITT Rec. T.81 (1992 E)	p.39
            % 
            % TODO MOVE DOCS HERE FROM THE createBitStream method! 
            %
            % Note: This method encodes 2 quantisation tables, one for
            % luminance channels and one for chroma.
            
            % DQT
            markerDefineQuantisationTable   = Utilities.hexToShort('FFDB');
            
            % Lq
            segmentLength                   = Utilities.decimalToShort(2 + (2*65)); % 2 tables of 65 bytes each
            
            % Y Table
            % Pq:Tq
            luminanceTablePrecisionAndID    = Utilities.decimalNibblesToByte(0, 0); % 8 bit, table 0
            % Entries - arrayfun expects a scalar return so instead set
            % UniformOutput = false and then use cell2mat on the resulting
            % cell array to flatten it
            luminanceTableEntries           = cell2mat( arrayfun(@Utilities.decimalToByte, ...
                                                TransformCoding.coefficientOrdering( ...
                                                    obj.luminanceScaledQuantisationTable), 'UniformOutput', false));
            
            % Chroma Table
            % Pq:Tq
            chromaTablePrecisionAndID       = Utilities.decimalNibblesToByte(0, 1); % 8 bit, table 1
            % Entries
            chromaTableEntries              = cell2mat( arrayfun(@Utilities.decimalToByte, ...
                                                TransformCoding.coefficientOrdering( ...
                                                    obj.chromaScaledQuantisationTable), 'UniformOutput', false));
            
            bits = cat(2, ...
                markerDefineQuantisationTable, ...
                segmentLength, ...
                luminanceTablePrecisionAndID, ...
                luminanceTableEntries, ...
                chromaTablePrecisionAndID, ...
                chromaTableEntries ...
                );
        end

        function bits = createBitStreamForHuffmanTables(obj)
            % --------------------------
            % Huffman Table entries
            % --------------------------
            % Ref: CCITT Rec. T.81 (1992 E)	p.40
            
            % 4 TABLES
            
            % Define Huffman Table (DHT)
            markerDefineHuffmanTable    = Utilities.hexToShort('FFC4');

            % Lh - 4 tables * (17 bytes + numberOfValuesPerTable)
            segmentLength               = Utilities.decimalToShort(2 + ...
                                            (17 + length(EntropyCoding.LuminanceDCHuffmanSymbolValuesPerCode)) + ...
                                            (17 + length(EntropyCoding.LuminanceACHuffmanSymbolValuesPerCode)) + ...
                                            (17 + length(EntropyCoding.ChromaDCHuffmanSymbolValuesPerCode)) + ...
                                            (17 + length(EntropyCoding.ChromaACHuffmanSymbolValuesPerCode)));
            
            % Per table:
            % Luminance (ID 0) DC
            % Tc:Th
            luminanceTableDCTypeAndID    = Utilities.decimalNibblesToByte(0, 0);
            
            % Li 
            luminanceTableDCLengthCounts = cell2mat( arrayfun(@Utilities.decimalToByte, EntropyCoding.LuminanceDCHuffmanCodeCountPerCodeLength, 'UniformOutput', false));
            % Vi,j
            luminanceTableDCValues      = cell2mat( arrayfun(@Utilities.decimalToByte, EntropyCoding.LuminanceDCHuffmanSymbolValuesPerCode, 'UniformOutput', false));
            
            % AC
            % Tc:Th
            luminanceTableACTypeAndID    = Utilities.decimalNibblesToByte(1, 0);
            
            % Li 
            luminanceTableACLengthCounts = cell2mat( arrayfun(@Utilities.decimalToByte, EntropyCoding.LuminanceACHuffmanCodeCountPerCodeLength, 'UniformOutput', false));
            % Vi,j
            luminanceTableACValues      = cell2mat( arrayfun(@Utilities.decimalToByte, EntropyCoding.LuminanceACHuffmanSymbolValuesPerCode, 'UniformOutput', false));

            % Chroma (ID 1) DC 
            % Tc:Th
            chromaTableDCTypeAndID      = Utilities.decimalNibblesToByte(0, 1);
            
            % Li 
            chromaTableDCLengthCounts   = cell2mat( arrayfun(@Utilities.decimalToByte, EntropyCoding.ChromaDCHuffmanCodeCountPerCodeLength, 'UniformOutput', false));
            % Vi,j
            chromaTableDCValues         = cell2mat( arrayfun(@Utilities.decimalToByte, EntropyCoding.ChromaDCHuffmanSymbolValuesPerCode, 'UniformOutput', false));
            
            % AC
            % Tc:Th
            chromaTableACTypeAndID      = Utilities.decimalNibblesToByte(1, 1);
            
            % Li 
            chromaTableACLengthCounts   = cell2mat( arrayfun(@Utilities.decimalToByte, EntropyCoding.ChromaACHuffmanCodeCountPerCodeLength, 'UniformOutput', false));
            % Vi,j
            chromaTableACValues         = cell2mat( arrayfun(@Utilities.decimalToByte, EntropyCoding.ChromaACHuffmanSymbolValuesPerCode, 'UniformOutput', false));
            
            bits = cat(2, ...
                markerDefineHuffmanTable, ...
                segmentLength, ...
                luminanceTableDCTypeAndID, ...
                luminanceTableDCLengthCounts, ...
                luminanceTableDCValues, ...
                luminanceTableACTypeAndID, ...
                luminanceTableACLengthCounts, ...
                luminanceTableACValues, ...
                chromaTableDCTypeAndID, ...
                chromaTableDCLengthCounts, ...
                chromaTableDCValues, ...
                chromaTableACTypeAndID, ...
                chromaTableACLengthCounts, ...
                chromaTableACValues ...
                );
        end

    end
end 

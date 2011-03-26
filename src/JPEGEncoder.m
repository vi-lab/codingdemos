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
        function obj = DemoJPEGEncoder(source)
            if exist('source','var')
                obj.input(source);
            end
            
            % set parameter defaults
            obj.qualityFactor = 60;
            obj.chromaSamplingMode = '4:2:0';
        end

        function set.input(obj, data)
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
                throw(MException('DemoJPEGEncoder:input', 'The input image data must be either a struct with y, cb and cr fields corresponding to the 3 channels, a string file name to read, or a ycbcr image matrix.')); 
            end
            % TODO: START CODING??? maybe optionally
        end
        
        function set.qualityFactor(obj, data)
            obj.qualityFactor = data;
            
            % TODO: UPDATE ENCODING
        end
       
        function set.chromaSamplingMode(obj, data)
            obj.chromaSamplingMode = data;
            
            % TODO: UPDATE ENCODING
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
        
        function success = encodeToFile(obj, fileName)
            success = Utilities.writeBinaryFileFromArray( fileName, Utilities.binaryToNumericArray(obj.encode()) );
        end

        function stream = encode(obj)
            % Encode Baseline DCT JPEG
            % ------------------------
            % Refs: 
            % Baseline process: CCITT Rec. T.81 (1992 E) p.87
            
            
            
            % check if input data is set
            
            % for each colour channel 
            %if ~isfield(obj.imageStruct, 'y')
            %    throw(MException('DemoJPEGEncoder:encode', 'No ''y'' channel was found on the source image.')); 
            %end
            
            % if subsampling is necessary
            if isa(obj.imageStruct, 'struct') 
                % TODO: HERE WE NEED to make sure its YCBCR
                
                if isfield(obj.imageStruct, 'mode')
                    if strcmp(obj.imageStruct.mode, obj.chromaSamplingMode)
                        % already ok
                    else
                        % convert
                    end
                else
                    % struct but no mode, so convert
                end
            else
                % no struct so create from matrix
            end
                        
            obj.luminanceScaledQuantisationTable = TransformCoding.qualityFactorToQuantisationTable(TransformCoding.luminanceQuantisationTable, obj.qualityFactor);
            obj.chromaScaledQuantisationTable = TransformCoding.qualityFactorToQuantisationTable(TransformCoding.chromaQuantisationTable, obj.qualityFactor);
            
            % TODO: Expand to be divisible by 8????????? or does blkproc
            % handle this?
            

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
            obj.imageStruct.y   = int8(double(obj.imageStruct.y) - 128);
            obj.imageStruct.cb  = int8(double(obj.imageStruct.cb) - 128);
            obj.imageStruct.cr  = int8(double(obj.imageStruct.cr) - 128);
            
            % perform DCT and quant
            obj.yCoefficients = blkproc(obj.imageStruct.y, [8 8], @dct2);
            obj.yQuantisedCoefficients = blkproc(obj.yCoefficients, [8 8], @(block)obj.quantiseLuminanceCoefficients(block));
            
            obj.cbCoefficients = blkproc(obj.imageStruct.cb, [8 8], @dct2);
            obj.cbQuantisedCoefficients = blkproc(obj.cbCoefficients, [8 8], @(block)obj.quantiseChromaCoefficients(block));
            
            obj.crCoefficients = blkproc(obj.imageStruct.cr, [8 8], @dct2);
            obj.crQuantisedCoefficients = blkproc(obj.crCoefficients, [8 8], @(block)obj.quantiseChromaCoefficients(block));
            
            % zigzag
            obj.yOrderedCoefficients = blkproc(obj.yQuantisedCoefficients, [8 8], @TransformCoding.coefficientOrdering);
            obj.cbOrderedCoefficients = blkproc(obj.cbQuantisedCoefficients, [8 8], @TransformCoding.coefficientOrdering);
            obj.crOrderedCoefficients = blkproc(obj.crQuantisedCoefficients, [8 8], @TransformCoding.coefficientOrdering);
            
            % RLE
            obj.yZerosRunLengthCodedOrderedCoefficients = blkproc(obj.yOrderedCoefficients, [1 64], @TransformCoding.zerosRunLengthCoding);
            obj.cbZerosRunLengthCodedOrderedCoefficients = blkproc(obj.cbOrderedCoefficients, [1 64], @TransformCoding.zerosRunLengthCoding);
            obj.crZerosRunLengthCodedOrderedCoefficients = blkproc(obj.crOrderedCoefficients, [1 64], @TransformCoding.zerosRunLengthCoding);
            
            % Huffman
            
            stream = obj.createBitStream();
        end
        
        % Helper Methods
        function coeffs = quantiseLuminanceCoefficients(obj, block)
            coeffs = TransformCoding.luminanceQuantisation(block, obj.luminanceScaledQuantisationTable);
        end
        
        function coeffs = quantiseChromaCoefficients(obj, block)
            coeffs = TransformCoding.chromaQuantisation(block, obj.chromaScaledQuantisationTable);
        end
        
        function stream = createBitStream(obj)
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
            % 1) <[TABLES]>   &&&&&&&&&&&&&&&&&&&&&& HERE ? &&&&&&&&&&&&&&&&&&&&
            % 2) [FRAMEHEADER]
            % 3) [SCAN]
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
            % 1) <[TABLES]>  &&&&&&&&&&&&&&&&&&&&&& HERE ? &&&&&&&&&&&&&&&&&&&&
            % 2) [SCANHEADER]
            % 3) [Entropy coded segment ECS]
            %
            % A [SCANHEADER] is composed of:
            % 1) A Start of Scan marker (SOS)
            % 2) 
            %
            % An [ECS] (entropy coded segment) is as follows:
            % 1)
            %
            % The [TABLES] for quantisation and Huffman coding are as
            % follows:
            % 1)
            %
            % Since a number of segments are not used in the implementation
            % they are not discussed further. Please refer to the standards
            % documentation for more. Markers: DNL, DRI, RST, COM, APP ETC
            
            % Markers
            % -------
            % Ref: CCITT Rec. T.81 (1992 E)	p. 32
            
            % SOI : Marks start of a JPEG image
            markerStartOfImage          = Utilities.hexToShort('FFD8');%dec2bin(hex2dec('FFD8'),16);

            % EOI : Marks the end of the JPEG file
            markerEndOfImage            = Utilities.hexToShort('FFD9');%dec2bin(hex2dec('FFD9'),16);
            
            % Frame Header Format
            % -------------------
            % Ref: CCITT Rec. T.81 (1992 E)	p. 35
            % and
            % http://en.wikibooks.org/wiki/JPEG_-_Idea_and_Practice/The_header_part
            
            % SOF0 : Marks that this is a Baseline DCT mode JPEG
            markerStartOfFrame_Mode0    = Utilities.hexToShort('FFC0');%dec2bin(hex2dec('FFC0'),16);
            
            % Here is a header from a real JPEG using 4:2:2
            % FF C0, 00 11, 08, 01 90, 02 80, 03, 01, 21, 00, 02, 11, 01, 03, 11, 01
            % Using the notation of the T.81:
            % SOF0, Lf(17), P(8), Y(400), X(640), Nf(3), Ci(1=Y), Hi(2):Vi(1), Tqi(0), Ci(2=Cb), Hi(1):Vi(1), Tqi(1), Ci(3=Cr), Hi(1):Vi(1), Tqi(1)
            % followed by the huffman tables
            
            % From a real JPEG using 4:4:4 then Hi = 1 Vi = 1 for all
            
            % From a real JPEG using 4:2:0 then Hi = 2 Vi = 2 for Y and 1,1
            % for chroma
            
            [Hi Vi] = Subsampling.modeToHorizontalAndVerticalSamplingFactor(obj.imageStruct.mode);
            
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
            %yHorizontalSamplingFactor   = dec2bin(Hi,4);
            % Vi1   (1 nibble)
            %yVerticalSamplingFactor     = dec2bin(Vi,4);
            yHorizontalVerticalSamplingFactor       = Utilities.decimalNibblesToByte(Hi, Vi);
            % Tqi1  (1 byte)
            yQuantisationTableDestinationSelector   = Utilities.decimalToByte(0);%dec2bin(0,8); %Table0 for Y 
            
            % Ci2   (1 byte)
            cbComponentIdentifier       = Utilities.decimalToByte(2);%dec2bin(2,8);
            % Hi2   (1 nibble)
            %cbHorizontalSamplingFactor  = dec2bin(1,4);
            % Vi2   (1 nibble)
            %cbVerticalSamplingFactor    = dec2bin(1,4);
            cbHorizontalVerticalSamplingFactor      = Utilities.decimalNibblesToByte(1, 1);
            % Tqi2  (1 byte)
            cbQuantisationTableDestinationSelector  = Utilities.decimalToByte(1);%dec2bin(1,8); %Table1 for chroma
            
            % Ci3   (1 byte)
            crComponentIdentifier       = Utilities.decimalToByte(3);%dec2bin(3,8);
            % Hi3   (1 nibble)
            %crHorizontalSamplingFactor  = dec2bin(1,4);
            % Vi3   (1 nibble)
            %crVerticalSamplingFactor 	= dec2bin(1,4);
            crHorizontalVerticalSamplingFactor      = Utilities.decimalNibblesToByte(1, 1);
            % Tqi3  (1 byte)
            crQuantisationTableDestinationSelector  = Utilities.decimalToByte(1);%dec2bin(1,8);
            
            
            % Tables
            % ------
                        
            markerDefineQuantisationTable   = Utilities.hexToShort('FFDB');%dec2bin(hex2dec('FFDB'),16);
            markerDefineHuffmanTable        = Utilities.hexToShort('FFC4');%dec2bin(hex2dec('FFC4'),16);
            
            
            
            % Scan Header
            % -----------
            % Ref: CCITT Rec. T.81 (1992 E)	p.37
            
            % From real JPEG image using 4:2:0"
            % FF DA 00 0C 03 01 00 02 11 03 11 00 3F 00
            % SOS, Ls(12), Ns(3), Cs1(1=Y), Td1(0):Ta1(0), Cs2(2=Cb), Td2(1):Ta2(1), Cs3(3=Cr), Td3(1):Ta3(1), Ss(0), Se(3F), Ah(0):Al(0)
            
            % SOS marker
            markerStartOfScan       = Utilities.hexToShort('FFDA');%dec2bin(hex2dec('FFDA'), 16);
            
            % Ls    (2 bytes)
            % Ns    (1 byte)
            % 
            
            
            % Entropy Coded Segment 0
            
            % *********************************
            % TODO:
            % DONT FORGET TO PADD 0xFFs in Huffman coded data with 0x00
            % !!!!!!!
            % PAD with 1s to end if nec (I think) -- div by 8 and remainder
            % is how many bits need adding
            
            
            stream = strcat(markerStartOfImage, ... % SOI
                markerStartOfFrame_Mode0, ...% SOF: start frame header
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
                crQuantisationTableDestinationSelector, ... % end frame header
                markerEndOfImage);  % EOI
            
            
            % TODO:
            % optimisation wise will be quicker to build in numeric form
            % but will look at this later
            
            % CONVERT to numeric array for writing to file
            
            
            obj.output = stream;
        end
    end
end 

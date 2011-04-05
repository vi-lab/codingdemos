classdef JPEGDecoder < handle
%JPEGDECODER Summary of this class goes here
%   Detailed explanation goes here
%
% Copyright 2011, Stephen Ierodiaconou, University of Bristol.


    properties (SetObservable)
        inputStruct
    end
    
    properties (SetObservable, SetAccess='private')
        verbose = false;
        
        chromaSamplingMode
        
        % TODO : REFACTOR NAMING 
        
        
        % Quantisation tables cell array
        quantisationTables
        
        % BITS and HUFVALS arrays
        huffmanACCodeCountPerCodeLength
        huffmanACSymbolValuesPerCode
        huffmanDCCodeCountPerCodeLength
        huffmanDCSymbolValuesPerCode
        
        % HUFFCODE arrays
        huffcodeForDCCellArray
        huffcodeForACCellArray
        % Huffman code tables
        huffmanCodesForDCCellArray
        huffmanCodesForACCellArray
        
        % Scan segments - channels of the image
        scanSegments
        
        % RS values for ZRLC from entropy decode
        zerosRunLengthCodedOrderedACCoefficients
        
        % Output image data
        outputImageSize
        numberOfChannels
        
        outputImageMatrix
        outputImageStruct
        
        
        
%{
        yComponentIdentifier
        yHorizontalSamplingFactor
        yVerticalSamplingFactor
        yQuantisationTableDestinationSelector
        cbComponentIdentifier
        cbHorizontalSamplingFactor
        cbVerticalSamplingFactor
        cbQuantisationTableDestinationSelector
        crComponentIdentifier
        crHorizontalSamplingFactor
        crVerticalSamplingFactor
        crQuantisationTableDestinationSelector
        %}
        %{
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
        %}
    end

    methods
        function obj = JPEGDecoder(source)
            if exist('source','var')
                obj.inputStruct = source;
            end
        end

        function set.inputStruct(obj, data)
            %if source is a string read file, if its a vector is logical
            %bit stream
            if isa(data, 'char')
                obj.inputStruct = struct('fileName', data, ...
                                        ... %'binaryData', Utilities.readBinaryFileToArray(data, 'logical'), ...
                                        'numericData', Utilities.readBinaryFileToArray(data, 'numeric'));
            elseif isa(data, 'logical')
                obj.inputStruct = struct('binaryData', data);
            elseif isa(data, 'struct')   %%%%%%%%%%%%%%%% STRUCT DATA FROM encoder, all data 
                %%%%%%obj.data = data;
            else
                throw(MException('JPEGDecoder:input', 'The input image data must be either a string file name to read, or a bistream in the form of a logical matrix of bits .')); 
            end
        end
        
        function outputImage = decode(obj, verbose)
            outputImage = [];            
            if exist('verbose', 'var')
                obj.verbose = verbose;
            end
            
            if isfield(obj.inputStruct, 'binaryData')
               obj.decodeFromLogicalArray(); 
            elseif isfield(obj.inputStruct, 'numericData')
               obj.decodeFromNumericArray(); 
            else
                %%%%%%%% STRUCT FROM ENCODER, only do whats needed, (prob
                %%%%%%%% no entropy decode)
            end
            
            % For each channel
            
            % AC de-Run-length code
            
            
            
            % DC de-diff
            
            
            % Dequantise, tables are zigzaged
            
            
            % add DC
            
            
            % Dezigzag coeffs
            
            
            
            % IDCT
            
            
            
            % Level shift
            
            

            %{
            % decode bitstream
            
            obj.imageStruct = ;
            
            % ETC ETC ETC
            obj.output = struct('image', obj.imageStruct, 'PSNR', 123); 
            obj.imageMatrix = Subsampling.subsampledToYCbCrImage(obj.imageStruct);
            outputImage = obj.imageMatrix;
            %}
        end
        
        function decodeFromNumericArray(obj)
            % For each segment marker decode section
            test1 = true;
            hasSeenSOI = false; 
            hasSeenEOI = false;
            hasSeenSOF = false;
            hasSeenDQT = false;
            hasSeenDHT = false;
            hasSeenSOS = false;
            numberOfBytes = length(obj.inputStruct.numericData);
            currentByte = 1;
            
            while test1
                if obj.inputStruct.numericData(currentByte) == 255
                    currentByte = currentByte + 1;
                    switch(obj.inputStruct.numericData(currentByte))
                        case 0 % FF 00 = pad, Not A Marker
                            if obj.verbose
                                disp('(NaM) - should have been consumed, this must be an error or bad bitstream');
                            end
                        case 216 % FF D8 = 255 216 = Start of Image
                            if obj.verbose
                                disp('(SOI)');
                            end
                            hasSeenSOI = true;
                        case 217 % FF D9 = 255 217 = End of Image
                            if obj.verbose
                                disp('(EOI)');
                            end
                            hasSeenEOI = true;
                        case 192 % FF C0 = 255 192 = Frameheader, Mode 0
                            if obj.verbose
                                disp('(SOF), Mode 0');
                            end
                            hasSeenSOF = true;
                            
                            % decode it
                            currentByte = obj.decodeFrameHeaderFromNumericData(currentByte + 1);
                            
                        case 218 % FF DA = 255 218 = Start of Scan
                            if ~hasSeenSOF || ~hasSeenDQT || ~hasSeenDHT
                                throw(MException('JPEGDecoder:decodeFromNumericArray', 'A Scan Segment header (or Start of Scan marker) was encountered before one of more of the frame header or huffman or quantisation tables where found.')); 
                            end
                            if obj.verbose
                                disp('(SOS)');
                            end
                            hasSeenSOS = true;
                            
                            % decode it
                            currentByte = obj.decodeScanSegmentFromNumericData(currentByte + 1);
 
                        case 219 % FF DB = 255 219 = Start of Quantisation Tables
                            if obj.verbose
                                disp('(DQT)');
                            end
                            hasSeenDQT = true;
                            
                            % decode it
                            currentByte = obj.decodeQuantisationTablesFromNumericData(currentByte + 1);
                            
                        case 196 % FF C4 = 255 196 = Start of Huffman tables
                            if obj.verbose
                                disp('(DHT)');
                            end
                            % replaces prev tables if they are already
                            % defined
                            hasSeenDHT = true;
                            
                            % Decode it
                            currentByte = obj.decodeHuffmanTablesFromNumericData(currentByte + 1);
                            
                    end
                end
                currentByte = currentByte + 1;
                test1 = (currentByte < numberOfBytes);
            end
            
            if ~hasSeenSOS
                throw(MException('JPEGDecoder:decodeFromNumericArray', 'The stream to decode does not contain anyay Start Of Scan marker. Without any scan segments there is no image data.')); 
            end
            
            if ~hasSeenSOI
                throw(MException('JPEGDecoder:decodeFromNumericArray', 'The stream to decode contains no Start Of Image marker. Some of the image may have been decoded however so please check the output.')); 
            end
            
            if ~hasSeenEOI
                throw(MException('JPEGDecoder:decodeFromNumericArray', 'The stream to decode contains no End Of Image marker. Some of the image may have been decoded however so please check the output.')); 
            end
        end
        
        % TODO: MAKE THESE INTO UTILITIES!
        function short = getNumericShort(obj, startByte)
            short = (obj.inputStruct.numericData(startByte) * 256) + obj.inputStruct.numericData(startByte + 1);
        end
        
        function [high low] = getNumericNibblesFromByte(obj, startByte)
            low = bitand(obj.inputStruct.numericData(startByte), 15);
            high = bitand(floor(obj.inputStruct.numericData(startByte) / 16), 15);
        end
        
        function endByte = decodeFrameHeaderFromNumericData(obj, startByte)
            % Lf    (2 bytes)
            segmentLength       = obj.getNumericShort(startByte);
            % P     (1 byte)
            dataByteSize        = obj.inputStruct.numericData(startByte + 2);
            % Y     (2 byte)
            imageHeight         = obj.getNumericShort(startByte + 3);
            % X     (2 byte)
            imageWidth          = obj.getNumericShort(startByte + 5);
            obj.outputImageSize = [imageWidth imageHeight];
            % Nf    (1 byte)
            obj.numberOfChannels    = obj.inputStruct.numericData(startByte + 7);

            % Ci1   (1 byte)
            obj.yComponentIdentifier                    = obj.inputStruct.numericData(startByte + 8);
            % Hi1   (1 nibble)
            % Vi1   (1 nibble)
            [obj.yHorizontalSamplingFactor obj.yVerticalSamplingFactor] = obj.getNumericNibblesFromByte(startByte + 9);
            % Tqi1  (1 byte)
            obj.yQuantisationTableDestinationSelector   = obj.inputStruct.numericData(startByte + 10);
            
            % Ci2   (1 byte)
            obj.cbComponentIdentifier                   = obj.inputStruct.numericData(startByte + 11);
            % Hi2   (1 nibble)
            % Vi2   (1 nibble)
            [obj.cbHorizontalSamplingFactor obj.cbVerticalSamplingFactor] = obj.getNumericNibblesFromByte(startByte + 12);
            % Tqi2  (1 byte)
            obj.cbQuantisationTableDestinationSelector  = obj.inputStruct.numericData(startByte + 13);
            
            % Ci3   (1 byte)
            obj.crComponentIdentifier                   = obj.inputStruct.numericData(startByte + 14);
            % Hi3   (1 nibble)
            % Vi3   (1 nibble)
            [obj.crHorizontalSamplingFactor obj.crVerticalSamplingFactor] = obj.getNumericNibblesFromByte(startByte + 15);
            % Tqi3  (1 byte)
            obj.crQuantisationTableDestinationSelector  = obj.inputStruct.numericData(startByte + 16);

            
            if obj.verbose
                disp (['- Frame Header: (' num2str(segmentLength) ' bytes), precision: ' num2str(dataByteSize) ', image (width, height): (' num2str(imageWidth) ', ' num2str(imageHeight) '), channels: ' num2str(obj.numberOfChannels)]);
                disp (['-- Component ' num2str(obj.yComponentIdentifier) ' (Hi,Vi): (' num2str(obj.yHorizontalSamplingFactor) ', ' num2str(obj.yVerticalSamplingFactor) '), Quantisation Table: ' num2str(obj.yQuantisationTableDestinationSelector)]);
                disp (['-- Component ' num2str(obj.cbComponentIdentifier) ' (Hi,Vi): (' num2str(obj.cbHorizontalSamplingFactor) ', ' num2str(obj.cbVerticalSamplingFactor) '), Quantisation Table: ' num2str(obj.cbQuantisationTableDestinationSelector)]);
                disp (['-- Component ' num2str(obj.crComponentIdentifier) ' (Hi,Vi): (' num2str(obj.crHorizontalSamplingFactor) ', ' num2str(obj.crVerticalSamplingFactor) '), Quantisation Table: ' num2str(obj.crQuantisationTableDestinationSelector)]);
            end
            endByte = startByte + segmentLength - 1;
        end
        
        
        function endByte = decodeQuantisationTablesFromNumericData(obj, startByte)
            % --------------------------
            % Quantisation Table entries
            % --------------------------
            % Ref: CCITT Rec. T.81 (1992 E)	p.39
            % 
            % TODO MOVE DOCS HERE FROM THE createBitStream method! 
            %
            % Note: This method encodes 2 quantisation tables, one for
            % luminance channels and one for chroma.
            
            % Lq
            segmentLength                   = obj.getNumericShort(startByte);
            if obj.verbose
                disp(['- Quantisation Table Segment (' num2str(segmentLength) ' bytes)']);
            end
            currentByte = startByte + 2;
            % tables
            while (currentByte < startByte + segmentLength - 1)
                % Pq:Tq
                [tablePrecision tableID]    = obj.getNumericNibblesFromByte(currentByte);
                % Entries
                obj.quantisationTables{tableID + 1} = TransformCoding.coefficientOrdering(obj.inputStruct.numericData(currentByte+1:currentByte+64), 'dezigzag');
                if obj.verbose
                    disp(['-- Table ' num2str(tableID) ': ']);
                    
                    obj.quantisationTables{tableID + 1}
                end
                
                currentByte = currentByte + 65;
            end
            
            %endByte = currentByte;
            endByte = startByte + segmentLength - 1; 
        end
        
        
        
        function endByte = decodeHuffmanTablesFromNumericData(obj, startByte)
 

            segmentLength                   = obj.getNumericShort(startByte);
            if obj.verbose
                disp(['- Huffman Table Segment (' num2str(segmentLength) ' bytes)']);
            end
            currentByte = startByte + 2;
            % tables
            while (currentByte < startByte + segmentLength - 1)
                % Tc:Th
                [tableType tableID]    = obj.getNumericNibblesFromByte(currentByte);
                
                % Li 
                Li = obj.inputStruct.numericData(currentByte + 1:currentByte + 16);
                
                currentByte = currentByte + 17;
                
                % Vi,j
                LiOffset = cumsum(Li) + currentByte;
                bytePositions = [currentByte; LiOffset(1:end - 1)];
                
                Vij = arrayfun(@(cnt, curr)(obj.inputStruct.numericData(curr:curr + cnt - 1)), ...
                    Li, bytePositions, 'UniformOutput', false);
                
                currentByte = LiOffset(end);
                
                if tableType == 0
                    obj.huffmanDCCodeCountPerCodeLength{tableID + 1} = Li;
                    obj.huffmanDCSymbolValuesPerCode{tableID + 1} = Vij;
                    % Create the bit tables from Li and Vi,j tables
                    % Huffman Code DC Values
                    % Ref: CCITT Rec. T.81 (1992 E) p.88
                    [a b] = obj.createHuffmanCodes(Li.', cell2mat(Vij).');
                    obj.huffmanCodesForDCCellArray{tableID + 1} = a;
                    obj.huffcodeForDCCellArray{tableID + 1} = b;
                    
                elseif tableType == 1
                    obj.huffmanACCodeCountPerCodeLength{tableID + 1} = Li;
                    obj.huffmanACSymbolValuesPerCode{tableID + 1} = Vij;
                    % Huffman Code AC Values
                    % Ref: CCITT Rec. T.81 (1992 E) p.89
                    [a b] = obj.createHuffmanCodes(Li.', cell2mat(Vij).');
                    obj.huffmanCodesForACCellArray{tableID + 1} = a;
                    obj.huffcodeForACCellArray{tableID + 1} = b;
                else
                    throw(MException('JPEGDecoder:decodeHuffmanTablesFromNumericData', 'The table type (Tc) can only be 0 or 1 where 0 = DC and 1 = AC.')); 
                end

                if obj.verbose
                    if tableType; type = 'AC'; else type = 'DC'; end;
                    disp(['-- Table ' type ', ID ' num2str(tableID)]);
                    %Li
                    %Vij
                end
                
            end
            
            %endByte = currentByte;
            endByte = startByte + segmentLength - 1; 
        end
        
        function [huffmanCodesCellArray, huffcode] = createHuffmanCodes(obj, bits, huffvals)
            [huffsize, lastk] = EntropyCoding.generateTableOfHuffmanCodeSizes(bits);
            huffcode = EntropyCoding.generateTableOfHuffmanCodes(huffsize);
            [ehufco, ehufsi] = EntropyCoding.generateEncodingProcedureCodeTables( huffvals, huffcode, huffsize, lastk );
            huffmanCodesCellArray = arrayfun(@Utilities.decimalToLogical, ehufco, ehufsi, 'UniformOutput', false);
        end
        
        function endByte = decodeScanSegmentFromNumericData(obj, startByte)

            % NOTE: this only supports non-interleaved data at the moment
            
            % Ls    (2 bytes)
            segmentLength = obj.getNumericShort(startByte);
            
            if obj.verbose
                disp(['- Scan Segment (header ' num2str(segmentLength) ' bytes):']);
            end
            
            % Ns    (1 byte)
            componentCount = obj.inputStruct.numericData(startByte + 2);
            if componentCount > 1
                disp('Warning: This code only supports non-interleaved data!');
            end

            % Cs1   (1 byte)
            channelID  = obj.inputStruct.numericData(startByte + 3);
            % Td1:Ta1 (1 byte)
            obj.scanSegments{channelID} = struct();
            [obj.scanSegments{channelID}.huffmanDCTableID obj.scanSegments{channelID}.huffmanACTableID] = obj.getNumericNibblesFromByte(startByte + 4);

            % Ss    (1 byte)
            obj.scanSegments{channelID}.startPredictorID = obj.getNumericNibblesFromByte(startByte + 5);
            % Se    (1 byte)
            obj.scanSegments{channelID}.endPredictorID = obj.getNumericNibblesFromByte(startByte + 6);
            % Ah:Al (1 byte)
            [obj.scanSegments{channelID}.successiveApproximationBitPositionHigh obj.scanSegments{channelID}.successiveApproximationBitPositionLow] = obj.getNumericNibblesFromByte(startByte + 7);
            
            if obj.verbose
                disp(['-- Segment ' num2str(channelID) ', Huffman DC Table: ' num2str(obj.scanSegments{channelID}.huffmanDCTableID) ', Huffman AC Table: ' num2str(obj.scanSegments{channelID}.huffmanACTableID) ]);
            end
            
            % Decode segment
            endByte = obj.decodeEntropyCodedSegmentFromNumericData(startByte + 8, channelID);
                           
            %endByte = startByte + segmentLength - 1;            
        end
        
        
        function endByte = decodeEntropyCodedSegmentFromNumericData(obj, startByte, channelID)
            if obj.verbose
                disp(['- Entropy Coded Segment ' num2str(channelID) ':']);
            end
            
            huffmanDCTableID = obj.scanSegments{channelID}.huffmanDCTableID; 
            % DECODE procedure
            % Ref: CCITT Rec. T.81 (1992 E)	p.107
            % DC
            BITS = obj.huffmanDCCodeCountPerCodeLength{huffmanDCTableID + 1};
            HUFFVAL = obj.huffmanDCSymbolValuesPerCode{huffmanDCTableID + 1};
            HUFFCODE = obj.huffcodeForDCCellArray{huffmanDCTableID + 1};
            [minCodeForDC maxCodeForDC valueTablePointer] = EntropyCoding.generateDecodingProcedureTable(BITS, HUFFCODE);
            
            % convert to logical and start matching to Huffman Codes
            % NON-INTERLEAVED

            currentByte = startByte;
            
            [ VALUE endByte endBit ] = EntropyCoding.decodeValue( obj.inputStruct.numericData, startByte, 1, minCodeForDC, maxCodeForDC, valueTablePointer, HUFFVAL );
            [ VALUE endByte endBit ] = EntropyCoding.decodeValue( obj.inputStruct.numericData, endByte, endBit + 1, minCodeForDC, maxCodeForDC, valueTablePointer, HUFFVAL );            
            %{
            % compute total pixels for channel with its Hi,Vi and image w,h
            totalBlocks = a; %****************************
            
            for i=1:totalBlocks
                % For given block 
                
                % Decode each coeff
                for c=1:64
                    code = [];
                    
                    if c == 1
                        % DC
                        % DIFF
                    else
                        % RS
                        % if RS = EOB
                        if 
                            break;
                        end
                    
                    end
                end
            end
            
            
            % RS value
            %obj.zerosRunLengthCodedOrderedACCoefficients{channelID}
            endByte
            %}
        end
        
        
        function decodeFromLogicalArray(obj)
            % For each segment marker decode section
            test1 = true;
            
            numberOfBits = length(obj.inputStruct.binaryData);
            currentBit = 1;
                
            while test1
                if Utilities.logicalToUnsignedDecimal(obj.inputStruct.binaryData(currentBit:currentBit+7)) == 255
                    currentBit = currentBit + 8;
                    
                    %%%%%instead of conert do logical array compare
                    
                    switch(Utilities.logicalToUnsignedDecimal(obj.inputStruct.binaryData(currentBit:currentBit+7)))
                        case 216 % FF D8 = 255 216 = Start of Image
                            disp('SOI');
                        case 217 % FF D9 = 255 217 = End of Image
                            disp('EOI');
                    end
                end
                currentBit = currentBit + 8;
                test1 = (currentBit < numberOfBits);
            end
        end
        
        function levelShiftInputImage(obj)
            % -----------
            % Level Shift
            % -----------
            % Ref:
            % http://compgroups.net/comp.compression/Level-Shift-in-JPEG-optional-or-mandatory
            
            %%%%% After a non-differential frame decoding process computes
            %%%%% the IDCT and produces a block of reconstructed image samples, an inverse level shift shall restore the samples to the unsigned representation by adding 2P ? 1 and clamping the results to the range 0 to 2P ? 1.
            obj.imageStruct.y   = uint8(double(obj.imageStruct.yLevelShifted) + 128);
            obj.imageStruct.cb  = uint8(double(obj.imageStruct.cbLevelShifted) + 128);
            obj.imageStruct.cr  = uint8(double(obj.imageStruct.crLevelShifted) + 128);
        end
   end
end 

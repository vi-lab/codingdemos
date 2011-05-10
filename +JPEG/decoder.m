classdef decoder < handle
%JPEG.DECODER The JPEG decoder body
%
%   +JPEG/decoder.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   JPEG.decoder main properties:
%    * verbose (r/w): boolean to enable/disable verbose console output
%    * inputStruct (r/w): The subsampled input image structure
%    * outputImageMatrix (r): The decoded image in matrix (YCbCr) form
%    * outputImageStruct (r): The decoded image in subsampled struct form
%
%   JPEG.decoder public methods:
%    * decoder(parameters): The decoder constructor, ...
%    * decode(parameters): The main decode method. Call this to decode the
%    current input. Returns the decoded image in RGB matrix form.
%
%   Example usage:
%       obj = JPEG.decoder('image.jpg');
%       imshow(obj.decode('Verbose', true));
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

    properties (SetObservable)
        inputStruct
        verbose = false;
    end

    properties (SetObservable, SetAccess='private')

        chromaSamplingMode
        outputImageSize
        numberOfChannels

        componentIdentifier
        horizontalSamplingFactor
        verticalSamplingFactor
        quantisationTableDestinationSelector

        componentSizeInBlocks

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

        % DC Category and magnitude bits
        differentiallyCodedDCCoefficient
        % RS values for ZRLC from entropy decode
        zerosRunLengthCodedOrderedACCoefficients


        % Output image data
        outputImageMatrix
        outputImageStruct

    end

    methods
        function obj = decoder(source)
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

        % TODO: Should take varargs so that you can pass in what to do
        function outputImage = decode(obj, verbose)
            outputImage = [];
            if exist('verbose', 'var')
                obj.verbose = verbose;
            end

            % First the input data is decoded. This involves finding JPEG
            % segment markers to identify each region (quantisation tables,
            % huffman tables, entropy coded blocks etc) and then decoding
            % them and extracting parameters.
            if isfield(obj.inputStruct, 'binaryData')
               obj.decodeFromLogicalArray();
            elseif isfield(obj.inputStruct, 'numericData')
               obj.decodeFromNumericArray();
            else
                %%%%%%%% STRUCT FROM ENCODER, only do whats needed, (prob
                %%%%%%%% no entropy decode)

            end

            % For each channel
            for c=1:obj.numberOfChannels

                channelID = obj.componentIdentifier(c);

                if obj.verbose
                    disp(['Reconstructing channel ' num2str(channelID) '.']);
                end

                % Reconstruct DC diff values by sign extending.
                blocksDCDiffValues{c} = cellfun(@(cat, mag)( ...
                        EntropyCoding.extendSignBitOfDecodedValue(mag, cat) ...
                    ), obj.differentiallyCodedDCCoefficient{c}(:,1).', obj.differentiallyCodedDCCoefficient{c}(:,2).');

                % These decoded values are differential so cumulative sum
                % them to get original values
                blocksDCValues{c} = cumsum(blocksDCDiffValues{c});

                % Reconstruct the AC coefficients by decoding the run
                % lengths and then sign extending to recover original
                % coefficient values.

                % This is performed by calling for each block cell
                % of AC ZRLC coefficients decodeACZerosRunLengthValue().
                % This returns the decoded run and value in a cell for each
                % (Run, Value) combination (EOBs are translated into a
                % zero). Cell2mat then combines a transpose of this (to get
                % in column ordeR) into a vector and this is then extended
                % with zeros to get the whole 63 coefficients
                %blocksACCoefficients{c} = cellfun(@(block)(...
                %           arrayfun(@(RS, mag)(EntropyCoding.decodeACZerosRunLengthValue(RS, mag)), block(:,1), block(:,2), 'UniformOutput', false) ...
                %    ), obj.zerosRunLengthCodedOrderedACCoefficients{c}, 'UniformOutput', false);

                blocksACCoefficients{c} = cellfun(@(block)(...
                        Utilities.padNumericArray( ...
                            cell2mat(...
                                cellfun(@(RS, mag)(EntropyCoding.decodeACZerosRunLengthValue(RS, mag)), block(:,1), block(:,2), 'UniformOutput', false) ...
                            .') ...
                        , 0, 63) ...
                    ), obj.zerosRunLengthCodedOrderedACCoefficients{c}, 'UniformOutput', false);

                % Add DC values
                blocksWithACAndDCCoefficientsReordered{c} = arrayfun(@(dc, ac)([dc ac{1}]), ...
                                                                    blocksDCValues{c}, blocksACCoefficients{c}, 'UniformOutput', false);

                % Dezigzag coeffs
                blocksWithACCoefficientsReordered{c} = cellfun( @(coeffs)(TransformCoding.coefficientOrdering(coeffs, 'dezigzag')), ...
                                                                blocksWithACAndDCCoefficientsReordered{c},'UniformOutput',false);

                % Reshape
                quantisedChannel{c} = cell2mat(reshape(blocksWithACCoefficientsReordered{c}, obj.componentSizeInBlocks{c}(1), obj.componentSizeInBlocks{c}(2)).');

                % Dequantise
                dequantisedChannel{c} = blkproc(quantisedChannel{c}, [8 8], ...
                                                @(block)(block.*obj.quantisationTables{obj.quantisationTableDestinationSelector(channelID) + 1}));

                % IDCT
                reconstructedChannelWithLevelShift{c} = blkproc(dequantisedChannel{c}, [8 8], @idct2);

                % -----------
                % Level Shift
                % -----------
                % Ref: CCITT Rec. T.81 (1992 E) p.26
                % http://compgroups.net/comp.compression/Level-Shift-in-JPEG-optional-or-mandatory
                channel{c} = uint8(reconstructedChannelWithLevelShift{c} + 128);

            end

            obj.outputImageStruct = cell2struct(channel, {'y', 'cb', 'cr'}, 2);
            obj.outputImageMatrix = Subsampling.subsampledToYCbCrImage(obj.outputImageStruct);
            outputImage = ycbcr2rgb(obj.outputImageMatrix);

            if obj.verbose
                figure(1),Subsampling.subsampledImageShow(obj.outputImageStruct);
            end

        end
    end
    
    methods (Access='private')

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
            % ------------------------
            % Decode JPEG Frame header
            % ------------------------
            %

            % Lf    (2 bytes)
            segmentLength           = obj.getNumericShort(startByte);
            % P     (1 byte)
            dataByteSize            = obj.inputStruct.numericData(startByte + 2);
            % Y     (2 byte)
            imageHeight             = obj.getNumericShort(startByte + 3);
            % X     (2 byte)
            imageWidth              = obj.getNumericShort(startByte + 5);
            obj.outputImageSize     = [imageWidth imageHeight];
            % Nf    (1 byte)
            obj.numberOfChannels    = obj.inputStruct.numericData(startByte + 7);

            currentByte = startByte + 8;
            for i=1:obj.numberOfChannels
                % Ci1   (1 byte)
                obj.componentIdentifier(i) = obj.inputStruct.numericData(currentByte);
                % Hi1   (1 nibble)
                % Vi1   (1 nibble)
                [obj.horizontalSamplingFactor(obj.componentIdentifier(i)) obj.verticalSamplingFactor(obj.componentIdentifier(i))] = obj.getNumericNibblesFromByte(currentByte + 1);
                % Tqi1  (1 byte)
                obj.quantisationTableDestinationSelector(obj.componentIdentifier(i)) = obj.inputStruct.numericData(currentByte + 2);
                currentByte = currentByte + 3;
            end

            % Compute subsampling mode for this image
            if obj.numberOfChannels == 3
                obj.chromaSamplingMode = Subsampling.horizontalAndVerticalSamplingFactorsToMode(...
                                                obj.horizontalSamplingFactor(obj.componentIdentifier(1)), ...
                                                obj.verticalSamplingFactor(obj.componentIdentifier(1)), ...
                                                obj.horizontalSamplingFactor(obj.componentIdentifier(2)), ...
                                                obj.verticalSamplingFactor(obj.componentIdentifier(2)), ...
                                                obj.horizontalSamplingFactor(obj.componentIdentifier(3)), ...
                                                obj.verticalSamplingFactor(obj.componentIdentifier(3)));
                % Compute channel block sizes
                HiMax = max(obj.horizontalSamplingFactor(:));
                ViMax = max(obj.verticalSamplingFactor(:));
                obj.componentSizeInBlocks = arrayfun(@(Hi, Vi)...
                                                        ( ...
                                                            [ceil(obj.outputImageSize(1)/8*(Hi/HiMax)) ceil(obj.outputImageSize(2)/8*(Vi/ViMax))]...
                                                        ), ...
                                                    obj.horizontalSamplingFactor, obj.verticalSamplingFactor, 'UniformOutput', false);
            else
                obj.chromaSamplingMode = [];
                obj.componentSizeInBlocks = {[ceil(obj.outputImageSize(1)/8) ceil(obj.outputImageSize(2)/8)]};
            end


            % Verbose text
            if obj.verbose
                disp (['- Frame Header: (' num2str(segmentLength) ' bytes), precision: ' num2str(dataByteSize) ', image (width, height): (' num2str(imageWidth) ', ' num2str(imageHeight) '), channels: ' num2str(obj.numberOfChannels)]);
                for i=1:obj.numberOfChannels
                    disp (['-- Component ' num2str(obj.componentIdentifier(i)) ' (Hi,Vi): (' num2str(obj.horizontalSamplingFactor(obj.componentIdentifier(i))) ', ' num2str(obj.verticalSamplingFactor(obj.componentIdentifier(i))) '), Quantisation Table: ' num2str(obj.quantisationTableDestinationSelector(obj.componentIdentifier(i)))]);
                end
                disp(['-- Sampling Mode: ' obj.chromaSamplingMode]);
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


            segmentLength = obj.getNumericShort(startByte);
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
            huffmanACTableID = obj.scanSegments{channelID}.huffmanACTableID;
            % DECODE procedure
            % Ref: CCITT Rec. T.81 (1992 E)	p.107
            % DC
            BITS = obj.huffmanDCCodeCountPerCodeLength{huffmanDCTableID + 1};
            HUFFVALDC = cell2mat(obj.huffmanDCSymbolValuesPerCode{huffmanDCTableID + 1});
            HUFFCODE = obj.huffcodeForDCCellArray{huffmanDCTableID + 1};
            [minCodeForDC maxCodeForDC valueTablePointerForDC] = EntropyCoding.generateDecodingProcedureTable(BITS, HUFFCODE);

            BITS = obj.huffmanACCodeCountPerCodeLength{huffmanACTableID + 1};
            HUFFVALAC = cell2mat(obj.huffmanACSymbolValuesPerCode{huffmanACTableID + 1});
            HUFFCODE = obj.huffcodeForACCellArray{huffmanACTableID + 1};
            [minCodeForAC maxCodeForAC valueTablePointerForAC] = EntropyCoding.generateDecodingProcedureTable(BITS, HUFFCODE);

            clear BITS HUFFCODE
            % convert to logical and start matching to Huffman Codes
            % NON-INTERLEAVED

            % HERE WE WILL END UP WITH BLOCKS but still RLZ and DC DIffed
            currentByte = startByte;
            % Cur bit starts at 0 as its incremented at start of call to
            % decode
            currentBit = 0;

            % compute total pixels for channel with its Hi,Vi and image w,h
            totalBlocks = obj.componentSizeInBlocks{channelID};

            for i=1:totalBlocks(1)*totalBlocks(2)
                % For given block
                % DC Category Huffman decode
                [categoryOfDCDiff currentByte currentBit] = EntropyCoding.decodeValue( obj.inputStruct.numericData, currentByte, currentBit, minCodeForDC, maxCodeForDC, valueTablePointerForDC, HUFFVALDC );

                lengthOfExtraBits = categoryOfDCDiff;

                [magnitudeExtraBitsValue currentByte currentBit] = EntropyCoding.getValueBetweenBitsFromNumericArray( obj.inputStruct.numericData, currentByte, currentBit, lengthOfExtraBits);

                obj.differentiallyCodedDCCoefficient{channelID}(i,:) = {categoryOfDCDiff, magnitudeExtraBitsValue};

                acLength = 0;
                c = 0;

                % Decode each coeff
                while acLength < 63
                    % decode RS value
                    [valueForRS currentByte currentBit] = EntropyCoding.decodeValue( obj.inputStruct.numericData, currentByte, currentBit, minCodeForAC, maxCodeForAC, valueTablePointerForAC, HUFFVALAC );

                    zerosLength = bitshift(valueForRS, -4);

                    c = c + 1;
                    % if RS = EOB stop block
                    if valueForRS == 0
                        obj.zerosRunLengthCodedOrderedACCoefficients{channelID}{i}(c, :) = {0, 0, 0};
                        break;
                    else
                        % Get extra magnitude bits (RECEIVE)
                        lengthOfExtraBits = bitand(valueForRS, 15);
                        [magnitudeExtraBitsValue currentByte currentBit] = EntropyCoding.getValueBetweenBitsFromNumericArray( obj.inputStruct.numericData, currentByte, currentBit, lengthOfExtraBits);

                        obj.zerosRunLengthCodedOrderedACCoefficients{channelID}{i}(c, :) = {valueForRS, magnitudeExtraBitsValue, zerosLength};
                        acLength = acLength + zerosLength + 1;
                    end
                end
            end

            endByte = currentByte;

        end

        function decodeFromLogicalArray(obj)
        end

   end
end

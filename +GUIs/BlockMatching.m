classdef BlockMatching < GUIs.base
%BLOCKMATCHING Demo showing the progress of a number of block matching techniques
%
%   +GUIs/BlockMatching.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Demonstrates the block match search techniques for the video motion
%   estimation process. Select an input sequence and configure the search
%   by choosing an algorithm, maximum search distance, macro block size.
%   Then choose a frame and reference and then click on a macroblock to
%   show the search results for the given block / parameters in the results
%   table. To view each search step use the buttons in the top right,
%   either freerun or single step through each search point.
%
%   Start a new screen by calling the class constructor:
%       `GUIs.BlockMatching`
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

    properties
        hInputImageAxes
        hOutputImageAxes
        hMotionVectorsImageAxes
        hResidualImageAxes
        hCurrentBlock
        hTargetBlock
        hResidualBlock
        hResultText
        hPlayPauseButton
        hStepButton
        hFrameNumberCombo
        hReferenceFrameNumberCombo
        hVerboseCheck
        hShowGridCheck
        hSearchTypeCombo
        hSearchDistanceCombo
        hSearchBlockSizeCombo
        hDifferenceTypeCombo
        hDifferenceTypeComboText
        hResultsTable
        hBlockResultText

        showGrid = 1;
        playTimer

        hInputSelectedBlockRectangle
        hInputImage
        hRefImage
        hMVImage

        videoEncoders
        videoEncoder

        blockMatchingStruct
        searchAlgorithm

        currentBlock
        currentSearchData

        animationStep = 0;
        animationRects
        isAnimating = false;

        predictionError
        motionVectors
        residual
        selectedBlockCoords

        referenceNumber = 1;
        frameNumber = 10;
    end

    methods
        function obj = BlockMatching()
            obj = obj@GUIs.base('Motion Estimation: Block Matching');
            if ~exist( 'cachedVideos.mat', 'file')
                obj.reloadVideo(obj);
            else
                load('cachedVideos.mat', 've');
                obj.videoEncoders = ve;
            end

            obj.createInputVideoSelectComboBoxAndText([0.01 0.96 0.1 0.03], [0.0 0.93 0.25 0.03]);

            obj.createTextElement([0.01 0.895 0.11 0.03], 'Frame No.', 9, 'on', 'white', obj.hExternalPanel, 'FontName', 'Helvetica');
            obj.hFrameNumberCombo = uicontrol('Style', 'popupmenu', ...
                                        'Parent', obj.hExternalPanel, ...
                                        'FontSize', 11, ...
                                        'FontName', 'Helvetica',...
                                        'Units', 'Normalized', ...
                                        'Position',[0.01 0.87 0.11 0.03],...
                                        'String', {'2'},...
                                        'Callback', @(source, event)(obj.changeFrameNumber(source)));
            obj.createTextElement([0.12 0.895 0.11 0.03], 'Ref No.', 9, 'on', 'white', obj.hExternalPanel, 'FontName', 'Helvetica');
            obj.hReferenceFrameNumberCombo = uicontrol('Style', 'popupmenu', ...
                                        'Parent', obj.hExternalPanel, ...
                                        'FontSize', 11, ...
                                        'FontName', 'Helvetica',...
                                        'Units', 'Normalized', ...
                                        'Position',[0.12 0.87 0.11 0.03],...
                                        'String', {'1'},...
                                        'Callback', @(source, event)(obj.changeFrameNumber(source)));
            obj.hVerboseCheck = uicontrol('Style', 'checkbox', ...
                                        'Parent', obj.hExternalPanel, ...
                                        'FontSize', 9, ...
                                        'FontName', 'Helvetica',...
                                        'Units', 'Normalized', ...
                                        'Position',[0.37 0.96 0.3 0.03],...
                                        'String', 'Verbose output? (on MATLAB console)',...
                                        'Value', 0,...
                                        'Visible','off',...
                                        'Callback', @(source, event)(obj.changeSettings(source)));
            obj.hShowGridCheck = uicontrol('Style', 'checkbox', ...
                                        'Parent', obj.hExternalPanel, ...
                                        'FontSize', 9, ...
                                        'FontName', 'Helvetica',...
                                        'Units', 'Normalized', ...
                                        'Position',[0.15 0.96 0.1 0.03],...
                                        'String', 'Show Grid?',...
                                        'Value', 1,...
                                        'Callback', @(source, event)(obj.changeSettings(source)));
            obj.createTextElement([0.27 0.96 0.1 0.03], 'Search Type', 9, 'on', 'white', obj.hExternalPanel, 'FontName', 'Helvetica');
            obj.hSearchTypeCombo = uicontrol('Style', 'popupmenu', ...
                                        'Parent', obj.hExternalPanel, ...
                                        'FontSize', 11, ...
                                        'FontName', 'Helvetica',...
                                        'Units', 'Normalized', ...
                                        'Position',[0.26 0.93 0.3 0.03],...
                                        'String', {'Full Search (FSA)' 'Diamond Search (DSA)'},...
                                        'Value', 2,...
                                        'Callback', @(source, event)(obj.changeSettings(source)));
            obj.hDifferenceTypeComboText = obj.createTextElement([0.27 0.895 0.1 0.03], 'Difference calculation', 9, false, 'white', obj.hExternalPanel, 'FontName', 'Helvetica');
            obj.hDifferenceTypeCombo = uicontrol('Style', 'popupmenu', ...
                                        'Parent', obj.hExternalPanel, ...
                                        'FontSize', 11, ...
                                        'FontName', 'Helvetica',...
                                        'Units', 'Normalized', ...
                                        'Position',[0.26 0.87 0.3 0.03],...
                                        'String', {'SAD: Sum of Absolute Differences' 'MAD: Mean of Absolute Differences' 'SSD: Sum of Squared Differences' 'MSD: Mean of Squared Differences'},...
                                        'Value', 2, ...
                                        'Visible', 'off',...
                                        'Callback', @(source, event)(obj.changeSettings(source)));
            obj.createTextElement([0.61 0.96 0.1 0.03], 'Search Distance', 9, 'on', 'white', obj.hExternalPanel, 'FontName', 'Helvetica');
            obj.hSearchDistanceCombo = uicontrol('Style', 'popupmenu', ...
                                        'Parent', obj.hExternalPanel, ...
                                        'FontSize', 11, ...
                                        'FontName', 'Helvetica',...
                                        'Units', 'Normalized', ...
                                        'Position',[0.60 0.93 0.1 0.03],...
                                        'String', {'32' '24' '16' '12' '8' '4' '2'},...
                                        'Value', 5,...
                                        'Callback', @(source, event)(obj.changeSettings(source)));
            obj.createTextElement([0.71 0.96 0.1 0.03], 'Block Size', 9, 'on', 'white', obj.hExternalPanel, 'FontName', 'Helvetica');
            obj.hSearchBlockSizeCombo = uicontrol('Style', 'popupmenu', ...
                                        'Parent', obj.hExternalPanel, ...
                                        'FontSize', 11, ...
                                        'FontName', 'Helvetica',...
                                        'Units', 'Normalized', ...
                                        'Position',[0.70 0.93 0.1 0.03],...
                                        'String', {'32' '16' '8' '4'},...
                                        'Value', 2, ...
                                        'Callback', @(source, event)(obj.changeSettings(source)));
            % Step
            % Free run
            obj.hPlayPauseButton = uicontrol('Style', 'togglebutton', ...
                                    'Parent', obj.hExternalPanel, ...
                                    'FontSize', 9, ...
                                    'FontName', 'Helvetica',...
                                    'Units', 'Normalized', ...
                                    'Position',[0.81 0.91 0.08 0.08],...
                                    'String', 'Free Run',...
                                    'Enable', 'off',...
                                    'Callback', @(source, event)(obj.toggleFreerun(source)));
            obj.hStepButton = uicontrol('Style', 'pushbutton', ...
                                    'Parent', obj.hExternalPanel, ...
                                    'FontSize', 9, ...
                                    'FontName', 'Helvetica',...
                                    'Units', 'Normalized', ...
                                    'Position',[0.89 0.91 0.08 0.08],...
                                    'String', 'Step',...
                                    'Enable', 'off',...
                                    'Callback', @(source, event)(obj.step()));

            obj.createTextElement([0.01 0.83 0.2 0.03], 'Input Image', 11, 'on', 'white', obj.hExternalPanel, 'FontName', 'Helvetica'); %, 'HorizontalAlignment', 'center',
            obj.hInputImageAxes = obj.createAxesForImage([.01 .44 .30 .39]);
            obj.createTextElement([0.32 0.83 0.2 0.03], 'Reference w. Search Pattern', 11, 'on', 'white', obj.hExternalPanel, 'FontName', 'Helvetica');
            obj.hOutputImageAxes = obj.createAxesForImage([.32 .44 .30 .39]);
            obj.createTextElement([0.01 0.40 0.2 0.03], 'Motion Vectors', 11, 'on', 'white', obj.hExternalPanel, 'FontName', 'Helvetica');
            obj.hMotionVectorsImageAxes = obj.createAxesForImage([.01 .01 .30 .39]);
            obj.createTextElement([0.32 0.40 0.2 0.03], 'Residual Frame', 11, 'on', 'white', obj.hExternalPanel, 'FontName', 'Helvetica');
            obj.hResidualImageAxes = obj.createAxesForImage([.32 .01 .30 .39]);

            obj.createTextElement([0.66 0.70 0.08 0.15], 'Current Block', 11, 'on', 'white', obj.hExternalPanel, 'FontName', 'Helvetica');
            obj.hCurrentBlock = obj.createAxesForImage([.75 .74 .12 .15]);
            obj.createTextElement([0.66 0.54 0.08 0.15], 'Reference Block', 11, 'on', 'white', obj.hExternalPanel, 'FontName', 'Helvetica');
            obj.hTargetBlock = obj.createAxesForImage([.75 .58 .12 .15]);
            obj.createTextElement([0.66 0.38 0.08 0.15], 'Residual Block', 11, 'on', 'white', obj.hExternalPanel, 'FontName', 'Helvetica');
            obj.hResidualBlock = obj.createAxesForImage([.75 .41 .12 .15]);
            obj.hResultText = obj.createTextElement([0.88 0.55 0.11 0.15], '(Result of comparison)', 9, 'on', 'white', obj.hExternalPanel, 'FontName', 'Helvetica');

            obj.hBlockResultText = obj.createTextElement([0.7 0.36 0.25 0.04], '(Result)', 12, 'on', 'white', obj.hExternalPanel, 'FontName', 'Helvetica');

            obj.createTextElement([0.7 0.32 0.25 0.03], 'Error at each location in search', 9, 'on', 'white', obj.hExternalPanel, 'FontName', 'helvetica');
            obj.hResultsTable = uitable('Data',[], ...
                                        'ColumnName', {'Location', 'Error'}, ...
                                        'Parent', obj.hExternalPanel, ...
                                        'Units', 'Normalized', ...
                                        'RowStriping', 'on', ...
                                        'RowName', [],...
                                        'FontSize', 10,...
                                        'FontName', 'Helvetica',...
                                        'ColumnWidth', num2cell(ones(1,2).*80), ...
                                        'Position', [0.7 0.01 0.25 0.30]);

            linkaxes([obj.hInputImageAxes obj.hOutputImageAxes obj.hMotionVectorsImageAxes obj.hResidualImageAxes]);

            obj.changeVideoInput(obj.hInputImageSelect);
        end

        function changeVideoInput(obj, source)
            switch(get(source, 'Value'))
                case 1
                    obj.videoEncoder = obj.videoEncoders{1};
                case 2
                    obj.videoEncoder = obj.videoEncoders{2};
                case 3
                    obj.videoEncoder = obj.videoEncoders{3}; 
            end

            a = 1:size(obj.videoEncoder.imageMatrix, 4);
            strings = {};
            for i=1:length(a) 
                strings{end+1}=num2str(a(i));
            end
            set(obj.hFrameNumberCombo, 'String', strings);
            set(obj.hReferenceFrameNumberCombo, 'String', strings);

            set(obj.hReferenceFrameNumberCombo, 'Value', obj.referenceNumber);
            set(obj.hFrameNumberCombo, 'Value', obj.frameNumber);
            
            obj.changeSettings(obj.hVerboseCheck);
            obj.changeSettings(obj.hSearchTypeCombo);
            obj.changeSettings(obj.hSearchDistanceCombo);
            obj.changeSettings(obj.hDifferenceTypeCombo);
            obj.changeSettings(obj.hSearchBlockSizeCombo);

            obj.residual = zeros(size(obj.videoEncoder.imageMatrix,1),size(obj.videoEncoder.imageMatrix,2));

            obj.updateMainAxes();
        end

        function updateMainAxes(obj)
            im = ycbcr2rgb(obj.videoEncoder.imageMatrix(:,:,:,obj.frameNumber));
            if obj.showGrid
                bs = obj.blockMatchingStruct.blockSize;
                [X, Y] = meshgrid(1:bs:size(im,2), 1:bs:size(im,1));
                for i=1:numel(X)
                    im(Y(i):Y(i)+bs-1,X(i),:) = 0;
                    im(Y(i),X(i):X(i)+bs-1,:) = 0;
                end
            end
            obj.hInputImage = imshow(im, 'Parent', obj.hInputImageAxes);
            set(obj.hInputImage, 'ButtonDownFcn', @(src, evt)(obj.imageClick(src)));

            ref = ycbcr2rgb(obj.videoEncoder.imageMatrix(:,:,:,obj.referenceNumber));
            if obj.showGrid
                bs = obj.blockMatchingStruct.blockSize;
                [X, Y] = meshgrid(1:bs:size(ref,2), 1:bs:size(ref,1));
                for i=1:numel(X)
                    ref(Y(i):Y(i)+bs-1,X(i),:) = 0;
                    ref(Y(i),X(i):X(i)+bs-1,:) = 0;
                end
            end
            obj.hRefImage = imshow(ref, 'Parent', obj.hOutputImageAxes);
            set(obj.hRefImage, 'ButtonDownFcn', @(src, evt)(obj.imageClick(src)));

        end

        function updateMVView(obj)
            ref = ycbcr2rgb(obj.videoEncoder.imageMatrix(:,:,:,obj.referenceNumber));
            if obj.showGrid
                bs = obj.blockMatchingStruct.blockSize;
                [X, Y] = meshgrid(1:bs:size(ref,2), 1:bs:size(ref,1));
                for i=1:numel(X)
                    ref(Y(i):Y(i)+bs-1,X(i),:) = 0;
                    ref(Y(i),X(i):X(i)+bs-1,:) = 0;
                end
            end
            obj.hMVImage = imshow(ref, 'Parent', obj.hMotionVectorsImageAxes);

            hold(obj.hMotionVectorsImageAxes, 'on');
            hold(obj.hOutputImageAxes, 'on');
            x = [];y = [];u = [];v = [];
            if ~isempty(obj.motionVectors)
                for i=1:length(obj.motionVectors)
                    if ~isempty(obj.motionVectors{i})
                        x = [x obj.motionVectors{i}(4)];
                        y = [y obj.motionVectors{i}(5)];
                        u = [u obj.motionVectors{i}(1)];
                        v = [v obj.motionVectors{i}(2)];
                    end
                end
            end

            quiver(obj.hMotionVectorsImageAxes, x, y, u, v, 0, 'k');
            quiver(obj.hOutputImageAxes, x, y, u, v, 0, 'k');

            hold(obj.hMotionVectorsImageAxes, 'off');
            hold(obj.hOutputImageAxes, 'off');

            if ~isempty(obj.residual)
                imagesc(obj.residual, 'Parent', obj.hResidualImageAxes);
            end
        end

        function imageClick(obj, imageHandle)
            if ~obj.isAnimating
                % handle input / output image clicks
                if imageHandle == obj.hInputImage
                    selectedPoint = get(obj.hInputImageAxes, 'CurrentPoint');
                else
                    selectedPoint = get(obj.hOutputImageAxes, 'CurrentPoint');
                end

                obj.updateMainAxes();
                bs = obj.blockMatchingStruct.blockSize;
                bx = (floor((selectedPoint(1,1)-1) / bs)*bs) + 1;
                by = (floor((selectedPoint(1,2)-1) / bs)*bs) + 1;
                obj.selectedBlockCoords = [bx by bs bs];

                obj.hInputSelectedBlockRectangle = rectangle('Parent', obj.hInputImageAxes, 'Position', obj.selectedBlockCoords, 'EdgeColor', [0 0 0], 'LineWidth', 1.5);
                % convert into linear block index
                obj.currentBlock = ceil(by/bs) + floor(bx/bs)*floor(size(obj.videoEncoder.imageMatrix(:,:,:,obj.frameNumber), 1)/bs);

                obj.doBlock();

                set(obj.hPlayPauseButton, 'Enable', 'on');
                set(obj.hStepButton, 'Enable', 'on');

                obj.updateTable();
            end
        end

        function changeSettings(obj, source)
            switch source
                case obj.hShowGridCheck
                    if get(obj.hShowGridCheck, 'Value') == 1
                        obj.showGrid = true;
                    else
                        obj.showGrid = false;
                    end
                    obj.updateMainAxes();

                case obj.hSearchTypeCombo
                    if get(obj.hSearchTypeCombo, 'Value') == 1
                        obj.blockMatchingStruct.algorithm = 'FSA';
                    else
                        obj.blockMatchingStruct.algorithm = 'DSA';
                    end
                    switch obj.blockMatchingStruct.algorithm
                        case {'FSA', 'full', 'fullsearch'}
                            obj.searchAlgorithm = @MotionEstimation.fullSearch;
                        case {'DSA', 'diamond', 'diamondsearch'}
                            obj.searchAlgorithm = @MotionEstimation.diamondSearch;
                    end

                case obj.hVerboseCheck
                    if get(obj.hVerboseCheck, 'Value') == 1
                        obj.blockMatchingStruct.verbose = true;
                    else
                        obj.blockMatchingStruct.verbose = false;
                    end

                case obj.hSearchDistanceCombo
                    strings = get(obj.hSearchDistanceCombo, 'String');
                    s = strings{get(obj.hSearchDistanceCombo, 'Value')};
                    obj.blockMatchingStruct.maximumSearchDistance = str2double(s);

                case obj.hSearchBlockSizeCombo
                    strings = get(obj.hSearchBlockSizeCombo, 'String');
                    s = strings{get(obj.hSearchBlockSizeCombo, 'Value')};
                    obj.blockMatchingStruct.blockSize = str2double(s);

                case obj.hDifferenceTypeCombo
                    switch get(obj.hDifferenceTypeCombo, 'Value')
                        case 1
                            obj.blockMatchingStruct.differenceCalculation = 'sad';
                        case 2
                            obj.blockMatchingStruct.differenceCalculation = 'mad';
                        case 3
                            obj.blockMatchingStruct.differenceCalculation = 'ssd';
                        case 4
                            obj.blockMatchingStruct.differenceCalculation = 'msd';
                    end
                    switch lower(obj.blockMatchingStruct.differenceCalculation)
                        case {'sad', 'sumofabsolutedifferences'}
                            obj.blockMatchingStruct.matchFunction = @MotionEstimation.sumOfAbsoluteDifference;
                        case {'mad', 'meanofabsolutedifferences'}
                            obj.blockMatchingStruct.matchFunction = @MotionEstimation.meanOfAbsoluteDifference;
                        case {'ssd', 'sumofsquaredifferences'}
                            obj.blockMatchingStruct.matchFunction = @MotionEstimation.sumOfSquaredDifference;
                        case {'msd', 'meanofsquaredifferences'}
                            obj.blockMatchingStruct.matchFunction = @MotionEstimation.meanOfSquaredDifference;
                    end
            end
        end

        function changeFrameNumber(obj, source)
            obj.stopFreerun();
            obj.animationStep = 0;
            if source == obj.hReferenceFrameNumberCombo
                obj.referenceNumber = get(obj.hReferenceFrameNumberCombo, 'Value');
            else
                obj.frameNumber = get(obj.hFrameNumberCombo, 'Value');
            end
            obj.updateMainAxes();
        end

        function toggleFreerun(obj, source)
            if ~obj.isAnimating
                obj.playTimer = timer('Period', 0.05, 'BusyMode', 'drop', 'ExecutionMode', 'fixedspacing', 'TimerFcn', @(x,y)obj.step());
                start(obj.playTimer);
                obj.isAnimating = true;
            else
                obj.stopFreerun();
            end
        end
        function stopFreerun(obj)
            if obj.isAnimating
                stop(obj.playTimer);
                delete(obj.playTimer);
                obj.playTimer = [];
                obj.isAnimating = false;
            end
        end

        function step(obj)
            obj.animationStep = obj.animationStep + 1;
            if (obj.animationStep > length(obj.currentSearchData))
                obj.animationStep = 0;
                set(obj.hPlayPauseButton, 'Value', 0);
                obj.stopFreerun();
                set(obj.hPlayPauseButton, 'Enable', 'off');
                set(obj.hStepButton, 'Enable', 'off');
            else
                if ~isempty(obj.currentSearchData{obj.animationStep})
                    bs = obj.blockMatchingStruct.blockSize;
                    x = obj.currentSearchData{obj.animationStep}.blockx;
                    y = obj.currentSearchData{obj.animationStep}.blocky;
                    xref = obj.currentSearchData{obj.animationStep}.xref; 
                    yref = obj.currentSearchData{obj.animationStep}.yref;
                    imshow(ycbcr2rgb(obj.videoEncoder.imageMatrix(y:y+bs-1,x:x+bs-1,:,obj.frameNumber)), 'Parent', obj.hCurrentBlock);
                    imshow(ycbcr2rgb(obj.videoEncoder.imageMatrix(yref:yref+bs-1,xref:xref+bs-1,:,obj.referenceNumber)), 'Parent', obj.hTargetBlock);
                    imagesc(sum(obj.currentSearchData{obj.animationStep}.errorSurface, 3), 'Parent', obj.hResidualBlock);
                    set(obj.hResultText, 'String', ['Block (' num2str(x) ',' num2str(y) '), Ref (' num2str(xref) ',' num2str(yref) ') with error ' num2str(obj.currentSearchData{obj.animationStep}.matchError)] );
                    obj.animationRects(obj.animationStep) = rectangle('Parent', obj.hOutputImageAxes, 'Position', [xref yref obj.blockMatchingStruct.blockSize obj.blockMatchingStruct.blockSize] , 'EdgeColor', [.6 .6 (obj.currentSearchData{obj.animationStep}.step/(obj.currentSearchData{end}.step+1))], 'LineWidth', 1);
                end
            end
        end

        function doBlock(obj)
            % process next block
            bs = obj.blockMatchingStruct.blockSize;
            [motionVector pError obj.currentSearchData] = obj.searchAlgorithm(obj.videoEncoder.imageMatrix(:,:,:,obj.frameNumber), obj.videoEncoder.imageMatrix(:,:,:,obj.referenceNumber), obj.blockMatchingStruct, obj.currentBlock);

            obj.motionVectors{obj.currentBlock} = squeeze(motionVector(1,1,:));
            x = obj.motionVectors{obj.currentBlock}(4);
            y = obj.motionVectors{obj.currentBlock}(5);
            obj.predictionError{obj.currentBlock} = sum(pError(1:bs,1:bs,:),3);
            obj.residual(y:y+bs-1, x:x+bs-1) = obj.predictionError{obj.currentBlock};

            set(obj.hBlockResultText, 'String', ['Best vector: (' num2str(obj.motionVectors{obj.currentBlock}(1)) ',' num2str(obj.motionVectors{obj.currentBlock}(2)) ') with error ' num2str(obj.motionVectors{obj.currentBlock}(3))] );
            obj.animationStep = 0;

            obj.updateMVView();
        end

        function updateTable(obj)
            data = {};
            cnt = 1;
            for i=1:length(obj.currentSearchData)
                if ~isempty(obj.currentSearchData{i})
                    data{cnt, 1} = obj.currentSearchData{i}.i;
                    data{cnt, 2} = obj.currentSearchData{i}.j;
                    data{cnt, 3} = obj.currentSearchData{i}.matchError;
                    cnt = cnt + 1;
                end
            end
            set(obj.hResultsTable, 'Data', data);
        end

        function reloadVideo(obj, source)
            disp('This is either the first time you are running the demo and the demo cache must be created, or you have requested a video recode.');
            obj.videoEncoders{1} = Video.encoder('examples/vidseq/suzie_:001:070:.png');
            obj.videoEncoders{1}.encode('gop', 'ipppp', 'verbose', true, 'Quality', 80, 'BlockMatchingSearchDistance', 8, 'BlockMatching', 'DSA');
            obj.videoEncoders{2} = Video.encoder('examples/vidseq/foreman_:001:070:.png');
            obj.videoEncoders{2}.encode('gop', 'ipppp', 'verbose', true, 'Quality', 50, 'BlockMatchingSearchDistance', 8, 'BlockMatching', 'DSA');
            obj.videoEncoders{3} = Video.encoder('examples/vidseq/carphone_:001:070:.png');
            obj.videoEncoders{3}.encode('gop', 'ippppppppp', 'verbose', true, 'Quality', 80, 'BlockMatchingSearchDistance', 8, 'BlockMatching', 'DSA');
            ve = obj.videoEncoders;
            save('cachedVideos.mat', 've');
        end

        function handleCloseRequest(obj, source, event)
            obj.stopFreerun();
            delete(gcf);
        end

        function changeScreenMode(obj, source)

            obj.changeScreenMode@GUIs.base(source);

            if strcmp(get(source, 'State'), 'on')
                % on
                %set(obj.h, 'Visible', 'on');
                set(obj.hDifferenceTypeCombo, 'Visible', 'on');
                set(obj.hDifferenceTypeComboText, 'Visible', 'on');
                set(obj.hVerboseCheck, 'Visible', 'on');
            else
                % off
                %set(obj.h, 'Visible', 'off');
                set(obj.hDifferenceTypeCombo, 'Visible', 'off');
                set(obj.hDifferenceTypeComboText, 'Visible', 'off');
                set(obj.hVerboseCheck, 'Visible', 'off');
            end
            
        end
    end
end 

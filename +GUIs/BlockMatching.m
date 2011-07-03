classdef BlockMatching < GUIs.base
%BLOCKMATCHING Demo showing the progress of a number of block matching techniques
%
%   +GUIs/BlockMatching.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   
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
        hSearchTypeCombo
        hSearchDistanceCombo
        hSearchBlockSizeCombo
        hDifferenceTypeCombo
        hResultsTable

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
        currentCoords
        currentCompareBlock
        currentReferenceX
        currentReferenceY
        currentMotionVectors
        currentBlockResiduals
        motionVectors
        residual
        selectedBlockCoords

        referenceNumber = 1;
        frameNumber = 2;
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

            obj.createInputVideoSelectComboBoxAndText([0.01 0.96 0.25 0.03], [0.0 0.93 0.25 0.03]);

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
            obj.createTextElement([0.27 0.895 0.1 0.03], 'Difference calculation', 9, 'on', 'white', obj.hExternalPanel, 'FontName', 'Helvetica');
            obj.hDifferenceTypeCombo = uicontrol('Style', 'popupmenu', ...
                                        'Parent', obj.hExternalPanel, ...
                                        'FontSize', 11, ...
                                        'FontName', 'Helvetica',...
                                        'Units', 'Normalized', ...
                                        'Position',[0.26 0.87 0.3 0.03],...
                                        'String', {'SAD: Sum of Absolute Differences' 'MAD: Mean of Absolute Differences' 'SSD: Sum of Squared Differences' 'MSD: Mean of Squared Differences'},...
                                        'Value', 2, ...
                                        'Callback', @(source, event)(obj.changeSettings(source)));
            obj.createTextElement([0.61 0.96 0.1 0.03], 'Search Distance', 9, 'on', 'white', obj.hExternalPanel, 'FontName', 'Helvetica');
            obj.hSearchDistanceCombo = uicontrol('Style', 'popupmenu', ...
                                        'Parent', obj.hExternalPanel, ...
                                        'FontSize', 11, ...
                                        'FontName', 'Helvetica',...
                                        'Units', 'Normalized', ...
                                        'Position',[0.60 0.93 0.1 0.03],...
                                        'String', {'8' '4' '2'},...
                                        'Value', 2,...
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
                                    'Value', 1,...
                                    'Enable', 'off',...
                                    'Callback', @(source, event)(obj.toggleFreerun(source)));
            obj.hStepButton = uicontrol('Style', 'pushbutton', ...
                                    'Parent', obj.hExternalPanel, ...
                                    'FontSize', 9, ...
                                    'FontName', 'Helvetica',...
                                    'Units', 'Normalized', ...
                                    'Position',[0.89 0.91 0.08 0.08],...
                                    'String', 'Step',...
                                    'Value', 1,...
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
            obj.hResultText = obj.createTextElement([0.88 0.55 0.11 0.15], '(Result of comparison)', 11, 'on', 'white', obj.hExternalPanel, 'FontName', 'Helvetica');

            obj.createTextElement([0.7 0.32 0.25 0.03], 'Error at each location in search', 10, 'on', 'white', obj.hExternalPanel, 'FontName', 'helvetica');
            obj.hResultsTable = uitable('Data',[1 2; 1 2; 1 2;], ...
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

          	%obj.hInputImage = Subsampling.subsampledImageShow(obj.encoderInstance.imageStruct, 'Parent', obj.hInputImageAxes);
            obj.updateMainAxes();
            % This way of organising is a mess, IDs created in order of
            % initial call but here assumed in specific order
            %{
            obj.setVideoPlayer(1, 'input', obj.videoEncoder.imageMatrix);
            obj.setVideoPlayer(2, 'output', obj.videoEncoder.reconstructedVideo);
            obj.setVideoPlayer(3,'residual', obj.videoEncoder.predictionErrorFrame);
            obj.setVideoPlayer(4,'reconstructedresidual', obj.videoEncoder.reconstructedPredictionErrorFrame);
            obj.setVideoPlayer(5,'motionvectors', obj.videoEncoder.reconstructedVideo);
            %}
        end

        function updateMainAxes(obj)
            obj.hInputImage = imshow(ycbcr2rgb(obj.videoEncoder.imageMatrix(:,:,:,obj.frameNumber)), 'Parent', obj.hInputImageAxes);
            set(obj.hInputImage, 'ButtonDownFcn', @(src, evt)(obj.imageClick(src)));
            
            hold(obj.hInputImageAxes, 'on');

            obj.hRefImage = imshow(ycbcr2rgb(obj.videoEncoder.imageMatrix(:,:,:,obj.referenceNumber)), 'Parent', obj.hOutputImageAxes);
            set(obj.hRefImage, 'ButtonDownFcn', @(src, evt)(obj.imageClick(src)));

            hold(obj.hOutputImageAxes, 'on');
        end

        function updateReferenceRectsAxes(obj)
            if ~isempty(obj.selectedBlockCoords)
                obj.hInputSelectedBlockRectangle = rectangle('Parent', obj.hOutputImageAxes, 'Position', obj.selectedBlockCoords, 'EdgeColor', [0 0 0], 'LineWidth', 1.5);
            end
            if ~isempty(obj.currentReferenceY)
                rectangle('Parent', obj.hOutputImageAxes, 'Position', [obj.currentReferenceX obj.currentReferenceY obj.blockMatchingStruct.blockSize obj.blockMatchingStruct.blockSize] , 'EdgeColor', [.5 .5 .9], 'LineWidth', 1.5);
            end
        end

        function updateMVView(obj)
            obj.hMVImage = imshow(ycbcr2rgb(obj.videoEncoder.imageMatrix(:,:,:,obj.referenceNumber)), 'Parent', obj.hMotionVectorsImageAxes);
            
            if ~isempty(obj.motionVectors)
                for i=1:length(obj.motionVectors)
                    if ~isempty(obj.motionVectors{i})
                        obj.motionVectors{i}
                    end
                end
            end

            if ~isempty(obj.residual)
                imagesc(obj.residual, 'Parent', obj.hResidualImageAxes);
            end
        end
        function updateBlockView(obj)
            if ~isempty(obj.selectedBlockCoords)
                imshow(ycbcr2rgb(obj.videoEncoder.imageMatrix(obj.selectedBlockCoords(2):obj.selectedBlockCoords(2)+obj.selectedBlockCoords(4),obj.selectedBlockCoords(1):obj.selectedBlockCoords(1)+obj.selectedBlockCoords(3),:,obj.frameNumber)), 'Parent', obj.hCurrentBlock);
            end
            if ~isempty(obj.currentReferenceX)
                imshow(ycbcr2rgb(obj.videoEncoder.imageMatrix(obj.currentReferenceY:obj.currentReferenceY+obj.blockMatchingStruct.blockSize-1,...
                    obj.currentReferenceX:obj.currentReferenceX+obj.blockMatchingStruct.blockSize-1,:,obj.referenceNumber)), 'Parent', obj.hTargetBlock);
                %imshow(obj.residual(obj.currentReferenceY:obj.currentReferenceY+obj.blockMatchingStruct.blockSize-1,...
                %    obj.currentReferenceX:obj.currentReferenceX+obj.blockM
                %    atchingStruct.blockSize-1), 'Parent', obj.hResidualBlock);
                imagesc(obj.currentBlockResiduals{obj.currentCompareBlock-1}, 'Parent', obj.hResidualBlock);
            end
        end

        function imageClick(obj, imageHandle)
            % handle input / output image clicks
            %if imageHandle == obj.hInputImage
                selectedPoint = get(obj.hInputImageAxes, 'CurrentPoint');
                bs = obj.blockMatchingStruct.blockSize;
                bx = (floor((selectedPoint(1,1)-1) / bs)*bs) + 1;
                by = (floor((selectedPoint(1,2)-1) / bs)*bs) + 1;
                obj.selectedBlockCoords = [bx by bs bs];

                obj.hInputSelectedBlockRectangle = rectangle('Parent', obj.hInputImageAxes, 'Position', obj.selectedBlockCoords, 'EdgeColor', [0 0 0], 'LineWidth', 1.5);
                % convert into linear block index
                %obj.currentBlock = ceil(bx/bs) + floor(by/bs)*floor(size(obj.videoEncoder.imageMatrix(:,:,:,obj.frameNumber), 2)/bs);
                obj.currentBlock = ceil(by/bs) + floor(bx/bs)*floor(size(obj.videoEncoder.imageMatrix(:,:,:,obj.frameNumber), 1)/bs);
                obj.currentCompareBlock = 1;
                obj.currentMotionVectors = [];
                set(obj.hPlayPauseButton, 'Enable', 'on');
                set(obj.hStepButton, 'Enable', 'on');

                obj.updateMainAxes();
            %end
        end

        function changeSettings(obj, source)
            switch source
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
                    obj.reset();
                    obj.blockMatchingStruct.maximumSearchDistance = str2double(s);

                case obj.hSearchBlockSizeCombo
                    strings = get(obj.hSearchBlockSizeCombo, 'String');
                    s = strings{get(obj.hSearchBlockSizeCombo, 'Value')};
                    obj.blockMatchingStruct.blockSize = str2double(s);
                    obj.reset();

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
            if source == obj.hReferenceFrameNumberCombo
                obj.referenceNumber = get(obj.hReferenceFrameNumberCombo, 'Value');
            else
                obj.frameNumber = get(obj.hFrameNumberCombo, 'Value');
            end
            obj.updateMainAxes();
        end
        
        function reset(obj)
            obj.motionVectors = [];
        	obj.selectedBlockCoords = [];
            obj.currentMotionVectors = [];
            obj.currentBlock = 1;
            obj.currentCompareBlock = 1;
            set(obj.hPlayPauseButton, 'Enable', 'off');
            set(obj.hStepButton, 'Enable', 'off');
            obj.updateMainAxes();
        end

        function toggleFreerun(obj, source)
            if isempty(obj.playTimer)
                obj.playTimer = timer('Period', 0.05, 'BusyMode', 'drop', 'ExecutionMode', 'fixedspacing', 'TimerFcn', @(x,y)obj.step());
                start(obj.playTimer);
            else
                obj.stopFreerun();
            end
        end
        function stopFreerun(obj)
            if ~isempty(obj.playTimer)
                stop(obj.playTimer);
                delete(obj.playTimer);
                obj.playTimer = [];
            end
        end

        function step(obj)
            % process next block
            cont = true;
            bs = obj.blockMatchingStruct.blockSize;
            while cont
                [motionVector predictionError invalidBlock continueBlock blockX blockY refX refY] = obj.searchAlgorithm(obj.videoEncoder.imageMatrix(:,:,:,obj.frameNumber), obj.videoEncoder.imageMatrix(:,:,:,obj.referenceNumber), obj.blockMatchingStruct, obj.currentBlock, obj.currentCompareBlock);
                if ~invalidBlock
                    obj.currentReferenceX = refX;
                    obj.currentReferenceY = refY;
                    %obj.residual(obj.currentReferenceY:obj.currentReferenceY+bs-1,obj.currentReferenceX:obj.currentReferenceX+bs-1,:) = predictionError(1:bs,1:bs,:);
                    obj.currentCoords{obj.currentCompareBlock} = [refX refY];
                    obj.currentBlockResiduals{obj.currentCompareBlock} = sum(predictionError(1:bs,1:bs,:),3);
                    obj.currentMotionVectors{obj.currentCompareBlock} = motionVector(1,1,:);
                    set(obj.hResultText, 'String', ['Vector (' num2str(motionVector(1,1,1)) ',' num2str(motionVector(1,1,2)) ') error: ' num2str(motionVector(1,1,3))]);
                    cont = false;
                end
                if continueBlock
                    obj.currentCompareBlock = obj.currentCompareBlock + 1;
                else
                    obj.stopFreerun();
                    set(obj.hPlayPauseButton, 'Enable', 'off');
                    set(obj.hStepButton, 'Enable', 'off');
                    cont = false;
                    
                    % Select best vector for currentBlock
                    best = -1;
                    err = 100000000;
                    for i=1:length(obj.currentMotionVectors)
                        if obj.currentMotionVectors{i}(3) < err
                            err = obj.currentMotionVectors{i}(3);
                            best = i;
                        end
                    end
                    obj.motionVectors{obj.currentBlock} = obj.currentMotionVectors{best};
                    obj.residual(obj.currentCoords{best}(2):obj.currentCoords{best}(2)+bs-1, obj.currentCoords{best}(1):obj.currentCoords{best}(1)+bs-1) = obj.currentBlockResiduals{best};
                    set(obj.hResultText, 'String', ['Best Vector (' num2str(obj.motionVectors{obj.currentBlock}(1)) ',' num2str(obj.motionVectors{obj.currentBlock}(2)) ') error: ' num2str(obj.motionVectors{obj.currentBlock}(3))]);
                    obj.updateMVView();
                    obj.updateTable();
                end
            end
            %obj.updateMainAxes();
            obj.updateBlockView();
        end
        
        function updateTable(obj)
            data = {};
            cnt = 1;
            for i=1:length(obj.currentMotionVectors)
                if ~isempty(obj.currentMotionVectors{i})
                    data{cnt, 1} = obj.currentMotionVectors{i}(1);
                    data{cnt, 2} = obj.currentMotionVectors{i}(2);
                    data{cnt, 3} = obj.currentMotionVectors{i}(3);
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

    end
end 

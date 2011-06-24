classdef VideoEncoder < GUIs.base
%VIDEOENCODER Summary of this class goes here
%   Detailed explanation goes here

    properties
        videoEncoders
        videoEncoder

        hFrameTextInfo
        hDiagramElements
        hPlayPauseButton
        hStepButton
        hRepeatCheckBox
        hShowResidualsCheckBox
        hStatSelect

        videoStatAxes
        videoBitRateAxes
        statGraphZoomState
        statGraphPosition
        statGraphZoomDelta

        videoPlayers
        playTimer
        repeatVideo = false;
        outputStatsToPlot = [];
        outputPlotType = 1;
    end

    methods
        function obj = VideoEncoder()
            obj = obj@GUIs.base('Video Encoding: A motion compensated video encoder');
            if ~exist( 'cachedVideos.mat', 'file')
                obj.reloadVideo(obj);
            else
                load('cachedVideos.mat', 've');
                obj.videoEncoders = ve;
            end

            % UI Elements
            obj.hInputImageSelectText = obj.createTextElement([0.01 0.93 0.1 0.03], 'Input Sequence:', 11, true, 'white', obj.hExternalPanel, 'FontName', 'helvetica');
            obj.hInputImageSelect = uicontrol('Style', 'popupmenu', ...
                                        'Parent', obj.hExternalPanel, ...
                                        'FontSize', 11, ...
                                        'FontName', 'Helvetica',...
                                        'Units', 'Normalized', ...
                                        'Position',[0.1 0.93 0.2 0.03],...
                                        'String', {'Suzie (I, 4 P) Quality 80' 'Foreman  (I, 4 P) Quality 50' 'Carphone  (I, 9 P) Quality 80'},...
                                        'Value', 1, ...
                                        'Callback', @(source, event)(obj.changeInput(source)));
            obj.hRepeatCheckBox = uicontrol('Style', 'checkbox', ...
                                    'Parent', obj.hExternalPanel, ...
                                    'FontSize', 9, ...
                                    'FontName', 'Helvetica',...
                                    'Units', 'Normalized', ...
                                    'Position',[0.02 0.97 0.1 0.03],...
                                    'String', 'Loop Video?',...
                                    'Value', 0,...
                                    'Callback', @(source, event)(obj.toggleLoopVideo(source)));
            obj.hPlayPauseButton = uicontrol('Style', 'togglebutton', ...
                                    'Parent', obj.hExternalPanel, ...
                                    'FontSize', 9, ...
                                    'FontName', 'Helvetica',...
                                    'Units', 'Normalized', ...
                                    'Position',[0.12 0.97 0.1 0.03],...
                                    'String', 'Pause',...
                                    'Value', 1,...
                                    'Callback', @(source, event)(obj.togglePlayVideo(source)));
            obj.hStepButton = uicontrol('Style', 'pushbutton', ...
                                    'Parent', obj.hExternalPanel, ...
                                    'FontSize', 9, ...
                                    'FontName', 'Helvetica',...
                                    'Units', 'Normalized', ...
                                    'Position',[0.22 0.97 0.1 0.03],...
                                    'String', 'Step 1 Frame',...
                                    'Value', 1,...
                                    'Callback', @(source, event)(obj.showNextFrame()));
            obj.hShowResidualsCheckBox = uicontrol('Style', 'checkbox', ...
                                    'Parent', obj.hExternalPanel, ...
                                    'FontSize', 9, ...
                                    'FontName', 'Helvetica',...
                                    'Units', 'Normalized', ...
                                    'Position',[0.35 0.97 0.13 0.03],...
                                    'String', 'Show Residuals?',...
                                    'Value', 0,...
                                    'Callback', @(source, event)(obj.toggleShowResiduals(source)));

            obj.hFrameTextInfo = obj.createTextElement([0.55 0.95 0.44 0.04], '(Frame info)', 14, 'on', 'white', obj.hExternalPanel, 'FontName', 'helvetica', 'BackgroundColor', [0.8 0.8 0.8], 'HorizontalAlignment', 'center');

            obj.hStatSelect = uicontrol('Style', 'popupmenu', ...
                                        'Parent', obj.hExternalPanel, ...
                                        'FontSize', 11, ...
                                        'FontName', 'Courier New',...
                                        'Units', 'Normalized', ...
                                        'Position',[0.69 0.5 0.25 0.03],...
                                        'String', {'Total bits per Frame (split bar)','Residual coding bits per Frame','Motion vectors bits per Frame', 'Total bits per Frame (single bar)','PSNR per Frame'},...
                                        'Callback', @(source, event)(obj.changeStatsOnDisplay(source)));
            % draw encoder
            mainCanvas = axes('Parent', obj.hExternalPanel, ...
                                        'Box', 'off', ...
                                        'Visible', 'on', ...
                                        'XTick', [],...
                                        'YTick', [],...
                                        'XColor', [1 1 1],...
                                        'YColor', [1 1 1],...
                                        'Units', 'Normalized', ...
                                        'Position', [0 0 1 1]);

            obj.lineWithArrowHead([0.3 0.745], [0.33 0.745]); % in to sum

            rectangle('Position', [0.33 0.72 0.03 0.05], 'Curvature', [1,1], 'Parent', mainCanvas); % sum node
            obj.hDiagramElements{1} = obj.createTextElement([0.35 0.68 0.03 0.02], '-', 10, 'on', 'white', obj.hExternalPanel);

            obj.lineWithArrowHead([0.36 0.745], [0.39 0.745]); % sum to t/q

            box = rectangle('Position', [0.39 0.70 0.1 0.10], 'Parent', mainCanvas, 'Curvature', 0.1); % t/q
            obj.hDiagramElements{2} = obj.createTextElement([0.395 0.705 0.09 0.06],'Transform & Quantisation', 10, 'on', 'white', obj.hExternalPanel,'HorizontalAlignment', 'center',  'FontName', 'helvetica');

            obj.lineWithArrowHead([0.49 0.745], [0.57 0.745]); %t/q to entropy

            rectangle('Position', [0.57 0.70 0.08 0.10], 'Parent', mainCanvas, 'Curvature', 0.1); % entropy
            obj.hDiagramElements{3} = obj.createTextElement([0.575 0.705 0.07 0.06], 'Entropy Coding', 10, 'on', 'white', obj.hExternalPanel,'HorizontalAlignment', 'center',  'FontName', 'helvetica');

            obj.lineWithArrowHead([0.65 0.745], [0.69 0.745]); % entropy to out

            obj.lineWithArrowHead([0.53 0.745], [0.53 0.6]); % t/q to inv t/q

            rectangle('Position', [0.48 0.50 0.10 0.10], 'Parent', mainCanvas, 'Curvature', 0.1); % inv t/q
            obj.hDiagramElements{4} = obj.createTextElement([0.485 0.505 0.09 0.07], 'Inverse Quantisation & Transform', 10, 'on', 'white', obj.hExternalPanel,'HorizontalAlignment', 'center',  'FontName', 'helvetica');

            obj.lineWithArrowHead([0.53 0.5], [0.53 0.45]); % inv t/q to reconstruction adder node

            rectangle('Position', [0.515 0.40 0.03 0.05], 'Curvature', [1,1], 'Parent', mainCanvas); % sum node after inv t/q
            obj.hDiagramElements{5} = obj.createTextElement([0.48 0.435 0.015 0.02], '+', 10, 'on', 'white', obj.hExternalPanel);

            obj.lineWithArrowHead([0.53 0.4], [0.53 0.35]); % recon to buffer

            rectangle('Position', [0.48 0.25 0.10 0.10], 'Parent', mainCanvas, 'Curvature', 0.1); % buffer
            obj.hDiagramElements{6} = obj.createTextElement([0.485 0.255 0.09 0.06], 'Frame Buffer', 10, 'on', 'white', obj.hExternalPanel, 'HorizontalAlignment', 'center', 'FontName', 'helvetica');

            obj.lineWithArrowHead([0.48 0.3], [0.4 0.3]); % buffer to mec (ref)
            obj.lineWithArrowHead([0.31 0.745], [0.31 0.35]); % input to mec (ref)

            rectangle('Position', [0.30 0.25 0.10 0.10], 'Parent', mainCanvas, 'Curvature', 0.1); % mec
            obj.hDiagramElements{7} = obj.createTextElement([0.305 0.255 0.09 0.07], 'Motion Estimation & Compensation', 10, 'on', 'white', obj.hExternalPanel, 'HorizontalAlignment', 'center', 'FontName', 'helvetica');

            line([0.35 0.35], [0.25 0.2], 'Color', [0 0 0]);
            line([0.35 0.62], [0.2 0.2], 'Color', [0 0 0]);
            obj.lineWithArrowHead([0.62 0.2], [0.62 0.7]); % Mec to entropy

            obj.lineWithArrowHead([0.345 0.35], [0.345 0.72]); % Mec to input sum
            obj.lineWithArrowHead([0.345 0.425], [0.515 0.425]); % prediction to recon summer
            
            obj.hDiagramElements{8} = obj.createTextElement([0.01 0.88 0.25 0.03], 'Input Frames', 10, 'on', 'white', obj.hExternalPanel);
            obj.hDiagramElements{9} = obj.createTextElement([0.69 0.43 0.25 0.03], 'Output Frames', 10, 'on', 'white', obj.hExternalPanel);
            obj.hDiagramElements{10} = obj.createTextElement([0.01 0.43 0.25 0.03], 'Motion Vectors', 10, 'on', 'white', obj.hExternalPanel);
            obj.hDiagramElements{11} = obj.createTextElement([0.69 0.885 0.25 0.03], 'Output Data per Frame', 10, 'on', 'white', obj.hExternalPanel);
            %obj.hDiagramElements{12} = obj.createTextElement([0.4 0.95 0.25 0.03], 'Residual Frame', 10, 'on', 'white', obj.hExternalPanel);
            %obj.hDiagramElements{13} = obj.createTextElement([0.4 0.65 0.25 0.03], 'Coded Residual Frame', 10, 'on', 'white', obj.hExternalPanel);

            xlim(mainCanvas, [0 1]);
            ylim(mainCanvas, [0 1]);

            % Axes
            obj.createVideoPlayer('input', ...
                                [0.01 0.60 0.28 0.28], [0 -0.15 0.2 0.2]);
            obj.createVideoPlayer('output', ...
                                [0.69 0.15 0.28 0.28], [-0.2 -0.2 0.2 0.2]);
            obj.createVideoPlayer('residual', ...
                                [0.4 0.75 0.2 0.2], [-0.1 -0.2 0.2 0.2]);
            obj.createVideoPlayer('reconstructedresidual', ...
                                [0.4 0.45 0.2 0.2], [-0.1 -0.3 0.2 0.2]);
            obj.createVideoPlayer('motionvectors', ...
                                [0.01 0.15 0.28 0.28], [0 -0.10 0.2 0.2]);

            obj.changeInput(obj.hInputImageSelect);


            obj.statGraphPosition = [0.70 0.55 0.28 0.3];
            obj.videoBitRateAxes = axes('Position', [0.70 0.55 0.28 0.3], 'Parent', obj.hExternalPanel);
            obj.statGraphZoomState = 0;
            obj.statGraphZoomDelta = [-0.2 -0.2 0.2 0.2];

            obj.toggleShowResiduals(obj.hShowResidualsCheckBox);
            obj.togglePlayVideo(obj.hPlayPauseButton);
        end
 
        function ax = createVideoPlayer(obj, type, pos, zoomPosDelta)
            playerID = length(obj.videoPlayers) + 1;
            ax = obj.createAxesForImage(pos, obj.hExternalPanel);
            %obj.setVideoPlayer(playerID, type, matrix);
            obj.videoPlayers{playerID}.position = pos;
            obj.videoPlayers{playerID}.zoomstate = 0;
            obj.videoPlayers{playerID}.zoomdelta = zoomPosDelta;
            obj.videoPlayers{playerID}.frame = 0;
            obj.videoPlayers{playerID}.parent = ax;
        end

        function setVideoPlayer(obj, playerID, type, matrix)
            switch type
                case {'residual', 'reconstructedresidual'}
                    % turn into matrix block
                    matrix = matrix.';
                    m = zeros(size(obj.videoEncoder.imageMatrix, 1), size(obj.videoEncoder.imageMatrix, 2), 3, length(matrix(:)));
                    for i=1:length(matrix(:))
                        if ~isempty(matrix{i})
                            if strcmp(type, 'reconstructedresidual')
                                m(:,:,:,i) = Subsampling.subsampledToYCbCrImage(matrix{i});
                            else
                                m(:,:,:,i) = matrix{i};
                            end
                        end
                    end
                    obj.videoPlayers{playerID}.data = m;
                    obj.videoPlayers{playerID}.type = 'residualmatrixdata';
                case {'input','output'}  
                    obj.videoPlayers{playerID}.data = matrix;
                    obj.videoPlayers{playerID}.type = 'rgbimagedata';
                case 'motionvectors'
                    obj.videoPlayers{playerID}.data = matrix;
                    obj.videoPlayers{playerID}.type = 'motionvectorsonrgbimagedata';
            end
        end

        function graphClick(obj, source)
            switch obj.statGraphZoomState
                case 0
                    obj.hideControls();
                    set(source, 'Position', obj.statGraphPosition + obj.statGraphZoomDelta);
                    obj.statGraphZoomState = 1;
                case 1
                    set(source, 'Position', [0.1 0.1 0.8 0.8]);
                    obj.statGraphZoomState = 2;
                case 2
                    set(source, 'Position', obj.statGraphPosition);
                    obj.statGraphZoomState = 0;
                    obj.showControls();
            end            
        end
        
        function videoClick(obj, source, playerID)
            % maximise video
            container = get(get(source, 'Parent'), 'Parent');
            order = get(obj.hExternalPanel, 'Children');
            order(container == order) = [];
            set(obj.hExternalPanel, 'Children', [container; order]);
            switch obj.videoPlayers{playerID}.zoomstate
                case 0
                    obj.hideControls();
                    set(container, 'Position', obj.videoPlayers{playerID}.position + obj.videoPlayers{playerID}.zoomdelta);
                    obj.videoPlayers{playerID}.zoomstate = 1;
                case 1
                    set(container, 'Position', [0.1 0.1 0.8 0.8]);
                    obj.videoPlayers{playerID}.zoomstate = 2;
                case 2
                    set(container, 'Position', obj.videoPlayers{playerID}.position);
                    obj.videoPlayers{playerID}.zoomstate = 0;
                    obj.showControls();
            end
        end
        
        function hideControls(obj)
            for i=1:length(obj.hDiagramElements)
                set(obj.hDiagramElements{i}, 'Visible', 'off');
            end
            set(obj.hStatSelect, 'Visible', 'off');
        end

        function showControls(obj)
            for i=1:length(obj.videoPlayers)
                if obj.videoPlayers{i}.zoomstate ~= 0 && ~strcmp(obj.videoPlayers{i}.type, 'residualmatrixdata')
                    return;
                end
            end
            if get(obj.hShowResidualsCheckBox, 'Value')
                return;
            end
            for i=1:length(obj.hDiagramElements)
                set(obj.hDiagramElements{i}, 'Visible', 'on');
            end
            set(obj.hStatSelect, 'Visible', 'on');
        end

        function changeStatsOnDisplay(obj, source)
            obj.outputPlotType = get(source, 'Value');
            obj.outputStatsToPlot = [];
        end

        function changeInput(obj, source)
            obj.stopVideo();
            switch(get(source, 'Value'))
                case 1
                    obj.videoEncoder = obj.videoEncoders{1};
                case 2
                    obj.videoEncoder = obj.videoEncoders{2};
                case 3
                    obj.videoEncoder = obj.videoEncoders{3}; 
            end

            % This way of organising is a mess, IDs created in order of
            % initial call but here assumed in specific order
            obj.setVideoPlayer(1, 'input', obj.videoEncoder.imageMatrix);
            obj.setVideoPlayer(2, 'output', obj.videoEncoder.reconstructedVideo);
            obj.setVideoPlayer(3,'residual', obj.videoEncoder.predictionErrorFrame);
            obj.setVideoPlayer(4,'reconstructedresidual', obj.videoEncoder.reconstructedPredictionErrorFrame);
            obj.setVideoPlayer(5,'motionvectors', obj.videoEncoder.reconstructedVideo);

        end

        function playVideos(obj)
            % update frame by frame, on a timer callback?
            if isempty(obj.playTimer)
                obj.playTimer = timer('Period', 1.0/obj.videoEncoder.frameRate,'ExecutionMode', 'fixedspacing', 'TimerFcn', @(x,y)obj.showNextFrame());
                start(obj.playTimer);
            else

            end
        end

        function resetPlayers(obj)
            for j=1:length(obj.videoPlayers)
                obj.videoPlayers{j}.frame = 1;
            end
            obj.outputStatsToPlot = [];
        end

        function showNextFrame(obj)
            for i=1:length(obj.videoPlayers)
                obj.videoPlayers{i}.frame = obj.videoPlayers{i}.frame + 1;
                if i == 1
                    if obj.videoPlayers{i}.frame > size(obj.videoPlayers{i}.data, 4)
                        obj.resetPlayers();
                        if ~obj.repeatVideo
                            obj.stopVideo();
                            return;
                        end
                    end
                end
                frame = obj.videoPlayers{i}.data(:,:,:,obj.videoPlayers{i}.frame);

                [GOPIndex frameIndex] = obj.videoEncoder.getGOPAndFrameIndex(obj.videoPlayers{i}.frame);
                infoText = ['Frame: ' num2str(obj.videoPlayers{i}.frame) ' (GOP: ' num2str(GOPIndex) ', frame: ' num2str(frameIndex) ') - ' upper(obj.videoEncoder.structureOfGOPString(frameIndex)) ' frame.'];
                set(obj.hFrameTextInfo, 'String', infoText);

                switch obj.videoPlayers{i}.type
                    case 'residualmatrixdata'
                        obj.videoPlayers{i}.hFrame = imagesc(sum(frame,3), 'Parent', obj.videoPlayers{i}.parent);
                        set(obj.videoPlayers{i}.hFrame, 'ButtonDownFcn', @(source, evt)(obj.videoClick(source, i)));
                        colormap bone
                    case 'rgbimagedata'
                        obj.videoPlayers{i}.hFrame = imshow(ycbcr2rgb(frame), 'Parent', obj.videoPlayers{i}.parent);
                        set(obj.videoPlayers{i}.hFrame, 'ButtonDownFcn', @(source, evt)(obj.videoClick(source, i)));
                    case 'motionvectorsonrgbimagedata'
                        mVs = obj.videoEncoder.motionVectors{GOPIndex, frameIndex};
                        bs = obj.videoEncoder.blockMatching.blockSize;
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

                        obj.videoPlayers{i}.hFrame = imshow(ycbcr2rgb(frame), 'Parent', obj.videoPlayers{i}.parent);
                        set(obj.videoPlayers{i}.hFrame, 'ButtonDownFcn', @(source, evt)(obj.videoClick(source, i)));
                        hold(obj.videoPlayers{i}.parent, 'on');
                        qv = quiver(obj.videoPlayers{i}.parent, x, y, u, v, 'k');
                        hold(obj.videoPlayers{i}.parent, 'off');
                        set(qv, 'ButtonDownFcn', @(source, evt)(obj.videoClick(obj.videoPlayers{i}.hFrame, i)));
                end

                % update stats graph
                if i == 1
                    stats = obj.videoEncoder.getStatistics();
                    if isempty(obj.outputStatsToPlot)
                        obj.outputStatsToPlot = zeros(size(obj.videoEncoder.imageMatrix, 4),2);
                    end
                    switch obj.outputPlotType
                        case 1 % combined
                            obj.outputStatsToPlot(obj.videoPlayers{i}.frame,1) = stats{GOPIndex}.frames{frameIndex}.frameBits;
                            obj.outputStatsToPlot(obj.videoPlayers{i}.frame,2) = stats{GOPIndex}.frames{frameIndex}.motionVectorBits;
                            bar(obj.videoBitRateAxes, obj.outputStatsToPlot(1:obj.videoPlayers{i}.frame,:) ,'stack');
                            xlim(obj.videoBitRateAxes, [1 size(obj.videoEncoder.imageMatrix, 4)]);
                        case 2 % frameBits
                            obj.outputStatsToPlot(obj.videoPlayers{i}.frame,1) = stats{GOPIndex}.frames{frameIndex}.frameBits;
                            bar(obj.videoBitRateAxes, obj.outputStatsToPlot(1:obj.videoPlayers{i}.frame,1), 'grouped');
                            xlim(obj.videoBitRateAxes, [1 size(obj.videoEncoder.imageMatrix, 4)]);
                        case 3 % motionVectorBits
                            obj.outputStatsToPlot(obj.videoPlayers{i}.frame,1) = stats{GOPIndex}.frames{frameIndex}.motionVectorBits;
                            bar(obj.videoBitRateAxes, obj.outputStatsToPlot(1:obj.videoPlayers{i}.frame,1), 'grouped');
                            xlim(obj.videoBitRateAxes, [1 size(obj.videoEncoder.imageMatrix, 4)]);
                        case 4 % total bits
                            obj.outputStatsToPlot(obj.videoPlayers{i}.frame,1) = stats{GOPIndex}.frames{frameIndex}.bits;
                            bar(obj.videoBitRateAxes, obj.outputStatsToPlot(1:obj.videoPlayers{i}.frame,1), 'grouped');
                            xlim(obj.videoBitRateAxes, [1 size(obj.videoEncoder.imageMatrix, 4)]);
                        case 5 % psnr
                            obj.outputStatsToPlot(obj.videoPlayers{i}.frame,1) = stats{GOPIndex}.frames{frameIndex}.psnr;
                            plot(obj.videoBitRateAxes, obj.outputStatsToPlot(1:obj.videoPlayers{i}.frame,1));
                            xlim(obj.videoBitRateAxes, [1 size(obj.videoEncoder.imageMatrix, 4)]);
                    end
                    
                    set(obj.videoBitRateAxes, 'ButtonDownFcn', @(source, evt)(obj.graphClick(source)));
                end
            end
        end

        function stopVideo(obj)
            set(obj.hPlayPauseButton, 'Value', 0);
            obj.togglePlayVideo(obj.hPlayPauseButton);
        end

        function toggleLoopVideo(obj,source)
            obj.repeatVideo = ~obj.repeatVideo;
        end

        function togglePlayVideo(obj,source)
            if get(source, 'Value')
                obj.playVideos();
                set(source, 'String', 'Pause');
                set(obj.hStepButton, 'Enable', 'off');
            else
                obj.clearTimer();
                set(source, 'String', 'Play');
                set(obj.hStepButton, 'Enable', 'on');
                set(obj.hStatSelect, 'Enable', 'on')
            end
        end

        function toggleShowResiduals(obj,source)
            if get(source, 'Value')
                state = 'on';
                obj.hideControls();
            else
                state = 'off';
                obj.showControls();
            end
            for i=1:length(obj.videoPlayers)
                if strcmp(obj.videoPlayers{i}.type, 'residualmatrixdata')
                    set(get(obj.videoPlayers{i}.parent, 'Parent'), 'Visible', state);
                end
            end
        end

        function handleCloseRequest(obj, source, event)
            obj.stopVideo();
            delete(gcf);
        end

        function clearTimer(obj)
            if ~isempty(obj.playTimer)
                stop(obj.playTimer);
                delete(obj.playTimer);
                obj.playTimer = [];
            end
        end

        function reloadVideo(obj, source)
            obj.stopVideo();
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

        function changeScreenMode(obj, source)

            obj.changeScreenMode@GUIs.base(source);

            if strcmp(get(source, 'State'), 'on')
                % on
                %set(obj.h, 'Visible', 'on');
            else
                % off
                %set(obj.h, 'Visible', 'off');
            end
            
        end

    end
end 

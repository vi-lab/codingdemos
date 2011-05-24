classdef VideoEncoder < GUIs.base
%VIDEOENCODER Summary of this class goes here
%   Detailed explanation goes here

    properties
        videoEncoder

        hFrameTextInfo
        hPlayPauseButton
        hStepButton
        hRepeatCheckBox
        hShowResidualsCheckBox

        videoStatAxes
        videoBitRateAxes

        videoPlayers
        playTimer
        repeatVideo = false;
        frameStatsToPlot = [];
    end

    methods
        function obj = VideoEncoder()
            obj = obj@GUIs.base('VideoEncoder');
            if ~exist( 'cachedVideo.mat', 'file')
                obj.reloadVideo(obj);
            else
                load('cachedVideo.mat', 've');
                obj.videoEncoder = ve;
            end

            % extra toolbar button to recreate video
            icon = imresize(imread('+GUIs/images/icons/refresh_48.png','BackgroundColor',[1 1 1]), [16 16]);
            uitoggletool(obj.hMainToolbar,'CData',icon,'TooltipString','Reload Video', ...
                                                    'Separator','on', ...
                                                    'ClickedCallback', @(source, event)(obj.reloadVideo(source)));

            % UI Elements
            obj.hRepeatCheckBox = uicontrol('Style', 'checkbox', ...
                                    'Parent', obj.hExternalPanel, ...
                                    'FontSize', 9, ...
                                    'FontName', 'Courier New',...
                                    'Units', 'Normalized', ...
                                    'Position',[0.02 0.97 0.1 0.03],...
                                    'String', 'Loop Video?',...
                                    'Value', 0,...
                                    'Callback', @(source, event)(obj.toggleLoopVideo(source)));
            obj.hPlayPauseButton = uicontrol('Style', 'togglebutton', ...
                                    'Parent', obj.hExternalPanel, ...
                                    'FontSize', 9, ...
                                    'FontName', 'Courier New',...
                                    'Units', 'Normalized', ...
                                    'Position',[0.12 0.97 0.1 0.03],...
                                    'String', 'Pause',...
                                    'Value', 1,...
                                    'Callback', @(source, event)(obj.togglePlayVideo(source)));
            obj.hStepButton = uicontrol('Style', 'pushbutton', ...
                                    'Parent', obj.hExternalPanel, ...
                                    'FontSize', 9, ...
                                    'FontName', 'Courier New',...
                                    'Units', 'Normalized', ...
                                    'Position',[0.22 0.97 0.1 0.03],...
                                    'String', 'Step 1 Frame',...
                                    'Value', 1,...
                                    'Callback', @(source, event)(obj.showNextFrame()));
            obj.hShowResidualsCheckBox = uicontrol('Style', 'checkbox', ...
                                    'Parent', obj.hExternalPanel, ...
                                    'FontSize', 9, ...
                                    'FontName', 'Courier New',...
                                    'Units', 'Normalized', ...
                                    'Position',[0.45 0.97 0.1 0.03],...
                                    'String', 'Show Residuals?',...
                                    'Value', 0,...
                                    'Callback', @(source, event)(obj.toggleShowResiduals(source)));

            obj.hFrameTextInfo = obj.createTextElement([0.01 0.01 0.7 0.04], '(Frame info)', 14, 'on', 'white', obj.hExternalPanel);

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
            obj.createTextElement([0.35 0.66 0.07 0.03], 'subtract', 10, 'on', 'white', obj.hExternalPanel);

            obj.lineWithArrowHead([0.36 0.745], [0.4 0.745]); % sum to t/q

            box = rectangle('Position', [0.40 0.70 0.08 0.10], 'Parent', mainCanvas); % t/q
            obj.createTextElement([0.405 0.705 0.07 0.09],'Transform/Quantisation', 10, 'on', 'white', obj.hExternalPanel);

            obj.lineWithArrowHead([0.48 0.745], [0.55 0.745]); %t/q to entropy

            rectangle('Position', [0.55 0.70 0.08 0.10], 'Parent', mainCanvas); % entropy
            obj.createTextElement([0.555 0.705 0.07 0.09], 'Entropy Coding', 10, 'on', 'white', obj.hExternalPanel);

            obj.lineWithArrowHead([0.63 0.745], [0.69 0.745]); % entropy to out

            obj.lineWithArrowHead([0.5 0.745], [0.5 0.6]); % t/q to inv t/q

            rectangle('Position', [0.45 0.50 0.10 0.10], 'Parent', mainCanvas); % inv t/q
            obj.createTextElement([0.455 0.505 0.09 0.09], 'Inverse Quantisation/Transform', 10, 'on', 'white', obj.hExternalPanel);

            obj.lineWithArrowHead([0.5 0.5], [0.5 0.45]); % inv t/q to reconstruction adder node

            rectangle('Position', [0.485 0.40 0.03 0.05], 'Curvature', [1,1], 'Parent', mainCanvas); % sum node after inv t/q
            obj.createTextElement([0.43 0.435 0.04 0.03], 'add', 10, 'on', 'white', obj.hExternalPanel);

            obj.lineWithArrowHead([0.5 0.4], [0.5 0.35]); % recon to buffer

            rectangle('Position', [0.47 0.25 0.10 0.10], 'Parent', mainCanvas); % buffer
            obj.createTextElement([0.475 0.255 0.09 0.09], 'Frame Buffer', 10, 'on', 'white', obj.hExternalPanel);

            obj.lineWithArrowHead([0.47 0.3], [0.4 0.3]); % buffer to mec (ref)
            obj.lineWithArrowHead([0.31 0.745], [0.31 0.35]); % input to mec (ref)

            rectangle('Position', [0.30 0.25 0.10 0.10], 'Parent', mainCanvas); % mec
            obj.createTextElement([0.305 0.255 0.09 0.09], 'Motion Estimation/Compensation', 10, 'on', 'white', obj.hExternalPanel);

            line([0.35 0.35], [0.25 0.2], 'Color', [0 0 0]);
            line([0.35 0.6], [0.2 0.2], 'Color', [0 0 0]);
            obj.lineWithArrowHead([0.6 0.2], [0.6 0.7]); % Mec to entropy

            obj.lineWithArrowHead([0.345 0.35], [0.345 0.72]); % Mec to input sum
            obj.lineWithArrowHead([0.345 0.425], [0.485 0.425]); % prediction to recon summer

            xlim(mainCanvas, [0 1]);
            ylim(mainCanvas, [0 1]);

            % Axes
            obj.setVideoPlayer('input', obj.videoEncoder.imageMatrix, ...
                                [0.01 0.65 0.28 0.28], [0 -0.2 0.2 0.2]);
            obj.setVideoPlayer('output', obj.videoEncoder.reconstructedVideo, ...
                                [0.69 0.35 0.28 0.28], [-0.2 -0.2 0.2 0.2]);
            obj.setVideoPlayer('residual', obj.videoEncoder.predictionErrorFrame, ...
                                [0.4 0.75 0.2 0.2], [-0.1 -0.1 0.2 0.2]);
            obj.setVideoPlayer('reconstructedresidual', obj.videoEncoder.reconstructedPredictionErrorFrame, ...
                                [0.4 0.45 0.2 0.2], [-0.1 -0.2 0.2 0.2]);
            obj.setVideoPlayer('motionvectors', obj.videoEncoder.reconstructedVideo, ...
                                [0.01 0.25 0.28 0.28], [0 -0.1 0.2 0.2]);

            obj.videoBitRateAxes = axes('Position', [0.69 0.65 0.3 0.3], 'Parent', obj.hExternalPanel);
            obj.videoStatAxes = axes('Position', [0.69 0.05 0.3 0.3], 'Parent', obj.hExternalPanel);


            obj.toggleShowResiduals(obj.hShowResidualsCheckBox);
            obj.togglePlayVideo(obj.hPlayPauseButton);
        end
 
        function ax = setVideoPlayer(obj, type, matrix, pos, zoomPosDelta)
            playerID = length(obj.videoPlayers) + 1;
            ax = obj.createAxesForImage(pos, obj.hExternalPanel);
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
            obj.videoPlayers{playerID}.position = pos;
            obj.videoPlayers{playerID}.zoomstate = 0;
            obj.videoPlayers{playerID}.zoomdelta = zoomPosDelta;
            obj.videoPlayers{playerID}.frame = 0;
            obj.videoPlayers{playerID}.parent = ax;
        end

        function playVideos(obj)
            % update frame by frame, on a timer callback?
            if isempty(obj.playTimer)
                obj.playTimer = timer('Period', 1.0/obj.videoEncoder.frameRate,'ExecutionMode', 'fixedspacing', 'TimerFcn', @(x,y)obj.showNextFrame());
                start(obj.playTimer);
            else

            end
        end

        function showNextFrame(obj)
            for i=1:length(obj.videoPlayers)
                obj.videoPlayers{i}.frame = obj.videoPlayers{i}.frame + 1;
                if obj.videoPlayers{i}.frame > size(obj.videoPlayers{i}.data, 4)
                    if obj.repeatVideo
                        obj.videoPlayers{i}.frame = 1;
                        obj.frameStatsToPlot = [];
                    else
                        obj.stopVideo();
                        obj.frameStatsToPlot = [];
                        return;
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
                        quiver(obj.videoPlayers{i}.parent, x, y, u, v, 'k');
                        hold(obj.videoPlayers{i}.parent, 'off');
                end

                % update stats graph
                if i == 1
                    obj.frameStatsToPlot = [obj.frameStatsToPlot obj.videoEncoder.frameStatistics{obj.videoPlayers{i}.frame}.psnr];
                    plot(obj.videoStatAxes, obj.frameStatsToPlot);
                    xlim(obj.videoStatAxes, [1 size(obj.videoEncoder.imageMatrix, 4)]);
                    %ylim(obj.videoStatAxes, [10 50]);

                    % TODO: This will plot bit counts when I have them
                    bar(obj.videoBitRateAxes, obj.frameStatsToPlot);
                    xlim(obj.videoBitRateAxes, [1 size(obj.videoEncoder.imageMatrix, 4)]);
                end
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
                    set(container, 'Position', obj.videoPlayers{playerID}.position + obj.videoPlayers{playerID}.zoomdelta);
                    obj.videoPlayers{playerID}.zoomstate = 1;
                case 1
                    set(container, 'Position', [0.1 0.1 0.8 0.8]);
                    obj.videoPlayers{playerID}.zoomstate = 2;
                case 2
                    set(container, 'Position', obj.videoPlayers{playerID}.position);
                    obj.videoPlayers{playerID}.zoomstate = 0;
            end
        end

        function stopVideo(obj)
            set(obj.hPlayPauseButton, 'Value', 0);
            obj.togglePlayVideo(obj.hPlayPauseButton);
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
            end
        end

        function toggleShowResiduals(obj,source)
            if get(source, 'Value')
                state = 'on';
            else
                state = 'off';
            end
            for i=1:length(obj.videoPlayers)
                if strcmp(obj.videoPlayers{i}.type, 'residualmatrixdata')
                    set(get(obj.videoPlayers{i}.parent, 'Parent'), 'Visible', state);
                end
            end
        end

        function toggleLoopVideo(obj,source)
            obj.repeatVideo = ~obj.repeatVideo;
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
            obj.videoEncoder = Video.encoder('examples/imseq/vid:0000:0024:.jpg');
            obj.videoEncoder.encode('gop', 'ipppp', 'verbose', true, 'Quality', 80, 'BlockMatchingSearchDistance', 8, 'BlockMatching', 'DSA');
            ve = obj.videoEncoder;
            save('cachedVideo.mat', 've');
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

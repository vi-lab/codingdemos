classdef VideoEncoder < GUIs.base
%VIDEOENCODER Summary of this class goes here
%   Detailed explanation goes here

    properties
        videoEncoder

        hRepeatCheckBox

        videoInputAxes
        videoOutputAxes
        videoResidualAxes
        videoReconstructedResidualAxes
        videoStatAxes
        videoMVAxes

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

            % draw encoder
            %mainCanvas  = obj.createAxesForImage([0 0 1 1], obj.hExternalPanel);
            mainCanvas = axes('Parent', obj.hExternalPanel, ...
                                        'Box', 'off', ...
                                        'Visible', 'on', ...
                                        'XTick', [],...
                                        'YTick', [],...
                                        'XColor', [1 1 1],...
                                        'YColor', [1 1 1],...
                                        'Units', 'Normalized', ...
                                        'Position', [0 0 1 1]);
            rectangle('Position', [0.32 0.75 0.02 0.02], 'Curvature', [1,1], 'Parent', mainCanvas);
            rectangle('Position', [0.35 0.70 0.10 0.05], 'Parent', mainCanvas);
            rectangle('Position', [0.50 0.70 0.10 0.05], 'Parent', mainCanvas);
            rectangle('Position', [0.50 0.50 0.10 0.05], 'Parent', mainCanvas);
            rectangle('Position', [0.50 0.45 0.02 0.02], 'Curvature', [1,1], 'Parent', mainCanvas);
            rectangle('Position', [0.50 0.40 0.10 0.05], 'Parent', mainCanvas);
            rectangle('Position', [0.35 0.40 0.10 0.05], 'Parent', mainCanvas);
            xlim(mainCanvas, [0 1]);
            ylim(mainCanvas, [0 1]);

            obj.hRepeatCheckBox = uicontrol('Style', 'checkbox', ...
                                    'Parent', obj.hExternalPanel, ...
                                    'FontSize', 9, ...
                                    'FontName', 'Courier New',...
                                    'Units', 'Normalized', ...
                                    'Position',[0.02 0.97 0.15 0.03],...
                                    'String', 'Loop Video?',...
                                    'Value', 0,...
                                    'Callback', @(source, event)(obj.toggleLoopVideo(source)));

            obj.videoInputAxes  = obj.createAxesForImage([0.01 0.65 0.3 0.3], obj.hExternalPanel);
            obj.videoResidualAxes = obj.createAxesForImage([0.4 0.75 0.2 0.2], obj.hExternalPanel);
            obj.videoReconstructedResidualAxes = obj.createAxesForImage([0.4 0.45 0.2 0.2], obj.hExternalPanel);
            obj.videoOutputAxes = obj.createAxesForImage([0.65 0.65 0.3 0.3], obj.hExternalPanel);
            obj.videoStatAxes   = axes('Position', [0.65 0.35 0.3 0.3], 'Parent', obj.hExternalPanel);
            obj.videoMVAxes     = obj.createAxesForImage([0.65 0.01 0.3 0.3], obj.hExternalPanel);

            obj.setVideoPlayer(1, 'input', obj.videoEncoder.imageMatrix, obj.videoInputAxes);
            obj.setVideoPlayer(2, 'output', obj.videoEncoder.reconstructedVideo, obj.videoOutputAxes);
            obj.setVideoPlayer(3, 'residual', obj.videoEncoder.predictionErrorFrame, obj.videoResidualAxes);
            obj.setVideoPlayer(4, 'reconstructedresidual', obj.videoEncoder.reconstructedPredictionErrorFrame, obj.videoReconstructedResidualAxes);
            %obj.setVideoPlayer(3, cell2mat(obj.videoEncoder.reconstructedPredictionErrorFrame), obj.videoMVAxes);
            obj.playVideos();
        end
 
        function setVideoPlayer(obj, playerID, type, matrix, axes)
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
            end
            obj.videoPlayers{playerID}.frame = 0;
            obj.videoPlayers{playerID}.parent = axes;
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
                        obj.clearTimer();
                        obj.frameStatsToPlot = [];
                        return;
                    end
                end
                frame = obj.videoPlayers{i}.data(:,:,:,obj.videoPlayers{i}.frame);
                switch obj.videoPlayers{i}.type
                    case 'residualmatrixdata'
                        imagesc(sum(frame,3), 'Parent', obj.videoPlayers{i}.parent);
                        colormap bone
                    case 'rgbimagedata'
                        imshow(ycbcr2rgb(frame), 'Parent', obj.videoPlayers{i}.parent);
                end

                % update stats graph
                if i == 1
                    obj.frameStatsToPlot = [obj.frameStatsToPlot obj.videoEncoder.frameStatistics{obj.videoPlayers{i}.frame}.psnr];
                    plot(obj.videoStatAxes, obj.frameStatsToPlot);
                    xlim(obj.videoStatAxes, [1 size(obj.videoEncoder.imageMatrix, 4)]);
                    %ylim(obj.videoStatAxes, [10 50]);
                end
            end
        end

        function handleCloseRequest(obj, source, event)
            obj.clearTimer();
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
            obj.clearTimer();
            obj.videoEncoder = Video.encoder('examples/imseq/vid:0000:0024:.jpg');
            obj.videoEncoder.encode('gop', 'ipppp', 'verbose', true, 'Quality', 80, 'BlockMatchingSearchDistance', 8, 'BlockMatching', 'DSA');
            ve = obj.videoEncoder;
            save('cachedVideo.mat', 've');
        end

        function toggleLoopVideo(obj,source)
            obj.clearTimer();
            obj.repeatVideo = ~obj.repeatVideo;
            obj.playVideos();
        end
    end
end 

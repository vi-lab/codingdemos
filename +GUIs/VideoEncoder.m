classdef VideoEncoder < GUIs.base
%VIDEOENCODER Summary of this class goes here
%   Detailed explanation goes here

    properties
        videoEncoder

        videoInputAxes
        videoOutputAxes
        videoMVAxes

        videoPlayers
        playTimer
        repeatVideo = true;
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

            obj.videoInputAxes  = obj.createAxesForImage([0.01 0.65 0.3 0.3], obj.hExternalPanel);
            obj.videoOutputAxes = obj.createAxesForImage([0.65 0.65 0.3 0.3], obj.hExternalPanel);
            obj.videoMVAxes     = obj.createAxesForImage([0.65 0.1 0.3 0.3], obj.hExternalPanel);

            %obj.videoEncoder.playVideo('in', 'parent', obj.videoInputAxes, 'framerate', 5);
            %obj.videoEncoder.playVideo('out', 'parent', obj.videoOutputAxes, 'framerate', 5);
            %obj.videoEncoder.playVideo('out', 'parent', obj.videoMVAxes, 'framerate', 5, 'showMotionVectors', true, 'showResidual', true);
            obj.setVideoPlayer(1, obj.videoEncoder.imageMatrix, obj.videoInputAxes);
            obj.setVideoPlayer(2, obj.videoEncoder.reconstructedVideo, obj.videoOutputAxes);
            %obj.setVideoPlayer(3, cell2mat(obj.videoEncoder.reconstructedPredictionErrorFrame), obj.videoMVAxes);
            obj.playVideos();
        end
 
        function setVideoPlayer(obj, playerID, matrix, axes)
            obj.videoPlayers{playerID}.data = matrix;
            obj.videoPlayers{playerID}.frame = 1;
            obj.videoPlayers{playerID}.parent = axes;
            imshow(ycbcr2rgb(matrix(:,:,:,1)), 'Parent', axes);
        end

        function playVideos(obj)
            % update frame by frame, on a timer callback?
            if isempty(obj.playTimer)
                obj.playTimer = timer('Period', 1.0/obj.videoEncoder.frameRate,'ExecutionMode', 'fixedrate', 'TimerFcn', @(x,y)obj.showNextFrame());
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
                    else
                        stop(obj.playTimer);
                        delete(obj.playTimer);
                        obj.playTimer = [];
                        return;
                    end
                end
                imshow(ycbcr2rgb(obj.videoPlayers{i}.data(:,:,:,obj.videoPlayers{i}.frame)), 'Parent', obj.videoPlayers{i}.parent);
            end
        end

        function handleCloseRequest(obj, source, event)
            if ~isempty(obj.playTimer)
                stop(obj.playTimer);
                delete(obj.playTimer);
                obj.playTimer = [];
            end
            delete(gcf);
        end

        function reloadVideo(obj, source)
            obj.videoEncoder = Video.encoder('examples/imseq/vid:0000:0024:.jpg');
            obj.videoEncoder.encode('gop', 'ipppp', 'verbose', true, 'Quality', 80, 'BlockMatchingSearchDistance', 8, 'BlockMatching', 'DSA');
            ve = obj.videoEncoder;
            save('cachedVideo.mat', 've');
        end
    end
end 

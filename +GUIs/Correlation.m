classdef Correlation < GUIs.base
%CORRELATION Screen designed to demostrate spatial & temporal redundancy
%
%   +GUIs/Correlation.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   The following screen demostrates the spatial and temporal redundancy
%   by allowing the user to explore the correlation between spatially
%   adjacent and temporally adjacent pixels for images and videos and
%   random data. Click on the input image or video to select the row or
%   pixel being explored.
%
%   Start a new screen by calling the class constructor:
%       `GUIs.Correlation`
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

    properties
        hMotionCorrelationPanel
        hImageAxes
        hSpatialCorrelationAxes
        hSpatialInfo

        hImage
        hSamplesSlider
        hSamplesSliderText
        chosenRow
        hChosenLine

        numberOfSamples = 10;

        hTemporalCorrelationAxes
        hVideoAxes
        hVideo
        hVideoInfo
        hVideoPlayButton
        hVideoStepButton
        hVideoLoadButton
        hVideoRandomButton
        hVideoSamplesSliderText
        hVideoSamplesSlider

        videoEncoder
        chosenVideoPoint

        videoData
        currentFrame = 0;
        numberOfVideoSamples = 10;
    end

    methods
        function obj = Correlation()
            obj = obj@GUIs.base('Spatial Correlation');

            obj.chosenRow = 1;
            obj.chosenVideoPoint = [1 1];

            % Show input image selection
            obj.createInputImageSelectComboBoxAndText([0.02 0.96 0.25 0.03], [0.02 0.90 0.2 0.03]);
            uicontrol('Style', 'pushbutton', 'String', 'Random Image',...
                                        'Parent', obj.hExternalPanel,...
                                        'Units', 'Normalized', ...
                                        'Position', [0.24 0.92 0.1 0.03],...
                                        'Callback', @(src,evt)obj.randomImage);
            obj.hImageAxes = obj.createAxesForImage([0.01 0.55 0.3 0.35], obj.hExternalPanel);
            obj.createTextElement([0.01 0.5 0.4 0.03], 'Click to select a row for correlation plot.', 9, 'on', 'white', obj.hExternalPanel);
            obj.hSpatialCorrelationAxes = axes('Parent', obj.hExternalPanel, 'Position', [0.4 0.56 0.54 0.38]);
            set(get(obj.hSpatialCorrelationAxes,'XLabel'),'String','Offset in Pixels');
            set(get(obj.hSpatialCorrelationAxes,'YLabel'),'String','Correlation');
            obj.hSpatialInfo = obj.createTextElement([0.35 0.97 0.4 0.03], ['Chosen Row: ' num2str(obj.chosenRow)], 12, 'on', 'white', obj.hExternalPanel);
            obj.hSamplesSliderText = obj.createTextElement([0.6 0.96 0.14 0.03], 'No. Samples:', 10, false);
            obj.hSamplesSlider = uicontrol('Style', 'slider', ...
                                                'Visible', 'off', ...
                                                'Parent', obj.hExternalPanel, ...
                                                'Min', 1, 'Max', 100, ...
                                                'Units', 'Normalized', ...
                                                'Position', [0.74 0.96 0.25 0.03], ...
                                                'Value', obj.numberOfSamples,...
                                                'Callback', @(source, event)(obj.sampleNumberChange(source)));

            obj.hMotionCorrelationPanel = uipanel('FontSize', 12,  ...
                            'FontName', 'Courier', ...
                            'BackgroundColor', 'white', ...
                            'Units', 'Normalized', ...
                            'Position', [0.0 .01 1.0 .47]);
            obj.createTextElement([0.0 .93 1.0 0.07], ' Temporal Correlation', 15, true, [.8 .8 .8], obj.hMotionCorrelationPanel,'FontName', 'arial');
            obj.hTemporalCorrelationAxes = axes('Parent', obj.hMotionCorrelationPanel, 'Position', [0.4 0.15 0.54 0.65]);
            set(get(obj.hTemporalCorrelationAxes,'XLabel'),'String','Offset in Time (Frames)');
            set(get(obj.hTemporalCorrelationAxes,'YLabel'),'String','Correlation');
            obj.hVideoInfo = obj.createTextElement([0.35 0.85 0.4 0.07], ['Chosen Pixel: (' num2str(obj.chosenVideoPoint(1)) ',' num2str(obj.chosenVideoPoint(2)) ')'], 12, 'on', 'white', obj.hMotionCorrelationPanel);
            obj.hVideoAxes = obj.createAxesForImage([0.01 0.1 0.3 0.71], obj.hMotionCorrelationPanel);
            obj.hVideoLoadButton = uicontrol('Style', 'pushbutton', 'String', 'Load Video',...
                                        'Parent', obj.hMotionCorrelationPanel,...
                                        'Units', 'Normalized', ...
                                        'Position', [0.01 0.82 0.10 0.05],...
                                        'Callback', @(src,evt)(obj.videoLoad(src)));
            obj.hVideoPlayButton = uicontrol('Style', 'pushbutton', 'String', 'Play',...
                                        'Parent', obj.hMotionCorrelationPanel,...
                                        'Enable', 'off', ...
                                        'Units', 'Normalized', ...
                                        'Position', [0.11 0.82 0.05 0.05],...
                                        'Callback', @(src,evt)(obj.videoPlay(src)));
            obj.hVideoStepButton = uicontrol('Style', 'pushbutton', 'String', 'Step',...
                                        'Parent', obj.hMotionCorrelationPanel,...
                                        'Enable', 'off', ...
                                        'Units', 'Normalized', ...
                                        'Position', [0.16 0.82 0.05 0.05],...
                                        'Callback', @(src,evt)(obj.videoStep(src)));
            obj.createTextElement([0.01 0.01 0.4 0.06], 'Click to select a pixel for the correlation plot.', 9, 'on', 'white', obj.hMotionCorrelationPanel);
            obj.hVideoRandomButton = uicontrol('Style', 'pushbutton', 'String', 'Random Video',...
                                        'Parent', obj.hMotionCorrelationPanel,...
                                        'Units', 'Normalized', ...
                                        'Position', [0.21 0.82 0.1 0.05],...
                                        'Callback', @(src,evt)(obj.randomVideo(src)));
            obj.hVideoSamplesSliderText = obj.createTextElement([0.6 0.88 0.14 0.05], 'No. Samples:', 10, false, 'white', obj.hMotionCorrelationPanel);
            obj.hVideoSamplesSlider = uicontrol('Style', 'slider', ...
                                                'Visible', 'off', ...
                                                'Parent', obj.hMotionCorrelationPanel, ...
                                                'Min', 1, 'Max', 100, ...
                                                'Units', 'Normalized', ...
                                                'Position', [0.74 0.88 0.25 0.05], ...
                                                'Value', obj.numberOfVideoSamples,...
                                                'Callback', @(source, event)(obj.videoSampleNumberChange(source)));
                                    
            obj.changeInput(obj.hInputImageSelect);

            obj.setSliderLength();
        end

        function changeInput(obj, source)
            % Call super class implementation which does the loading etc
            obj.changeInput@GUIs.base(source);
            obj.setSliderLength();
            obj.updateAxes();
            obj.updateCorrelationPlots();
        end

        function randomImage(obj, source, event)
            obj.inputMatrix = uint8(floor(rand(256,256).*255));
            obj.updateAxes();
            obj.updateCorrelationPlots();
        end

        function updateCorrelationPlots(obj)
            % Y channel
            if ~isempty(obj.hChosenLine)
                delete(obj.hChosenLine);
                obj.hChosenLine = [];
            end
            data = obj.inputMatrix(:,:,1);
            data = data(obj.chosenRow,:,1);
            data = data - mean(data(:));
            coefs = xcorr(data, min(obj.numberOfSamples,length(data)), 'unbiased');  % floor(length(data)/4)
            plot(obj.hSpatialCorrelationAxes, coefs(ceil(length(coefs)/2):end));
            set(obj.hSpatialInfo, 'String', ['Chosen Row: ' num2str(obj.chosenRow)]);
            set(get(obj.hSpatialCorrelationAxes,'XLabel'),'String','Offset in Pixels');
            set(get(obj.hSpatialCorrelationAxes,'YLabel'),'String','Correlation');
            obj.hChosenLine = rectangle('Parent', obj.hImageAxes, ...
                                       'Position', [0.5  obj.chosenRow-0.5 size(obj.inputMatrix,2) 1], ...
                                       'EdgeColor', [0 0 0], 'LineWidth', 1);
        end

        function updateAxes(obj)
            if ~isempty(obj.hChosenLine)
                delete(obj.hChosenLine);
                obj.hChosenLine = [];
            end
            obj.hImage = imshow(obj.inputMatrix(:,:,1), 'Parent', obj.hImageAxes);
            set(obj.hImage, 'ButtonDownFcn', @(source, evt)(obj.imageClick(source)));
        end

        function sampleNumberChange(obj, source)
            obj.numberOfSamples = ceil(get(source, 'Value'));
            obj.updateAxes();
            obj.updateCorrelationPlots();
        end
        
        function setSliderLength(obj)
            set(obj.hSamplesSlider, 'Value', min(10,size(obj.inputMatrix(:,:,1),2)));
            set(obj.hSamplesSlider, 'Max', size(obj.inputMatrix(:,:,1),2));
        end

        function imageClick(obj, source)
           % handle input / output image clicks
            if ~isempty(obj.inputMatrix)
                selectedPoint = floor(get(obj.hImageAxes, 'CurrentPoint'));
                obj.chosenRow = selectedPoint(1,2);
                obj.updateCorrelationPlots();
            end
        end

        function videoLoad(obj, source)
            set(source, 'Enable', 'off');
            obj.videoEncoder = Video.encoder('examples/imseq/vid:0000:0025:.jpg');
            obj.videoData = zeros(1,size(obj.videoEncoder.imageMatrix,4));
            obj.setVideoSliderLength();
            obj.videoPlay(obj.hVideoPlayButton);
        end

        function randomVideo(obj, source)
            obj.chosenVideoPoint = [1 1];
            obj.videoEncoder = [];
            set(source, 'Enable', 'on');
            set(obj.hVideoLoadButton, 'Enable', 'on');
            obj.videoEncoder.imageMatrix = rand(256,256,1,20);
            obj.videoData = zeros(1,size(obj.videoEncoder.imageMatrix,4));
            obj.setVideoSliderLength();
            obj.videoPlay(obj.hVideoPlayButton);
        end

        function videoClick(obj, source)
           % handle input / output image clicks
            if ~isempty(obj.videoEncoder.imageMatrix)
                obj.chosenVideoPoint = floor(get(obj.hVideoAxes, 'CurrentPoint'));
                obj.chosenVideoPoint = obj.chosenVideoPoint(1,:);
            end
        end

        function setVideoSliderLength(obj)
            set(obj.hVideoSamplesSlider, 'Value', min(10,size(obj.videoEncoder.imageMatrix,4)));
            set(obj.hVideoSamplesSlider, 'Max', size(obj.videoEncoder.imageMatrix,4));
            obj.videoSampleNumberChange(obj.hVideoSamplesSlider);
        end

        function videoSampleNumberChange(obj, source)
            obj.numberOfVideoSamples = ceil(get(source, 'Value'));
        end

        function videoPlay(obj, source)
            set(source, 'Enable', 'off');
            set(obj.hVideoStepButton, 'Enable', 'off');
            set(obj.hVideoRandomButton, 'Enable', 'off');
            for i=1:obj.numberOfVideoSamples
                obj.hVideo = imshow(obj.videoEncoder.imageMatrix(:,:,1,i), 'Parent', obj.hVideoAxes);
                set(obj.hVideo, 'ButtonDownFcn', @(source, evt)(obj.videoClick(source)));
                obj.updateVideoPlot(i);
                pause(0.05);
            end 
            set(obj.hVideoRandomButton, 'Enable', 'on');
            set(source, 'Enable', 'on');
            set(obj.hVideoStepButton, 'Enable', 'on');
        end

        function videoStep(obj, source)
            obj.currentFrame = obj.currentFrame + 1;
            if obj.currentFrame > obj.numberOfVideoSamples
                obj.currentFrame = 1;
            end
            set(source, 'Enable', 'off');
            obj.hVideo = imshow(obj.videoEncoder.imageMatrix(:,:,1,obj.currentFrame), 'Parent', obj.hVideoAxes);
            set(obj.hVideo, 'ButtonDownFcn', @(source, evt)(obj.videoClick(source)));
            obj.updateVideoPlot(obj.currentFrame);
            set(source, 'Enable', 'on');
        end

        function updateVideoPlot(obj, frame)
            obj.videoData(1,frame) = obj.videoEncoder.imageMatrix(obj.chosenVideoPoint(2),obj.chosenVideoPoint(1),1,frame);
            data = obj.videoData;
            data(1,1:frame) = data(1,1:frame) - mean(data(1,1:frame) );
            coefs = xcorr(data, frame-1, 'unbiased');
            plot(obj.hTemporalCorrelationAxes, coefs(ceil(length(coefs)/2):end));
            xlim(obj.hTemporalCorrelationAxes, [1 obj.numberOfVideoSamples]);
            set(get(obj.hTemporalCorrelationAxes,'XLabel'),'String','Offset in Time (Frames)');
            set(get(obj.hTemporalCorrelationAxes,'YLabel'),'String','Correlation');
            set(obj.hVideoInfo, 'String', ['Chosen Pixel: (' num2str(obj.chosenVideoPoint(1)) ',' num2str(obj.chosenVideoPoint(2)) ')']);
        end

        function handleKeyPress(obj, source, event)
            if ~isempty(obj.inputMatrix)
                if strcmp(event.Key, 'uparrow')
                    obj.chosenRow = obj.chosenRow - 1;
                    if obj.chosenRow < 1
                       obj.chosenRow = size(obj.inputMatrix, 1);
                    end
                elseif strcmp(event.Key, 'downarrow')
                    obj.chosenRow = obj.chosenRow + 1;
                    if obj.chosenRow > size(obj.inputMatrix, 1);
                       obj.chosenRow = 1;
                    end
                end
                obj.updateCorrelationPlots();
            end
        end

        function changeScreenMode(obj, source)

            obj.changeScreenMode@GUIs.base(source);

            if strcmp(get(source, 'State'), 'on')
                % on
                set(obj.hSamplesSliderText, 'Visible', 'on');
                set(obj.hSamplesSlider, 'Visible', 'on');
                set(obj.hVideoSamplesSliderText, 'Visible', 'on');
                set(obj.hVideoSamplesSlider, 'Visible', 'on');
            else
                % off
                set(obj.hSamplesSliderText, 'Visible', 'off');
                set(obj.hSamplesSlider, 'Visible', 'off');
                set(obj.hVideoSamplesSliderText, 'Visible', 'off');
                set(obj.hVideoSamplesSlider, 'Visible', 'off');
            end
            
        end
    end
end 

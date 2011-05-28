classdef Correlation < GUIs.base
%CORRELATION Summary of this class goes here
%   Detailed explanation goes here

    properties
        hMotionCorrelationPanel
        hImageAxes
        hSpatialCorrelationAxes
        hSpatialInfo

        hImage
        chosenRow
        hChosenLine

        hVideoSelect
        hTemporalCorrelationAxes
        hVideoAxes
        hVideo
        hVideoInfo

        videoEncoder
        chosenVideoPoint
    end

    methods
        function obj = Correlation()
            obj = obj@GUIs.base('Spatial Correlation');

            obj.chosenRow = 1;
            obj.chosenVideoPoint = [1 1];

            % Show input image selection
            obj.createInputImageSelectComboBoxAndText([0.02 0.96 0.25 0.03], [0.02 0.90 0.2 0.03]);
            obj.hVideoSelect = uicontrol('Style', 'pushbutton', 'String', 'Random Image',...
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

            obj.hMotionCorrelationPanel = uipanel('FontSize', 12,  ...
                            'FontName', 'Courier', ...
                            'BackgroundColor', 'white', ...
                            'Units', 'Normalized', ...
                            'Position', [0.0 .01 1.0 .47]);
            obj.createTextElement([0.0 .93 1.0 0.07], ' Temporal Correlation', 15, true, [.8 .8 .8], obj.hMotionCorrelationPanel);
            obj.hTemporalCorrelationAxes = axes('Parent', obj.hMotionCorrelationPanel, 'Position', [0.4 0.15 0.54 0.65]);
            set(get(obj.hTemporalCorrelationAxes,'XLabel'),'String','Offset in Time (Frames)');
            set(get(obj.hTemporalCorrelationAxes,'YLabel'),'String','Correlation');
            obj.hVideoInfo = obj.createTextElement([0.35 0.85 0.4 0.07], ['Chosen Pixel: (' num2str(obj.chosenVideoPoint(1)) ',' num2str(obj.chosenVideoPoint(2)) ')'], 12, 'on', 'white', obj.hMotionCorrelationPanel);
            obj.hVideoAxes = obj.createAxesForImage([0.01 0.1 0.3 0.71], obj.hMotionCorrelationPanel);
            obj.hVideoSelect = uicontrol('Style', 'pushbutton', 'String', 'Load Video',...
                                        'Parent', obj.hMotionCorrelationPanel,...
                                        'Units', 'Normalized', ...
                                        'Position', [0.01 0.82 0.15 0.07],...
                                        'Callback', @(src,evt)obj.videoLoad);
            obj.hVideoSelect = uicontrol('Style', 'pushbutton', 'String', 'Play',...
                                        'Parent', obj.hMotionCorrelationPanel,...
                                        'Units', 'Normalized', ...
                                        'Position', [0.16 0.82 0.15 0.07],...
                                        'Callback', @(src,evt)obj.videoPlay);
            obj.createTextElement([0.01 0.01 0.4 0.06], 'Click to select a pixel for the correlation plot.', 9, 'on', 'white', obj.hMotionCorrelationPanel);    
        end

        function videoLoad(obj)
            obj.videoEncoder = Video.encoder('examples/imseq/vid:0000:0025:.jpg');
            obj.videoPlay();
        end

        function changeInput(obj, source)
            % Call super class implementation which does the loading etc
            obj.changeInput@GUIs.base(source);
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
            coefs = xcorr(data, length(data));
            %coefs = autocorr(data(obj.chosenRow,:,1), size(data,2)-1);
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

        function imageClick(obj, source)
           % handle input / output image clicks
            if ~isempty(obj.inputMatrix)
                selectedPoint = floor(get(obj.hImageAxes, 'CurrentPoint'));
                obj.chosenRow = selectedPoint(1,2);
                obj.updateCorrelationPlots();
            end
        end

        function videoClick(obj, source)
           % handle input / output image clicks
            if ~isempty(obj.videoEncoder.imageMatrix)
                obj.chosenVideoPoint = floor(get(obj.hVideoAxes, 'CurrentPoint'));
                obj.chosenVideoPoint = obj.chosenVideoPoint(1,:);
            end
        end

        function videoPlay(obj, source)
            data = zeros(1,size(obj.videoEncoder.imageMatrix,4));
            for i=1:size(obj.videoEncoder.imageMatrix,4)
                obj.hVideo = imshow(obj.videoEncoder.imageMatrix(:,:,1,i), 'Parent', obj.hVideoAxes);
                set(obj.hVideo, 'ButtonDownFcn', @(source, evt)(obj.videoClick(source)));
                data(1,i) = obj.videoEncoder.imageMatrix(obj.chosenVideoPoint(2),obj.chosenVideoPoint(1),1,i);
                coefs = xcorr(data, i);
                %plot(obj.hTemporalCorrelationAxes, coefs(ceil(length(coefs)/2):end));
                plot(obj.hTemporalCorrelationAxes, coefs(ceil(length(coefs)/2):end));
                xlim(obj.hTemporalCorrelationAxes, [1 size(obj.videoEncoder.imageMatrix,4)]);
                set(get(obj.hTemporalCorrelationAxes,'XLabel'),'String','Offset in Time (Frames)');
                set(get(obj.hTemporalCorrelationAxes,'YLabel'),'String','Correlation');
                set(obj.hVideoInfo, 'String', ['Chosen Pixel: (' num2str(obj.chosenVideoPoint(1)) ',' num2str(obj.chosenVideoPoint(2)) ')']);
                pause(0.1);
            end 
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
    end
end 

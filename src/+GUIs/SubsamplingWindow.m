classdef SubsamplingWindow < GUIs.base
%SUBSAMPLINGWINDOW Summary of this class goes here
%   Detailed explanation goes here

   properties
       
       hChannelSelect
       hChannelSelectText
       hInterpolationSelect
       hInterpolationSelectText
       hInputImageSelect
       hInputImageSelectText
       hSubsampleModeSelect
       hShowChannelUpsampledCheckBox
       
       %hInputImageAxes
       hInputImage
       hSubsampledImageAxes
       hSubsampledImage
       hShownImage
       
       hSelectedBlockPanel
       hSubsamplingModeImageAxes

       lastClickedBlockX
       lastClickedBlockY
       
       defaultSubsamplingMode
       subsamplingMode
       interpolationMode
       showChannelInColour
       upsampleImage
       channelToShow
   end

   methods
        function obj = SubsamplingWindow(fileName)
           
            obj = obj@GUIs.base('Subsampling: Utilising Perceptual Redundancy');
           
            if exist('fileName', 'var')
                %throw(MException('TransformWindow:TransformWindow', 'You must pass in the instance of the JPEG encoder.'));
               
                % Load from file
            end

            % default modes
            %obj.subsamplingMode = {'4:4:4' '4:2:2' '4:2:0'}; 
            obj.defaultSubsamplingMode = [1 3 6];
            obj.channelToShow = 'all';
            obj.interpolationMode = 'nearest';
            obj.upsampleImage = {true true true};
            obj.showChannelInColour = true;
                       

           % Input image select Combo box
           obj.hInputImageSelectText = uicontrol('Parent', obj.hExternalPanel, ...
                                        'Style', 'text', ...
                                        'String', 'Input Image:', ...
                                        'Units', 'Normalized', ...
                                        'HorizontalAlignment', 'left', ...
                                        'Position', [0.06 0.91 0.3 0.07], ...
                                        'Fontsize', 11, ...
                                        'FontName', 'Courier New',...
                                        'BackgroundColor', 'white');

           obj.hInputImageSelect = uicontrol('Style', 'popupmenu', ...
                                        'Parent', obj.hExternalPanel, ...
                                        'FontSize', 11, ...
                                        'FontName', 'Courier New',...
                                        'Units', 'Normalized', ...
                                        'Position',[0.06 0.87 0.2 0.08],...
                                        'String', 'a|b|c',...
                                        'Callback', @(source, event)(obj.changeInputOnDisplay(source)));
           p = getpixelposition(obj.hInputImageSelect);
           setpixelposition(obj.hInputImageSelect, [p(1) p(2) 200 50]);
           
           obj.populateExampleImagesFromExamplesDirectory();
                                    
           % Popup: Channel Selection
           obj.hChannelSelectText = uicontrol('Parent', obj.hExternalPanel, ...
                                        'Style', 'text', ...
                                        'String', 'Channel type to show:', ...
                                        'Units', 'Normalized', ...
                                        'HorizontalAlignment', 'left', ...
                                        'Position', [0.4 0.91 0.3 0.07], ...
                                        'Fontsize', 11, ...
                                        'FontName', 'Courier New',...
                                        'BackgroundColor', 'white');
                    
           obj.hChannelSelect = uicontrol('Style', 'popupmenu', ...
                                        'Parent', obj.hExternalPanel, ...
                                        'FontSize', 11, ...
                                        'FontName', 'Courier New',...
                                        'Units', 'Normalized', ...
                                        'Position',[0.4 0.87 0.2 0.08],...
                                        'String', 'All Channels/Whole Colour Image (Y+Cb+Cr Channels)|Luminance (Y Channel)|Chroma/Colour (Cb Channel)|Chroma/Colour (Cr Channel)',...
                                        'Callback', @(source, event)(obj.changeChannelOnDisplay(source)));
           p = getpixelposition(obj.hChannelSelect);
           setpixelposition(obj.hChannelSelect, [p(1) p(2) 200 50]);
           
           
           % Popup: Filter Selection
           obj.hInterpolationSelectText = uicontrol('Parent', obj.hExternalPanel, ...
                                        'Style', 'text', ...
                                        'String', 'Interpolation for upsample:', ...
                                        'Units', 'Normalized', ...
                                        'Position', [0.71 0.91 0.28 0.07], ...
                                        'HorizontalAlignment', 'left', ...
                                        'Fontsize', 10, ...
                                        'FontName', 'Courier New',...
                                        'Visible', 'off', ...
                                        'BackgroundColor', 'white');

           obj.hInterpolationSelect = uicontrol('Style', 'popupmenu', ...
                                        'Parent', obj.hExternalPanel, ...
                                        'FontSize', 11, ...
                                        'FontName', 'Courier New',...
                                        'Units', 'Normalized', ...
                                        'Position',[0.71 0.87 0.2 0.08],...
                                        'String', {'Nearest neighbour' 'Bilinear' 'Bicubic'},...
                                        'Visible', 'off', ...
                                        'Callback', @(source, event)(obj.changeInterpolationMode(source)));
           p = getpixelposition(obj.hInterpolationSelect);
           setpixelposition(obj.hInterpolationSelect, [p(1) p(2) 200 50]);
           
           % selected block panel
           obj.hSelectedBlockPanel = uipanel('Title', 'Subsampled chroma for selected block (click on image to select):', ...
                                       'Parent', obj.hExternalPanel, ...
                                        'FontSize', 10,  ...
                                        'FontName', 'Courier', ...
                                        'BackgroundColor', 'white', ...
                                        'Units', 'Normalized', ...
                                        'Visible', 'off', ...
                                        'Position', [.01 .01 .98 .25]);
           
            %hCMZ = uicontextmenu;
            %hZMenu = uimenu('Parent',hCMZ,'Label','Switch to pan','Callback','pan(gcbf,''on'')');
            for i=1:3
                obj.hSubsampledImageAxes{i} = axes('Parent', obj.hExternalPanel, ...
                                        'Box', 'on', ...
                                        'Visible', 'on', ...
                                        'XTick', [],...
                                        'YTick', [],...
                                        ... %'UIContextMenu',hCMZ, ...
                                        'Units', 'Normalized', ...
                                        'Position', [((0.33*(i-1))+.01) .35 .32 .5]);

                % Draw initial image placeholder
                axis([0 1 0 1]);
                line([0 1], [1 0], 'LineWidth',1,'Color',[.8 .8 .8]);
                line([0 1], [0 1], 'LineWidth',1,'Color',[.8 .8 .8]);
                
                % Subsampling mode images
                arrayfun(@(c, text)(uicontrol('Parent', obj.hSelectedBlockPanel, ...
                                        'Style', 'text', ...
                                        'String', text, ...
                                        'Units', 'Normalized', ...
                                        'HorizontalAlignment', 'left', ...
                                        'Position', [((0.34*(i-1))+(.01+(floor(c/3)*.15))) (.38+(rem(c+1,2)*.5)) .14 .1], ...
                                        'Fontsize', 11, ...
                                        'FontName', 'Courier New',...
                                        'BackgroundColor', 'white')), [1:4], { 'cb' 'block' 'cr' 'samples'},'UniformOutput', false);

                obj.hSubsamplingModeImageAxes{i} = arrayfun(@(c)(...
                                    axes('Parent', obj.hSelectedBlockPanel, ...
                                        'Box', 'on', ...
                                        'Visible', 'on', ...
                                        'XTick', [],...
                                        'YTick', [],...
                                        'Units', 'Normalized', ...
                                        'Position', [((0.34*(i-1))+(.01+(floor(c/3)*.15))) (.05+(rem(c+1,2)*.5)) .14 .31]) ...
                                    ), [1:4],'UniformOutput', false);
            end
            
            linkaxes(cell2mat(obj.hSubsampledImageAxes), 'xy');


           for i=1:3
               h = uicontrol('Parent', obj.hExternalPanel, ...
                                        'Style', 'text', ...
                                        'String', 'Subsampling Mode:', ...
                                        'Units', 'Normalized', ...
                                        'HorizontalAlignment', 'left', ...
                                        'Position', [((0.33*(i-1))+0.01) 0.3 0.2 0.03], ...
                                        'Fontsize', 10, ...
                                        'FontName', 'Courier New',...
                                        'BackgroundColor', 'white');
               p = getpixelposition(h);
               setpixelposition(h, [p(1) p(2) 180 30]);

               obj.hSubsampleModeSelect{i} = uicontrol('Style', 'popupmenu', ...
                                        'Parent', obj.hExternalPanel, ...
                                        'FontSize', 10, ...
                                        'FontName', 'Courier New',...
                                        'Units', 'Normalized', ...
                                        'Position',[((0.33*(i-1))+0.01) 0.26 0.2 0.08],...
                                        'Value', obj.defaultSubsamplingMode(i), ...
                                        'String', obj.subsamplingModes(),...
                                        'Callback', @(source, event)(obj.changeSubsamplingModeForImage(source)));
               p = getpixelposition(obj.hSubsampleModeSelect{i});
               setpixelposition(obj.hSubsampleModeSelect{i}, [p(1) p(2) 100 30]);
               
               % update combos
               obj.changeSubsamplingModeForImage(obj.hSubsampleModeSelect{i});
               
               obj.hShowChannelUpsampledCheckBox{i} = uicontrol('Style', 'checkbox', ...
                                        'Parent', obj.hExternalPanel, ...
                                        'FontSize', 9, ...
                                        'FontName', 'Courier New',...
                                        'Units', 'Normalized', ...
                                        'Position',[((0.33*(i-1))+0.15) 0.26 0.2 0.08],...
                                        'String', 'Show upsampled?',...
                                        'Value', 1,...
                                        'Enable','off',...
                                        'Callback', @(source, event)(obj.toggleShowImageWithUpsampling(source)));
               p = getpixelposition(obj.hShowChannelUpsampledCheckBox{i});
               setpixelposition(obj.hShowChannelUpsampledCheckBox{i}, [p(1) p(2) 200 30]);

           end
           
           %obj.changeInputOnDisplay(obj.hInputImageSelect);
           
           % Give keyboard focus to image select element
           uicontrol(obj.hInputImageSelect);
       end

        function changeScreenMode(obj, source)

            if strcmp(get(source, 'State'), 'on')
                % on
                set(obj.hInterpolationSelect, 'Visible', 'on');
                set(obj.hInterpolationSelectText, 'Visible', 'on');
                set(obj.hSelectedBlockPanel, 'Visible', 'on');
                set(source, 'CData', imresize(imread('+GUIs/images/icons/cancel_48.png','BackgroundColor',[1 1 1]), [16 16]));
            else
                % off
                set(obj.hInterpolationSelect, 'Visible', 'off');
                set(obj.hInterpolationSelectText, 'Visible', 'off');
                set(obj.hSelectedBlockPanel, 'Visible', 'off');
                set(source, 'CData', imresize(imread('+GUIs/images/icons/add_48.png','BackgroundColor',[1 1 1]), [16 16]));
            end
        end
       
       function imageClick(obj, source)
           % handle input / output image clicks
            if ~isempty(obj.inputMatrix)
                
                % TODO: urg for loops

                for i=1:length(obj.hShownImage)
                    if source == obj.hShownImage{i}
                        selectedPoint = get(obj.hSubsampledImageAxes{i}, 'CurrentPoint');
                        obj.lastClickedBlockX = (floor((selectedPoint(1,1)-1) / 4)*4) + 1;
                        obj.lastClickedBlockY = (floor((selectedPoint(1,2)-1) / 2)*2) + 1;
                        break;
                    end
                end
                obj.updateSubsampleViews();
            end               
       end
       
       function updateSubsampleViews(obj)
            for i=1:length(obj.hShownImage)
                if ~isempty(obj.lastClickedBlockX) && ~isempty(obj.lastClickedBlockY)
                    %Subsampling.subsampledImageShow(obj.imageStruct{i}, 'Parent', obj.hSubsamplingModeImageAxes{i}{4}, ...
                    %                                'Channel', 'y', 'Block', [bx by 4 2], 'Interpolation', obj.interpolationMode);
                    imshow([1 1 1 1; 1 1 1 1], 'Parent', obj.hSubsamplingModeImageAxes{i}{4});
                    % Draw rectangles for mode
                    
                    % FIXME
                    
                    [ yHi yVi cbHi cbVi crHi crVi ] = Subsampling.modeToHorizontalAndVerticalSamplingFactors(obj.imageStruct{i}.mode);

                    mHi = max([yHi cbHi crHi]);
                    mVi = max([yVi cbVi crVi]);

                    X = [1:mHi:4];%((samplesPerHorizontalDistance - 1)*2)+1];
                    Y = [1:mVi:2];
                    %coordinatesOfRects = meshgrid(X, Y)
                    %if coordinatesOfRects == 1
                    %    coordinatesOfRects = [1 1];
                    %end
                    coordinatesOfRects = [];
                    cnt = 1;
                    for l = 1:length(Y)
                        for k = 1:length(X)
                            coordinatesOfRects(cnt, :) = [X(k) Y(l)];
                            cnt = cnt + 1;
                        end
                    end

                    positionsLuminance = {[0.5 0.5 4 2]};

                    positionsChroma = arrayfun(@(x, y)([x-0.4 y-0.4 mHi-0.2 mVi-0.2]), coordinatesOfRects(:,1), coordinatesOfRects(:,2), 'UniformOutput', false);

                    cellfun(@(r)(rectangle('EdgeColor', [0 0 0], 'LineWidth', 0.5, 'Parent', obj.hSubsamplingModeImageAxes{i}{4}, 'Position', r)), ...
                                positionsLuminance);
                    cellfun(@(r)(rectangle('EdgeColor', [0 0 0.7], 'LineWidth', 0.5, 'Parent', obj.hSubsamplingModeImageAxes{i}{4}, 'Position', r)), ...
                                positionsChroma);
                    cellfun(@(r)(rectangle('EdgeColor', [0 0.7 0], 'LineWidth', 0.5, 'Parent', obj.hSubsamplingModeImageAxes{i}{4}, 'Position', r)), ...
                                cellfun(@(arr)([arr(1)+0.1 arr(2)+0.1 arr(3)-0.2 arr(4)-0.2]), positionsChroma,'UniformOutput', false));


                    Subsampling.subsampledImageShow(obj.imageStruct{i}, 'Parent', obj.hSubsamplingModeImageAxes{i}{1}, ...
                                                    'Channel', 'cb',  'Block', [obj.lastClickedBlockX obj.lastClickedBlockY 4 2], ...
                                                    'Interpolation', obj.interpolationMode, 'ColourDisplay', obj.showChannelInColour);
                    Subsampling.subsampledImageShow(obj.imageStruct{i}, 'Parent', obj.hSubsamplingModeImageAxes{i}{3}, ...
                                                    'Channel', 'cr', 'Block', [obj.lastClickedBlockX obj.lastClickedBlockY 4 2], ...
                                                    'Interpolation', obj.interpolationMode, 'ColourDisplay', obj.showChannelInColour);
                    Subsampling.subsampledImageShow(obj.imageStruct{i}, 'Parent', obj.hSubsamplingModeImageAxes{i}{2}, ...
                                                    'Channel', 'all', 'Block', [obj.lastClickedBlockX obj.lastClickedBlockY 4 2], ...
                                                    'Interpolation', obj.interpolationMode, 'ColourDisplay', obj.showChannelInColour);
                end
            end
       end
       
       function modes = subsamplingModes(obj)
           modes = {'4:4:4' '4:4:0' '4:2:2' '4:2:0' '4:1:1' '4:1:0'};
       end
       
       function changeSubsamplingModeForImage(obj, source)
           for i=1:length(obj.hSubsampleModeSelect)
               if source == obj.hSubsampleModeSelect{i}
                    strings = get(source, 'String');
                    obj.subsamplingMode{i} = strings{get(source, 'Value')};
                    break;
               end
           end
           
           obj.doSubsamplingOnImageMatrix();
           obj.updateAxes();
       end
       
       function changeInputOnDisplay(obj, source)
           files = get(source, 'String');
           fileName = fullfile('exampleImages', files{get(source, 'Value')});
           imageRGB = imread(fileName);
           
            if isempty(imageRGB)
                throw(MException('SubsamplingWindow:changeInputOnDisplay', 'The specified file could not be opened. It maybe corrupt or have been removed.'));
            end

            if isempty(obj.channelToShow)
                % Set a default
                obj.channelToShow = 'all';
            end
            
            obj.inputMatrix = rgb2ycbcr(imageRGB);
            
            obj.doSubsamplingOnImageMatrix();
            obj.updateAxes();
       end
       
       function changeChannelOnDisplay(obj, source)
            selected = get(source, 'Value');
            switch(selected)
                case 1
                    obj.channelToShow = 'all';
                case 2
                    obj.channelToShow = 'y';
                case 3
                    obj.channelToShow = 'cb';
                case 4
                    obj.channelToShow = 'cr';
            end
            
            obj.updateShowUpsampledCheckBoxStatus();
            
            obj.updateAxes();
       end
       
        function toggleShowImageWithUpsampling(obj, source)
            if ~isempty(obj.inputMatrix)
                for i=1:length(obj.hShowChannelUpsampledCheckBox)
                    if source == obj.hShowChannelUpsampledCheckBox{i}
                        if get(obj.hShowChannelUpsampledCheckBox{i}, 'Value')
                            
                            obj.upsampleImage{i} = true;
                            
                            %get(obj.hSubsampledImageAxes{i}, 'XLim')
                            %get(obj.hSubsampledImageAxes{i}, 'YLim')
                            %set(obj.hSubsampledImageAxes{i}, 'XLimMode', 'auto');
                            
                            obj.updateAxes();
                        else

                            obj.upsampleImage{i} = false;
                            obj.updateAxes();
                            % update the settings for the axis
                            %get(obj.hSubsampledImageAxes{i}, 'XLim')
                            set(obj.hSubsampledImageAxes{i}, 'XLimMode', 'manual', 'YLimMode', 'manual', 'XLim', [1 size(obj.inputMatrix, 2)], 'YLim', [1 size(obj.inputMatrix, 1)]);
                            axis(obj.hSubsampledImageAxes{i}, 'image');
                        
                        end
                        break;
                    end
                end

                
            end
        end
       
        function updateShowUpsampledCheckBoxStatus(obj)
            if strcmp(obj.channelToShow, 'all')
                % disable
                enabled = 'off';
            else
                % enable
                enabled = 'on';
            end
            
            for i=1:length(obj.hShowChannelUpsampledCheckBox)
                set(obj.hShowChannelUpsampledCheckBox{i}, 'Enable', enabled);
            end
        end
       
        function changeInterpolationMode(obj, source)
            switch get(source, 'Value')
                case 1
                    obj.interpolationMode = 'nearest';
                case 2
                    obj.interpolationMode = 'bilinear';
                case 3
                    obj.interpolationMode = 'bicubic';
            end
           
            obj.updateAxes();
        end
       
       function doSubsamplingOnImageMatrix(obj)
            if ~isempty(obj.inputMatrix)
                for i=1:length(obj.subsamplingMode)
                    obj.imageStruct{i} = Subsampling.ycbcrImageToSubsampled(obj.inputMatrix, 'Mode', obj.subsamplingMode{i});
                end
            end
       end

       function updateAxes(obj)
           for i=1:length(obj.imageStruct)
                if obj.upsampleImage{i}
                    obj.hShownImage{i} = Subsampling.subsampledImageShow(obj.imageStruct{i}, 'Parent', obj.hSubsampledImageAxes{i}, ...
                        'Channel', obj.channelToShow, 'Interpolation', obj.interpolationMode, 'ColourDisplay', obj.showChannelInColour);
                else
                    obj.hShownImage{i} = imshow(obj.imageStruct{i}.(obj.channelToShow), 'Parent', obj.hSubsampledImageAxes{i});
                end
                set(obj.hShownImage{i}, 'ButtonDownFcn', @(source, evt)(obj.imageClick(source)));
           end
           
           obj.updateSubsampleViews();
       end

       function populateExampleImagesFromExamplesDirectory(obj)
           examples = struct2cell([dir('exampleImages/*.bmp') dir('exampleImages/*.jpg') dir('exampleImages/*.png')]);
           set(obj.hInputImageSelect, 'String', examples(1,:));
       end
   end
end 

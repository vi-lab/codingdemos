classdef base < handle
%BASE The base GUI class.
%
%   +GUIs/base.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   This class encapsulates the common functionality and behaviours for all
%   demo screens. All GUIs should inherit from this. Some common
%   functionality is implemented in some callbacks that can be extended or
%   overridden.
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

   properties
       hMainWindow
       hMainToolbar
       hToolbarPanButton
       hToolbarZoomButton

       windowSize

       hExternalPanel
       hButtonHome
       hButtonBackUp
       hButtonNext
       hButtonAdvancedMode

       hInputImageSelectText
       hInputImageSelect

       examplesDirectory

       inputMatrix
       imageStruct
       channelToShow
   end

   methods
        function obj = base(panelTitle, examplesDirectory)
            % ----------------------------
            % Constructor for Demo Screens
            % ----------------------------
            %
            % Initialises the screen with a common toolbar and title box.
            % The main containing panel for the screen is also created.

            if ~exist('examplesDirectory', 'var')
                obj.examplesDirectory = 'examples/';
            else
                obj.examplesDirectory = examplesDirectory;
            end

            scrsz = get(0, 'ScreenSize');
            obj.windowSize = scrsz;
            obj.hMainWindow = figure('Position', [1 scrsz(4)/1 scrsz(3)*0.75 scrsz(3)*0.75], 'Color', [1 1 1], 'KeyPressFcn', @(src,evt)(obj.handleKeyPress(src,evt)), 'CloseRequestFcn', @(src,evt)(obj.handleCloseRequest(src,evt)));

            screensInOrder = GUIs.order;

            className = regexp(class(obj), '\.', 'split');
            screenID = strmatch(className{2}, screensInOrder);
            if isempty(screenID)
                close(obj.hMainWindow);
                throw(MException('GUIsbase:constructor', ['The required screen named ''' className{2} ''' cannot be found in the order matrix (see ''GUIs.order'').']));
            end
            prevID = screenID - 1;
            if prevID < 1
                prevID = length(screensInOrder);
            end
            nextID = screenID + 1;
            if nextID > length(screensInOrder)
                nextID = 1;
            end
            % Hide Standard Toolbar
            set(obj.hMainWindow,'Toolbar','none');
            % Custom Toolbar
            obj.hMainToolbar = uitoolbar( obj.hMainWindow );
            icon = imresize(imread('+GUIs/images/icons/home_48.png','BackgroundColor',[1 1 1]), [16 16]);
            obj.hButtonHome = uipushtool(obj.hMainToolbar,'CData',icon,'TooltipString','Back to Home Screen.',...
                                                    'ClickedCallback', @(source, event)(obj.changeScreen(screensInOrder{1})));

            icon = imresize(imread('+GUIs/images/icons/arrow_left_green_48.png','BackgroundColor',[1 1 1]), [16 16]);
            obj.hButtonBackUp = uipushtool(obj.hMainToolbar,'CData',icon,'TooltipString','Back to previous Screen.',...
                                                    'ClickedCallback', @(source, event)(obj.changeScreen(screensInOrder{prevID})));

            icon = imresize(imread('+GUIs/images/icons/arrow_right_green_48.png','BackgroundColor',[1 1 1]), [16 16]);
            obj.hButtonNext = uipushtool(obj.hMainToolbar,'CData',icon,'TooltipString','To next Screen.', ...
                                                    'ClickedCallback', @(source, event)(obj.changeScreen(screensInOrder{nextID})));

            icon = imresize(imread('+GUIs/images/icons/add_48.png','BackgroundColor',[1 1 1]), [16 16]);
            obj.hButtonAdvancedMode = uitoggletool(obj.hMainToolbar,'CData',icon,'TooltipString','Toggle Advanced options...', ...
                                                    'Separator','on', ...
                                                    'ClickedCallback', @(source, event)(obj.changeScreenMode(source)));
            icon = imresize(imread('+GUIs/images/icons/search_48.png','BackgroundColor',[1 1 1]), [16 16]);
            obj.hToolbarZoomButton = uitoggletool(obj.hMainToolbar,'CData',icon,'TooltipString','Switch to and from zoom mode', ...
                                                    'Separator','on', ...
                                                    'ClickedCallback', @(source, event)(obj.changeZoomMode(source)));
            icon = imresize(imread('+GUIs/images/icons/mouse_48.png','BackgroundColor',[1 1 1]), [16 16]);
            obj.hToolbarPanButton = uitoggletool(obj.hMainToolbar,'CData',icon,'TooltipString','Switch to and from pan mode', ...
                                                    'ClickedCallback', @(source, event)(obj.changePanMode(source)));

            icon = imresize(imread('+GUIs/images/icons/refresh_48.png','BackgroundColor',[1 1 1]), [16 16]);
            uitoggletool(obj.hMainToolbar,'CData',icon,'TooltipString','Reset window', ...
                                                    'Separator','on', ...
                                                    'ClickedCallback', @(source, event)(obj.resetWindow(source)));

            % external panel
            obj.hExternalPanel = uipanel('FontSize', 15,  ...
                                        'FontName', 'Courier', ...
                                        'BackgroundColor', 'white', ...
                                        'Units', 'Normalized', ...
                                        'Position', [0.0 .01 1.0 .95]);

            obj.createTextElement([0.0 .96 1.0 0.035], [' ' panelTitle], 15, true, [.8 .8 .8], obj.hMainWindow);

        end

        function handle = createTextElement(obj, position, text, fontSize, visible, backgroundColor, parent)
            % ---------------------
            % Create a text element
            % ---------------------
            %
            % Instantiates a text style uicontrol. The 'position' and
            % 'text' parameters are mandatory but the rest are optional.
            % Parameters:
            %   * position: a position vector in normalised units
            %   * text: the string to display
            %   * fontSize (optional): the size of the font
            %   * visible (optional): a boolean indicating visible state
            %   * backgroundColor (optional): the element background colour
            %   * parent (optional): the parent object handle

            if ~exist('backgroundColor', 'var')
                backgroundColor = 'white';
            end
            if ~exist('fontSize', 'var')
                fontSize = 11;
            end
            if ~exist('parent', 'var')
                parent = obj.hExternalPanel;
            end
            if ~exist('visible', 'var')
                visible = 'on';
            else
                if visible
                    visible = 'on';
                else
                    visible = 'off';
                end
            end
            handle = uicontrol('Parent', parent, ...
                                'Visible', visible, ...
                                'Style', 'text', ...
                                'String', text, ...
                                'Units', 'Normalized', ...
                                'HorizontalAlignment', 'left', ...
                                'Position', position, ...
                                'BackgroundColor', backgroundColor,...
                                'Fontsize', fontSize, ...
                                'FontName', 'Courier New');
        end

        function createInputImageSelectComboBoxAndText(obj, textPosition, position, examplesDirectory)
            % ---------------------------------------------------
            % Create a combobox with images in examples directory
            % ---------------------------------------------------
            %
            % Create a drop down (popupmenu) style uicontrol populated
            % with the image file names in the examples folder.
            % Parameters:
            %   * textPosition: the position of the partner text element in
            %   normalised units.
            %   * position: the position of the dropdown in normalised
            %   units
            %   * examplesDirectory (optional): the location of the
            %   examples

            if exist('examplesDirectory', 'var')
                obj.examplesDirectory = examplesDirectory;
            end

            obj.hInputImageSelectText = obj.createTextElement(textPosition, 'Input Image:');

            obj.hInputImageSelect = uicontrol('Style', 'popupmenu', ...
                                        'Parent', obj.hExternalPanel, ...
                                        'FontSize', 11, ...
                                        'FontName', 'Courier New',...
                                        'Units', 'Normalized', ...
                                        'Position', position,...
                                        'String', 'a|b|c',...
                                        'Callback', @(source, event)(obj.changeInput(source)));
            p = getpixelposition(obj.hInputImageSelect);
            setpixelposition(obj.hInputImageSelect, [p(1) p(2) 200 50]);
            set(obj.hInputImageSelect, 'String', obj.getExampleImagesFromExamplesDirectory());
        end

        function ax = createAxesForImage(obj, position, parent)
            % ---------------------------------
            % Create a set of axes for an image
            % ---------------------------------
            %
            % Create an axes at the given location with no ticks, a box,
            % and a X shape holding contents.
            % Parameters:
            %   * position: the position of the element in normalised units
            %   * parent (optional): the parent handle, defaults to the
            %   external panel

            if ~exist('parent', 'var')
                parent = obj.hExternalPanel;
            end
            container = uipanel('Parent', parent, 'BackgroundColor', [.8 .8 .8], ...
                                        'Units', 'Normalized', ...
                                        'Position', position);
            ax = axes('Parent', container, ...
                                        'Box', 'on', ...
                                        'Visible', 'on', ...
                                        'XTick', [],...
                                        'YTick', [],...
                                        'Units', 'Normalized', ...
                                        'Position', [0 0 1 1]);

            % Draw initial image placeholder
            axis([0 1 0 1]);
            line([0 1], [1 0], 'LineWidth',1,'Color',[.8 .8 .8]);
            line([0 1], [0 1], 'LineWidth',1,'Color',[.8 .8 .8]);
        end

        function changeInput(obj, source)
            % ---------------------------------------------
            % Default callback for the input image combobox
            % ---------------------------------------------
            %
            % The default callback gets the selected file and opens it from
            % the examples directory and sets the 'inputMatrix' instance
            % variable to the resulting YCbCr image.

            files = get(source, 'String');
            fileName = fullfile(obj.examplesDirectory, files{get(source, 'Value')});
            imageRGB = imread(fileName);

            if isempty(imageRGB)
                throw(MException('GUIsBase:changeInputOnDisplay', 'The specified file could not be opened. It maybe corrupt or have been removed.'));
            end

            if isempty(obj.channelToShow)
                % Set a default
                obj.channelToShow = 'all';
            end

            obj.inputMatrix = rgb2ycbcr(imageRGB);
        end

        function changeZoomMode(obj, source)
            % -----------------------------------------------
            % Default callback for toolbar zoom toggle button
            % -----------------------------------------------
            %
            % By default pan mode is disabled if it is on and zoom mode is
            % toggled.

            if strcmp(get(source, 'State'), 'on')
                % on
                if strcmp(get(obj.hToolbarPanButton, 'State'), 'on')
                    set(obj.hToolbarPanButton, 'State', 'off');
                    obj.changePanMode(obj.hToolbarPanButton);
                end
                zoom('on');
                set(source, 'CData', imresize(imread('+GUIs/images/icons/search_48.png','BackgroundColor',[0 0 0]), [16 16]));
            else
                % off
                zoom('off');
                set(source, 'CData', imresize(imread('+GUIs/images/icons/search_48.png','BackgroundColor',[1 1 1]), [16 16]));
            end
        end

        function changePanMode(obj, source)
            % ----------------------------------------------
            % Default callback for toolbar pan toggle button
            % ----------------------------------------------
            %
            % By default zoom mode is disabled if it is on and pan mode is
            % toggled.

            if strcmp(get(source, 'State'), 'on')
                % on
                if strcmp(get(obj.hToolbarZoomButton, 'State'), 'on')
                    set(obj.hToolbarZoomButton, 'State', 'off');
                    obj.changeZoomMode(obj.hToolbarZoomButton);
                end
                pan('on');
                set(source, 'CData', imresize(imread('+GUIs/images/icons/mouse_48.png','BackgroundColor',[0 0 0]), [16 16]));
            else
                % off
                pan('off');
                set(source, 'CData', imresize(imread('+GUIs/images/icons/mouse_48.png','BackgroundColor',[1 1 1]), [16 16]));
            end
        end

        function changeScreenMode(obj, source)
            % ------------------------------------------------------
            % Default callback for toolbar screen mode toggle button
            % ------------------------------------------------------
            %
            % Toggles state of advanced mode button. NOTE: this should be
            % extended to enable/disable/show/hide the necessary elements
            % for the given screen.

            if strcmp(get(source, 'State'), 'on')
                % on
                % Override and add your code here
                set(source, 'CData', imresize(imread('+GUIs/images/icons/add_48.png','BackgroundColor',[0 0 0]), [16 16]));
            else
                % off
                % Override and add your code here
                set(source, 'CData', imresize(imread('+GUIs/images/icons/add_48.png','BackgroundColor',[1 1 1]), [16 16]));
            end
        end

        function fileNames = getExampleImagesFromExamplesDirectory(obj)
            % -------------------
            % List example images
            % -------------------
            %
            % Returns a cell array of filenames from the examples directory
            % for images of type BMP, PNG and JPG.

            examples = struct2cell([dir(fullfile(obj.examplesDirectory, '*.bmp')); dir(fullfile(obj.examplesDirectory, '*.jpg')); dir(fullfile(obj.examplesDirectory, '*.png'))]);
            fileNames = examples(1,:);
        end

        function changeScreen(obj, screenName)
            % -----------------------------------------------
            % Default callback for navigation toolbar buttons
            % -----------------------------------------------
            %
            % By default the desired screen name (fully qualified, ie. with
            % package name) is passed and executed and the current window
            % is closed.
            GUIs.(screenName)();
            close(obj.hMainWindow);
        end

        function handleKeyPress(obj, source, event)
        end

        function handleCloseRequest(obj, source, event)
        end
   end
end

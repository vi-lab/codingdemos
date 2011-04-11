classdef base < handle
%BASE Summary of this class goes here
%   Detailed explanation goes here

   properties
       hMainWindow
       hMainToolbar
       
       windowSize
       
       hExternalPanel
       hButtonHome
       hButtonBackUp
       hButtonNext
       hButtonAdvancedMode
       
       inputMatrix
       imageStruct
   end

   methods
        function obj = base(panelTitle)
            scrsz = get(0, 'ScreenSize');
            obj.windowSize = scrsz;
            obj.hMainWindow = figure('Position', [1 scrsz(4)/1 scrsz(3)*0.6 scrsz(3)*0.6], 'Color', [1 1 1]);
            
            % Hide Standard Toolbar
            set(obj.hMainWindow,'Toolbar','none');
            % Custom Toolbar
            obj.hMainToolbar = uitoolbar( obj.hMainWindow );
            icon = imresize(imread('+GUIs/images/icons/home_48.png','BackgroundColor',[1 1 1]), [16 16]);
            obj.hButtonHome = uipushtool(obj.hMainToolbar,'CData',icon,'TooltipString','Back to Home Screen.');
            icon = imresize(imread('+GUIs/images/icons/arrow_left_green_48.png','BackgroundColor',[1 1 1]), [16 16]);
            obj.hButtonBackUp = uipushtool(obj.hMainToolbar,'CData',icon,'TooltipString','Back to previous Screen.');
            icon = imresize(imread('+GUIs/images/icons/arrow_right_green_48.png','BackgroundColor',[1 1 1]), [16 16]);
            obj.hButtonNext = uipushtool(obj.hMainToolbar,'CData',icon,'TooltipString','To next Screen.');
            icon = imresize(imread('+GUIs/images/icons/add_48.png','BackgroundColor',[1 1 1]), [16 16]);
            obj.hButtonAdvancedMode = uitoggletool(obj.hMainToolbar,'CData',icon,'TooltipString','Toggle Advanced options...', ...
                                                    'Separator','on', ...
                                                    'ClickedCallback', @(source, event)(obj.changeScreenMode(source)));
            icon = imresize(imread('+GUIs/images/icons/search_48.png','BackgroundColor',[1 1 1]), [16 16]);
            uitoggletool(obj.hMainToolbar,'CData',icon,'TooltipString','Switch to and from zoom mode', ...
                                                    'Separator','on', ...
                                                    'ClickedCallback', @(source, event)(obj.changeZoomMode(source)));
            icon = imresize(imread('+GUIs/images/icons/mouse_48.png','BackgroundColor',[1 1 1]), [16 16]);
            uitoggletool(obj.hMainToolbar,'CData',icon,'TooltipString','Switch to and from pan mode', ...
                                                    'ClickedCallback', @(source, event)(obj.changePanMode(source)));   

            icon = imresize(imread('+GUIs/images/icons/refresh_48.png','BackgroundColor',[1 1 1]), [16 16]);
            uitoggletool(obj.hMainToolbar,'CData',icon,'TooltipString','Reset window', ...
                                                    'Separator','on', ...
                                                    'ClickedCallback', @(source, event)(obj.resetWindow(source)));            

            % external panel
            obj.hExternalPanel = uipanel('Title', panelTitle, ...
                                        'FontSize', 15,  ...
                                        'FontName', 'Courier', ...
                                        'BackgroundColor', 'white', ...
                                        'Units', 'Normalized', ...
                                        'Position', [.01 .01 .98 .98]);

        end
        
        function changeZoomMode(obj, source)
            if strcmp(get(source, 'State'), 'on')
                % on
                zoom('on');
                set(source, 'CData', imresize(imread('+GUIs/images/icons/cross_48.png','BackgroundColor',[1 1 1]), [16 16]));
            else
                % off
                zoom('off');
                set(source, 'CData', imresize(imread('+GUIs/images/icons/search_48.png','BackgroundColor',[1 1 1]), [16 16]));
            end
        end
        
        function changePanMode(obj, source)
            if strcmp(get(source, 'State'), 'on')
                % on
                pan('on');
                set(source, 'CData', imresize(imread('+GUIs/images/icons/cross_48.png','BackgroundColor',[1 1 1]), [16 16]));
            else
                % off
                pan('off');
                set(source, 'CData', imresize(imread('+GUIs/images/icons/mouse_48.png','BackgroundColor',[1 1 1]), [16 16]));
            end
        end
       
        function changeScreenMode(obj, source)

            if strcmp(get(source, 'State'), 'on')
                % on
                % Override and add your code here
                set(source, 'CData', imresize(imread('+GUIs/images/icons/cancel_48.png','BackgroundColor',[1 1 1]), [16 16]));
            else
                % off
                % Override and add your code here
                set(source, 'CData', imresize(imread('+GUIs/images/icons/add_48.png','BackgroundColor',[1 1 1]), [16 16]));
            end
        end
       
   end
end 

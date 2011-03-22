classdef teachingtool < handle
%TEACHINGTOOL Summary of this class goes here
%   Detailed explanation goes here

    properties
        % demo objects
        imageEncoder
        imageDecoder
        videoEncoder
        videoDecoder
       
        % listeners
        listenerImageEncoderCoefficients
       
        % UI handles
        hMainWindow
        
        hStatusTextElement
        hTestButton
    end

    methods
        function obj = teachingtool()
            % create instances of the encoder objects, then initialise the
            % GUI
           
            obj.imageEncoder = DemoJPEGEncoder();
            
            obj.imageEncoder.inputImageData = 'lena_color_256.bmp';
           
            obj.hMainWindow = figure('Position',[10 10 980 680], 'Color', 'w', 'Renderer','opengl');

            % THE FOLLOWING IS JUST TESTING CODE
            obj.hTestButton = uicontrol(obj.hMainWindow, 'Style', 'pushbutton', 'String', 'Test', 'Position', [20 150 100 70], 'Callback', {@teachingtool.buttonCallback, obj});
            obj.hStatusTextElement = uicontrol(obj.hMainWindow, 'Style', 'text', 'String', 'Stat', 'Position',[100 150 100 70]);
%{            
       % Prevent an annoying warning msg
warning off MATLAB:uitabgroup:OldVersion
 
% Prepare a tab-group consisting of two tabs
hTabGroup = uitabgroup; drawnow;
tab1 = uitab(hTabGroup, 'title','Panel 1');
a = axes('parent', tab1); surf(peaks);
tab2 = uitab(hTabGroup, 'title','Panel 2');
uicontrol(tab2, 'String','Close', 'Callback','close(gcbf)');
 
% Get the underlying Java reference (use hidden property)
jTabGroup = getappdata(handle(hTabGroup),'JTabbedPane');     
%}            
            % add observers
            obj.listenerImageEncoderCoefficients = addlistener(obj.imageEncoder, 'coefficients', 'PostSet', @(src,event)handlePropertyEventsFromImageEncoder(obj,src,event));
        end

        function buttonCallback(hObject, eventdata, obj)
            obj.imageEncoder.changeCoeffs(1234);
            %obj.imageEncoder.zigZagOrdering(1234);
        end

        function handlePropertyEventsFromImageEncoder(obj, source, event)

            switch source.Name
                case 'coefficients'
                    set(obj.hStatusTextElement, 'String', 'coeffs changed in imageCoder');
            end

        end
    end
end 

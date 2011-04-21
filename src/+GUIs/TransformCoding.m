classdef TransformCoding < GUIs.base
%TRANSFORMWINDOW Summary of this class goes here
%   Detailed explanation goes here
%
%   +GUIs/TransformCoding.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   HELP INFO
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

   properties
       
       encoderInstance
       
       hInputImage
       hInputImageAxes
       
       hQuantisationSlider
       
       hOutputImage
       hOutputImageAxes
       
       hBasesPanel
       hButtonSetAll
       hButtonClearAll
       
       hSelectedBlockPanel
       %hSelectedBlockAxes
       hSelectedBlock
       hSelectedBlockRectangle
       
       hDataTable

       changeCoefficientMapLive

       bases
       basisButtonImages

       coefficientMap
   end
   
	methods
        function obj = TransformCoding(encoder, decoder)

            obj = obj@GUIs.base('Transform Coding: DCT');

            if ~exist('encoder', 'var')
                %throw(MException('TransformWindow:TransformWindow', 'You must pass in the instance of the JPEG encoder.'));
                encoder = JPEG.encoder('../examples/lena_color_256.bmp');
            end

            if isempty(encoder.reconstruction)
                encoder.encode('DoStagesAfterQuantisation', false, 'DoReconstruction', true, 'CoefficientMap', obj.coefficientMap);
            end

            obj.encoderInstance = encoder;
           
            % Input and output image axes
            obj.hInputImageAxes = obj.createAxesForImage([.01 .50 .30 .48]);

            obj.hOutputImageAxes = obj.createAxesForImage([.01 .01 .30 .48]);

            obj.hQuantisationSlider = uicontrol('Style', 'slider', ...
                                                'Parent', obj.hExternalPanel, ...
                                                'Min', 0, 'Max', 100, ...
                                                'Units', 'Normalized', ...
                                                'Position', [.01 .46 0.3 0.03], ...
                                                'Value', obj.encoderInstance.qualityFactor,...
                                                'Callback', @(source, event)(obj.quantisationFactorChange(source)));

            % Create basis images
            [X,Y] = meshgrid(1:8,1:8);
            obj.bases = arrayfun(@(x,y)(TransformCoding.createBasisImage(x,y)), X(:), Y(:), 'UniformOutput', false);

            % Create panel for basis
            obj.hBasesPanel = uipanel('Parent', obj.hExternalPanel, ...
                                    'BackgroundColor', 'white', ...
                                    'Position', [0.45 0.65 0.34 0.34], ...
                                    'ResizeFcn', @(src, evt)(obj.resizeBasesPanel()));

            % Create toggle buttons
            arrayfun(@(i)(uicontrol('Parent', obj.hBasesPanel, ...
                                'Style', 'togglebutton', ...
                                ... %'String', ['basis' num2str(X(i)) num2str(Y(i))], ... % FOR DEBUGGING
                                'Units', 'Normalized', ...
                                'Position', [(0.125*(X(i)-1)) (1-(0.1111*(Y(i)))) 0.125 0.1111], ...
                                ... %Position', [(40*(X(i)-1)) (340-(40*(Y(i)))) 40 40], ...
                                'Tag', ['basis' num2str(i)], ... %['basis' num2str(X(i)) num2str(Y(i))], ...
                                'Value', 1, ...
                                'Callback', @(src, evt)(obj.toggleCoefficient(src, obj.changeCoefficientMapLive)))...
                            ), 1:length(obj.bases));

            obj.changeCoefficientMapLive = true;

            obj.hButtonSetAll = uicontrol('Style', 'pushbutton', ...
                                        'Parent', obj.hBasesPanel, ...
                                        'FontSize', 8,  ...
                                        ...%'FontName', 'Courier New',...
                                        'String', 'Set All', ...
                                        'Callback', @(src, evt)(obj.setAllCoefficients()), ...
                                        'Position', [0.1 0.0 0.4 0.1], ...
                                        'Units', 'Normalized');

            obj.hButtonClearAll = uicontrol('Style', 'pushbutton', ...
                                        'Parent', obj.hBasesPanel, ...
                                        'FontSize', 8,  ...    
                                        'String', 'Remove All', ...
                                        'Callback', @(src, evt)(obj.clearAllCoefficients()), ...
                                        'Units', 'Normalized', ...
                                        'Position', [0.5 0.0 0.4 0.1]);

            obj.hSelectedBlockPanel = uipanel('Parent', obj.hMainWindow, ...
                                    'BackgroundColor', 'white', ...
                                    'Title', 'Selected Block', ...
                                    'FontSize', 13,  ...
                                    'FontName', 'Courier', ...
                                    'Position', [0.45 0.02 0.45 0.6]);
           
            %obj.hSelectedBlockAxes = axes('Parent', obj.hSelectedBlockPanel, ...
            %                            'Box', 'on', ...
            %                            'Visible', 'off', ...
            %                            'Position', [.01 .55 .3 .5], ...
            %                            'Units', 'Normalized');
            %dat = rand(8); 
            %cnames = {'1','2','3','4','5','6','7','8'}; 
            obj.hDataTable{1} = uitable('Data',[], ...
                                        'ColumnName', [], ...
                                        'Parent', obj.hSelectedBlockPanel, ...
                                        'Units', 'Normalized', ...
                                        'ColumnFormat', {'bank','bank','bank','bank','bank','bank','bank','bank'},...
                                        'ColumnEditable', true(1,1:8), ...
                                        'RowStriping', 'on', ...
                                        'FontSize', 11,...
                                        'FontName', 'Courier New',...
                                        'ColumnWidth', num2cell(ones(1,8).*65), ...
                                        'Position', [0.01 0.01 0.99 0.42]);
            obj.hDataTable{2} = uitable('Data',[], ...
                                        'ColumnName', [], ...
                                        'Parent', obj.hSelectedBlockPanel, ...
                                        'Units', 'Normalized', ...
                                        'ColumnFormat', {'bank','bank','bank','bank','bank','bank','bank','bank'},...
                                        'ColumnEditable', true(1,1:8), ...
                                        'RowStriping', 'on', ...
                                        'FontSize', 11,...
                                        'FontName', 'Courier New',...
                                        'ColumnWidth', num2cell(ones(1,8).*65), ...
                                        'Position', [0.01 0.51 0.99 0.42]);

           

            linkaxes([obj.hInputImageAxes obj.hOutputImageAxes]);

            obj.updateAxes();
        end

        function quantisationFactorChange(obj, source)
            set(source, 'Enable', 'off');
            drawnow;
            % add monitor
            %addlistener(obj.encoderInstance, 'reconstruction', 'PostSet', @(source, event)obj.encoderFinishedQuantisationChange(source, event));            
            % Spawn on thread

            
            % Just call directly
            obj.encoderInstance.qualityFactor = ceil(get(source, 'Value'));
            obj.encoderInstance.encode('DoEntropyCode', false, 'DoReconstruction', true, 'CoefficientMap', obj.coefficientMap);

            %disp('Finished quantisation change.');
            
            set(source, 'Enable', 'on');
            
            obj.updateAxes();
        end

        function imageClick(obj, imageHandle)
            % handle input / output image clicks
            if imageHandle == obj.hInputImage
                selectedPoint = get(obj.hInputImageAxes, 'CurrentPoint');
                bx = (floor((selectedPoint(1,1)-1) / 8)*8) + 1;
                by = (floor((selectedPoint(1,2)-1) / 8)*8) + 1;
                %obj.hSelectedBlock =
                %Subsampling.subsampledImageShow(obj.encoderInstance.imageSt
                %ruct, 'Parent', obj.hSelectedBlockAxes, 'Channel', 'y', 'Block', [bx by 8 8]);
                if ~isempty(obj.hSelectedBlockRectangle)
                    cellfun(@(rect)delete(rect), obj.hSelectedBlockRectangle);
                end
                obj.hSelectedBlockRectangle{1} = rectangle('Parent', obj.hInputImageAxes, 'Position', [bx by 8 8], 'EdgeColor', [0 0 0], 'LineWidth', 1.5);
                obj.hSelectedBlockRectangle{2} = rectangle('Parent', obj.hOutputImageAxes, 'Position', [bx by 8 8], 'EdgeColor', [0 0 0], 'LineWidth', 1.5);

                set(obj.hDataTable{1}, 'Data', obj.encoderInstance.coefficients{1}(by:by+7, bx:bx+7));
                
                set(obj.hDataTable{2}, 'Data', obj.encoderInstance.quantisedCoefficients{1}(by:by+7, bx:bx+7));
            else
               %disp(get(obj.hOutputImageAxes, 'CurrentPoint'))
            end
        end

        function resizeBasesPanel(obj)   
           % Force bases panel to be square
           p = getpixelposition(obj.hBasesPanel);
           setpixelposition(obj.hBasesPanel, [p(1) p(2) (p(4)-p(4)*0.1111) p(4)]);
           
           % update button cdata
           %[X,Y] = meshgrid(1:8,1:8);
           for i=1:length(obj.bases)
               % get basis button
               b = findobj(obj.hBasesPanel, 'Tag', ['basis' num2str(i)]); %['basis' num2str(X(i)) num2str(Y(i))]);
               im = obj.bases{i};
               % normalise
               im = im - min(im(:));
               mx = max(im(:));
               if mx == 0
                    im = ones(size(im));
               else
                    im = im ./ mx;
               end
               % resize to button size
               xywh = getpixelposition(b);
               smallestDim = min(xywh(3:4));
               im = imresize(im, [smallestDim smallestDim], 'nearest');
               % create surrounding black box
               im(1:end, 1) = 0; im(1:end, end) = 0; im(1, 1:end) = 0; im(end, 1:end) = 0;
               
               obj.basisButtonImages{i} = repmat(im, [1 1 3]);
               % set on button
               %set(b, 'CData', obj.basisButtonImages{i});
               obj.toggleCoefficient(b, false);
           end
        end

        function toggleCoefficient(obj, source, updateNow)
            basisName = get(source, 'Tag');
            indexOfBasis = str2double(basisName(6:end));
            [r c] = ind2sub([8 8], indexOfBasis);
            if ~get(source, 'Value') 
                set(source, 'CData', []);
                obj.coefficientMap(r, c) = 0;
            else
                set(source, 'CData', obj.basisButtonImages{indexOfBasis});
                obj.coefficientMap(r, c) = 1;
            end
            if updateNow
                obj.quantisationFactorChange(obj.hQuantisationSlider);
            end
        end
       
        function setAllCoefficients(obj)
            for i=1:length(obj.basisButtonImages)
                b = findobj(obj.hMainWindow, 'Tag', ['basis' num2str(i)]);
                set(b, 'Value', 1);
                obj.toggleCoefficient(b, false);
            end

            obj.quantisationFactorChange(obj.hQuantisationSlider);
        end

        function clearAllCoefficients(obj)
            for i=1:length(obj.basisButtonImages)
                b = findobj(obj.hMainWindow, 'Tag', ['basis' num2str(i)]);
                set(b, 'Value', 0);
                obj.toggleCoefficient(b, false);
            end

            obj.quantisationFactorChange(obj.hQuantisationSlider);
        end
        
        function updateAxes(obj)
            obj.hInputImage = Subsampling.subsampledImageShow(obj.encoderInstance.imageStruct, 'Parent', obj.hInputImageAxes);           
            set(obj.hInputImage, 'ButtonDownFcn', @(src, evt)(obj.imageClick(src)));

            obj.hOutputImage = Subsampling.subsampledImageShow(obj.encoderInstance.reconstruction, 'Parent', obj.hOutputImageAxes);           
            set(obj.hOutputImage, 'ButtonDownFcn', @(src, evt)(obj.imageClick(src)));
            
            obj.hSelectedBlockRectangle = [];
        end

    end
end

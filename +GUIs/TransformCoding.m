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
       hPSNRText

       hBasesPanel
       hButtonSetAll
       hButtonClearAll

       hSelectedBlockPanel
       hSelectedBlock
       hSelectedBlockRectangle
       selectedBlockCoords = [];

       hDataTable

       changeCoefficientMapLive

       bases
       basisButtonImages

       coefficientMap
   end
   
	methods
        function obj = TransformCoding()

            obj = obj@GUIs.base('Transform Coding: DCT');
           
            % Input and output image axes
            obj.createInputImageSelectComboBoxAndText([0.01 0.96 0.1 0.03], [0.11 0.95 0.1 0.03]);
            obj.hInputImageAxes = obj.createAxesForImage([.01 .50 .30 .45]);

            obj.hOutputImageAxes = obj.createAxesForImage([.69 .5 .30 .45]);
            obj.createTextElement([0.69 0.96 0.1 0.03], 'Output Image');
            obj.hPSNRText = obj.createTextElement([0.8 0.96 0.2 0.03], '(PSNR: )');

            obj.createTextElement([.35 0.55 0.24 0.03], 'JPEG Quality Factor:');
            obj.hQuantisationSlider = uicontrol('Style', 'slider', ...
                                                'Parent', obj.hExternalPanel, ...
                                                'Min', 0, 'Max', 100, ...
                                                'Units', 'Normalized', ...
                                                'Position', [.35 .52 0.3 0.03], ...
                                                'Value', 60,...
                                                'Callback', @(source, event)(obj.quantisationFactorChange(source)));
            obj.createTextElement([0.35 0.5 0.04 0.03], '0');
            obj.createTextElement([0.475 0.5 0.04 0.03], '50');
            obj.createTextElement([0.60 0.5 0.04 0.03], '100');

            % Create basis images
            [X,Y] = meshgrid(1:8,1:8);
            obj.bases = arrayfun(@(x,y)(TransformCoding.createBasisImage(x,y)), X(:), Y(:), 'UniformOutput', false);

            % Create panel for basis
            obj.createTextElement([0.4 0.96 0.24 0.03], 'Click to select DCT bases:');
            obj.hBasesPanel = uipanel('Parent', obj.hExternalPanel, ...
                                    'BackgroundColor', 'white', ...
                                    'Units', 'Normalized', ...
                                    'Position', [0.4 0.62 0.34 0.34], ...
                                    'ResizeFcn', @(src, evt)(obj.resizeBasesPanel()));

            % Create toggle buttons
            arrayfun(@(i)(uicontrol('Parent', obj.hBasesPanel, ...
                                'Style', 'togglebutton', ...
                                'Units', 'Normalized', ...
                                'Position', [(0.125*(X(i)-1)) (1-(0.1111*(Y(i)))) 0.125 0.1111], ...
                                'Tag', ['basis' num2str(i)], ...
                                'Value', 1, ...
                                'Callback', @(src, evt)(obj.toggleCoefficient(src, obj.changeCoefficientMapLive)))...
                            ), 1:length(obj.bases));

            obj.changeCoefficientMapLive = true;

            obj.hButtonSetAll = uicontrol('Style', 'pushbutton', ...
                                        'Parent', obj.hBasesPanel, ...
                                        'FontSize', 8,  ...
                                        'String', 'Set All', ...
                                        'Callback', @(src, evt)(obj.setAllCoefficients()), ...
                                        'Units', 'Normalized', ...
                                        'Position', [0.1 0.0 0.4 0.1]);

            obj.hButtonClearAll = uicontrol('Style', 'pushbutton', ...
                                        'Parent', obj.hBasesPanel, ...
                                        'FontSize', 8,  ...    
                                        'String', 'Remove All', ...
                                        'Callback', @(src, evt)(obj.clearAllCoefficients()), ...
                                        'Units', 'Normalized', ...
                                        'Position', [0.5 0.0 0.4 0.1]);

            % Selected block
            obj.hSelectedBlockPanel = uipanel('Parent', obj.hMainWindow, ...
                                    'BackgroundColor', 'white', ...
                                    'Title', 'Selected Block', ...
                                    'FontSize', 13,  ...
                                    'FontName', 'Courier', ...
                                    'Position', [0.01 0.01 0.98 0.47]);

            % Tables for block data
            titles = {'Input Y Pixel Values', 'Dequantised DCT Coefficients', 'DCT Coefficients', 'Inverse Transform Coefficients', 'Quantised DCT Coefficients' ,'Output Y Pixel Values'};
            for i=1:6
                c = (0.01+(0.32*floor((i-1)/2)));
                obj.createTextElement([c (0.45+(rem(i,2).*0.5)) 0.2 0.05], titles{i}, 9, 'on', 'white', obj.hSelectedBlockPanel);
                obj.hDataTable{i} = uitable('Data',[], ...
                                        'ColumnName', [], ...
                                        'Parent', obj.hSelectedBlockPanel, ...
                                        'Units', 'Normalized', ...
                                        'RowStriping', 'on', ...
                                        'RowName', [],...
                                        'FontSize', 10,...
                                        'FontName', 'Courier New',...
                                        'ColumnWidth', num2cell(ones(1,8).*40), ...
                                        'Position', [c (0.01+(rem(i,2).*0.5)) 0.31 0.42]);
            end

            linkaxes([obj.hInputImageAxes obj.hOutputImageAxes]);

            obj.changeInput(obj.hInputImageSelect);

            obj.updateAxes();
        end

        function imageClick(obj, imageHandle)
            % handle input / output image clicks
            if imageHandle == obj.hInputImage
                selectedPoint = get(obj.hInputImageAxes, 'CurrentPoint');
                bx = (floor((selectedPoint(1,1)-1) / 8)*8) + 1;
                by = (floor((selectedPoint(1,2)-1) / 8)*8) + 1;
                obj.selectedBlockCoords = [bx by 8 8];

                obj.updateDataTables();
                obj.updateAxes();
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
            if ~isempty(obj.hSelectedBlockRectangle)
                cellfun(@(rect)delete(rect), obj.hSelectedBlockRectangle);
                obj.hSelectedBlockRectangle = [];
            end
            if ~isempty(obj.encoderInstance)
                obj.hInputImage = Subsampling.subsampledImageShow(obj.encoderInstance.imageStruct, 'Parent', obj.hInputImageAxes);
                set(obj.hInputImage, 'ButtonDownFcn', @(src, evt)(obj.imageClick(src)));

                obj.hOutputImage = Subsampling.subsampledImageShow(obj.encoderInstance.reconstruction, 'Parent', obj.hOutputImageAxes);
                set(obj.hOutputImage, 'ButtonDownFcn', @(src, evt)(obj.imageClick(src)));

                set(obj.hPSNRText, 'String', ['(PSNR: ' sprintf('%.2f', Utilities.peakSignalToNoiseRatio(obj.encoderInstance.reconstruction.y, obj.inputMatrix(:,:,1))) ' dB)']);

                if ~isempty(obj.selectedBlockCoords)
                    obj.hSelectedBlockRectangle{1} = rectangle('Parent', obj.hInputImageAxes, 'Position', obj.selectedBlockCoords, 'EdgeColor', [0 0 0], 'LineWidth', 1.5);
                    obj.hSelectedBlockRectangle{2} = rectangle('Parent', obj.hOutputImageAxes, 'Position', obj.selectedBlockCoords, 'EdgeColor', [0 0 0], 'LineWidth', 1.5);
                end
            end
        end

        function clearDataTables(obj)
            for i=1:length(obj.hDataTable)
                set(obj.hDataTable{i}, 'Data', []);
            end
        end

        function updateDataTables(obj)
                if ~isempty(obj.selectedBlockCoords)
                    bx = obj.selectedBlockCoords(1);
                    by = obj.selectedBlockCoords(2);
                    set(obj.hDataTable{1}, 'Data', round(obj.encoderInstance.imageMatrix(by:by+7, bx:bx+7,1)));
                    set(obj.hDataTable{3}, 'Data', round(obj.encoderInstance.coefficients{1}(by:by+7, bx:bx+7)));
                    set(obj.hDataTable{5}, 'Data', round(obj.encoderInstance.quantisedCoefficients{1}(by:by+7, bx:bx+7)));
                    set(obj.hDataTable{2}, 'Data', round(obj.encoderInstance.deQuantisedCoefficients{1}(by:by+7, bx:bx+7)));
                    set(obj.hDataTable{4}, 'Data', round(obj.encoderInstance.inverseTransformedData{1}(by:by+7, bx:bx+7)));
                    set(obj.hDataTable{6}, 'Data', round(obj.encoderInstance.inverseTransformedAndShiftedData{1}(by:by+7, bx:bx+7)));
                end
        end

        function changeInput(obj, source)
            % Call super class implementation which does the loading etc
            if obj.loadedImage ~= get(source, 'Value')
                obj.changeInput@GUIs.base(source);
                obj.selectedBlockCoords = [];
                obj.quantisationFactorChange(obj.hQuantisationSlider);
            end
        end

        function quantisationFactorChange(obj, source)
            if ~isempty(obj.inputMatrix)
                set(source, 'Enable', 'off');
                drawnow;
                obj.encoderInstance = JPEG.encoder(obj.inputMatrix);
                obj.encoderInstance.encode('DoStagesAfterQuantisation', false, 'DoReconstruction', true, 'CoefficientMap', obj.coefficientMap, 'Quality', ceil(get(source, 'Value')));
                set(source, 'Enable', 'on');
                obj.updateDataTables();
                obj.updateAxes();
            end
        end
    end
end


classdef JPEGCodec < GUIs.base
%JPEGCODEC Summary of this class goes here
%   Detailed explanation goes here

    properties
        encoderInstance
        decoderInstance

        hInputImageAxes

        hQuantisationSlider
        hBitstreamTextBox
        hQValueText
        hInputSizeText
        hInputBitCountText
        hOutputBitCountText
        hSavingText
        hPSNRText

        hOutputImage
        hOutputImageAxes

        cache
    end

    methods
        function obj = JPEGCodec()
            obj = obj@GUIs.base('JPEG: The encoder and decoder block diagrams');

            % Read cache 
            if exist('JPEGcache.mat', 'file')
                load 'JPEGcache.mat'
                obj.cache = cache;
            end

            mainCanvas = axes('Parent', obj.hExternalPanel, ...
                                        'Box', 'off', ...
                                        'Visible', 'on', ...
                                        'XTick', [],...
                                        'YTick', [],...
                                        'XColor', [1 1 1],...
                                        'YColor', [1 1 1],...
                                        'Units', 'Normalized', ...
                                        'Position', [0 0 1 1]);

            % ENC

            rectangle('Position', [0.01 0.90 0.20 0.08], 'Parent', mainCanvas, 'LineStyle', ':');
            obj.createTextElement([0.02 0.945 0.18 0.03], 'JPEG Quality:', 10, 'on', 'white', obj.hExternalPanel, 'FontName', 'helvetica');
            obj.createTextElement([0.02 0.92 0.04 0.03], '0', 10, 'on', 'white', obj.hExternalPanel);
            obj.createTextElement([0.09 0.92 0.04 0.03], '50', 10, 'on', 'white', obj.hExternalPanel);
            obj.createTextElement([0.16 0.92 0.04 0.03], '100', 10, 'on', 'white', obj.hExternalPanel);
            obj.lineWithArrowHead([0.21 0.94], [0.25 0.94]); % Q to q

            rectangle('Position', [0.01 0.75 0.2 0.14], 'Parent', mainCanvas, 'LineStyle', ':');            

            obj.lineWithArrowHead([0.1 0.61], [0.1 0.75]); % input image box to input dot box

            %obj.createTextElement([0.02 0.79 0.12 0.03], 'Input Size:', 10, 'on', 'white', obj.hExternalPanel);
            obj.hInputSizeText = obj.createTextElement([0.02 0.75 0.18 0.05], '--', 9, 'on', 'white', obj.hExternalPanel);

            obj.lineWithArrowHead([0.21 0.86], [0.25 0.86]); % in to t

            rectangle('Position', [0.25 0.85 0.1 0.1], 'Parent', mainCanvas, 'Curvature', 0.1); % t
            element = obj.createTextElement([0.26 0.86 0.08 0.063], 'Transform & Quantisation', 11, 'on', 'white', obj.hExternalPanel, 'HorizontalAlignment', 'center', 'FontName', 'helvetica');
            %set(element, 'Enable', 'on');
            %set(element, 'ButtonDownFcn', @(source,event)(obj.changeScreen('TransformCoding')));
            %{
            uicontrol('Style', 'pushbutton', ...
                    'BackgroundColor', [.9 .9 .9], ...
                    'Parent', obj.hExternalPanel, ...
                    'Min', 0, 'Max', 100, ...
                    'Units', 'Normalized', ...
                    'Position', [0.25 0.85 0.1 0.1], ...
                    'String', 'Transform (DCT) & Quantisation', ...
                    'Callback', @(source,event)(obj.changeScreen('TransformCoding')));
            %}
            rectangle('Position', [0.23 0.75 0.28 0.22], 'Parent', mainCanvas, 'LineStyle', ':');  % encoder body
            obj.createTextElement([0.24 0.755 0.26 0.03], 'ENCODER', 12, 'on', 'white', obj.hExternalPanel, 'HorizontalAlignment', 'center', 'FontName', 'arial');

            obj.lineWithArrowHead([0.35 0.9], [0.4 0.9]); % t to e

            rectangle('Position', [0.4 0.85 0.1 0.1], 'Parent', mainCanvas, 'Curvature', 0.1); % e
            obj.hQValueText = obj.createTextElement([0.26 0.8 0.10 0.03], 'Q:', 10, 'on', 'white', obj.hExternalPanel);
            obj.createTextElement([0.41 0.86 0.08 0.063], 'Entropy Coding', 11, 'on', 'white', obj.hExternalPanel, 'HorizontalAlignment', 'center', 'FontName', 'helvetica');

            % show text with val of Quant

            obj.lineWithArrowHead([0.5 0.9], [0.6 0.9]); % channel

            % show some of bits
            %rectangle('Position', [0.6 0.85 0.2 0.1], 'Parent', mainCanvas, 'LineStyle', ':'); % iq
            obj.createTextElement([0.6 0.97 0.3 0.03], 'The first 1000 output bits...', 10, 'on', 'white', obj.hExternalPanel);
            obj.hBitstreamTextBox = uicontrol('Style', 'edit', ...
                                                'BackgroundColor', [.9 .9 .9], ...
                                                'Parent', obj.hExternalPanel, ...
                                                'Min', 0, 'Max', 100, ...
                                                'Units', 'Normalized', ...
                                                'Position', [0.6 0.86 0.3 0.1], ...
                                                'String', 'bits');
            % DEC

            line([0.55 0.6], [0.75 0.9], 'Color', [0 0 0], 'LineStyle', '-.');
            obj.createTextElement([0.52 0.8 0.1 0.03], '(Channel)', 10, 'on', 'white', obj.hExternalPanel, 'FontAngle', 'italic');
            obj.lineWithArrowHead([0.55 0.75], [0.65 0.75]); % id to it

            rectangle('Position', [0.62 0.66 0.32 0.16], 'Parent', mainCanvas, 'LineStyle', ':');  % encoder body
            obj.createTextElement([0.63 0.665 0.3 0.03], 'DECODER', 12, 'on', 'white', obj.hExternalPanel, 'HorizontalAlignment', 'center', 'FontName', 'arial');

            rectangle('Position', [0.65 0.7 0.1 0.1], 'Parent', mainCanvas, 'Curvature', 0.1); % id
            obj.createTextElement([0.66 0.71 0.08 0.063], 'Entropy Decoding', 11, 'on', 'white', obj.hExternalPanel, 'HorizontalAlignment', 'center', 'FontName', 'helvetica');

            obj.lineWithArrowHead([0.75 0.75], [0.8 0.75]);

            rectangle('Position', [0.8 0.7 0.12 0.1], 'Parent', mainCanvas, 'Curvature', 0.1); % it
            obj.createTextElement([0.81 0.71 0.1 0.073], 'Inverse Transform & Quantisation', 11, 'on', 'white', obj.hExternalPanel, 'HorizontalAlignment', 'center', 'FontName', 'helvetica');

            line([0.92 0.95], [0.75 0.75], 'Color', [0 0 0]);
            obj.lineWithArrowHead([0.95 0.75], [0.95 0.61]);

            obj.createTextElement([0.01 0.61 0.2 0.03], 'Uncompressed Input Image', 10, 'on', 'white', obj.hExternalPanel, 'FontName', 'helvetica');
            obj.createTextElement([0.60 0.61 0.2 0.03], 'Decoded Output Image', 10, 'on', 'white', obj.hExternalPanel, 'FontName', 'helvetica');

            obj.hInputBitCountText  = obj.createTextElement([0.43 0.55 0.15 0.06], 'Input Bit Count: ', 15, 'on', 'white', obj.hExternalPanel, 'FontName', 'helvetica');
            obj.hOutputBitCountText = obj.createTextElement([0.43 0.45 0.15 0.06], 'Output Bit Count: ', 15, 'on', 'white', obj.hExternalPanel, 'FontName', 'helvetica');
            obj.hSavingText         = obj.createTextElement([0.43 0.35 0.15 0.06], 'Bit Saving: ', 15, 'on', 'white', obj.hExternalPanel, 'FontName', 'helvetica');
            obj.hPSNRText           = obj.createTextElement([0.43 0.25 0.15 0.06], 'PSNR of output: ', 15, 'on', 'white', obj.hExternalPanel, 'FontName', 'helvetica');

            xlim(mainCanvas, [0 1]);
            ylim(mainCanvas, [0 1]);

            % UI Elements
            obj.createInputImageSelectComboBoxAndText([0.02 0.85 0.15 0.03], [0.01 0.80 0.19 0.06]);

            obj.hInputImageAxes = obj.createAxesForImage([.01 .01 .4 .6]);

            obj.hOutputImageAxes = obj.createAxesForImage([.59 .01 .4 .6]);

            linkaxes([obj.hInputImageAxes obj.hOutputImageAxes], 'xy');

            obj.hQuantisationSlider = uicontrol('Style', 'slider', ...
                                                'Parent', obj.hExternalPanel, ...
                                                'Min', 0, 'Max', 100, ...
                                                'Units', 'Normalized', ...
                                                'Position', [0.02 0.9 0.18 0.03], ...
                                                'Value', 60, ... %obj.encoderInstance.qualityFactor,...
                                                'Callback', @(source, event)(obj.quantisationFactorChange(source)));
            set(obj.hInputImageSelect, 'Value', 1);
            obj.changeInput(obj.hInputImageSelect);

            set(obj.hButtonAdvancedMode, 'Enable', 'off');
        end

        function quantisationFactorChange(obj, source)
            obj.doEncodeDecode();
            obj.updateAxes();
        end

        function doEncodeDecode(obj)
            set(obj.hQuantisationSlider, 'Enable', 'off');
            drawnow;
            obj.encoderInstance = JPEG.encoder(obj.inputMatrix);
            obj.decoderInstance = JPEG.decoder(obj.encoderInstance.encode('Quality', ceil(get(obj.hQuantisationSlider, 'Value'))));
            obj.decoderInstance.decode();
            set(obj.hBitstreamTextBox, 'String', num2str(obj.encoderInstance.output(1:1000)));
            set(obj.hQuantisationSlider, 'Enable', 'on');
        end

        function updateAxes(obj)
            outbits = length(obj.encoderInstance.output);
            inpixels = size(obj.inputMatrix,2)*size(obj.inputMatrix,2);
            inbits = inpixels * 24; % assuming 24bpp
            
            set(obj.hInputBitCountText, 'String', ['Input Bit Count: ' num2str(inbits)]);
            set(obj.hOutputBitCountText, 'String', ['Output Bit Count: ' num2str(outbits)]);
            set(obj.hSavingText, 'String', ['Bit Saving: ' num2str(round(((inbits - outbits)/inbits) * 100)) '%']);
            set(obj.hPSNRText, 'String', ['PSNR of output: ' num2str(Utilities.peakSignalToNoiseRatio(obj.decoderInstance.outputImageMatrix, obj.inputMatrix))]);
            set(obj.hInputSizeText, 'String', [num2str(size(obj.inputMatrix,2)) ' by ' num2str(size(obj.inputMatrix,1)) ' = ' num2str(inpixels) ' pixels']);
            set(obj.hQuantisationSlider, 'Value', obj.encoderInstance.qualityFactor);
            set(obj.hBitstreamTextBox, 'String', num2str(obj.encoderInstance.output(1:1000)));
            set(obj.hQValueText, 'String', ['Q: ' num2str(obj.encoderInstance.qualityFactor)]);
            Subsampling.subsampledImageShow(obj.encoderInstance.imageStruct, 'Parent', obj.hInputImageAxes);
            Subsampling.subsampledImageShow(obj.decoderInstance.outputImageStruct, 'Parent', obj.hOutputImageAxes);
        end

        function changeInput(obj, source)
            % Call super class implementation which does the loading etc
            obj.changeInput@GUIs.base(source);

            value = 100*get(source, 'Value') + ceil(get(obj.hQuantisationSlider, 'Value'));

            if value <= length(obj.cache) && ~isempty(obj.cache{value})
                obj.encoderInstance = obj.cache{value}{1};
                obj.decoderInstance = obj.cache{value}{2};
            else
                obj.doEncodeDecode();
                obj.cache{value}{1} = obj.encoderInstance;
                obj.cache{value}{2} = obj.decoderInstance;
            end

            obj.updateAxes();
        end

        function handleCloseRequest(obj, source, event)
            cache = obj.cache;
            save('JPEGcache.mat', 'cache');
            delete(gcf);
        end
    end
end

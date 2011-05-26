classdef JPEGCodec < GUIs.base
%JPEGCODEC Summary of this class goes here
%   Detailed explanation goes here

    properties
        encoderInstance
        decoderInstance

        hInputImage
        hInputImageAxes

        hQuantisationSlider

        hOutputImage
        hOutputImageAxes
    end

    methods
        function obj = JPEGCodec(encoder, decoder)
            obj = obj@GUIs.base('JPEGCodec');

            if ~exist('encoder', 'var')
                encoder = JPEG.encoder('examples/lena_color_256.bmp');
            end

            if isempty(encoder.reconstruction)
                encoder.encode('DoStagesAfterQuantisation', false, 'DoReconstruction', true);
            end

            obj.encoderInstance = encoder;

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

            rectangle('Position', [0.01 0.75 0.19 0.24], 'Parent', mainCanvas, 'LineStyle', ':');
            obj.lineWithArrowHead([0.1 0.61], [0.1 0.75]); % input image box to input dot box

            obj.createTextElement([0.01 0.8 0.19 0.03], 'INPUT BITS/PIXELS', 10, 'on', 'white', obj.hExternalPanel);

            obj.lineWithArrowHead([0.2 0.9], [0.25 0.9]); % in to t

            rectangle('Position', [0.25 0.85 0.1 0.1], 'Parent', mainCanvas); % t

            obj.lineWithArrowHead([0.35 0.9], [0.4 0.9]); % in to t

            rectangle('Position', [0.4 0.85 0.1 0.1], 'Parent', mainCanvas); % q

            % show text with val of Quant

            obj.lineWithArrowHead([0.5 0.9], [0.6 0.9]); % channel

            % show some of bits
            rectangle('Position', [0.6 0.85 0.2 0.1], 'Parent', mainCanvas, 'LineStyle', ':'); % iq

            % DEC

            line([0.5 0.6], [0.75 0.9], 'Color', [0 0 0]);
            obj.lineWithArrowHead([0.5 0.75], [0.6 0.75]); % iq to it

            rectangle('Position', [0.6 0.7 0.1 0.1], 'Parent', mainCanvas); % iq

            obj.lineWithArrowHead([0.7 0.75], [0.75 0.75]); % it to out

            rectangle('Position', [0.75 0.7 0.1 0.1], 'Parent', mainCanvas); % it
            %obj.createTextElement([0.501 0.701 0.09 0.09], 'RECT', 10, 'on', 'white', obj.hExternalPanel);

            obj.lineWithArrowHead([0.85 0.75], [0.9 0.75]); % it to out

            xlim(mainCanvas, [0 1]);
            ylim(mainCanvas, [0 1]);

            % UI Elements
            obj.createInputImageSelectComboBoxAndText([0.01 0.96 0.19 0.03], [0.01 0.9 0.19 0.06]);

            obj.hInputImageAxes = obj.createAxesForImage([.01 .01 .35 .6]);

            obj.hOutputImageAxes = obj.createAxesForImage([.64 .01 .35 .6]);

            obj.hQuantisationSlider = uicontrol('Style', 'slider', ...
                                                'Parent', obj.hExternalPanel, ...
                                                'Min', 0, 'Max', 100, ...
                                                'Units', 'Normalized', ...
                                                'Position', [.01 .75 0.19 0.03], ...
                                                'Value', obj.encoderInstance.qualityFactor,...
                                                'Callback', @(source, event)(obj.quantisationFactorChange(source)));

        end
    end
end

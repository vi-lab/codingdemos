classdef Correlation < GUIs.base
%CORRELATION Summary of this class goes here
%   Detailed explanation goes here

    properties
        hImageAxes
        hCorrelationAxes
    end

    methods
        function obj = Correlation()
            obj = obj@GUIs.base('Correlation');

            % Show input image selection
            obj.createInputImageSelectComboBoxAndText([0.06 0.96 0.25 0.03], [0.06 0.9 0.2 0.08]);

            obj.hImageAxes = obj.createAxesForImage([0.01 0.2 0.3 0.68], obj.hExternalPanel);

            obj.hCorrelationAxes = axes('Parent', obj.hExternalPanel, 'Position', [0.35 0.02 0.64 0.47]);
           % axes('Parent', obj.hExternalPanel, 'Position', [0.35 0.5 0.64 0.47]);
        end
        
        function changeInput(obj, source)
            % Call super class implementation which does the loading etc
            obj.changeInput@GUIs.base(source);
            obj.updateCorrelationPlots();
            obj.updateAxes();
        end

        function updateCorrelationPlots(obj)
            % Y channel
            data = obj.inputMatrix(:,:,1);
            coefs = xcorr(data(:), 1000);
            plot(obj.hCorrelationAxes, coefs(ceil(length(coefs)/2):end));
        end

        function updateAxes(obj)
            imshow(obj.inputMatrix(:,:,1), 'Parent', obj.hImageAxes);
        end
    end
end 

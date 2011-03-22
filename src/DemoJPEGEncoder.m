classdef DemoJPEGEncoder < handle
%TRANSFORMBLOCK Summary of this class goes here
%Detailed explanation goes here

    properties (SetObservable)
        coefficients
    end

    methods
        
        function data=changeCoeffs(obj, blah)
            obj.coefficients = 1;
        end

        function data=zigZagOrdering(obj, blah)
        end

        function data=sequentialOrdering(obj, blah)
        end

        function data=runLengthCoding(obj, blah)
        end
    end
end 

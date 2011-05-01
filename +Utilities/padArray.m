function [ paddedArray ] = padArray( array, padValue, lengthWithPadding )
%PADARRAY Summary of this function goes here
%   Detailed explanation goes here

paddedArray = ones(1, lengthWithPadding) .* padValue;
paddedArray(1:length(array)) = array;

if length(paddedArray) > lengthWithPadding
    disp('WARNING: Input array is larger than desired array with pad! Array will be trimmed.');
    paddedArray(lengthWithPadding+1:end) = [];
end

end

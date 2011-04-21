function [ paddedArray ] = padArray( array, padValue, lengthWithPadding )
%PADARRAY Summary of this function goes here
%   Detailed explanation goes here

paddedArray = ones(1, lengthWithPadding) .* padValue;
paddedArray(1:length(array)) = array;

if length(paddedArray) > 63
    disp('!!!!!');
    paddedArray(64:end) = [];
end

end

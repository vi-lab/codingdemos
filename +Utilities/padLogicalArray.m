function [ paddedArray ] = padLogicalArray( array, byteLength, padValue )
%PADLOGICALARRAY Summary of this function goes here
%   Detailed explanation goes here

if ~exist('byteLength', 'var')
    byteLength = 8;
end

if ~exist('padValue', 'var')
    padValue = 1;
end

padLength = byteLength - rem(length(array), byteLength);

paddedArray = cat(2, array, logical(ones(1, padLength).*padValue));
end

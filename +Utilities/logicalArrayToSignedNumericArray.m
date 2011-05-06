function [ array ] = logicalArrayToSignedNumericArray( binaryArray, padding )
%BINARYTONUMERICARRAY Summary of this function goes here
%   Detailed explanation goes here

if ~exist('padding', 'var')
    padding = 1;
end

paddedArray = Utilities.padLogicalArray(binaryArray, 8, padding);
array = Utilities.logicalToSignedDecimal(reshape(paddedArray, 8, []).');
end

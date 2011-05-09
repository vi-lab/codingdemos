function [ error, surface ] = sumOfSquaredDifference( b1, b2 )
%SUMOFABSOLUTEDIFFERENCE Summary of this function goes here
%   Detailed explanation goes here
surface = b1 - b2;
error = sum(surface(:).^2);
end

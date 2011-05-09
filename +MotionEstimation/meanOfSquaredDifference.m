function [ error, surface ] = meanOfSquaredDifference( b1, b2 )
%SUMOFABSOLUTEDIFFERENCE Summary of this function goes here
%   Detailed explanation goes here
surface = b1 - b2;
error = mean(surface(:).^2);
end

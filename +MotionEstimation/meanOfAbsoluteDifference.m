function [ error, surface ] = meanOfAbsoluteDifference( b1, b2 )
%SUMOFABSOLUTEDIFFERENCE Summary of this function goes here
%   Detailed explanation goes here
surface = b1 - b2;
error = mean(abs(surface(:)));
end

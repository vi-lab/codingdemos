function [ differential ] = differentiallyCodeDC( DCblock )
%DIFFERENTIALLYCODEDC Summary of this function goes here
%   Detailed explanation goes here

% DC values are taken in raster order, so since matlab works with row order
% we will transpose first

DCblock = reshape(DCblock.', [], 1);
differential = [DCblock(1); (DCblock(2:end) - DCblock(1:end-1))];

end

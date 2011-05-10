function [ differential ] = differentiallyCodeDC( DCblock )
%DIFFERENTIALLYCODEDC Calculate the differential values for a block of input values
%
%   +TranformCoding/differentiallyCodeDC.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   The DC values are taken in raster order if the input is a matrix. 
%
%   Ref: CCITT Rec. T.81 (1992 E) p. 28, Section A.3.5
%
%   Parameters -
%       DCblock: the input DC values (as a vector or matrix subsequently taken in row (raster) order)
%   Returns -
%       differential: the differentials vector
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

% DC values are taken in raster order, so since matlab works with row order
% we will transpose first
DCblock = reshape(DCblock.', [], 1);
differential = [DCblock(1); (DCblock(2:end) - DCblock(1:end-1))];

end

function [ data ] = dequantisationWithTable( block, table )
%DEQUANTISATIONWITHTABLE Dequantise the given block with the given quantisation table
%
%   +TranformCoding/dequantisationWithTable.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Perform dequantisation on the block with the given table.
%
%   Ref: CCITT Rec. T.81 (1992 E) p. 27-28, Section A.3.4
%
%   Parameters -
%       block: the input quantised block of DCT coefficients
%       table: the quantisation table
%   Returns -
%       quantisedBlock: the dequantised coefficient block
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

% FIXME: vectorise

data = round(block .* table);

end

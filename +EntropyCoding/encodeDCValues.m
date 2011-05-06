function [ encodedLogicalBitArray ] = encodeDCValues( diffValues, huffmanTable )
%ENCODEDCVALUES Encode a single DC value using the given Huffman Code table
%
%   +EntropyCoding/encodeDCValues.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   HELP INFO
%   Note: maximum encoded value should not exceed 16 bits.
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.
%

% To get the category of the value we simply take the length in
% bits needed to represent the number.
% http://mathworld.wolfram.com/BitLength.html
lengthsInBits = ceil( log2(abs(diffValues) + 1) );

% the huffman code is followed by the bits of the magnitude value
% Index into huffman table is length in bits + 1
diffValues(diffValues < 0) = diffValues(diffValues < 0) - 1;

% For DC maximum length for magnitude is 11 bits
% Ref: CCITT Rec. T.81 (1992 E) p.89
valueBits = Utilities.decimalToLogical(diffValues, 11);

% Note that the most significant bit of the appended bit sequence is 0 for
% negative differences and 1 for positive differences.
encodedLogicalBitArray = arrayfun(@(x)([huffmanTable{lengthsInBits(x) + 1} (valueBits(x, end - (lengthsInBits(x) - 1):end))]), ...
    1:length(lengthsInBits), 'UniformOutput', false);

end

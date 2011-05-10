function [ encodedLogicalBitArray ] = encodeDCValues( diffValues, huffmanTable )
%ENCODEDCVALUES Encode a single DC value using the given Huffman Code table
%
%   +EntropyCoding/encodeDCValues.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Encode the DC differential values with the given Huffman codes table.
%   The JPEG DC encoding process involves differentially coding the DC
%   DCT coefficient. The difference between the DC value of the current
%   block and the previous block is coded as a Huffman code representing
%   the bit length of the difference value and the magnitude of the value
%   in the minimum number of bits required to represent the 2's compliment
%   value.
%
%   Ref: CCITT Rec. T.81 (1992 E) p.88-89, Section F.1.1.5.1 and F.1.2.1
%
%   Note: maximum encoded value should not exceed 16 bits.
%
%   Parameters -
%       diffValues: the DC difference values array
%       huffmanTable: the AC coefficient Huffman code table (as a cell array of logical bit arrays)
%   Returns -
%       encodedLogicalBitArray: the resulting encoded values as a cell array of logical arrays of bits
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

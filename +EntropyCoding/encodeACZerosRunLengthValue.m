function [ encodedLogicalBitArray ] = encodeACZerosRunLengthValue( runLength, value, huffmanTable )
%ENCODEACZEROSRUNLENGTHVALUE Summary of this function goes here
%   Detailed explanation goes here
%
%   +EntropyCoding/encodeACZerosRunLengthValue.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   HELP INFO
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

% Create actual 'RS' values
% for each nonzero coefficient create the 'RS' value which is
% an 8-bit value (RRRR:SSSS) comprising of the top 4 bits
% (RRRR) encoding the run length of zeros, and (SSSS) the low 4
% bits representing the category of the amplitude of the
% coefficient magnitude. 
% The special RS values include 0xF0 representing a run of 16
% zeros (15 zeros followed by a zero) and 0x00 representing the
% end of the block (ie there are no more RS values for this
% block.

if runLength == 0 && value == 0
    % EOB : end of block marker
    encodedLogicalBitArray = huffmanTable{1};
else
    % This could be optimised as a look up table
    lengthInBits = ceil( log2(abs(value) + 1) );

    %RSbinary = Utilities.decimalNibblesToByte(runLength, lengthInBits)
    RS = (runLength * 16) + lengthInBits;

    % For AC coeffs the magnitude can be up to 10 bits long
    % Ref: CCITT Rec. T.81 (1992 E) p.90
    if value < 0
        value = value - 1;
    end

    valueBits = Utilities.decimalToLogical(value,  10);
    % Note that the most significant bit of the appended bit sequence is 0 for
    % negative differences and 1 for positive differences.
    extraBitsForMagnitude = valueBits(end - (lengthInBits - 1):end);
    encodedLogicalBitArray = [huffmanTable{RS + 1} extraBitsForMagnitude];
end

end

function [ encodedLogicalBitArray ] = encodeACZerosRunLengthValue( runLength, value, huffmanTable )
%ENCODEACZEROSRUNLENGTHVALUE Summary of this function goes here
%   Detailed explanation goes here


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

% This could be optimised as a look up table
lengthInBits = ceil( log2(abs(value) + 1) );

RS = Utilities.decimalNibblesToByte(runLength, lengthInBits);

if value > 0
    valueBits = Utilities.decimalToByte(value);
else
    valueBits = Utilities.decimalToByte(value - 1);
end

encodedLogicalBitArray = [huffmanTable{RS + 1} valueBits(end - (lengthInBits - 1):end)];

end

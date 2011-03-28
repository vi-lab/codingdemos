function [ table ] = LuminanceACHuffmanCodeCountPerCodeLength( )
%LuminanceACHuffmanCodeCountPerCodeLength The BITS array for the luminance AC Huffman tables
%   The BITS array for the luminance AC Huffman tables as recommended by
%   the standard.
%   Ref: CCITT Rec. T.81 (1992 E) p. 158, Table K.5

table = [0 2 1 3 3 2 4 3 5 5 4 4 0 0 1 125];

end

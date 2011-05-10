function [ VALUE curByte curBit ] = decodeValue( data, startByteLocation, prevBitLocation, MINCODE, MAXCODE, VALPTR, HUFFVAL )
%DECODEVALUE Decode JPEG encoded data in byte stream with given Huffman table data
%
%   +EntropyCoding/decodeValue.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Decode data from a JPEG bit stream. Implementations of the decode
%   methods specified in the standard doc, specifically DECODE (p.107),
%   RECEIVE and NEXTBIT (p.110). The tables that create MINCODE, MAXCODE
%   and VALPTR are however generated in 
%   EntropyCoding.generateDecodingProcedureTable before calling
%   decodeValue.
%
%   Ref: CCITT Rec. T.81 (1992 E) p. 107, Section F.2.2.3
%
%   Parameters -
%       data: JPEG bit stream numeric array of uint8 values
%       startByteLocation: byte index at start of current encoded value
%       prevBitLocation: the previous bit location
%       MINCODE: see EntropyCoding.generateDecodingProcedureTable
%       MAXCODE: see EntropyCoding.generateDecodingProcedureTable
%       VALPTR: see EntropyCoding.generateDecodingProcedureTable
%       HUFFVAL: the Huffman table symbol values
%   Returns -
%       VALUE: the decoded value
%       curByte: the byte index at the end of the decoded value
%       curBit: the bit location of the last bit of the decoded value
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

I = 1;

curByte = startByteLocation;
curBit = prevBitLocation + 1;

if curBit > 8
    % SKIP PAD
    if data(curByte) == 255
        if data(curByte + 1) == 0
            curByte = curByte + 1;
        else
            throw(MException('EntropyCoding:decodeValue', 'While decoding an entropy coded segment a marker was encoutered. Maybe the JPEG is corrupt?.'));
        end
    end

    curBit = 1;
    curByte = curByte + 1;
end

% this could be called number of times per byte if code is less than 1 byte
% long. maybe could compute before call this method so result is cached
%bits = Utilities.decimalToByte(data(curByte));
bits = uint32(Utilities.unsignedDecimalToByteWithLookupTable(data(curByte)));

CODE = bits(curBit);%Utilities.getBitFromNumericData(data, curByte, curBit);

% if CODE was signed when it is greater than 32767 it becomes negative
while CODE > MAXCODE(I) && CODE < 32768
%while typecast(CODE, 'int16') > MAXCODE(I)
    I = I + 1;

    % FIXME: Next bit should be a seperate routine to handle pad bytes and
    % DNL markers
    % Ref: CCITT Rec. T.81 (1992 E)	p.111, Figure F.18
    curBit = curBit + 1;
    if curBit > 8
        % SKIP PAD
        if data(curByte) == 255
            if data(curByte + 1) == 0
                curByte = curByte + 1;
            else
                throw(MException('EntropyCoding:decodeValue', 'While decoding an entropy coded segment a marker was encoutered. Maybe the JPEG is corrupt?.'));
            end
        end

        curBit = 1;
        curByte = curByte + 1;
        
        %bits = Utilities.decimalToByte(data(curByte));
        bits = uint32(Utilities.unsignedDecimalToByteWithLookupTable(data(curByte)));
        
    end
    
    CODE = bitshift(CODE,1) + bits(curBit);
end

J = VALPTR(I);
J = J + CODE - MINCODE(I);
if iscell(HUFFVAL)
    VALUE = HUFFVAL{J};
else
    VALUE = HUFFVAL(J);
end

end

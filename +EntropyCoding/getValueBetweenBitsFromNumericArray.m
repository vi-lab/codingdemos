function [ value, curByte, curBit ] = getValueBetweenBitsFromNumericArray( data, startByteLocation, prevBitLocation, lengthInBits )
%GETVALUEBETWEENBITSFROMNUMERICARRAY Return the value represented by the given length of bits in the bit stream
%
%   +EntropyCoding/getValueBetweenBitsFromNumericArray.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Designed to handle JPEG pad bytes.
%
%   Ref: CCITT Rec. T.81 (1992 E) p.91 Section F.1.2.3
%
%   Parameters -
%       data: bit stream numeric array of uint8 values
%       startByteLocation: byte index at start of current encoded value
%       prevBitLocation: the previous bit location
%       lengthInBits: the length in bits of the value to extract
%   Returns -
%       value: the unsigned value
%       curByte: the index of the byte at the end of the extract process
%       curBit: the index of the bit in the current byte at the end of the extract process
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

if lengthInBits < 1
    value = [];
    curByte = startByteLocation;
    curBit = prevBitLocation;
else

    curByte = startByteLocation;
    curBit = prevBitLocation + 1;

    if curBit > 8
        % SKIP PAD
        if data(curByte) == 255
            if data(curByte + 1) == 0
                curByte = curByte + 1;
            else
                throw(MException('EntropyCoding:getValueBetweenBitsFromNumericArray', 'While decoding an entropy coded segment a marker was encoutered. Maybe the JPEG is corrupt?.'));
            end
        end
        curBit = 1;
        curByte = curByte + 1;
    end

    bits = uint32(Utilities.unsignedDecimalToByteWithLookupTable(data(curByte)));

    value = bits(curBit);

    for i=1:lengthInBits-1
        % FIXME: Next bit should be a seperate routine to handle pad bytes and
        % DNL markers
        % Ref: CCITT Rec. T.81 (1992 E)	p.111, F.18
        curBit = curBit + 1;
        if curBit > 8
            % SKIP PAD
            if data(curByte) == 255
                if data(curByte + 1) == 0
                    curByte = curByte + 1;
                else
                    throw(MException('EntropyCoding:getValueBetweenBitsFromNumericArray', ['While decoding an entropy coded segment a marker was encoutered. Maybe the JPEG is corrupt?.']));
                end
            end
            curBit = 1;
            curByte = curByte + 1;
            bits = uint32(Utilities.unsignedDecimalToByteWithLookupTable(data(curByte)));
        end

        value = bitshift(value,1) + bits(curBit);
    end
end

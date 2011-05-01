function [ value, curByte, curBit ] = getValueBetweenBitsFromNumericArray( data, startByteLocation, prevBitLocation, lengthInBits )
%GETVALUEBETWEENBITSFROMNUMERICARRAY Summary of this function goes here
%   Detailed explanation goes here

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
                throw(MException('EntropyCoding:decodeValue', 'While decoding an entropy coded segment a marker was encoutered. Maybe the JPEG is corrupt?.'));
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
                    throw(MException('Utilities:getValueBetweenBitsFromNumericArray', ['While decoding an entropy coded segment a marker was encoutered. Maybe the JPEG is corrupt?.'])); 
                end
            end
            curBit = 1;
            curByte = curByte + 1;
            bits = uint32(Utilities.unsignedDecimalToByteWithLookupTable(data(curByte)));
        end

        value = bitshift(value,1) + bits(curBit);
    end
end

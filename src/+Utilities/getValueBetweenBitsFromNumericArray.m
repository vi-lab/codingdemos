function [ value, endByte, endBit ] = getValueBetweenBitsFromNumericArray( data, startByteLocation, startBitLocation, lengthInBits )
%GETVALUEBETWEENBITSFROMNUMERICARRAY Summary of this function goes here
%   Detailed explanation goes here

if lengthInBits < 1
    value = [];
    endByte = startByteLocation;
    endBit = startBitLocation;
else

    curByte = startByteLocation;
    curBit = startBitLocation;

    bits = Utilities.decimalToByte(data(curByte));

    value = uint16(bits(curBit));

    for i=1:lengthInBits-1
        % FIXME: Next bit should be a seperate routine to handle pad bytes and
        % DNL markers
        % Ref: CCITT Rec. T.81 (1992 E)	p.111, F.18
        curBit = curBit + 1;
        if curBit > 8
            
            % SKIP PAD
            if data(curByte) == 255
                if data(curByte + 1) == 0
                    %data(curByte + 1) = [];
                    curByte = curByte + 1;
                else
                    throw(MException('JPEGDecoder:getValueBetweenBitsFromNumericArray', ['While decoding an entropy coded segment a marker was encoutered. Maybe the JPEG is corrupt?.'])); 
                end
            end

            curBit = 1;
            curByte = curByte + 1;
            
            bits = Utilities.decimalToByte(data(curByte));
        end

        value = bitshift(value,1) + uint16(bits(curBit));
    end

    endByte = curByte;
    endBit = curBit + 1;
    if endBit > 8
        endBit = 1;
        endByte = endByte + 1;
        
        % SKIP PAD
        if data(endByte) == 255
            if data(endByte + 1) == 0
                endByte = endByte + 1;
            else
                throw(MException('JPEGDecoder:getValueBetweenBitsFromNumericArray', ['While decoding an entropy coded segment a marker was encoutered. Maybe the JPEG is corrupt?.'])); 
            end
        end
    end
end

end

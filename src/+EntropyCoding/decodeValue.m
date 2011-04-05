function [ VALUE endByte endBit ] = decodeValue( data, startByteLocation, startBitLocation, MINCODE, MAXCODE, VALPTR, HUFFVAL )
%DECODEVALUE Summary of this function goes here
%   Detailed explanation goes here
I = 1;

curByte = startByteLocation;
curBit = startBitLocation;

bits = Utilities.decimalToByte(data(curByte));

CODE = uint16(bits(curBit));%Utilities.getBitFromNumericData(data, curByte, curBit);

while typecast(CODE, 'int16') > MAXCODE(I)
    I = I + 1;
    
    CODE = bitshift(CODE,1) + uint16(bits(curBit));
    
    % next bit
    curBit = curBit + 1;
    if curBit > 8
        curBit = 1;
        curByte = curByte + 1;
        bits = Utilities.decimalToByte(data(curByte));
    end
end

J = VALPTR(I);
J = J + CODE - MINCODE(I);
VALUE = HUFFVAL(J);

endBit = curBit;
endByte = curByte;

end

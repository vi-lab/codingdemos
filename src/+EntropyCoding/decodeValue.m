function [ VALUE nextByte nextBit ] = decodeValue( data, startByteLocation, startBitLocation, MINCODE, MAXCODE, VALPTR, HUFFVAL )
%DECODEVALUE Summary of this function goes here
%   Detailed explanation goes here

I = 1;

curByte = startByteLocation;
curBit = startBitLocation;

% this could be called number of times per byte if code is less than 1 byte
% long. maybe could compute before call this method so result is cached
%bits = Utilities.decimalToByte(data(curByte));
bits = uint16(Utilities.unsignedDecimalToByteWithLookupTable(data(curByte)));

CODE = bits(curBit);%Utilities.getBitFromNumericData(data, curByte, curBit);

% if CODE was signed when it is greater than 32767 it becomes negative
while CODE > MAXCODE(I) && CODE < 32768
%while typecast(CODE, 'int16') > MAXCODE(I)
    I = I + 1;

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
                throw(MException('EntropyCoding:decodeValue', ['While decoding an entropy coded segment a marker was encoutered. Maybe the JPEG is corrupt?.'])); 
            end
        end
        
        curBit = 1;
        curByte = curByte + 1;
        
        %bits = Utilities.decimalToByte(data(curByte));
        bits = uint16(Utilities.unsignedDecimalToByteWithLookupTable(data(curByte)));
        
    end
    
    CODE = bitshift(CODE,1) + bits(curBit);
end

if CODE > 32767
   disp('16 bit code'); 
end


J = VALPTR(I);
J = J + CODE - MINCODE(I);
if iscell(HUFFVAL)
    VALUE = HUFFVAL{J};
else
    VALUE = HUFFVAL(J);
end

nextBit = curBit + 1;
nextByte = curByte;
% check next bit valid
if nextBit > 8
    nextBit = 1;
    nextByte = nextByte + 1;
    % SKIP PAD
    if data(nextByte) == 255
        if data(nextByte + 1) == 0
            nextByte = nextByte + 1;
        else
            throw(MException('EntropyCoding:decodeValue', ['While decoding an entropy coded segment a marker was encoutered. Maybe the JPEG is corrupt?.'])); 
        end
    end
end

end

function [ MINCODE MAXCODE VALPTR ] = generateDecodingProcedureTable( BITS, HUFFCODE )
%GENERATEDECODINGPROCEDURETABLE Summary of this function goes here
%   Detailed explanation goes here

I = 1;
J = 1;
while I <= 16
    
    if BITS(I) == 0
        MAXCODE(I) = -1;
    else
        VALPTR(I) = J;
        MINCODE(I) = HUFFCODE(J);
        J = J + BITS(I) - 1;
        MAXCODE(I) = HUFFCODE(J);
        J = J + 1;
    end
    
    I = I + 1;
end

MAXCODE = int16(MAXCODE);

end

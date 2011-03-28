function [ EHUFCO, EHUFSI ] = generateEncodingProcedureCodeTables( HUFFVAL, HUFFCODE, HUFFSIZE, LASTK )
%GENERATEENCODINGPROCEDURECODETABLES Summary of this function goes here
%   DESCRIBE
%   
%   Ref: CCITT Rec. T.81 (1992 E) p. 53, Figure C.3

K = 1;
conditionA = true;

while conditionA
    I = HUFFVAL(K);
    EHUFCO(I+1) = HUFFCODE(K);
    EHUFSI(I+1) = HUFFSIZE(K);
    K = K + 1;
    conditionA = (K < LASTK);
end 


end

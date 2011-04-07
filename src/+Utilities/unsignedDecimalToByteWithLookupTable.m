function [ array ] = unsignedDecimalToByteWithLookupTable( dec )
%UNSIGNEDDECIMALTOBYTEWITHLOOKUPTABLE Summary of this function goes here
%   Detailed explanation goes here

%global lookupTable;
%if isempty(lookupTable)
% Generated with 
% for i=1:256; disp([strrep(strrep(dec2bin(i-1, 8), '0', '0 '), '1', '1 ') ';']); end;
lookupTable = logical([0 0 0 0 0 0 0 0 ;
0 0 0 0 0 0 0 1 ;
0 0 0 0 0 0 1 0 ;
0 0 0 0 0 0 1 1 ;
0 0 0 0 0 1 0 0 ;
0 0 0 0 0 1 0 1 ;
0 0 0 0 0 1 1 0 ;
0 0 0 0 0 1 1 1 ;
0 0 0 0 1 0 0 0 ;
0 0 0 0 1 0 0 1 ;
0 0 0 0 1 0 1 0 ;
0 0 0 0 1 0 1 1 ;
0 0 0 0 1 1 0 0 ;
0 0 0 0 1 1 0 1 ;
0 0 0 0 1 1 1 0 ;
0 0 0 0 1 1 1 1 ;
0 0 0 1 0 0 0 0 ;
0 0 0 1 0 0 0 1 ;
0 0 0 1 0 0 1 0 ;
0 0 0 1 0 0 1 1 ;
0 0 0 1 0 1 0 0 ;
0 0 0 1 0 1 0 1 ;
0 0 0 1 0 1 1 0 ;
0 0 0 1 0 1 1 1 ;
0 0 0 1 1 0 0 0 ;
0 0 0 1 1 0 0 1 ;
0 0 0 1 1 0 1 0 ;
0 0 0 1 1 0 1 1 ;
0 0 0 1 1 1 0 0 ;
0 0 0 1 1 1 0 1 ;
0 0 0 1 1 1 1 0 ;
0 0 0 1 1 1 1 1 ;
0 0 1 0 0 0 0 0 ;
0 0 1 0 0 0 0 1 ;
0 0 1 0 0 0 1 0 ;
0 0 1 0 0 0 1 1 ;
0 0 1 0 0 1 0 0 ;
0 0 1 0 0 1 0 1 ;
0 0 1 0 0 1 1 0 ;
0 0 1 0 0 1 1 1 ;
0 0 1 0 1 0 0 0 ;
0 0 1 0 1 0 0 1 ;
0 0 1 0 1 0 1 0 ;
0 0 1 0 1 0 1 1 ;
0 0 1 0 1 1 0 0 ;
0 0 1 0 1 1 0 1 ;
0 0 1 0 1 1 1 0 ;
0 0 1 0 1 1 1 1 ;
0 0 1 1 0 0 0 0 ;
0 0 1 1 0 0 0 1 ;
0 0 1 1 0 0 1 0 ;
0 0 1 1 0 0 1 1 ;
0 0 1 1 0 1 0 0 ;
0 0 1 1 0 1 0 1 ;
0 0 1 1 0 1 1 0 ;
0 0 1 1 0 1 1 1 ;
0 0 1 1 1 0 0 0 ;
0 0 1 1 1 0 0 1 ;
0 0 1 1 1 0 1 0 ;
0 0 1 1 1 0 1 1 ;
0 0 1 1 1 1 0 0 ;
0 0 1 1 1 1 0 1 ;
0 0 1 1 1 1 1 0 ;
0 0 1 1 1 1 1 1 ;
0 1 0 0 0 0 0 0 ;
0 1 0 0 0 0 0 1 ;
0 1 0 0 0 0 1 0 ;
0 1 0 0 0 0 1 1 ;
0 1 0 0 0 1 0 0 ;
0 1 0 0 0 1 0 1 ;
0 1 0 0 0 1 1 0 ;
0 1 0 0 0 1 1 1 ;
0 1 0 0 1 0 0 0 ;
0 1 0 0 1 0 0 1 ;
0 1 0 0 1 0 1 0 ;
0 1 0 0 1 0 1 1 ;
0 1 0 0 1 1 0 0 ;
0 1 0 0 1 1 0 1 ;
0 1 0 0 1 1 1 0 ;
0 1 0 0 1 1 1 1 ;
0 1 0 1 0 0 0 0 ;
0 1 0 1 0 0 0 1 ;
0 1 0 1 0 0 1 0 ;
0 1 0 1 0 0 1 1 ;
0 1 0 1 0 1 0 0 ;
0 1 0 1 0 1 0 1 ;
0 1 0 1 0 1 1 0 ;
0 1 0 1 0 1 1 1 ;
0 1 0 1 1 0 0 0 ;
0 1 0 1 1 0 0 1 ;
0 1 0 1 1 0 1 0 ;
0 1 0 1 1 0 1 1 ;
0 1 0 1 1 1 0 0 ;
0 1 0 1 1 1 0 1 ;
0 1 0 1 1 1 1 0 ;
0 1 0 1 1 1 1 1 ;
0 1 1 0 0 0 0 0 ;
0 1 1 0 0 0 0 1 ;
0 1 1 0 0 0 1 0 ;
0 1 1 0 0 0 1 1 ;
0 1 1 0 0 1 0 0 ;
0 1 1 0 0 1 0 1 ;
0 1 1 0 0 1 1 0 ;
0 1 1 0 0 1 1 1 ;
0 1 1 0 1 0 0 0 ;
0 1 1 0 1 0 0 1 ;
0 1 1 0 1 0 1 0 ;
0 1 1 0 1 0 1 1 ;
0 1 1 0 1 1 0 0 ;
0 1 1 0 1 1 0 1 ;
0 1 1 0 1 1 1 0 ;
0 1 1 0 1 1 1 1 ;
0 1 1 1 0 0 0 0 ;
0 1 1 1 0 0 0 1 ;
0 1 1 1 0 0 1 0 ;
0 1 1 1 0 0 1 1 ;
0 1 1 1 0 1 0 0 ;
0 1 1 1 0 1 0 1 ;
0 1 1 1 0 1 1 0 ;
0 1 1 1 0 1 1 1 ;
0 1 1 1 1 0 0 0 ;
0 1 1 1 1 0 0 1 ;
0 1 1 1 1 0 1 0 ;
0 1 1 1 1 0 1 1 ;
0 1 1 1 1 1 0 0 ;
0 1 1 1 1 1 0 1 ;
0 1 1 1 1 1 1 0 ;
0 1 1 1 1 1 1 1 ;
1 0 0 0 0 0 0 0 ;
1 0 0 0 0 0 0 1 ;
1 0 0 0 0 0 1 0 ;
1 0 0 0 0 0 1 1 ;
1 0 0 0 0 1 0 0 ;
1 0 0 0 0 1 0 1 ;
1 0 0 0 0 1 1 0 ;
1 0 0 0 0 1 1 1 ;
1 0 0 0 1 0 0 0 ;
1 0 0 0 1 0 0 1 ;
1 0 0 0 1 0 1 0 ;
1 0 0 0 1 0 1 1 ;
1 0 0 0 1 1 0 0 ;
1 0 0 0 1 1 0 1 ;
1 0 0 0 1 1 1 0 ;
1 0 0 0 1 1 1 1 ;
1 0 0 1 0 0 0 0 ;
1 0 0 1 0 0 0 1 ;
1 0 0 1 0 0 1 0 ;
1 0 0 1 0 0 1 1 ;
1 0 0 1 0 1 0 0 ;
1 0 0 1 0 1 0 1 ;
1 0 0 1 0 1 1 0 ;
1 0 0 1 0 1 1 1 ;
1 0 0 1 1 0 0 0 ;
1 0 0 1 1 0 0 1 ;
1 0 0 1 1 0 1 0 ;
1 0 0 1 1 0 1 1 ;
1 0 0 1 1 1 0 0 ;
1 0 0 1 1 1 0 1 ;
1 0 0 1 1 1 1 0 ;
1 0 0 1 1 1 1 1 ;
1 0 1 0 0 0 0 0 ;
1 0 1 0 0 0 0 1 ;
1 0 1 0 0 0 1 0 ;
1 0 1 0 0 0 1 1 ;
1 0 1 0 0 1 0 0 ;
1 0 1 0 0 1 0 1 ;
1 0 1 0 0 1 1 0 ;
1 0 1 0 0 1 1 1 ;
1 0 1 0 1 0 0 0 ;
1 0 1 0 1 0 0 1 ;
1 0 1 0 1 0 1 0 ;
1 0 1 0 1 0 1 1 ;
1 0 1 0 1 1 0 0 ;
1 0 1 0 1 1 0 1 ;
1 0 1 0 1 1 1 0 ;
1 0 1 0 1 1 1 1 ;
1 0 1 1 0 0 0 0 ;
1 0 1 1 0 0 0 1 ;
1 0 1 1 0 0 1 0 ;
1 0 1 1 0 0 1 1 ;
1 0 1 1 0 1 0 0 ;
1 0 1 1 0 1 0 1 ;
1 0 1 1 0 1 1 0 ;
1 0 1 1 0 1 1 1 ;
1 0 1 1 1 0 0 0 ;
1 0 1 1 1 0 0 1 ;
1 0 1 1 1 0 1 0 ;
1 0 1 1 1 0 1 1 ;
1 0 1 1 1 1 0 0 ;
1 0 1 1 1 1 0 1 ;
1 0 1 1 1 1 1 0 ;
1 0 1 1 1 1 1 1 ;
1 1 0 0 0 0 0 0 ;
1 1 0 0 0 0 0 1 ;
1 1 0 0 0 0 1 0 ;
1 1 0 0 0 0 1 1 ;
1 1 0 0 0 1 0 0 ;
1 1 0 0 0 1 0 1 ;
1 1 0 0 0 1 1 0 ;
1 1 0 0 0 1 1 1 ;
1 1 0 0 1 0 0 0 ;
1 1 0 0 1 0 0 1 ;
1 1 0 0 1 0 1 0 ;
1 1 0 0 1 0 1 1 ;
1 1 0 0 1 1 0 0 ;
1 1 0 0 1 1 0 1 ;
1 1 0 0 1 1 1 0 ;
1 1 0 0 1 1 1 1 ;
1 1 0 1 0 0 0 0 ;
1 1 0 1 0 0 0 1 ;
1 1 0 1 0 0 1 0 ;
1 1 0 1 0 0 1 1 ;
1 1 0 1 0 1 0 0 ;
1 1 0 1 0 1 0 1 ;
1 1 0 1 0 1 1 0 ;
1 1 0 1 0 1 1 1 ;
1 1 0 1 1 0 0 0 ;
1 1 0 1 1 0 0 1 ;
1 1 0 1 1 0 1 0 ;
1 1 0 1 1 0 1 1 ;
1 1 0 1 1 1 0 0 ;
1 1 0 1 1 1 0 1 ;
1 1 0 1 1 1 1 0 ;
1 1 0 1 1 1 1 1 ;
1 1 1 0 0 0 0 0 ;
1 1 1 0 0 0 0 1 ;
1 1 1 0 0 0 1 0 ;
1 1 1 0 0 0 1 1 ;
1 1 1 0 0 1 0 0 ;
1 1 1 0 0 1 0 1 ;
1 1 1 0 0 1 1 0 ;
1 1 1 0 0 1 1 1 ;
1 1 1 0 1 0 0 0 ;
1 1 1 0 1 0 0 1 ;
1 1 1 0 1 0 1 0 ;
1 1 1 0 1 0 1 1 ;
1 1 1 0 1 1 0 0 ;
1 1 1 0 1 1 0 1 ;
1 1 1 0 1 1 1 0 ;
1 1 1 0 1 1 1 1 ;
1 1 1 1 0 0 0 0 ;
1 1 1 1 0 0 0 1 ;
1 1 1 1 0 0 1 0 ;
1 1 1 1 0 0 1 1 ;
1 1 1 1 0 1 0 0 ;
1 1 1 1 0 1 0 1 ;
1 1 1 1 0 1 1 0 ;
1 1 1 1 0 1 1 1 ;
1 1 1 1 1 0 0 0 ;
1 1 1 1 1 0 0 1 ;
1 1 1 1 1 0 1 0 ;
1 1 1 1 1 0 1 1 ;
1 1 1 1 1 1 0 0 ;
1 1 1 1 1 1 0 1 ;
1 1 1 1 1 1 1 0 ;
1 1 1 1 1 1 1 1]);
%end

array = lookupTable(dec+1, :);

end

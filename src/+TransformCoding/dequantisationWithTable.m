function [ data ] = dequantisationWithTable( block, table )
%DEQUANTISATIONWITHTABLE Summary of this function goes here
%   Detailed explanation goes here
%QUANTISATION Summary of this function goes here
%   Detailed explanation goes here
data = round(block .* table);

end

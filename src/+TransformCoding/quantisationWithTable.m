function [ quantisedBlock ] = quantisationWithTable( block, table )
%QUANTISATION Summary of this function goes here
%   Detailed explanation goes here
quantisedBlock = round(block ./ table);

end

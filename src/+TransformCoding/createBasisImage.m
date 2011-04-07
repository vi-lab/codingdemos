function [ im ] = createBasisImage( x, y, sz )
%CREATEBASISIMAGE Summary of this function goes here
%   Detailed explanation goes here

if ~exist('sz', 'var')
    sz = [8 8];
end

c = zeros(sz(1), sz(2));

c(y, x) = 1;

im = idct2(c);

end

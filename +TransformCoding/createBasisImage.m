function [ im ] = createBasisImage( x, y, sz )
%CREATEBASISIMAGE Creates a DCT recontruction with only 1 coefficient
%
%   +TranformCoding/createBasisImage.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Creates a IDCT of only a single coefficient. This response thus is an
%   image of the actual basis represented by the particular coefficient.
%
%   Parameters -
%       x, y: the x and y coordinate of the coefficient to retain, i.e. the coefficient to generate the basis for
%   Optional Parameters -
%       sz: the size vector ([rows, columns]) of the DCT block, defaults to [8, 8]
%   Returns -
%       im: the IDCT result
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

if ~exist('sz', 'var')
    sz = [8 8];
end

c = zeros(sz(1), sz(2));

c(y, x) = 1;

im = idct2(c);

end

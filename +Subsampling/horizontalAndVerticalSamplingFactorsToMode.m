function [ mode ] = horizontalAndVerticalSamplingFactorsToMode( yHi, yVi, cbHi, cbVi, crHi, crVi )
%HORIZONTALANDVERTICALSAMPLINGFACTORSTOMODE Convert JPEG sampling factors to an actual sampling mode string.
%
%   +Subsampling/horizontalAndVerticalSamplingFactorsToMode.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   The sampling factors are essentially encoded relative to the maximum
%   sampling factors for the particular dimension. Thus the sampling rate
%   is Hi/Hmax and Vi/Vmax, and thus channels with more samples actually
%   have larger sampling factors Vi,Hi. For an image of size (X,Y) 100x100,
%   if the Y channel is 100x100 and the chroma channels 25x25 then the
%   maximum sampling factor is 4. Hence for the Y channel the number of
%   rows for example = y = Y(Vi/4). Since the Y channel is the same size as
%   the original y = 100, Y = 100 therefore Vi = 4. For the chroma channels
%   however y = 25, Y = 100, therefore Vi = 1.
%
%   Ref: CCITT Rec. T.81 (1992 E)   p. 24, Section A.1.1
%
%   Parameters -
%       yHi, yVi, cbHi, cbVi, crHi, crVi: The Horizontal and Vertical sampling factors for the Y, Cb and Cr channels
%   Returns -
%       mode: the subsampling mode string e.g. '4:2:2'
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.



% See: http://en.wikipedia.org/wiki/Chroma_subsampling
% This technique works for the subsampling modes used here. Given a factor
% of 4 for J, the factor for a is the J factor divided by the max
% horizontal sampling factor and the b factor is equal to a when the 
% vertical sampling is 1, and 0 otherwise

m1 = 4; m2 = 4; m3 = 4;

mHi = max([yHi cbHi crHi]);
mVi = max([yVi cbVi crVi]);

m2 = m1 / mHi;
if mVi == 1
    m3 = m2;
else
    m3 = 0;
end

mode = [num2str(m1) ':' num2str(m2) ':' num2str(m3)];

end

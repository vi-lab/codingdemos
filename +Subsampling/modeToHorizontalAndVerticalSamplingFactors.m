function [ yHi yVi cbHi cbVi crHi crVi ] = modeToHorizontalAndVerticalSamplingFactors( mode )
%MODETOHORIZONTALANDVERTICALSAMPLINGFACTOR Convert a mode string to JPEG sampling factors.
%
%   +Subsampling/modeToHorizontalAndVerticalSamplingFactors.m
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
%       mode: the subsampling mode string e.g. '4:2:2'
%   Returns -
%       yHi, yVi, cbHi, cbVi, crHi, crVi: The Horizontal and Vertical sampling factors for the Y, Cb and Cr channels
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.
 
switch mode
    case '4:4:4' 
        % no subsampling : Hmax = 1, Vmax = 1
        yHi = 1; yVi = 1; 
        cbHi = 1; cbVi = 1; 
        crHi = 1; crVi = 1;
    case '4:4:0' 
        % chroma all columns, half rows : Hmax = 1, Vmax = 2
        yHi = 1; yVi = 2; 
        cbHi = 1; cbVi = 1; 
        crHi = 1; crVi = 1;
    case '4:2:2' 
        % chroma all rows, half columns : Hmax = 2, Vmax = 1
        yHi = 2; yVi = 1; 
        cbHi = 1; cbVi = 1; 
        crHi = 1; crVi = 1;
    case '4:2:0' 
        % chroma half rows and columns : Hmax = 2, Vmax = 2
        yHi = 2; yVi = 2; 
        cbHi = 1; cbVi = 1; 
        crHi = 1; crVi = 1;
    case '4:1:1' 
        % chroma all rows, quarter columns : Hmax =4, Vmax = 1
        yHi = 4; yVi = 1; 
        cbHi = 1; cbVi = 1; 
        crHi = 1; crVi = 1;
    case '4:1:0' 
        % chroma half rows, quarter columns : Hmax = 4, Vmax = 2
        yHi = 4; yVi = 2; 
        cbHi = 1; cbVi = 1; 
        crHi = 1; crVi = 1;
end

end

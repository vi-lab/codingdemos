function [ modes ] = supportedModes( )
%SUPPORTEDMODES The supported modes of the subsampling package
%
%   +Subsampling/supportedModes.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Subsampling modes are normally described as a triplet of values
%   corresponding to the number of samples for chroma and luminance in each
%   direction of a block of pixels of size 4x2. The triplet is described in
%   the form 'J:a:b' where 'J' is the number of luminance pixels in a row
%   of the Jx2 block, 'a' is the number of chroma pixels in the first row
%   over the span of the 'J' pixels, ie 'J/a' is the sampling rate of the
%   chroma on the first row. 'b' is the same as 'a' but for the second row.
%   Hence '4:2:0' means a block of 4x2 pixels has 4 luma pixels per row, 2
%   chroma samples in the first row and no chroma samples in the second
%   row.
%   
%   The following reference provides a good introduction to this topic
%   Ref: http://dougkerr.net/pumpkin/articles/Subsampling.pdf
%
%   Returns:
%       modes: a cell array of mode strings
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.


    modes = {'4:4:4','4:4:0','4:2:2','4:2:0','4:1:1','4:1:0'};
end

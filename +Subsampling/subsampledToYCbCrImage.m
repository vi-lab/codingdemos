function [ ycbcrimage ] = subsampledToYCbCrImage( simage, upsampleFilter )
%SUBSAMPLEDTOYCBCRIMAGE Convert a subsampled image struct to a ycbcr image
%
%   +Subsampling/subsampledToYCbCrImage.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   The input image must be a subsampled image struct. Optionally specify
%   an interpolation mode.
%   The subsampled image struct must contain a y, cb and cr field.
%
%   Parameters -
%       simage: the subsampled image struct to convert
%   Optional Parameters -
%       upsampleFilter: the upsampling filter name string, e.g. 'bilinear'
%   Returns -
%       ycbcrimage: an (h,w,d) YCbCr image matrix (in the same type as the type of the input struct fields)
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.


if ~exist('upsampleFilter', 'var')
    upsampleFilter = 'bilinear';
end

if isfield(simage, {'y','cb','cr'})
    osize = size(simage.y);
    ycbcrimage = uint8(zeros(osize(1), osize(2), 3));
    ycbcrimage(:,:,1) = simage.y;
    ycbcrimage(:,:,2) = imresize(simage.cb, [osize(1) osize(2)], upsampleFilter);
    ycbcrimage(:,:,3) = imresize(simage.cr, [osize(1) osize(2)], upsampleFilter);
else 
    throw(MException('Subsample:NoColourChannels', 'The input image must be a struct with y, cb and cr or r, g, b fields corresponding to the 3 channels.'));
end

end

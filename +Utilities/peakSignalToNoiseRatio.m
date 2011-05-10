function PSNR = peakSignalToNoiseRatio(b1, b2)
%PEAKSIGNALTONOISERATIO Calculate the PSNR between two matricies or vectors
%
%   +Utilites/peakSignalToNoiseRatio.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   The peak signal to noise ratio is described here:
%   http://en.wikipedia.org/wiki/Peak_signal-to-noise_ratio
%
%   Parameters -
%       b1, b2: the input vectors or matricies
%   Returns -
%       PSNR: the signal to noise ratio
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

% First compute the mean square error
MSE = mean2((b1 - b2).^2 );
PSNR = 10*log10((255^2) / double(MSE));
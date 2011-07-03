function [ motionVectors predictionError ] = createMotionVectorsAndPredictionError( inputImageStruct, referenceFrameStruct, blockMatching)
%CREATEMOTIONVECTORSANDPREDICTIONERROR 
%
%   +MotionEstimation/createMotionVectorsAndPredictionError.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

% Support algorithms:
%{
    From http://en.wikipedia.org/wiki/Block-matching_algorithm
    Full Search Algorithm (FSA)
    Diamond Search Algorithm (DSA)
%}
switch blockMatching.algorithm
    case {'FSA', 'full', 'fullsearch'}
        searchAlgorithm = @MotionEstimation.fullSearch;
    case {'DSA', 'diamond', 'diamondsearch'}
        searchAlgorithm = @MotionEstimation.diamondSearch;
end

switch lower(blockMatching.differenceCalculation)
    case {'sad', 'sumofabsolutedifferences'}
        blockMatching.matchFunction = @MotionEstimation.sumOfAbsoluteDifference;
    case {'mad', 'meanofabsolutedifferences'}
        blockMatching.matchFunction = @MotionEstimation.meanOfAbsoluteDifference;
    case {'ssd', 'sumofsquaredifferences'}
        blockMatching.matchFunction = @MotionEstimation.sumOfSquaredDifference;
    case {'msd', 'meanofsquaredifferences'}
        blockMatching.matchFunction = @MotionEstimation.meanOfSquaredDifference;
end

inp = double(Subsampling.subsampledToYCbCrImage(inputImageStruct));
ref = double(Subsampling.subsampledToYCbCrImage(referenceFrameStruct));
[motionVectors predictionError] = searchAlgorithm(inp, ref, blockMatching);

end

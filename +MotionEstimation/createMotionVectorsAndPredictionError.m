function [ motionVectors predictionError ] = createMotionVectorsAndPredictionError( inputImageStruct, referenceFrameStruct, blockMatching)
%CREATEMOTIONVECTORSANDPREDICTIONERROR Summary of this function goes here
%   Detailed explanation goes here

switch blockMatching.algorithm
    case {'FSA', 'full', 'fullsearch'}
        searchAlgorithm = @MotionEstimation.fullSearch;
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

inp = Subsampling.subsampledToYCbCrImage(inputImageStruct);
ref = Subsampling.subsampledToYCbCrImage(referenceFrameStruct);
[motionVectors predictionError] = searchAlgorithm(inp, ref, blockMatching);

end

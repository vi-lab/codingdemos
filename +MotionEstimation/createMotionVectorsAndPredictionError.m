function [ motionVectors predictionError ] = createMotionVectorsAndPredictionError( inputImageStruct, referenceFrameStruct, blockMatchingAlgorithm )
%CREATEMOTIONVECTORSANDPREDICTIONERROR Summary of this function goes here
%   Detailed explanation goes here
motionVectors = [];

predictionError = Subsampling.subsampledToYCbCrImage(inputImageStruct);
end

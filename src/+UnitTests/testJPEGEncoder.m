function [ success ] = testJPEGEncoder( input_args )
%TESTJPEGENCODER Summary of this function goes here
%   Detailed explanation goes here
clear classes

%try 
    % test code
    obj.imageEncoder = JPEGEncoder();
    %obj.imageEncoder.input = 'lena_color_odd.bmp';
    obj.imageEncoder.input = 'lena_color_256.bmp';
    %obj.imageEncoder.input = 'lena_color_512.bmp';
    obj.imageEncoder.qualityFactor = 75;
    tic
	obj.imageEncoder.encodeToFile('test.jpg');    
    toc
    UnitTests.displayCJPEGDecode('test')
    
    success = true;
%{
catch ME
    disp('*** Unit Test Failure: ***');
    disp(mfilename('fullpath'));
    disp(ME.identifier);
    disp(ME.message);
    disp(ME.stack);
    success = false;
end
%}

end

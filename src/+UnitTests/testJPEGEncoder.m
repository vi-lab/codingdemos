function [ success ] = testJPEGEncoder( input_args )
%TESTJPEGENCODER Summary of this function goes here
%   Detailed explanation goes here
clear classes

%try 
    % test code
    obj.imageEncoder = JPEGEncoder();
    %obj.imageEncoder.input = 'lena_color_odd.bmp';
    obj.imageEncoder.input = 'lena_color_256.bmp';
    obj.imageEncoder.encode();
    
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
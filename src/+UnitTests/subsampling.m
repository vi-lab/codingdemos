function [ success ] = subsampling( )
%SUBSAMPLING Summary of this function goes here
%   Detailed explanation goes here

I = rgb2ycbcr(imread('lena_color_256.bmp'));
try 
    %s422 = Subsampling.imageTo422(I);
    s422 = Subsampling.ycbcrImageToSubsampled(I, 'Mode', '4:2:2' );

    %s420 = Subsampling.imageTo420(I);
    s420 = Subsampling.ycbcrImageToSubsampled(I, 'Mode', '4:2:0' );
    
    %r422 = Subsampling.s422ToImage(s422);
    r422 = Subsampling.subsampledToYCbCrImage(s422);

    %r420 = Subsampling.s420ToImage(s420);
    r420 = Subsampling.subsampledToYCbCrImage(s420);
    
    h = figure(1);
    set(h, 'Name', '4:4:4');
    imshow(ycbcr2rgb(uint8(I)));
    h = figure(2);
    set(h, 'Name', '4:2:2');
    Subsampling.subsampledImageShow(s422);
    h = figure(3);
    set(h, 'Name', '4:2:0');
    Subsampling.subsampledImageShow(s420);
    success = true;
catch ME
    
    disp('*** Unit Test Failure: ***');
    disp(mfilename('fullpath'));
    disp(ME.identifier);
    disp(ME.message);
    disp(ME.stack);
    success = false;
end

end

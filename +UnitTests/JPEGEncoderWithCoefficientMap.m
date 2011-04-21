function [ output_args ] = JPEGEncoderWithCoefficientMap( input_args )
%JPEGENCODERWITHCOEFFICIENTMAP Summary of this function goes here
%   Detailed explanation goes here

map = [
    0 1 1 0 0 0 0 0
    1 1 0 0 0 0 0 0
    1 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0
    ];

obj = JPEGEncoder('exampleImages/lena_color_256.bmp'); 

obj.encodeToFile('test.jpg', 'CoefficientMap', map);

imshow(imread('test.jpg'));

end

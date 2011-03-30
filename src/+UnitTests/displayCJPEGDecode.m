function [ output_args ] = displayCJPEGDecode( fileName )
%DISPLAYCJPEGDECODE Summary of this function goes here
%   Detailed explanation goes here

fid = fopen(fileName);
im = fread(fid, inf, '*uint8');
im = reshape(im, [sqrt(length(im)) sqrt(length(im))]);
fclose(fid);

subplot(2,2,1),imshow(im.')

fid = fopen([fileName '.jpg.2']);
im = fread(fid, inf, '*uint8');
im = reshape(im, [sqrt(length(im)) sqrt(length(im))]);
fclose(fid);

subplot(2,2,2),imshow(im.')

fid = fopen([fileName '.jpg.3']);
im = fread(fid, inf, '*uint8');
im = reshape(im, [sqrt(length(im)) sqrt(length(im))]);
fclose(fid);

subplot(2,2,3),imshow(im.')

end

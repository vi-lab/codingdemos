% test

% class for app, which contains all data, and then methods on this to do
% all manipulations
clear all;

I = imread('cameraman.tif');

entropy(I)

qf = 50; % 1 to 31


qt = TransformCoding.qualityFactorToQuantisationTable(TransformCoding.ACLuminanceQuantisationTable, qf);


fun = @dct2;
J = blkproc(I,[8 8],fun);


% write quant process. 

% block value / (respective val in quant matrix / Q)
% ./ (quantMatrix/Q)

% how will annon function here get hold of the necessary data? CLASS
% STATICS

fun = @(x) ( round(x ./ ([17,12,11,17,25,41,52,62;13,13,15,20,27,59,61,56;15,14,17,25,41,58,70,57;15,18,23,30,52,88,81,63;19,23,38,57,69,110,104,78;25,36,56,65,82,105,114,93;50,65,79,88,104,122,121,102;73,93,96,99,113,101,104,100;])) ); %quant(x, 100));
K = blkproc(J,[8 8],fun);


% zigzag indicies in column order
%idx = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];
%fun = @(x) ( x([1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7
%14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64]));
zigzag = blkproc(K,[8 8],@TransformCoding.coefficientOrdering);
% ordered as 32 x 2048, ie 32 by 32 blocks where for each block all values
% are as vector


rlcd = blkproc(zigzag,[1 64],@TransformCoding.zerosRunLengthCoding);

% dequant
fun = @(x) ( x .* ([17,12,11,17,25,41,52,62;13,13,15,20,27,59,61,56;15,14,17,25,41,58,70,57;15,18,23,30,52,88,81,63;19,23,38,57,69,110,104,78;25,36,56,65,82,105,114,93;50,65,79,88,104,122,121,102;73,93,96,99,113,101,104,100;]) ); %quant(x, 100));
IK = blkproc(K,[8 8],fun);


fun = @idct2;
R = blkproc(IK,[8 8],fun);

entropy(R)

figure(1),imagesc(abs(I-uint8(R)))
figure(2),imshow(I)
figure(3),imshow(uint8(R))


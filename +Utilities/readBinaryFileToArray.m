function array = readBinaryFileToArray( fileName, mode )
%READBINARYFILETOARRAY Reads the input file and optionally converts it to a logical bit array
%
%   +Utilites/readBinaryFileToArray.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Parameters -
%       fileName: the file to create
%   Optional Parameters -
%       mode: the optional mode, either 'numeric' or 'logical'
%   Returns -
%       array: the file array, numeric or logical array
%   
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

if ~exist('mode', 'var')
    mode = 'numeric';
end

fid = fopen(fileName,'rb');
if fid ~= -1
    array = fread(fid, inf, 'uint8');
    fclose(fid);
    if strcmpi(mode, 'logical')
        % convert to logical
        array = Utilities.unsignedNumericArrayToLogicalArray(array);
    end
else
    throw(MException('Utilities:readBinaryFileToLogicalArray', 'File could not be opened.')); 
end

end

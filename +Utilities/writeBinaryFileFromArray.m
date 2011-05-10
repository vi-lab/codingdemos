function success = writeBinaryFileFromArray( fileName, array )
%WRITEBINARYFILEFROMARRAY Creates the named file with the uint8 data array
%
%   +Utilites/writeBinaryFileFromArray.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Parameters -
%       fileName: the file to create
%       array: the data to write, a uint8 array
%   Returns -
%       byte: the 8 bit logical bit array
%   
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

fid = fopen(fileName,'wb');
if fid ~= -1
    fwrite(fid, array, 'uint8');
    fclose(fid);
    success = true;
else
    success = false;
end

end

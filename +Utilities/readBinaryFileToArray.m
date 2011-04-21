function array = readBinaryFileToArray( fileName, mode )
%WRITEBINARYFILEFROMARRAY Summary of this function goes here
%   Detailed explanation goes here

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

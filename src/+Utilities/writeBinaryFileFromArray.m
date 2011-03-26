function success = writeBinaryFileFromArray( fileName, array )
%WRITEBINARYFILEFROMARRAY Summary of this function goes here
%   Detailed explanation goes here

fid = fopen(fileName,'wb');
if fid ~= -1
    fwrite(fid, array, 'uint8');
    fclose(fid);
    success = true;
else
    success = false;
end

end

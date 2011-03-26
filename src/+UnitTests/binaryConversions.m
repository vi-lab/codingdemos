function [ success ] = binaryConversions( input_args )
%BINARYCONVERSIONS Summary of this function goes here
%   Detailed explanation goes here

try 
    % test code
    if ~isequal(logical([0 1 1 1 1 0 1 1]), Utilities.decimalToByte(123))
        throw(MException('unittest:binaryConversions','decimalToByte 1 failed'));
    end
    if ~isequal(logical([1 1 1 1 1 1 1 1]), Utilities.decimalToByte(1001))
        throw(MException('unittest:binaryConversions','decimalToByte 2 failed'));
    end
    if ~isequal(logical([0 0 0 0 0 0 1 1 1 1 1 0 1 0 0 1]), Utilities.decimalToShort(1001))
        throw(MException('unittest:binaryConversions','decimalToShort 1 failed'));
    end
    if ~isequal(logical([1 1 1 1 0 0 1 1]), Utilities.hexToByte('F3'))
        throw(MException('unittest:binaryConversions','hexToByte 1 failed'));
    end
    if ~isequal(logical([1 1 1 0 0 0 1 1 1 1 0 1 1 0 1 0]), Utilities.hexToShort('E3DA'))
        throw(MException('unittest:binaryConversions','hexToShort 1 failed'));
    end
    if ~isequal(logical([1 0 1 0 0 0 0 1]), Utilities.decimalNibblesToByte(10, 1))
        throw(MException('unittest:binaryConversions','decimalNibblesToByte 1 failed'));
    end
    if ~isequal(logical([1 0 1 0 1 0 1 1]), Utilities.hexNibblesToByte('A', 'B'))
        throw(MException('unittest:binaryConversions','hexNibblesToByte 1 failed'));
    end
    if Utilities.logicalToDecimal(logical([1 0 1 0 1 0 1 1])) ~= 171
        throw(MException('unittest:binaryConversions','logicalToDecimal 1 failed'));
    end
    if ~isequal([10 171 129], Utilities.binaryToNumericArray(logical([0 0 0 0 1 0 1 0 1 0 1 0 1 0 1 1 1 0 0 0 0 0 0])))
        throw(MException('unittest:binaryConversions','binaryToNumericArray 1 failed'));
    end
    
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

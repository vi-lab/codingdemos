function [ success ] = generateHuffmanTables( input_args )
%TEMPLATE Summary of this function goes here
%   Detailed explanation goes here


try 
    % test code
    bits = EntropyCoding.LuminanceDCHuffmanCodeCountPerCodeLength;
    huffvals = EntropyCoding.LuminanceDCHuffmanSymbolValuesPerCode;
    [huffsize, lastk] = EntropyCoding.generateTableOfHuffmanCodeSizes(bits);
    huffcode = EntropyCoding.generateTableOfHuffmanCodes(huffsize);
    [ehufco, ehufsi] = EntropyCoding.generateEncodingProcedureCodeTables( huffvals, huffcode, huffsize, lastk );
    disp('Luminance DC Huffman Codes');
    for i=1:length(ehufco)
        disp(dec2bin(ehufco(i), ehufsi(i)))
    end
    
    bits = EntropyCoding.ChromaDCHuffmanCodeCountPerCodeLength;
    huffvals = EntropyCoding.ChromaDCHuffmanSymbolValuesPerCode;
    [huffsize, lastk] = EntropyCoding.generateTableOfHuffmanCodeSizes(bits);
    huffcode = EntropyCoding.generateTableOfHuffmanCodes(huffsize);
    [ehufco, ehufsi] = EntropyCoding.generateEncodingProcedureCodeTables( huffvals, huffcode, huffsize, lastk );
    disp('Chroma DC Huffman Codes');
    for i=1:length(ehufco)
        disp(dec2bin(ehufco(i), ehufsi(i)))
    end
    
    bits = EntropyCoding.LuminanceACHuffmanCodeCountPerCodeLength;
    huffvals = EntropyCoding.LuminanceACHuffmanSymbolValuesPerCode;
    [huffsize, lastk] = EntropyCoding.generateTableOfHuffmanCodeSizes(bits);
    huffcode = EntropyCoding.generateTableOfHuffmanCodes(huffsize);
    [ehufco, ehufsi] = EntropyCoding.generateEncodingProcedureCodeTables( huffvals, huffcode, huffsize, lastk );
    disp('Luminance AC Huffman Codes');
    for i=1:length(ehufco)
        disp(dec2bin(ehufco(i), ehufsi(i)))
    end
    
    bits = EntropyCoding.ChromaACHuffmanCodeCountPerCodeLength;
    huffvals = EntropyCoding.ChromaACHuffmanSymbolValuesPerCode;
    [huffsize, lastk] = EntropyCoding.generateTableOfHuffmanCodeSizes(bits);
    huffcode = EntropyCoding.generateTableOfHuffmanCodes(huffsize);
    [ehufco, ehufsi] = EntropyCoding.generateEncodingProcedureCodeTables( huffvals, huffcode, huffsize, lastk );
    disp('Chroma AC Huffman Codes');
    for i=1:length(ehufco)
        disp(dec2bin(ehufco(i), ehufsi(i)))
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

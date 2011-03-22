function huffcode = DCHuffmanLuminanceCodeTable( cat )

% INFO 

cat = cat + 1;

DC_lum_huff = { '00'
                '010'
                '011'
                '100'
                '101'
                '110'
                '1110'
                '11110'
                '111110'
                '1111110'
                '11111110'
                '111111110'};

huffcode = DC_lum_huff{cat}; 

return
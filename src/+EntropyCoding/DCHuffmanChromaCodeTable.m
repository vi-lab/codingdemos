function huffcode = DCHuffmanChromaCodeTable( cat, chan )

cat = cat + 1;

DC_chr_huff = { '00'
                '01'
                '10'
                '110'
                '1110'
                '11110'
                '111110'
                '1111110'
                '11111110'
                '111111110'
                '1111111110'
                '11111111110'};

huffcode = DC_chr_huff{cat}; 

return
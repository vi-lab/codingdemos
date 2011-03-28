function [ table ] = LuminanceACHuffmanSymbolValuesPerCode( )
%LuminanceACHuffmanSymbolValuesPerCode The HUFFVALS array for the luminance AC Huffman tables
%   The HUFFVALS array for the luminance AC Huffman tables as recommended by
%   the standard.
%   Ref: CCITT Rec. T.81 (1992 E) p. 158, Table K.5

%{
In Hex
01 02 03 00 04 11 05 12 21 31 41 06 13 51 61 07
22 71 14 32 81 91 A1 08 23 42 B1 C1 15 52 D1 F0 
24 33 62 72 82 09 0A 16 17 18 19 1A 25 26 27 28 
29 2A 34 35 36 37 38 39 3A 43 44 45 46 47 48 49 
4A 53 54 55 56 57 58 59 5A 63 64 65 66 67 68 69 
6A 73 74 75 76 77 78 79 7A 83 84 85 86 87 88 89 
8A 92 93 94 95 96 97 98 99 9A A2 A3 A4 A5 A6 A7 
A8 A9 AA B2 B3 B4 B5 B6 B7 B8 B9 BA C2 C3 C4 C5 
C6 C7 C8 C9 CA D2 D3 D4 D5 D6 D7 D8 D9 DA E1 E2 
E3 E4 E5 E6 E7 E8 E9 EA F1 F2 F3 F4 F5 F6 F7 F8 
F9 FA
%}

% Table ordered by length, starting with 1 bit on the first line and going
% to 16 bits on the last
table = [ ...               % 1 bit
    1 2 ...                 % 2 bits
    3 ...                   % 3 bits
    0 4 17 ...
    5 18 33 ...
    49 65 ...
    6 19 81 97 ...
    7 34 113 ...
    20 50 129 145 161 ...
    8 35 66 177 193 ...
    21 82 209 240 ...
    36 51 98 114 ...
    ...
    ...                     % 14 bits 
    130 ...                 % 15 bits
    9 10 22 23 24 25 26 37 38 39 40 41 42 52 53 54 55 56 57 58 67 68 69 70 71 72 73 74 83 84 85 86 87 88 89 90 99 100 101 102 103 104 105 106 115 116 117 118 119 120 121 122 131 132 133 134 135 136 137 138 146 147 148 149 150 151 152 153 154 162 163 164 165 166 167 168 169 170 178 179 180 181 182 183 184 185 186 194 195 196 197 198 199 200 201 202 210 211 212 213 214 215 216 217 218 225 226 227 228 229 230 231 232 233 234 241 242 243 244 245 246 247 248 249 250];
end

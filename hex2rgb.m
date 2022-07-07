function rgb = hex2rgb( hex )
% HEX2RGB converts hex color triplets to rgb triplets.
% 
% Usage:
% rgb = hex2rgb( hex )
% 
% Input:
% hex:  a character array describing a hexadecimal color triplet. 
%       E.g.: 'FF909F'.
% 
% Output: 
% rgb: an RGB triplet. E.g. [ 255 144 159 ].

eachHex = regexp( hex, '[0-9A-F]{2}', 'match' );
rgb = nan( 1, 3 );
for i = 1 : 3
    rgb( 1, i ) = hex2dec( eachHex{ i } );
    
end
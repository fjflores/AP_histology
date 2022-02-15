function rgb = hex2rgb( hex )

match = regexp( hex, '([A-F]{2})', 'match' );
for i = 1 : numel( match )
    rgb( 1, i ) = hex2dec( match{ i } );
    
end
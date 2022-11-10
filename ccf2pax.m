function trPoints = ccf2pax( points )
% CCF2PAX converts ccf coordintaes to paxinos atlas.
% 
% Usage:
% trPoints = ccf2pax( points )
% 
% Input:
% points: 3 x n matrix of histology points in CCF coordinates from 
%         AP_get_probe_histology.
% 
% Output:
% trPoitns: 3 x n matrix of histology points in paxinos coordinates.

% NOTE
% Paxinos coordinates are in mm and relative to bregma, where:
% X = ML = left is negative, right is postivie
% Y = DV = dorsal is negative, ventral is positive
% Z = AP = posterior is negative, anterior is positive

bregma = allenCCFbregma();
x = ( points( :, 1 ) - bregma( 1 ) ) / 100; % AP
z = ( ( points( :, 2 ) - bregma( 2 ) ) / 100 ) * 0.945; % DV
y = ( points( :, 3 ) - bregma( 3 ) ) / 100; % ML

trPoints = [ y z -x ];

warning( [ 'Converted to Paxinos coordinates where negative ML values',...
    ' are in left hemisphere.' ] )

end
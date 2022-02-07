function [ xyzEst, R2 ] = fit3d( xyz )
% FIT3D outputs line fit to a cloud of points in 3d.
% 
% Usage:
% [ xyzEst, R2 ] = fit3d( xyz )
% 
% Input:
% xyz: matrix where rows are the observations and columns are the x, y and
%      z coordinates.
% 
% Output:
% xyzEst: start and end points for best fit, formatted as xyz.
% R2: r-squared value for the fit.

xyzHat = mean( xyz, 1 );
A = xyz - xyzHat;
N = length( A );
C = ( A' * A ) / ( N - 1 );
[ R, D, ~ ] = svd( C, 0 );
D = diag( D );
R2 = D( 1 ) / sum( D );
x = A * R( :, 1 );    % project residuals on R(:,1)
xMin = min( x );
xMax = max( x );
dx = xMax - xMin;
Xa = ( xMin + 0.01 * dx ) * R( :, 1 )' + xyzHat;
Xb = ( xMax + 0.05 * dx ) * R( :, 1 )' + xyzHat;
xyzEst = [ Xa; Xb ];
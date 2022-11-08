function [ vol, A, Cx, Cy, Cz ] = polyhedronvac( V, F )
% POLYHEDRONVAC Finds volume, surface area, and centroid of a polyhedron
%
% Usage:
% [ vol, A, Cx, Cy, Cz ] = polyhedronvac( V, F )
%
% Input:
% V: polyhedron vertices.
% F: polyhedron faces.
%
% Output:
% vol: volume of the polyhedron.
% A: area of the polyhedron.
% Cx, Cy, Cz: coordinates of the polyhedron centroid.
%
% (C) Ayad Al-Rumaithi
% https://www.mathworks.com/matlabcentral/fileexchange/93875-volume-surface-area-and-centroid-of-polyhedron

vol = 0;
A = 0;
Mx = 0;
My = 0;
Mz = 0;

for i = 1 : 1 : size( F, 1 )
    x1 = V(F(i,1),1);
    y1 = V(F(i,1),2);
    z1 = V(F(i,1),3);
    x2 = V(F(i,2),1);
    y2 = V(F(i,2),2);
    z2 = V(F(i,2),3);
    
    x3 = V(F(i,3),1);
    y3 = V(F(i,3),2);
    z3 = V(F(i,3),3);
    
    vi = 1/6*det([x1 x2 x3 0; y1 y2 y3 0; z1 z2 z3 0; 1 1 1 1]);
    ai = 1/2*norm(cross(V(F(i,2),:)-V(F(i,1),:),V(F(i,3),:)-V(F(i,1),:)));
    xi = 1/4*(x1+x2+x3);
    yi = 1/4*(y1+y2+y3);
    zi = 1/4*(z1+z2+z3);
    vol = vol+vi;
    A = A+ai;
    Mx = Mx+xi*vi;
    My = My+yi*vi;
    Mz = Mz+zi*vi;
    
end

Cx = Mx/vol;
Cy = My/vol;
Cz = Mz/vol;
S = sign(vol);
vol = vol * S;

function [newtheta,newphi]=incandrefl(theta,phi,a,b)
% filename: incandrefl.m
% Project: POFACETS
% Description: This  function receives the rotation angles of a facet (a,b)
% and the angle of incidence in global coordinates (theta, phi) and 
% calculates the angle of reflection in global coordinates
% Author:  Filippos Chatzigeorgiadis
% Date:   September 2004
% Place: NPS
% Last modifed: Sep 04 (v.3.0)
%find transformation matrix
T21=transfmatrix(a,b);
%convert to local spherical coordinates
[Rloc,thetaloc,philoc]=spherglobal2local(1,theta,phi,T21);


% inverse phi
philoc=pi+philoc;
[Rnew,newtheta,newphi]=spherlocal2global(Rloc,thetaloc,philoc,T21);


% %for all local thetas
% step=5;
% ind=1;
% for i=0.1:step:89.9
%     loctheta=i*pi/180;
%     [Rnew,thgl,phigl]=spherlocal2global(1,loctheta,philoc,T21);
%     newtheta(ind)=thgl;
%     newphi(ind)=phigl;
%     ind=ind+1;
%     [Rnew,thgl,phigl]=spherlocal2global(1,loctheta,philoc+pi,T21);
%     newtheta(ind)=thgl;
%     newphi(ind)=phigl;
%     ind=ind+1;
% end
%     
% % allow up to 0.5 degrees tolerance
% tol=0.5*pi/180;
% %check if incidence angle is included
% r1=find(abs(newtheta-theta)<tol);
% r2=find(abs(newphi-phi)<tol);
% if isempty(r1) | isempty(r2)
%     newtheta=[newtheta,theta];
%     newphi=[newphi,phi];
% end
% 
% 
% 
% %find specular by simply changing philoc by pi
% philocspec=philoc+pi;
% [Rnew,spectheta,specphi]=spherlocal2global(Rloc,thetaloc,philocspec,T21);
% %check if specular angle is included
% r1=find(abs(newtheta-spectheta)<tol);
% r2=find(abs(newphi-specphi)<tol);
% if isempty(r1) | isempty(r2)
%     newtheta=[newtheta,spectheta];
%     newphi=[newphi,specphi];
% end
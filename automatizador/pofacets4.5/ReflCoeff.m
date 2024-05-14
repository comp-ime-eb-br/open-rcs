function [gammapar,gammaperp,thetat,TIR]=ReflCoeff(er1,mr1,er2,mr2,thetai)
% filename: ReflCoeff.m
% Project: POFACETS
% Description: This  function computes the reflection coefficient
% for parallel and perpendicular polarization, the transmission angle
% and whether Total Internal Reflection (TIR) occurs 
% Author:  Filippos Chatzigeorgiadis
% Date:   September 2004
% Place: NPS
% Last modifed: Sep 04 (v.3.0)

% er1,mr1 relative parameters of space of incidence
% er2,mr2 relative parameters of space of tranmsission
% thetai: angle of incidence
% gammapar, gammaperp: reflection coefficients parallel and perpendicular
% thetat: transmission angle
% TIR=1 when Total Internal Reflection occurs, else TIR=0


m0=4*pi*1e-7;  e0=8.854e-12;

TIR=0;
sinthetat=sin(thetai)*sqrt(real(er1)*real(mr1)/(real(er2)*real(mr2)));
if sinthetat>1
    TIR=1;
    thetat=pi/2;
end
thetat=asin(sinthetat);
n1=sqrt(mr1*m0/(er1*e0));
n2=sqrt(mr2*m0/(er2*e0));
gammaperp=(n2*cos(thetai)-n1*cos(thetat))/(n2*cos(thetai)+n1*cos(thetat));
gammapar=(n2*cos(thetat)-n1*cos(thetai))/(n2*cos(thetat)+n1*cos(thetai));
    
    

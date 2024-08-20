function [R,RR,st,ct,cp,sp]=angledata(thr,phr)
% filename: angledata.m
% Project: POFACETS
% Description: This function computes the direction cosines of incident and RCS computation angles
% Author:  Prof. David C. Jenn, Elmo E. Garrido Jr. and Filippos
% Chatzigeorgiadis
% Date:   14 August 2000
% Place: NPS
% Last modifed: June 04 (v.3.0)

% thr, phr : theta and phi angles
% R=[u v w] direction cosines u=sintheta*cosphi, v=sintheta*sinphi, w=costheta
% RR=[uu vv ww] uu: costheta*cosphi, vv=costheta*sinphi, ww=-sintheta
% sp=sinphi 
% cp=cosphi 

 st = sin(thr); 	ct = cos(thr);
 cp = cos(phr);		sp = sin(phr);
 u = st*cp; 			v = st*sp; 			w = ct ; 			
 R = [u v w];
 uu = ct*cp; 		vv = ct*sp; 		ww = -st;
 RR=[uu vv ww]; 
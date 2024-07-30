function [RCpar,RCperp]=RClayers(thetai,phii,m,alpha,beta,freq)
% filename: RClayers.m
% Project: POFACETS
% Description: This  function receives the incidence angles, the facet number,
% the facet rotation angles and the operating frequency and returns the
% Reflection coefficients for parallel and perpendicular pol case for various
% material types (PEC, composite, composite on PEC, composite layers and composite layers on PEC
% Author:  Filippos Chatzigeorgiadis
% Date:   September 2004
% Place: NPS
% Last modifed: Sep 04 (v.3.0)
%
%Modified for version 3.0.1
%Capt Wade Brinkman
%Canadian Forces


global matrl 

switch matrl{m,1}
    case 'PEC'
      RCpar=-1;
      RCperp=-1;
    case 'Composite'
      matdata=matrl{m,2};
      er=matdata(1)-j*matdata(2)*matdata(1);
      mr=matdata(3)-j*matdata(4);
      t=matdata(5)*0.001;%convert to meters
      T21=transfmatrix(alpha,beta);
      %convert to local facet coordinates
      [Rloc,thetaloc,philoc]=spherglobal2local(1,thetai,phii,T21);
      %angle of incidence is thetaloc
      % 1st interface: air to material interface
      [G1par G1perp thetat TIR]=ReflCoeff(1,1,er,mr,thetaloc);
      % 2nd interface: material to air interface
      G2par=-G1par; G2perp=-G1perp;
      %find phase 
      v=3e8/sqrt(real(er)*real(mr));
      lamda=v/freq;
      b1=2*pi/lamda;
      phase=b1*t;
      %formulate matrices
      M1par=[exp(j*phase), G1par*exp(-j*phase);G1par*exp(j*phase), exp(-j*phase)];
      M1perp=[exp(j*phase), G1perp*exp(-j*phase);G1perp*exp(j*phase), exp(-j*phase)];
      M2par=[1, G2par;G2par, 1];
      M2perp=[1 G2perp;G2perp, 1];
      Mpar=M1par*M2par;
      Mperp=M1perp*M2perp;
      %compute Reflection Coefficients
      RCpar=Mpar(2,1)/Mpar(1,1);
      RCperp=Mperp(2,1)/Mperp(1,1);
      
  case 'Composite Layer on PEC';
      T21=transfmatrix(alpha,beta);
     %convert to local facet coordinates
     [Rloc,thetaloc,philoc]=spherglobal2local(1,thetai,phii,T21);
     %angle of incidence is thetaloc
     matdata=matrl{m,2};
     % find number of layers
     layers=size(matdata,2)/5;
     %initialize matrices
     Mpar=eye(2); Mperp=eye(2);
     % repeat for all except the last
     
     %THE NEW CODE STARTS HERE
     PEC = [1 0;-1 0];                  %this is the transmission matrix for PEC
     
     WMatrix_par = eye(2);      %initialize the wave matrix - parallel pol
     WMatrix_perp = eye(2);    %initialize the wave matrix - perpendicular pol
     
     e0=8.854e-12;                      %permittivity of free space
     u0=1.257e-6;                       %permeability of free space
     Z0 = 1;                                 %normalized impedance of free space
     lambda = 3e8/freq;             %current frequency in free space
     B0 = 2*pi/lambda;              %prop constant
     theta_inc = thetaloc;          %theta_inc is the incident angle of current layer junction
     
     for k = 1:layers;  %Build the wave matrix for each layer
         %extract material data from matdata
         erp = matdata(1,1+5*(k-1));
         erdp = erp*matdata(1,2+5*(k-1));
         erc = erp - j*erdp;
         urp = matdata(1,3+5*(k-1));
         urdp = matdata(1,4+5*(k-1));
         urc = urp - j*urdp;
         t = matdata(1,5+5*(k-1))*1e-3;
         
         Z_par(k) = sqrt(erc/urc-sin(theta_inc)^2)/(erc/urc*cos(theta_inc));  %impedence of layer k
         Z_perp(k) = cos(theta_inc)/sqrt(erc/urc-sin(theta_inc)^2);                 %for par & perp pol  
         Beta(k) = 2*pi/(lambda/sqrt(real(erc)*real(urc)));                                  %prop constant in media
         
         if k == 1;
            Gamma_par(k) = (Z_par(k)-Z0)/(Z_par(k)+Z0);
            tau_par(k) = 1 + Gamma_par(k);
            Gamma_perp(k) = (Z_perp(k)-Z0)/(Z_perp(k)+Z0);
            tau_perp(k) = 1 + Gamma_perp(k);
            
            PHI = B0*t*(erc*urc-sin(theta_inc)^2)^(.5);   %the new phase constant
            
         else
            Gamma_par(k) = (Z_par(k)-Z_par(k-1))/(Z_par(k)+Z_par(k-1));
            tau_par(k) = 1 + Gamma_par(k);
            Gamma_perp(k) = (Z_perp(k)-Z_perp(k-1))/(Z_perp(k)+Z_perp(k-1));
            tau_perp(k) = 1 + Gamma_perp(k);
            PHI = B0*t*(erc*urc-sin(theta_inc)^2)^(.5); %the new phase constant
         end
         
         %Update the Wave Matrix
         T_par = [exp(j*PHI)                                Gamma_par(k)*exp(-j*PHI);
                         Gamma_par(k)*exp(j*PHI)    exp(-j*PHI)                            ];
          
         WMatrix_par = 1/tau_par(k)*WMatrix_par*T_par;
         
         T_perp = [exp(j*PHI)                                 Gamma_perp(k)*exp(-j*PHI);
                            Gamma_perp(k)*exp(j*PHI)   exp(-j*PHI)                            ];
          
         WMatrix_perp = 1/tau_perp(k)*WMatrix_perp*T_perp;
     end;
     %finally, the last layer is PEC;
     
     WMatrix_par = WMatrix_par*PEC;
     WMatrix_perp = WMatrix_perp*PEC;
     RCperp = WMatrix_perp(2,1)/WMatrix_perp(1,1);
     RCpar = WMatrix_par(2,1)/WMatrix_par(1,1); 
   
  case 'Multiple Layers';
     T21=transfmatrix(alpha,beta);
     %convert to local facet coordinates
     [Rloc,thetaloc,philoc]=spherglobal2local(1,thetai,phii,T21);
     %angle of incidence is thetaloc
     matdata=matrl{m,2};
     % find number of layers
     layers=size(matdata,2)/5;
     %initialize matrices
     Mpar=eye(2); Mperp=eye(2);
     % repeat for all layers
     for lay=1:layers
        index=(lay-1)*5;
        %get layer data
        er(lay)=matdata(index+1)-j*matdata(index+2)*matdata(index+1);
        mr(lay)=matdata(index+3)-j*matdata(index+4);
        t(lay)=matdata(index+5)*0.001;%convert to meters
        % find reflection coefficients at each interface
        if lay==1 % 1st layer         
          [Gpar Gperp thetat(lay) TIR]=ReflCoeff(1,1,er(lay),mr(lay),thetaloc);   
        else % all other layers
           % previous transmission angle becomes incidence angle
          [Gpar Gperp thetat(lay) TIR]=ReflCoeff(er(lay-1),mr(lay-1),er(lay),mr(lay),thetat(lay-1));   
        end 
        %find phase 
        v=3e8/sqrt(real(er(lay))*real(mr(lay)));
        lamda=v/freq;
        b1=2*pi/lamda;
        phase=b1*t(lay);
        %form matrices
        Mpar=Mpar*[exp(j*phase), Gpar*exp(-j*phase);Gpar*exp(j*phase), exp(-j*phase)];  
        Mperp=Mperp*[exp(j*phase), Gperp*exp(-j*phase);Gperp*exp(j*phase), exp(-j*phase)];  
    end % for
    %now find reflection coefficients between last layer and air
    [Gpar Gperp thetatdum TIR]=ReflCoeff(er(layers),mr(layers),1,1,thetat(layers));   
    Mpar=Mpar*[exp(j*phase), Gpar*exp(-j*phase);Gpar*exp(j*phase), exp(-j*phase)];  
    Mperp=Mperp*[exp(j*phase), Gperp*exp(-j*phase);Gperp*exp(j*phase), exp(-j*phase)];          
    %compute Reflection Coefficients
    RCpar=Mpar(2,1)/Mpar(1,1);
    RCperp=Mperp(2,1)/Mperp(1,1); 
                     
  case 'Multiple Layers on PEC';
      %modification by Capt Wade Brinkman, Canadian Forces
      %Last Modified:  8 Oct 05
      %This modification will use the wave
      %transmission matrix.  The Reference for this work is Prof Jenn's 
      %EC3630 notea
      
      T21=transfmatrix(alpha,beta);
     %convert to local facet coordinates
     [Rloc,thetaloc,philoc]=spherglobal2local(1,thetai,phii,T21);
     %angle of incidence is thetaloc
     matdata=matrl{m,2};
     % find number of layers
     layers=size(matdata,2)/5;
     %initialize matrices
     Mpar=eye(2); Mperp=eye(2);
     % repeat for all except the last
     
     %THE NEW CODE STARTS HERE
     PEC = [1 0;-1 0];  %this is the transmission matrix for PEC
     
     WMatrix_par = eye(2);  %initialize the wave matrix - parallel pol
     WMatrix_perp = eye(2); %initialize the wave matrix - perpendicular pol
     
     e0=8.854e-12;                  %permittivity of free space
     u0=1.257e-6;                   %permeability of free space
     Z0 = 1;                             %normalized impedance of free space
     lambda = 3e8/freq;         %current frequency in free space
     B0 = 2*pi/lambda;          %prop constant
     theta_inc = thetaloc;      %theta_inc is the incident angle of current layer junction
     
     for k = 1:layers;  %Build the wave matrix for each layer
         %extract material data from matdata
         erp = matdata(1,1+5*(k-1));
         erdp = erp*matdata(1,2+5*(k-1));
         erc = erp - j*erdp;
         urp = matdata(1,3+5*(k-1));
         urdp = matdata(1,4+5*(k-1));
         urc = urp - j*urdp;
         t = matdata(1,5+5*(k-1))*1e-3;
         
         Z_par(k) = sqrt(erc/urc-sin(theta_inc)^2)/(erc/urc*cos(theta_inc));  %impedence of layer k
         Z_perp(k) = cos(theta_inc)/sqrt(erc/urc-sin(theta_inc)^2);                 %for par & perp pol  
         Beta(k) = 2*pi/(lambda/sqrt(real(erc)*real(urc)));                                  %prop constant in media
         
         if k == 1;
            Gamma_par(k) = (Z_par(k)-Z0)/(Z_par(k)+Z0);
            tau_par(k) = 1 + Gamma_par(k);
            Gamma_perp(k) = (Z_perp(k)-Z0)/(Z_perp(k)+Z0);
            tau_perp(k) = 1 + Gamma_perp(k);
            
            PHI = B0*t*(erc*urc-sin(theta_inc)^2)^(.5);   %the new phase constant
         else
            Gamma_par(k) = (Z_par(k)-Z_par(k-1))/(Z_par(k)+Z_par(k-1));
            tau_par(k) = 1 + Gamma_par(k);
            Gamma_perp(k) = (Z_perp(k)-Z_perp(k-1))/(Z_perp(k)+Z_perp(k-1));
            tau_perp(k) = 1 + Gamma_perp(k);
            
            PHI = B0*t*(erc*urc-sin(theta_inc)^2)^(.5); %the new phase constant
         end
         
         %Update the Wave Matrix
         T_par = [exp(j*PHI)                                Gamma_par(k)*exp(-j*PHI);
                         Gamma_par(k)*exp(j*PHI)    exp(-j*PHI)                            ];
          
         WMatrix_par = 1/tau_par(k)*WMatrix_par*T_par;
         
         T_perp = [exp(j*PHI)                                 Gamma_perp(k)*exp(-j*PHI);
                            Gamma_perp(k)*exp(j*PHI)   exp(-j*PHI)                            ];
          
         WMatrix_perp = 1/tau_perp(k)*WMatrix_perp*T_perp;
     end;
     %finally, the last layer is PEC;
     
     WMatrix_par = WMatrix_par*PEC;
     WMatrix_perp = WMatrix_perp*PEC;
     RCperp = WMatrix_perp(2,1)/WMatrix_perp(1,1);
     RCpar = WMatrix_par(2,1)/WMatrix_par(1,1); 
      
end
%NEW CODE ENDS HERE
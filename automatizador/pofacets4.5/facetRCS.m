function [Ets,Etd,Eps,Epd]=facetRCS(thr,phr,ithetar,iphir,N,ilum,iflag,alpha,beta,Rs,Area,x,y,z,vind,e0,Nt,Lt,cfac2,corel,wave,grreflpar,grreflperp,groundreflect,rsmethod,RCpar,RCperp)
% N : Norval vector
% phr, thr :RCS angle
% ithetar,iphr: incidence angle
% x y z coordinate matrices
% vind facet vertex index matrix
% e0 incident field
% Rs surface resistivity of facet (normalized to free space, eta0)
% Lt , Nt Taylor series parameters (region, tersm)
% Area: of facet
% Co: wave amplitude at all vertices
%cfac2: exp(-4*bk^2*delsq) with delsq=(std dev)^2
%corel: normalized correlatio distance
% wave: wavelength
% grreflpar= Ground Refl. Coefficient Parallel Pol.
% grreflperp = Ground Refl. Coefficient Perpendicular Pol.
% groundreflect=0 ignore, 1 use grreflpar and grreflperp
% rsmethod: 1 use Rs, 2 use RCpar, RCperp (reflection coefficients)
% --------------------------------------
% w-wi corrected
% NOTE: DIFFUSE CALCULATION NOT VALIDATED
% ct2, cti2 added back in 

Co=1; %wave amplitude at all vertices
bk=2*pi/wave;

%MONOSTATIC CASE
if (thr==ithetar) & (phr==iphir)
    
     %global angles and direction cosines
                st = sin(thr); ct = cos(thr);
   	            cp = cos(phr);	sp = sin(phr);
				u = st*cp; 	v = st*sp; 	w = ct ;            
                D0=[u v w];
                uu = ct*cp; vv = ct*sp; 	ww = -st;
                % Spherical coordinate system outward radial unit vector
				R = [u v w];
				    	    			% Test to see if front face is illuminated
                    ndotk = N*R.';
                   if (ilum == 1 & ndotk >= 1e-5) | ilum == 0
							% Local direction cosines
            	      ca = cos(alpha); sa = sin(alpha);  cb = cos(beta); sb = sin(beta);
					  T1 = [ca sa 0; -sa ca 0; 0 0 1]; T2 = [cb 0 -sb; 0 1 0; sb 0 cb];
                      D1 = T1*D0.';
                      D2 = T2*D1;
	                  u2 = D2(1); v2 = D2(2);  w2 = D2(3);
				      % Find spherical angles in local coordinates
                      st2 = sqrt(u2^2 + v2^2)*sign(w2);  
                      ct2 = sqrt(1 - st2^2);
    				  phi2 = atan2(v2,u2+1e-10);
				      th2 = acos(ct2);
   	                  cp2 = cos(phi2); 
      	              sp2 = sin(phi2);
        			  % Phase at the three vertices of triangle m; monostatic RCS needs "2"
            	   	  Dp = 2*bk*((x(vind(1)) - x(vind(3)))*u + ...
               	        	     (y(vind(1)) - y(vind(3)))*v + ...
                  	           (z(vind(1)) - z(vind(3)))*w);
	               	  Dq = 2*bk*((x(vind(2)) - x(vind(3)))*u + ...
   	                    		  (y(vind(2)) - y(vind(3)))*v + ...
      	                   	  (z(vind(2)) - z(vind(3)))*w);
         	      	  Do = 2*bk*(x(vind(3))*u + y(vind(3))*v + z(vind(3))*w);
					  % Incident field in local Cartesian coordinates (stored in e2)
		              e1 = T1*e0.';          
				      e2 = T2*e1;
					  % Incident field in local spherical coordinates 
		     		  Et2 =  e2(1)*ct2*cp2 + e2(2)*ct2*sp2 - e2(3)*st2;
					  Ep2 = -e2(1)*sp2 + e2(2)*cp2;
    				% Reflection coefficients (Rs is normalized to eta0)
		  			if rsmethod==1
                               % Reflection coefficients (Rs is normalized to eta0)
   		           				perp = -1/(2*Rs*ct2 + 1);  	%local TE polarization
					     	    para = 0;                			%local TM polarization
     						    if (2*Rs + ct2) ~=0 para = -ct2/(2*Rs + ct2); end
                     end
                     if rsmethod==2
                                perp=RCperp;
                                para=RCpar;
                      end
  	   	    		  % Surface current components in local Cartesian coordinates
					  Jx2 = (-Et2*cp2*para + Ep2*sp2*perp*ct2);   % ct2 added
    				  Jy2 = (-Et2*sp2*para - Ep2*cp2*perp*ct2);   % ct2 added
					  % Area integral for general case
					  DD = Dq - Dp;
					  expDo = exp(j*Do);
					  expDp = exp(j*Dp);
					  expDq = exp(j*Dq);
					  % Special case 1
   	  	       		  if abs(Dp) < Lt & abs(Dq) >= Lt
      	   				sic=0.;
         				for n = 0:Nt
		      	    			sic = sic + (j*Dp)^n/fact(n)*(-Co/(n+1)+expDq*(Co*G(n,-Dq)));
         				end
         				Ic=sic*2*Area*expDo/j/Dq;
						% Special case 2
		     		  elseif abs(Dp) < Lt & abs(Dq) < Lt
	   	      			sic = 0.;
         				for n = 0:Nt
          					for nn = 0:Nt
           						sic = sic+(j*Dp)^n*(j*Dq)^nn/fact(nn+n+2)*Co;
          					end
         				end
	         			Ic = sic*2*Area*expDo;
					% Special case 3
    				elseif abs(Dp) >= Lt & abs(Dq) < Lt
       					sic = 0.;
       					for n = 0:Nt
       						sic = sic+(j*Dq)^n/fact(n)*Co*G(n+1,-Dp)/(n+1);
       					end
       					Ic = sic*2*Area*expDo*expDp;
					% Special case 4
   					elseif abs(Dp) >= Lt & abs(Dq) >= Lt & abs(DD) < Lt
          				sic = 0.;
      					for n = 0:Nt
         					sic = sic+(j*DD)^n/fact(n)*(-Co*G(n,Dq)+expDq*Co/(n+1));
        				end
	       				Ic = sic*2*Area*expDo/j/Dq;
   	  				else
      	   				Ic = 2*Area*expDo*(expDp*Co/Dp/DD-expDq*Co/Dq/DD-Co/Dp/Dq);
     	    		end   % end of special cases test
                       
                     % Add diffuse component NOT VALIDATED
                     Edif = cfac2*Area*ct2^2*exp(-(corel*pi*st2/wave)^2);                                         
                     % Scattered field components for triangle m in local coordinates
                     Es2(1) = Jx2*Ic; 	 Es2(2) = Jy2*Ic; 	Es2(3) = 0;
           			 Ed2(1) = Jx2*Edif; Ed2(2) = Jy2*Edif;  Ed2(3) = 0;
        			 % Transform back to global coordinates, then sum field
	      			 Es1 =  T2.'*Es2.';
                     Es0 =  T1.'*Es1;
                     Ed1 =  T2.'*Ed2.'; 
                     Ed0 =  T1.'*Ed1;
                     Ets =  uu*Es0(1) + vv*Es0(2) + ww*Es0(3);
      				 Eps = -sp*Es0(1) + cp*Es0(2);
                     Etd =  uu*Ed0(1) + vv*Ed0(2) + ww*Ed0(3);
					 Epd = -sp*Ed0(1) + cp*Ed0(2);
                     % if ground reflection occurs, multiply Et with
                     % GrReflpar and Ep with GrReflperp
                     if groundreflect==1
                         Ets=Ets*grreflpar;
                         Etd=Etd*grreflpar;
                         Eps=Eps*grreflperp;
                         Epd=Epd*grreflperp;
                     end   
                 else
                   Ets =0;
      			   Eps =0;
                   Etd =0;
				   Epd =0;
                 
                 end %if ilum    


else %BISTATIC CASE
    % Global angles and direction cosine            
    st = sin(thr); 	ct = cos(thr);
    cp = cos(phr);		sp = sin(phr);
    u = st*cp; 			v = st*sp; 			w = ct ; 			D0=[u v w];
    uu = ct*cp; 		vv = ct*sp; 		ww = -st;
    % Spherical coordinate system outward radial unit vector
    R =[u v w];
    %incidence angle
    cpi = cos(iphir);  	spi = sin(iphir);
    sti = sin(ithetar);	cti = cos(ithetar);
    ui = sti*cpi;		vi = sti*spi; 		wi = cti;
    D0i = [ui vi wi];
    uui = cti*cpi;		vvi = cti*spi;		wwi = -sti;
    Ri =  [ui vi wi]; % 
    % normal dot ki= ri is positive
    ndotk  = N*R.';
    nidotk = N*Ri.';
    % Check to see if front face is illuminated
               if ((ilum == 1 & nidotk >= 0) | ilum == 0) | iflag == 1
                  % Check to see if front face is in view at the observation point
                  % (this is for diagnostic purposes -- should not be used in practice
                  % because then there would be no forward scattering!)
 	  	    	  % Local direction cosines
                    	ca = cos(alpha); 		sa = sin(alpha);  
                    	cb = cos(beta); 		sb = sin(beta);
                     T1 = [ca sa 0; -sa ca 0; 0 0 1]; 
                     T2 = [cb 0 -sb; 0 1 0; sb 0 cb];
                   	% Transform incidence quantities
                    	D1i = T1*D0i.';
                  	D2i = T2*D1i;
	                 	ui2 = D2i(1); 		vi2 = D2i(2);  	wi2 = D2i(3);
							% Find incident spherical angles in local coordinates
                    	sti2 = sqrt(ui2^2 + vi2^2)*sign(wi2);  
                    	cti2 = sqrt(1 - sti2^2);
    						iphi2 = atan2(vi2,ui2+1e-10);
						  	thi2 = acos(cti2);
   	              	cpi2 = cos(iphi2); 
      	           	spi2 = sin(iphi2);
                    	% Transform observation quantities
                    	D1 = T1*D0.';
                    	D2 = T2*D1;
                    	u2 = D2(1); v2 = D2(2);  w2 = D2(3);
                    	st2 = sqrt(u2^2 + v2^2)*sign(w2);  
                    	ct2 = sqrt(1 - st2^2);
    						phi2 = atan2(v2,u2+1e-10);
						  	th2 = acos(ct2);
   	              	cp2 = cos(phi2); 
      	           	sp2 = sin(phi2);
                    	% Phase at the three vertices of triangle m; monostatic RCS needs "2"
                          Dp = bk*((x(vind(1)) - x(vind(3)))*(u+ui) + ...
               	       	   (y(vind(1)) - y(vind(3)))*(v+vi) + ...
                  	         (z(vind(1)) - z(vind(3)))*(w+wi));
	               	      Dq = bk*((x(vind(2)) - x(vind(3)))*(u+ui) + ...
   	                    		(y(vind(2)) - y(vind(3)))*(v+vi) + ...
      	                   	(z(vind(2)) - z(vind(3)))*(w+wi));
         	      	      Do = bk* (x(vind(3))*(u+ui) + y(vind(3))*(v+vi) + z(vind(3))*(w+wi));
                  
							% Incident field in local Cartesian coordinates (stored in e2)
		     				e1 = T1*e0.';          
				     		e2 = T2*e1;
                     % Incident field in local spherical coordinates 
		     				Et2 =  e2(1)*cti2*cpi2 + e2(2)*cti2*spi2 - e2(3)*sti2;
						   Ep2 = -e2(1)*spi2 + e2(2)*cpi2;
							% Reflection coefficients (Rs is normalized to eta0)
		     				if rsmethod==1
                               % Reflection coefficients (Rs is normalized to eta0)
   		           				perp = -1/(2*Rs*cti2 + 1);  	%local TE polarization
					     	    para = 0;                			%local TM polarization
     						    if (2*Rs + cti2) ~=0 para = -cti2/(2*Rs + cti2); end
                            end
                            if rsmethod==2
                                perp=RCperp;
                                para=RCpar;
                            end
							% Surface current components in local Cartesian coordinates
				 		    Jx2 = (-Et2*cpi2*para + Ep2*spi2*perp*cti2);  % cti2 added
    			 			Jy2 = (-Et2*spi2*para - Ep2*cpi2*perp*cti2);  % cti2 added  
							% Area integral for general case
							DD = Dq - Dp;
							expDo = exp(j*Do);
							expDp = exp(j*Dp);
							expDq = exp(j*Dq);
							% Special case 1
   	  					if abs(Dp) < Lt & abs(Dq) >= Lt
      	   				sic=0.;
         					for n = 0:Nt
		      	    			sic = sic + (j*Dp)^n/fact(n)*(-Co/(n+1)+expDq*(Co*G(n,-Dq)));
         					end
         					Ic=sic*2*Area*expDo/j/Dq;
							% Special case 2
		     				elseif abs(Dp) < Lt & abs(Dq) < Lt
	   	      			sic = 0.;
         					for n = 0:Nt
          						for nn = 0:Nt
            						sic = sic+(j*Dp)^n*(j*Dq)^nn/fact(nn+n+2)*Co;
          						end
         					end
	         				Ic = sic*2*Area*expDo;
							% Special case 3
     						elseif abs(Dp) >= Lt & abs(Dq) < Lt
         					sic = 0.;
         					for n = 0:Nt
           						sic = sic+(j*Dq)^n/fact(n)*Co*G(n+1,-Dp)/(n+1);
         					end
         					Ic = sic*2*Area*expDo*expDp;
							% Special case 4
   	  					elseif abs(Dp) >= Lt & abs(Dq) >= Lt & abs(DD) < Lt
      	   				sic = 0.;
         					for n = 0:Nt
           						sic = sic+(j*DD)^n/fact(n)*(-Co*G(n,Dq)+expDq*Co/(n+1));
         					end
	         				Ic = sic*2*Area*expDo/j/Dq;
   	  					else
      	   				Ic = 2*Area*expDo*(expDp*Co/Dp/DD-expDq*Co/Dq/DD-Co/Dp/Dq);
     				end   % end of special cases test
                       
                     % Add diffuse component
                     Edif = cfac2*Area*ct2^2*exp(-(corel*pi*st2/wave)^2);                                         
                     % Scattered field components for triangle m in local coordinates
                     Es2(1) = Jx2*Ic; 	 Es2(2) = Jy2*Ic; 	Es2(3) = 0;
     				 Ed2(1) = Jx2*Edif; Ed2(2) = Jy2*Edif;  Ed2(3) = 0;
       				 % Transform back to global coordinates, then sum field
	      		     Es1 = T2.'*Es2.';
                     Es0 = T1.'*Es1;
                     Ed1 = T2.'*Ed2.'; 
                     Ed0 = T1.'*Ed1;
                     Ets =  uu*Es0(1) + vv*Es0(2) + ww*Es0(3);
       	    	     Eps = -sp*Es0(1) + cp*Es0(2);
                     Etd =  uu*Ed0(1) + vv*Ed0(2) + ww*Ed0(3);
      		         Epd = -sp*Ed0(1) + cp*Ed0(2);
                      % if ground reflection occurs, multiply Et with
                     % GrReflpar and Ep with GrReflperp
                     if groundreflect==1
                         Ets=Ets*grreflpar;
                         Etd=Etd*grreflpar;
                         Eps=Eps*grreflperp;
                         Epd=Epd*grreflperp;
                     end   
            else %if not illuminated
                      Ets=0;
                      Etd=0;
                      Eps=0;
                      Epd=0;
                  
            end

end%BISTATIC CASE

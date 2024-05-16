function CalcBistat(rsmethod,pathname,filename);
% filename: CalcBistat.m
% Project: POFACETS
% Description: This  program computes the bistatic RCs of a selected model.
% Author:  Prof. David C. Jenn, Elmo E. Garrido Jr. and Filippos
% Chatzigeorgiadis
% Date:   14 August 2000
% Place: NPS
% Last modifed: Feb 10 (v.3.2.1) labels changed to Latex (fixed for contour
% plot)
% added cleanup of gui background after LinearPlot
warning("off") 

global C
global coord nvert modelname symplanes matrl
global ntria facet scale changed
global thetadeg phideg RCSth RCSph
global Ethscat Ephscat

        h_figs = get(0,'children');
		for fig = h_figs'
		  if strcmp(get(fig,'Tag'),'bistatic');
           h_bistat = fig;
		  end
		end
      
      e0=8.85e-12;%permittivity of free space
      m0=4*pi*1e-7;%permeability of free space
      rad 	 = pi/180;   
      %open('MsgComputing.fig');
      txt = ['Computing the bistatic RCS of ',modelname,' model . . .'];         
      %set(findobj(gcf,'Tag','Msg'),'String',txt); 
       hwait=waitbar(0,txt);
      pause(0.1);     
      
      % Get parameters
      itheta = str2num(get(findobj(h_bistat,'Tag','iTheta'),'String'));
      iphi   = str2num(get(findobj(h_bistat,'Tag','iPhi'),'String'));
      ithetar=itheta*rad;
      iphir=iphi*rad;
      tstart = str2num(get(findobj(h_bistat,'Tag','TStart'),'String')); 
      tstop  = str2num(get(findobj(h_bistat,'Tag','TStop'),'String')); 
      delt   = str2num(get(findobj(h_bistat,'Tag','Delt'),'String')); 
      pstart = str2num(get(findobj(h_bistat,'Tag','PStart'),'String')); 
      pstop  = str2num(get(findobj(h_bistat,'Tag','PStop'),'String')); 
      delp   = str2num(get(findobj(h_bistat,'Tag','Delp'),'String')); 
      Lt     = str2num(get(findobj(h_bistat,'Tag','LRegion'),'String')); 
      Nt     = str2num(get(findobj(h_bistat,'Tag','NTerms'),'String'));       
      i_pol  = get(findobj(h_bistat,'Tag','IncPolar'),'Value');          
      freq	 = str2num(get(findobj(h_bistat,'Tag','Freq'),'String')); 
      wave   = C/(freq * 10^9);     
      bk     = 2*pi/wave;
     
      show3D= get(findobj(h_bistat,'Tag','ModelandRCS'),'Value');
      showpolar = get(findobj(h_bistat,'Tag','PolarPlot'),'Value');
      corr   = str2num(get(findobj(h_bistat,'Tag','Corr'),'String')); 
      corel	 = corr/wave; % normalized to the wavelength
      std    = str2num(get(findobj(h_bistat,'Tag','Std'),'String'));     
      delstd = std; 
      delsq  = delstd^2;  % variance
      cfac1  = exp(-4*bk^2*delsq);
      cfac2  = 4*pi*(bk*corel)^2*delsq;
      useground=get(findobj(h_bistat,'Tag','groundplane'),'Value');
           
      if useground==1
          %save initial data
          coordi=coord;
          faceti=facet;
          %create symmetric model
          xysymmetric;
          nvert = size(coord,1);
          ntria=size(facet,1);
          % get data about ground plane
          pec=get(findobj(h_bistat,'Tag','checkpec'),'Value');
          if pec==0
              relpermit=str2num(get(findobj(h_bistat,'Tag','relativeperm'),'String'));
          end
          % if ground plane is PEC both Refl. Coeff. are -1
          if pec==1
              igrreflpar=-1;
              igrreflperp=-1;
          else
             %find par and perp refl coefficients
             % for bistatic case incidence angle is always the same, hence
             % this can be done out of the RCS angle loop
             [igrreflpar,igrreflperp,thetat,TIR]=ReflCoeff(1,1,relpermit,1,itheta*rad);
          end
      end

    
      % Pattern loop
      cpi = cos(iphi*rad);  	spi = sin(iphi*rad);
      sti = sin(itheta*rad);	cti = cos(itheta*rad);
      ui = sti*cpi;		vi = sti*spi; 		wi = cti;
      D0i = [ui vi wi];
      uui = cti*cpi;		vvi = cti*spi;		wwi = -sti;
      Ri = - [ui vi wi];   
		if tstart == tstop, thr0 = tstart*rad; end
      if pstart == pstop, phr0 = pstart*rad; end
	   it = floor((tstop-tstart)/delt) + 1;
   	ip = floor((pstop-pstart)/delp) + 1;
      % Incident wave polarization
      if i_pol == 1	
         Et = 1+j*0;
         Ep = 0+j*0;
      else					
	      Et = 0+j*0;  
         Ep = 1+j*0;  
      end    
  		    
      
      xpts = coord(:,1);
      ypts = coord(:,2);
      zpts = coord(:,3);
      nverts = length(xpts);
      node1 = facet(:,1); 
      node2 = facet(:,2); 
      node3 = facet(:,3);
      % illumination flags for each triangle
      % Illumination flag : ilum=1 external face only defined by
      % right hand rule and CCW order of vertices
      ilum  = facet(:,4);	
  	  Rs    = facet(:,5); % resistivity of each triangle

      
   	  
      % turn off illumination test completely if iflag = 1 
      iflag = 0;
      ntria = length(node3);
      for i = 1:ntria 
			pts = [node1(i) node2(i) node3(i)];
		  	vind(i,:) = pts;       
		end
      x = xpts; y = ypts;  z = zpts;
      % Define position vectors to vertices
		for i = 1:nverts
			r(i,:) = [x(i) y(i) z(i)];
		end   
   	% Get edge vectors and normals from edge cross products
  		for i = 1:ntria
   		A = r(vind(i,2),:) - r(vind(i,1),:);
	   	B = r(vind(i,3),:) - r(vind(i,2),:);
		   C = r(vind(i,1),:) - r(vind(i,3),:);
         % compute outward normals from edge vectors
         N(i,:) = - cross(B,A);
			% Edge lengths for triangle "i"
   		d(i,1) = norm(A);
   		d(i,2) = norm(B);
		   d(i,3) = norm(C);
   		ss = .5*sum(d(i,:));
	   	Area(i) = sqrt(ss*(ss-d(i,1))*(ss-d(i,2))*(ss-d(i,3)));
	   	Nn = norm(N(i,:));
         % unit normals
         N(i,:) = N(i,:)/Nn;
         % rotation angles
         beta(i) = acos(N(i,3));  
         alpha(i) = atan2(N(i,2),N(i,1));
		end
      
      % Incident field in global Cartesian coordinates 
		e0(1) = uui*Et - spi*Ep;
		e0(2) = vvi*Et + cpi*Ep;
		e0(3) = wwi*Et;

   	for i1 = 1:ip
   		for i2 = 1:it
            
                waitbar(((i1-1)*it+i2)/(ip*it));                
                
				phi(i1,i2) = pstart + (i1-1)*delp;
				phr = phi(i1,i2)*rad;
				theta(i1,i2) = tstart + (i2-1)*delt;
                thr = theta(i1,i2)*rad;
				% Global angles and direction cosine            
				st = sin(thr); 	ct = cos(thr);
   	            cp = cos(phr);		sp = sin(phr);
				u = st*cp; 			v = st*sp; 			w = ct ; 			D0=[u v w];
				U(i1,i2) = u; 		V(i1,i2) = v;		W(i1,i2) = w;
				uu = ct*cp; 		vv = ct*sp; 		ww = -st;
				% Spherical coordinate system outward radial unit vector
				R = [u v w];
                
				% Begin loop over triangles
				sumt 	= 0;
                sump 	= 0;
                sumdt = 0;
                sumdp = 0;
                %dummy values for Refl Coeff when rsmethod=1                
                RCpar=0;
                RCperp=0;
                
                %find ground reflection coefficients for RCS angle
                if useground==1
                  % if ground plane is PEC both Refl. Coeff. are -1
                       if pec==1
                          grreflpar=-1;
                          grreflperp=-1;
                        else
                         %find par and perp refl coefficients
                            [grreflpar,grreflperp,thetat,TIR]=ReflCoeff(1,1,relpermit,1,thr);
                        end
                end
					         

            for m = 1:ntria
                % if applicable, reflection coefficients for parallel
                % and perpendicular polarization
                if rsmethod==2
                        [RCpar,RCperp]=RClayers(ithetar,iphir,m,alpha(m),beta(m),freq*1e9);
                end
                
                % CASE 1: simplest case: no ground
                if useground==0
                    Einc=e0;
                    [Ets Etd Eps Epd]=facetRCS(thr,phr,ithetar,iphir,N(m,:),ilum(m),iflag,alpha(m),beta(m),Rs(m),Area(m),x,y,z,vind(m,:),e0,Nt,Lt,cfac2,corel,wave,0,0,0,rsmethod,RCpar,RCperp);
                    % Sum over all triangles to get the total field
      				sumt  = sumt  + Ets;
   	   				sump  = sump  + Eps;
                    sumdt = sumdt + abs(Etd);
                    sumdp = sumdp + abs(Epd);
                end      
                
                % CASE 2: Ground plane present
                    if useground==1
                        % Step 1: theta incident, theta scattered
                        if m<=ntria/2 % usual case direct incident, direct scattered
                            Einc=e0;
                            [Ets Etd Eps Epd]=facetRCS(thr,phr,ithetar,iphir,N(m,:),ilum(m),iflag,alpha(m),beta(m),Rs(m),Area(m),x,y,z,vind(m,:),Einc,Nt,Lt,cfac2,corel,wave,grreflpar,grreflperp,0,rsmethod,RCpar,RCperp);
                        else %ground reflected incident, ground reflected scattered 
                            Et1=Et*igrreflpar;
                            Ep1=Ep*igrreflperp;
                            ex(1) = uui*Et1 - spi*Ep1;
                    		ex(2) = vvi*Et1 + cpi*Ep1;
                    		ex(3) = wwi*Et1;
                            Einc=ex;
                            [Ets Etd Eps Epd]=facetRCS(thr,phr,ithetar,iphir,N(m,:),ilum(m),iflag,alpha(m),beta(m),Rs(m),Area(m),x,y,z,vind(m,:),Einc,Nt,Lt,cfac2,corel,wave,grreflpar,grreflperp,1,rsmethod,RCpar,RCperp);
                        end    
                        %Sum over all triangles to get the total field
                         sumt = sumt + Ets;
   	   				     sump = sump + Eps;
                         sumdt = sumdt + abs(Etd);
                         sumdp = sumdp + abs(Epd);
                        
                         %Step 2: theta incident, pi-theta scattered
                         if m<=ntria/2 % direct incident, reflected scattered
                            Einc=e0;
                            [Ets Etd Eps Epd]=facetRCS(pi-thr,phr,ithetar,iphir,N(m,:),ilum(m),iflag,alpha(m),beta(m),Rs(m),Area(m),x,y,z,vind(m,:),Einc,Nt,Lt,cfac2,corel,wave,grreflpar,grreflperp,1,rsmethod,RCpar,RCperp);

                          else %ground reflected incident, direct scattered 
                            Et1=Et*igrreflpar;
                            Ep1=Ep*igrreflperp;
                            ex(1) = uui*Et1 - spi*Ep1;
                    		ex(2) = vvi*Et1 + cpi*Ep1;
                    		ex(3) = wwi*Et1;
                            Einc=ex;
                            [Ets Etd Eps Epd]=facetRCS(pi-thr,phr,ithetar,iphir,N(m,:),ilum(m),iflag,alpha(m),beta(m),Rs(m),Area(m),x,y,z,vind(m,:),Einc,Nt,Lt,cfac2,corel,wave,grreflpar,grreflperp,0,rsmethod,RCpar,RCperp);
                         end
                        %Sum over all triangles to get the total field
                         sumt = sumt + Ets;
   	   				     sump = sump + Eps;
                         sumdt = sumdt + abs(Etd);
                         sumdp = sumdp + abs(Epd);    
                   end % CASE 2        
            end      % end of triangle loop
            
            Ethscat(i1,i2)=sumt;
            Ephscat(i1,i2)=sump;
            Sth(i1,i2) = 10*log10(4*pi*cfac1*(abs(sumt)^2+sqrt(1-cfac1^2)*sumdt)/wave^2+1e-10);
            Sph(i1,i2) = 10*log10(4*pi*cfac1*(abs(sump)^2+sqrt(1-cfac1^2)*sumdp)/wave^2+1e-10);
%   	 		Sth(i1,i2) = 10*log10(4*pi*abs(sumt/wave)^2 + 1.e-10);
%    			Sph(i1,i2) = 10*log10(4*pi*abs(sump/wave)^2 + 1.e-10);
			end	% for i2 = 1:it 
   	end	% end of pattern loop (for i1 = 1:ip)
    
      %close waitbar
      close(hwait);
      % set plot range
   	  Smax = max([max(max(Sth)),max(max(Sph))]);
      Lmax = (floor(Smax/5) + 1)*5; 
       %dynamic range initially set to 60 for axis only
      Lmin = Lmax - 60;
      % true dynamic range is 120 for linear plots
   	  Sth(:,:) = max(Sth(:,:),Lmax-120);
	  Sph(:,:) = max(Sph(:,:),Lmax-120);
      RCSth=Sth;
      RCSph=Sph;
      thetadeg=theta;
      phideg=phi;
 
    if useground==1
      % reset initial mode
      coord=coordi;
      facet=faceti;
    end    
     
      
      if ip == 1	% phi-cut
        h=openfig('LinearPlot.fig');
        ax=findall(h,'Type','Axes');
        plot(ax,theta,Sth,theta,Sph,'--'); grid(ax, "on");
        title(['target: ',modelname,'  (\theta_i,\phi_i): ','(',num2str(itheta),' ',num2str(iphi),') solid: \theta  dashed: \phi  \phi= ',num2str(phi(1,1)),...
        '  wave (m): ',num2str(wave)]);
	   	xlabel(ax,'Bistatic Angle, \theta (deg)');
   		ylabel(ax,'RCS (dBsm)');
		axis(ax,[min(theta),max(theta),Lmin,Lmax]);
		end
      
      if it == 1	% theta-cut
        h=openfig('LinearPlot.fig');
        ax=findall(h,'Type','Axes');
        plot(phi,Sth,phi,Sph,'--'); grid on;
        title(['target: ',modelname,'  (\theta_i,\phi_i): ',' (',num2str(itheta),' ',num2str(iphi),') solid: \theta  dashed: \phi  \theta= ',num2str(theta(1,1)),...
        '  wave (m): ',num2str(wave)])
	    xlabel(ax,'Bistatic Angle, \phi (deg)');
   	 	ylabel(ax,'RCS (dBsm)');
		axis(ax,[min(phi),max(phi),Lmin,Lmax]);
		end
   
         % clean up the background
    openfig('bistatic.fig','reuse'); gca; axis off, title ' ';

   	if ip > 1 & it > 1
         %Dynamic range set for 80dB
         Sth(:,:) = max(Sth(:,:),Lmax-80);
         Sph(:,:) = max(Sph(:,:),Lmax-80);
     %   openfig('MPlot.fig'); 
     %    Lv = [0,-20];
         figure
         subplot(121); 
%        meshc(U,V,Sth);    
         contour(U,V,Sth); 
         ha1 = gca;
         set(ha1,'Box','on');
         colorbar
         axis([-1,1,-1,1])
		 title(['RCS-\theta of ',modelname]); 
		 axis square
         xlabel('U = sin(\theta) cos(\phi)'); 
         ylabel('V = sin(\theta) sin(\phi)'); 
         zlabel('RCS (dBsm)');
         
         subplot(122); 
%         meshc(U,V,Sph);
		 contour(U,V,Sph);  % contour levels
         ha2 = gca;
         set(ha2,'Box','on');
         colorbar
         axis([-1,1,-1,1])   
	     title(['RCS-\phi of ',modelname]); 
		 axis square
         xlabel('U = sin(\theta) cos(\phi)'); 
         ylabel('V = sin(\theta) sin(\phi)'); 
         zlabel('RCS (dBsm)');
		end
  
 
if show3D==1
   %set dynamic range back to 60dB
   Sth1(:,:) = max(Sth(:,:),Lmax-60);
   Sph1(:,:) = max(Sph(:,:),Lmax-60);
   %theta and phi angles
   theta1=tstart:delt:tstop;
   phi1=pstart:delp:pstop;
   %find max coordinate value
   m0=2*max(max(coord))*scale;
   %convert all RCS to positive dB
   MinRCSth=min(min(Sth1));
   MinRCSph=min(min(Sph1));
   MinRCS=min(MinRCSth,MinRCSph);
   Sth1=Sth1-MinRCS;
   Sph1=Sph1-MinRCS;
   %Normalize 
   MaxRCSth=max(max(Sth1));
   MaxRCSph=max(max(Sph1));
   MaxRCS=max(MaxRCSth,MaxRCSph);
   Sth1=m0.*Sth1./MaxRCS;
   Sph1=m0.*Sph1./MaxRCS;
   
   %calculate x,y,z values for Sth and Sph
   %simple Spherical to Cartesian coordinates with RCS being the R
  
   % plot curve for phi or theta depending on which one has more points
   if size(phi1,2)>size(theta1,2) 
     for i1=1:size(phi1,2);
       for i2=1:size(theta1,2);
        xth(i1,i2)=Sth1(i1,i2)*sin(theta1(i2)*pi/180)*cos(phi1(i1)*pi/180);
        yth(i1,i2)=Sth1(i1,i2)*sin(theta1(i2)*pi/180)*sin(phi1(i1)*pi/180);
        zth(i1,i2)=Sth1(i1,i2)*cos(theta1(i2)*pi/180);
        xph(i1,i2)=Sph1(i1,i2)*sin(theta1(i2)*pi/180)*cos(phi1(i1)*pi/180);
        yph(i1,i2)=Sph1(i1,i2)*sin(theta1(i2)*pi/180)*sin(phi1(i1)*pi/180);
        zph(i1,i2)=Sph1(i1,i2)*cos(theta1(i2)*pi/180);
      end
     end
   else
   %indexing is reversed to create smooth looking curves on theta
   for i1=1:size(phi1,2);
     for i2=1:size(theta1,2);
        xth(i2,i1)=Sth1(i1,i2)*sin(theta1(i2)*pi/180)*cos(phi1(i1)*pi/180);
        yth(i2,i1)=Sth1(i1,i2)*sin(theta1(i2)*pi/180)*sin(phi1(i1)*pi/180);
        zth(i2,i1)=Sth1(i1,i2)*cos(theta1(i2)*pi/180);
        xph(i2,i1)=Sph1(i1,i2)*sin(theta1(i2)*pi/180)*cos(phi1(i1)*pi/180);
        yph(i2,i1)=Sph1(i1,i2)*sin(theta1(i2)*pi/180)*sin(phi1(i1)*pi/180);
        zph(i2,i1)=Sph1(i1,i2)*cos(theta1(i2)*pi/180);
    end
   end
end
%reshpae arrays
xth=reshape(xth,1,prod(size(xth)));
yth=reshape(yth,1,prod(size(yth)));
zth=reshape(zth,1,prod(size(zth)));
xph=reshape(xph,1,prod(size(xph)));
yph=reshape(yph,1,prod(size(yph)));
zph=reshape(zph,1,prod(size(zph)));
figure;
%plot the model
PlotModel;
hold on;
%plot RCS theta and RCS phi
plot3(xth,yth,zth,'r');
plot3(xph,yph,zph,'g');
axis([-m0 m0 -m0 m0 -m0 m0]);
txt=['3D Bistatic RCS Plot of ',modelname,' Model. RED:RCS \theta, GREEN:RCS \phi'];
title(txt);
xlabel('x');
ylabel('y');
zlabel('z');
%Incidence
R=m0;
x=[R*sin(itheta*pi/180)*cos(iphi*pi/180) 0];
y=[R*sin(itheta*pi/180)*sin(iphi*pi/180) 0];
z=[R*cos(itheta*pi/180) 0];
line(x,y,z,'color','y','linewidth',2.5);
hold off;
end % if show3D==1;


if showpolar==1
     openfig('polargraph.fig');
end %if showpolar


%answer=questdlg('Save RCS Results?','Save to File','Mat File','Text File','No','Mat File');
answer = 'Auto';
switch answer
   case 'Mat File'
      [filename, pathname]=uiputfile('*.mat','Select file name','BResults');
      if filename~=0
          save([pathname,filename],'itheta','iphi','theta','phi','freq','Sth','Sph','Ethscat','Ephscat');
      end  
      
  case 'Text File'
      [filename, pathname]=uiputfile('*.m','Select file name','BResults.m');
      if filename~=0
          save([pathname,filename],'itheta','iphi','theta','phi','freq','Sth','Sph','Ethscat','Ephscat','-ASCII');
      end  
  case 'Auto'
      fullFileName = fullfile(pathname, filename);
      save(fullFileName,'itheta','iphi','theta','phi','freq','Sth','Sph','Ethscat','Ephscat');   
         
end


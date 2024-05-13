function CalcFreq;
% filename: CalcFreq.m
% Project: POFACETS
% Description: This  computes the monostatic or bistatic RCS of a selected model for a
% range of frequencies
% Author:  Prof. David C. Jenn, Elmo E. Garrido Jr. and Filippos
% Chatzigeorgiadis
% Date:   September 2004
% Place: NPS
% added cleanup of gui background after LinearPlot
% mods to turn off Polarplot in mfreq.fig
        
global C
global coord modelname symplanes matrl
global facet scale changed
global thetadeg phideg RCSth RCSph


nvert = size(coord,1);
ntria=size(facet,1);

     h_figs = get(0,'children');
	 for fig = h_figs'
		  if strcmp(get(fig,'Tag'),'mfreq');
           h_mono = fig;
		  end
	 end
    
     answer=questdlg('Use Surface Resistivity Values (Rs) or Material data?','Select Material Type','Rs','Material','Rs');
     switch answer
         case 'Rs'
             rsmethod=1;
         case 'Material'
             rsmethod=2;
      end
      e0=8.85e-12;%permittivity of free space
      m0=4*pi*1e-7;%permeability of free space
      
      
      %open('MsgComputing.fig');
      txt = ['Computing the monostatic RCS of ',modelname,' model . . .'];         
      %set(findobj(gcf,'Tag','Msg'),'String',txt); 
      hwait=waitbar(0,txt);
      pause(0.1);     
      
      % Get parameters
      fstart = str2num(get(findobj(h_mono,'Tag','FStart'),'String')); 
      fstop  = str2num(get(findobj(h_mono,'Tag','FStop'),'String')); 
      delf   = str2num(get(findobj(h_mono,'Tag','Delf'),'String')); 
      Lt     = str2num(get(findobj(h_mono,'Tag','LRegion'),'String')); 
      Nt     = str2num(get(findobj(h_mono,'Tag','NTerms'),'String')); 
      i_pol  = get(findobj(h_mono,'Tag','IncPolar'),'Value');           
      corr   = str2num(get(findobj(h_mono,'Tag','Corr'),'String'));      
      std    = str2num(get(findobj(h_mono,'Tag','Std'),'String'));     
      theta = str2num(get(findobj(h_mono,'Tag','thshow'),'String'));
      phi= str2num(get(findobj(h_mono,'Tag','phshow'),'String'));;
      useground=get(findobj(h_mono,'Tag','groundplane'),'Value');
      
      rad 	 = pi/180;    
      phr = phi*rad;
      thr = theta*rad;
      %global angles and direction cosines
      st = sin(thr); ct = cos(thr);
   	  cp = cos(phr);	sp = sin(phr);
      uu = ct*cp; vv = ct*sp; 	ww = -st;
      % Incident wave polarization
      if i_pol == 1	
         Et = 1+j*0; 
         Ep = 0+j*0;  
      else					
	      Et = 0+j*0;  
         Ep = 1+j*0;  
      end    
      %check if incidence angle sliders are on
      vis=get(findobj(h_mono,'Tag','iphslider'),'Visible');
      switch vis
          case 'on'
              bist=1; % bistatic case
          case 'off'
              bist=0; %monostatic case
      end
      % for bistatic case get incidence angle
      if bist==1
          itheta = str2num(get(findobj(h_mono,'Tag','ithshow'),'String'));
          iphi= str2num(get(findobj(h_mono,'Tag','iphshow'),'String'));
           iphr = iphi*rad;
           ithr = itheta*rad;
           sti = sin(ithr); cti = cos(ithr);
           cpi = cos(phr);	spi = sin(iphr);
           uui = cti*cpi; vvi = cti*spi; 	wwi = -sti;
           % Incident field in global Cartesian coordinates 
    	  e0(1) = uui*Et - spi*Ep;
	      e0(2) = vvi*Et + cpi*Ep;
    	  e0(3) = wwi*Et;
      elseif bist==0 %monostatic case
          e0(1) = uu*Et - sp*Ep;
	      e0(2) = vv*Et + cp*Ep;
    	  e0(3) = ww*Et;  
          ithr=thr;
          iphr=phr;
          uui=uu; vvi=vv; wwi=ww;
          spi=sp;cpi=cp;
      end
      
      if useground==1
          %save initial data
          coordi=coord;
          faceti=facet;
          %create symmetric model
          xysymmetric;
          nvert = size(coord,1);
          ntria=size(facet,1);
          % get data about ground plane
          pec=get(findobj(h_mono,'Tag','checkpec'),'Value');
          if pec==0
              relpermit=str2num(get(findobj(h_mono,'Tag','relativeperm'),'String'));
          end
          % if ground plane is PEC both Refl. Coeff. are -1
          if pec==1
              igrreflpar=-1;
              igrreflperp=-1;
          else
             %find par and perp refl coefficients
             % for bistatic case incidence angle is always the same, hence
             % this can be done out of the RCS angle loop
             [igrreflpar,igrreflperp,thetat,TIR]=ReflCoeff(1,1,relpermit,1,ithr);
          end
      end
              
      xpts = coord(:,1);
      ypts = coord(:,2);
      zpts = coord(:,3);
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
      for i = 1:ntria 
			pts = [node1(i) node2(i) node3(i)];
		  	vind(i,:) = pts;       
	  end
      x = xpts; y = ypts;  z = zpts;
      % Define position vectors to vertices
	  for i = 1:nvert
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
    
    
    index=1;
    reps=floor((fstop-fstart)/delf) + 1;
    for freq = fstart:delf:fstop
        
               waitbar(index/reps);
            
               wave   = 3e8/(freq * 10^9);
               corel	 = corr/wave; % normalized to the wavelength
               delstd = std; 
               delsq  = delstd^2;  % variance
               bk     = 2*pi/wave;
               cfac1  = exp(-4*bk^2*delsq);
               cfac2  = 4*pi*(bk*corel)^2*delsq;
                               
				% Begin loop over triangles
				sumt = 0;
                sump = 0;
                sumdt = 0;
                sumdp = 0;
                %dummy values for Refl Coeff when rsmethod=1                
                RCpar=0;
                RCperp=0;
                                       
	     		for m = 1:ntria
                       if rsmethod==2
                        [RCpar,RCperp]=RClayers(thr,phr,m,alpha(m),beta(m),freq*1e9);
                       end
                       % CASE 1: Usual case: no ground reflections
                       if useground==0
                           Einc=e0;
                           [Ets Etd Eps Epd]=facetRCS(thr,phr,ithr,iphr,N(m,:),ilum(m),iflag,alpha(m),beta(m),Rs(m),Area(m),x,y,z,vind(m,:),Einc,Nt,Lt,cfac2,corel,wave,0,0,0,rsmethod,RCpar,RCperp);
                           %Sum over all triangles to get the total field
                           sumt = sumt + Ets;
   	    			       sump = sump + Eps;
                           sumdt = sumdt + abs(Etd);
                           sumdp = sumdp + abs(Epd);
                       end %CASE 1
                       
                    % CASE 2: Ground plane present
                    if useground==1
                        % Step 1: theta incident, theta scattered
                        if m<=ntria/2 % usual case direct incident, direct scattered
                            Einc=e0;
                            [Ets Etd Eps Epd]=facetRCS(thr,phr,ithr,iphr,N(m,:),ilum(m),iflag,alpha(m),beta(m),Rs(m),Area(m),x,y,z,vind(m,:),Einc,Nt,Lt,cfac2,corel,wave,grreflpar,grreflperp,0,rsmethod,RCpar,RCperp);
                        else %ground reflected incident, ground reflected scattered 
                            Et1=Et*igrreflpar;
                            Ep1=Ep*igrreflperp;
                            ex(1) = uui*Et1 - spi*Ep1;
                    		ex(2) = vvi*Et1 + cpi*Ep1;
                    		ex(3) = wwi*Et1;
                            Einc=ex;
                            [Ets Etd Eps Epd]=facetRCS(thr,phr,ithr,iphr,N(m,:),ilum(m),iflag,alpha(m),beta(m),Rs(m),Area(m),x,y,z,vind(m,:),Einc,Nt,Lt,cfac2,corel,wave,grreflpar,grreflperp,1,rsmethod,RCpar,RCperp);
                        end    
                        %Sum over all triangles to get the total field
                         sumt = sumt + Ets;
   	   				     sump = sump + Eps;
                         sumdt = sumdt + abs(Etd);
                         sumdp = sumdp + abs(Epd);
                        
                         %Step 2: theta incident, pi-theta scattered
                         if m<=ntria/2 % direct incident, reflected scattered
                            Einc=e0;
                            [Ets Etd Eps Epd]=facetRCS(pi-thr,phr,ithr,iphr,N(m,:),ilum(m),iflag,alpha(m),beta(m),Rs(m),Area(m),x,y,z,vind(m,:),Einc,Nt,Lt,cfac2,corel,wave,grreflpar,grreflperp,1,rsmethod,RCpar,RCperp);

                          else %ground reflected incident, direct scattered 
                            Et1=Et*igrreflpar;
                            Ep1=Ep*igrreflperp;
                            ex(1) = uui*Et1 - spi*Ep1;
                    		ex(2) = vvi*Et1 + cpi*Ep1;
                    		ex(3) = wwi*Et1;
                            Einc=ex;
                            [Ets Etd Eps Epd]=facetRCS(pi-thr,phr,ithr,iphr,N(m,:),ilum(m),iflag,alpha(m),beta(m),Rs(m),Area(m),x,y,z,vind(m,:),Einc,Nt,Lt,cfac2,corel,wave,grreflpar,grreflperp,0,rsmethod,RCpar,RCperp);
                         end
                        %Sum over all triangles to get the total field
                         sumt = sumt + Ets;
   	   				     sump = sump + Eps;
                         sumdt = sumdt + abs(Etd);
                         sumdp = sumdp + abs(Epd);    
                   end % CASE 2        
                       
            end      % end of triangle loop
            Sth(index) = 10*log10(4*pi*cfac1*(abs(sumt)^2+sqrt(1-cfac1^2)*sumdt)/wave^2+1e-10);
            Sph(index) = 10*log10(4*pi*cfac1*(abs(sump)^2+sqrt(1-cfac1^2)*sumdp)/wave^2+1e-10);
            index=index+1;
   end	% end of pattern loop
    
    %close waitbar
    close(hwait);
    
	% set plot range
   	Smax = max([max(max(Sth)),max(max(Sph))]);
    Lmax = (floor(Smax/5) + 1)*5; 
    % dynamic range initially set to 60 for axis only
    Lmin = Lmax - 60;
    % true dynamic range is 120 for linearplots
   	Sth(:,:) = max(Sth(:,:),Lmax-120);
    Sph(:,:) = max(Sph(:,:),Lmax-120);
   
    if useground==1
      % reset initial mode
      coord=coordi;
      facet=faceti;
    end    
      
freq=fstart:delf:fstop;
    % Plot the Results
        h=openfig('LinearPlot.fig');
        %set(findobj(gcf,'Tag','polarplot'),'Visible','off');
        pt=findall(h,'Tag','polarplot'); set(pt,'Visible','off')
        ax=findall(h,'Type','Axes');
        plot(ax,freq,Sth,freq,Sph,'--'); grid(ax, "on");       
	   	xlabel(ax,'Frequency (GHz)');
   		ylabel(ax,'RCS (dBsm)');
		axis(ax,[fstart,fstop,Lmin,Lmax]);
        if bist==0
    		title(['target: ',modelname,'  solid: theta,dashed: phi. Angles phi= ',num2str(phi),', theta= ',num2str(theta),]);
        % clean up the background
            openfig('mfreq.fig','reuse'); gca; axis off, title ' ';
        else 
            title(['target: ',modelname,'  solid: theta,dashed: phi. Angles phi= ',num2str(phi),', theta= ',num2str(theta),', iphi= ',num2str(iphi),', itheta= ',num2str(itheta)]);
        % clean up the background
            openfig('mfreq.fig','reuse'); gca; axis off, title ' ';
        end     

answer=questdlg('Save RCS Results?','Save to File','Mat File','Text File','No','Mat File');
switch answer
   case 'Mat File'
      [filename, pathname]=uiputfile('*.mat','Select file name','FResults');
      if filename~=0
          if bist==0
            save([pathname,filename],'theta','phi','freq','Sth','Sph');
          else
           save([pathname,filename],'theta','phi','itheta','iphi','freq','Sth','Sph');
          end
      end  
      
  case 'Text File'
      [filename, pathname]=uiputfile('*.m','Select file name','FResults.m');
      if filename~=0
          if bist==0
            save([pathname,filename],'theta','phi','freq','Sth','Sph','-ASCII');
          else
            save([pathname,filename],'theta','phi','itheta','iphi','freq','Sth','Sph','-ASCII');
          end
      end  
      
         
end
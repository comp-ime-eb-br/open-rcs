function CalcMonoAuto(rsmethod,pathname,filename);
% filename: CalcMono.m
% Project: POFACETS
% Description: This  computes the monostatic RCS of a selected model.
% Author:  Prof. David C. Jenn, Elmo E. Garrido Jr. and Filippos
% Chatzigeorgiadis
% Date:   September 2004
% Place: NPS
% Modifed: openfig changes with holds; contour levels removed
% Feb 10 (v.3.2.1) labels changed to Latex (fixed for contour plot)
% Etscat, Epscat added to save plot
% scale factor added in coords (had been omitted)
% added cleanup of gui background after LinearPlot
warning("off")
      
global C
global coord modelname symplanes matrl
global facet scale changed
global thetadeg phideg RCSth RCSph
global Ethscat Ephscat

nvert = size(coord,1);
ntria=size(facet,1);

     h_figs = get(0,'children');
	 for fig = h_figs'
		  if strcmp(get(fig,'Tag'),'monostatic');
           h_mono = fig;
		  end
	 end
      e0=8.85e-12;%permittivity of free space
      m0=4*pi*1e-7;%permeability of free space
      
      
      %open('MsgComputing.fig');
      txt = ['Computing the monostatic RCS of ',modelname,' model . . .'];         
      set(findobj(gcf,'Tag','Msg'),'String',txt); 
      hwait=waitbar(0,txt);
      pause(0.1);     
      
      % Get parameters
      tstart = str2num(get(findobj(h_mono,'Tag','TStart'),'String')); 
      tstop  = str2num(get(findobj(h_mono,'Tag','TStop'),'String')); 
      delt   = str2num(get(findobj(h_mono,'Tag','Delt'),'String')); 
      pstart = str2num(get(findobj(h_mono,'Tag','PStart'),'String')); 
      pstop  = str2num(get(findobj(h_mono,'Tag','PStop'),'String')); 
      delp   = str2num(get(findobj(h_mono,'Tag','Delp'),'String')); 
      Lt     = str2num(get(findobj(h_mono,'Tag','LRegion'),'String')); 
      Nt     = str2num(get(findobj(h_mono,'Tag','NTerms'),'String')); 
      i_pol  = get(findobj(h_mono,'Tag','IncPolar'),'Value');           
      freq	 = str2num(get(findobj(h_mono,'Tag','Freq'),'String')); 
      show3D = get(findobj(h_mono,'Tag','ModelandRCS'),'Value');
      showpolar = get(findobj(h_mono,'Tag','PolarPlot'),'Value');
      usesymmetry= get(findobj(h_mono,'Tag','usesymmetry'),'Value');
      useground=get(findobj(h_mono,'Tag','groundplane'),'Value');
         
      
       %if ground plane is used, create symmetric model
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
      end
      
            
      wave   = 3e8/(freq * 10^9);
      corr   = str2num(get(findobj(h_mono,'Tag','Corr'),'String')); 
      corel	 = corr/wave; % normalized to the wavelength
      std    = str2num(get(findobj(h_mono,'Tag','Std'),'String'));     
      delstd = std; 
      delsq  = delstd^2;  % variance
      bk     = 2*pi/wave;
      cfac1  = exp(-4*bk^2*delsq);
      cfac2  = 4*pi*(bk*corel)^2*delsq;
      rad 	 = pi/180;    

	  if tstart == tstop, thr0 = tstart*rad; end
      if pstart == pstop, phr0 = pstart*rad; end
	  it = floor((tstop-tstart)/delt) + 1;
   	  ip = floor((pstop-pstart)/delp) + 1;
      
      %When symmetry conditions exist do some calculations of parameters
      % that are going to be used later for RCS calculations
      if usesymmetry==1
          %number of symmetry planes
          symnumber=size(symplanes,1)/3;
          
          for i=1:symnumber
           	A = symplanes((i-1)*3+2,:)-symplanes((i-1)*3+1,:);
	   	    B = symplanes((i-1)*3+3,:)-symplanes((i-1)*3+2,:);
		    C = symplanes((i-1)*3+1,:)-symplanes((i-1)*3+3,:);
            symN(i,:) = - cross(B,A);
          	symNn = norm(symN(i,:));
            % unit normals
            symN(i,:) = symN(i,:)/symNn;
            % rotation angles
            symbeta(i) = acos(symN(i,3));  
            symalpha(i) = atan2(symN(i,2),symN(i,1));
            ca = cos(symalpha(i)); sa = sin(symalpha(i));  cb = cos(symbeta(i)); sb = sin(symbeta(i));
		    symT1{i} = [ca sa 0; -sa ca 0; 0 0 1]; 
            symT2{i} = [cb 0 -sb; 0 1 0; sb 0 cb];
        end
      end
      
      
      % Incident wave polarization
      if i_pol == 1	
         Et = 1+j*0; 
         Ep = 0+j*0;  
      else					
	      Et = 0+j*0;  
         Ep = 1+j*0;  
      end    
		% Wave amplitude at all vertices
	  Co = 1;      
  
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
    
   
   	for i1 = 1:ip
   		for i2 = 1:it
                waitbar(((i1-1)*it+i2)/(ip*it));
                
                alreadycomputed=0;
				phi(i1,i2) = pstart + (i1-1)*delp;
				theta(i1,i2) = tstart + (i2-1)*delt;
                phr = phi(i1,i2)*rad;
                thr = theta(i1,i2)*rad;
                %global angles and direction cosines
                st = sin(thr); ct = cos(thr);
   	            cp = cos(phr);	sp = sin(phr);
				u = st*cp; 	v = st*sp; 	w = ct ;            
                D0=[u v w];
                U(i1,i2) = u; 	V(i1,i2) = v;	 W(i1,i2) = w;     
                if usesymmetry==1 %if symmetry is used
                    % for every symmetry plane
                    changed=0;
                    for i=1:symnumber
                      %find phi and theta in local coordinates
                      symD1 = symT1{i}*D0.';
                      symuvw = symT2{i}*symD1;
	                  symtheta=acos(symuvw(3));
                      if sin(symtheta)~=0
                        symphi=acos(symuvw(1)/sin(symtheta));
                      end
                      %convert theta to be within 0 and pi/2
                      if symtheta>pi/2
                          changed=1;
                          symtheta=abs(pi-symtheta);
                          %convert back to global coordinates
                          if sin(symtheta)~=0
                            symuvw2=[sin(symtheta)*cos(symphi);sin(symtheta)*sin(symphi);cos(symtheta)];
                          else
                            symuvw2=[0;0;1];
                          end
                          DD1 =  symT2{i}.'*symuvw2;
                          DD0 =  symT1{i}.'*DD1;
                          thr=acos(DD0(3));
                          if sin(thr)~=0
                            phr=acos(DD0(1)/sin(thr));
                            st = sin(thr); ct = cos(thr);
              	            cp = cos(phr);	sp = sin(phr);
                            u = st*cp; 	v = st*sp; 	w = ct ;            
                          else
                            u=0;v=0;w=1;
                          end %if sin(trh)
                          D0=[u v w];          
                      end%if symtheta
                     end%for
                     %check to see if RCS for this combination of angles
                     %has already been computed
                     if changed==1
                         %convert to degrees
                         phd=phr/rad;
                         thd=thr/rad;
                         if find(abs(phi-phd)<=1e-3) 
                             if find(abs(theta-thd)<=1e-3)
                               alreadycomputed=1;
                               pf=find(abs(phi-phd)<=1e-3);
                               tf=find(abs(theta(pf)-thd)<=1e-3);
                               indexfound=pf(tf);
                             end
                         end
                     end %if changed
                 end %if symmetry =1;
	
                 
	if alreadycomputed==0			            
			
                uu = ct*cp; vv = ct*sp; 	ww = -st;
                % Spherical coordinate system outward radial unit vector
				R = [u v w];
				% Incident field in global Cartesian coordinates 
				e0(1) = uu*Et - sp*Ep;
				e0(2) = vv*Et + cp*Ep;
				e0(3) = ww*Et;
                
                %if groundplane is used
                % for monostatic case reflection coefficients must be
                % computed for each incidence angle
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
                
                               
				% Begin loop over triangles
				sumt = 0;
                sump = 0;
                sumdt = 0;
                sumdp = 0;
                              
                %dummy values for Refl Coeff when rsmethod=1                
                RCpar=0;
                RCperp=0;
	     		for m = 1:ntria
                    % if applicable, reflection coefficients for parallel
                    % and perpendicular polarization
                    if rsmethod==2
                        [RCpar,RCperp]=RClayers(thr,phr,m,alpha(m),beta(m),freq*1e9);
                    end
                    
                    
                    % CASE 1: simplest case: no ground present
                    if useground==0
                       Einc=e0;
                       [Ets Etd Eps Epd]=facetRCS(thr,phr,thr,phr,N(m,:),ilum(m),iflag,alpha(m),beta(m),Rs(m),Area(m),x,y,z,vind(m,:),Einc,Nt,Lt,cfac2,corel,wave,0,0,0,rsmethod,RCpar,RCperp);
                       %Sum over all triangles to get the total field
                       sumt = sumt + Ets;
   	    			   sump = sump + Eps;
                       sumdt = sumdt + abs(Etd);
                       sumdp = sumdp + abs(Epd);

                   end 
                    
                    % CASE 2: Ground plane present
                    if useground==1 
                        % Step 1: theta incident, theta scattered
                        if m<=ntria/2 % usual case direct incident, direct scattered
                            Einc=e0;
                            [Ets Etd Eps Epd]=facetRCS(thr,phr,thr,phr,N(m,:),ilum(m),iflag,alpha(m),beta(m),Rs(m),Area(m),x,y,z,vind(m,:),Einc,Nt,Lt,cfac2,corel,wave,grreflpar,grreflperp,0,rsmethod,RCpar,RCperp);
                        else %ground reflected incident, ground reflected scattered 
                            Et1=Et*grreflpar;
                            Ep1=Ep*grreflperp;
                            ex(1) = uu*Et1 - sp*Ep1;
             				ex(2) = vv*Et1 + cp*Ep1;
             				ex(3) = ww*Et1;
                            Einc=ex;             
                            [Ets Etd Eps Epd]=facetRCS(thr,phr,thr,phr,N(m,:),ilum(m),iflag,alpha(m),beta(m),Rs(m),Area(m),x,y,z,vind(m,:),Einc,Nt,Lt,cfac2,corel,wave,grreflpar,grreflperp,1,rsmethod,RCpar,RCperp);
                        end    
                        %Sum over all triangles to get the total field
                         sumt = sumt + Ets;
   	   				     sump = sump + Eps;
                         sumdt = sumdt + abs(Etd);
                         sumdp = sumdp + abs(Epd);
                        
                         %Step 2: theta incident, pi-theta scattered
                         if m<=ntria/2 % direct incident, reflected scattered
                            Einc=e0;
                            [Ets Etd Eps Epd]=facetRCS(pi-thr,phr,thr,phr,N(m,:),ilum(m),iflag,alpha(m),beta(m),Rs(m),Area(m),x,y,z,vind(m,:),Einc,Nt,Lt,cfac2,corel,wave,grreflpar,grreflperp,1,rsmethod,RCpar,RCperp);

                          else %ground reflected incident, direct scattered 
                            Et1=Et*grreflpar;
                            Ep1=Ep*grreflperp;
                            ex(1) = uu*Et1 - sp*Ep1;
             				ex(2) = vv*Et1 + cp*Ep1;
             				ex(3) = ww*Et1;
                            Einc=ex;  
                            [Ets Etd Eps Epd]=facetRCS(pi-thr,phr,thr,phr,N(m,:),ilum(m),iflag,alpha(m),beta(m),Rs(m),Area(m),x,y,z,vind(m,:),Einc,Nt,Lt,cfac2,corel,wave,grreflpar,grreflperp,0,rsmethod,RCpar,RCperp);
                         end
                        %Sum over all triangles to get the total field
                         sumt = sumt + Ets;
   	   				     sump = sump + Eps;
                         sumdt = sumdt + abs(Etd);
                         sumdp = sumdp + abs(Epd);    
                   end % CASE 2     
                    
                      
            end      % end of triangle loop
            %thr*180/pi
            %a=input('rrrrrr');
            
            Ethscat(i1,i2)=sumt;
            Ephscat(i1,i2)=sump;
            Sth(i1,i2) = 10*log10(4*pi*cfac1*(abs(sumt)^2+sqrt(1-cfac1^2)*sumdt)/wave^2+1e-10);
            Sph(i1,i2) = 10*log10(4*pi*cfac1*(abs(sump)^2+sqrt(1-cfac1^2)*sumdp)/wave^2+1e-10);
            else %if already computed
                Sth(i1,i2)=Sth(indexfound);
                Sph(i1,i2)=Sph(indexfound);
            end %if alreadycomputed
	   end	% for i2 = 1:it 
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
    RCSth=Sth;
    RCSph=Sph;
    thetadeg=theta;
    phideg=phi;
    
    if useground==1
      % reset initial mode
      coord=coordi;
      facet=faceti;
    end
    
    % Plot the Results
    
     if ip == 1	% phi-cut
        h=openfig('LinearPlot.fig');
        ax=findall(h,'Type','Axes');
        plot(ax,theta,Sth,theta,Sph,'--'); grid(ax, "on");
		title(['target: ',modelname,'  solid: \theta       dashed: \phi       \phi= ',num2str(phi(1,1)),...
   	       	'     wave (m): ',num2str(wave)]);
	   	xlabel(ax,'Monostatic Angle, \theta (deg)');
   		ylabel(ax,'RCS (dBsm)');
		axis(ax,[min(theta),max(theta),Lmin,Lmax]);
        %hold off
    end %if ip
      if it == 1	% theta-cut
        h=openfig('LinearPlot.fig');
        ax=findall(h,'Type','Axes');
        plot(phi,Sth,phi,Sph,'--'); grid(ax, "on");
   		title(['target: ',modelname,'  solid: \theta       dashed: \phi       \theta= ',num2str(theta(1,1)),...
      	  		 '    wave (m): ',num2str(wave)]);
	   	xlabel(ax,'Monostatic Angle, \phi (deg)');
   	 	ylabel(ax,'RCS (dBsm)');
		axis(ax,[min(phi),max(phi),Lmin,Lmax]);
        %hold off
		end
   
   	if ip > 1 & it > 1
         %Dynamic range set for 80dB for surface plots
         Sth(:,:) = max(Sth(:,:),Lmax-80);
         Sph(:,:) = max(Sph(:,:),Lmax-80);
         %h=openfig('MPlot.fig'); 
         %ax=findall(h,'Type','Axes');
         %Lv = [0,-20];
         figure
         subplot(121);  
         % mesh(U,V,Sth,Lv);
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
         % mesh(U,V,Sph,Lv);
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

    % clean up the background
    openfig('monostatic.fig','reuse'); gca; axis off, title ' ';


% If 3D Plot option is selected, Plot model and RCS in 3D
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


   %reshape arrays
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
   txt=['3D RCS Plot of ',modelname,' Model: RED:RCS-\theta, GREEN:RCS-\phi'];
   title(txt);    xlabel('x'); ylabel('y'); zlabel('z');
   hold off;
end%if show3D

if showpolar==1
    f9=openfig('polargraph.fig'); 
    f9.HandleVisibility = "on"
    hold on
end %if showpolar

%answer=questdlg('Save RCS Results?','Save to File','Mat File','Text File','No','Mat File');
answer = 'Auto';
switch answer
   case 'Mat File'
      [filename, pathname]=uiputfile('*.mat','Select file name','MResults');
      if filename~=0
          save([pathname,filename],'theta','phi','freq','Sth','Sph','Ethscat','Ephscat');
      end  
      
  case 'Text File'
      [filename, pathname]=uiputfile('*.m','Select file name','MResults.m');
      Reth=real(Ethscat);
      Ieth=imag(Ethscat);
      Reph=real(Ephscat);
      Ieph=imag(Ephscat);
      if filename~=0
          save([pathname,filename],'theta','phi','freq','Sth','Sph','Reth','Ieth','Reph','Ieph','-ASCII');
      end 
  case 'Auto'
      Reth=real(Ethscat);
      Ieth=imag(Ethscat);
      Reph=real(Ephscat);
      Ieph=imag(Ephscat);
      dataHoraAtual = datetime('now');

      % Converter para o formato desejado
      formatoDesejado = 'yyyymmddHHMMSS';
      dataHoraFormatada = datestr(dataHoraAtual, formatoDesejado);
      filename = [dataHoraFormatada,'_',filename];
      fullFileName = fullfile(pathname, filename);
      save(fullFileName, 'theta', 'phi', 'freq', 'Sth', 'Sph', 'Reth', 'Ieth', 'Reph', 'Ieph', '-ASCII'); 
      
         
end

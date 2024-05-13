% clean and compress a pofacets file
% 			1. remove triangles with zero area
%			2. flag duplicate nodes but do not remove
clear
[filename, pathname]=uigetfile('*.mat','Select model');
if filename~=0
      load([pathname,filename],'coord','facet','scale','symplanes','comments','matrl')
      L=size(facet); nfaces=L(1);
      P=size(coord); nverts=P(1);
      disp(['cleaning and compressing ',filename])
      disp(['number of vertices read: ',num2str(nverts)])
      disp(['number of faces read ',num2str(nfaces)])
      h=waitbar(0,'Searching zero area facets ...');
      pause(0.1);      
  ifct=0;
  n1=facet(:,1); n2=facet(:,2); n3=facet(:,3); 
  del=1e-6;
  vind=coord;
    for i=1:nfaces
        x1=coord(n1(i),1); y1=coord(n1(i),2); z1=coord(n1(i),3);
        x2=coord(n2(i),1); y2=coord(n2(i),2); z2=coord(n2(i),3);
        x3=coord(n3(i),1); y3=coord(n3(i),2); z3=coord(n3(i),3);
        L1=sqrt((x1-x2)^2+(y1-y2)^2+(z1-z2)^2);
        L2=sqrt((x3-x2)^2+(y3-y2)^2+(z3-z2)^2);
        L3=sqrt((x1-x3)^2+(y1-y3)^2+(z1-z3)^2);
 % good facet so add to new table
        if L1>del & L2>del & L3>del
            ifct=ifct+1;
            newfacet(ifct,1:5)=facet(i,1:5);
        end
    end 
    close(h);    
disp(['number of facets with zero area removed: ',num2str(nfaces-ifct)])

idup=0;
  for i=1:nverts
      for n=i+1:nverts
          % tolerance on point displacements
          if abs(coord(i,1)-coord(n,1))<del & abs(coord(i,2)-coord(n,2))<del & abs(coord(i,1)-coord(n,2))<del
              idup=idup+1;
              dn(idup,1)=i; dn(idup,2)=n;
          end
      end
  end
disp(['number of duplicate nodes found (not removed): ',num2str(idup)])
disp(['final number of vertices saved: ',num2str(nverts)])
disp(['final number of facets saved: ',num2str(ifct)])

facet=newfacet;
      %modelname=filename(1:length(filename)-4);
      [filename pathname]=uiputfile('*.mat','Name of compressed file');
      if filename~=0
        save([pathname, filename],'coord','facet','scale','symplanes','comments','matrl');
      end      
 end % skip on cancel open file
 
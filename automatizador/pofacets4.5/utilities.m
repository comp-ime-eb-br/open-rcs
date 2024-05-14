function varargout = utilities(varargin)  %IN PROGRESS
% filename: utilities.m MODIFIED 2015
% added QUICKRANGE, mods to stl export
% Project: POFACETS
% Description: This program implements conversion of model files from
%           version 3.0 to 2.3 and the Non GUI and vice versa
%           It also allows the user to import models designed in AutoCAD
%           and saved in the stereo-lithographic format (*.stl), import and export models in acad
%           and demaco format, import models designed with the pdetool
% Author:  Filippos Chatzigeorgiadis
% Date:   February 2004
% Place: NPS
% 11/2006 only read 4 DEM parameters
% 11/2009 new STL read and write functions added
% 12/2010 new facet count
% 2/11 removed duplicate file extensions when exporting dem
% 2/11 CP added (no -), plot normals added, fixed export raw status bar


% UTILITIES M-file for utilities.fig
%      UTILITIES, by itself, creates a new UTILITIES or raises the existing
%      singleton*.
%
%      H = UTILITIES returns the handle to a new UTILITIES or the handle to
%      the existing singleton*.
%
%      UTILITIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UTILITIES.M with the given input arguments.
%
%      UTILITIES('Property','Value',...) creates a new UTILITIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before utilities_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to utilities_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help utilities

% Last Modified by GUIDE v2.5 30-Dec-2014 20:11:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @utilities_OpeningFcn, ...
                   'gui_OutputFcn',  @utilities_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before utilities is made visible.
function utilities_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to utilities (see VARARGIN)

% Choose default command line output for utilities
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes utilities wait for user response (see UIRESUME)
% uiwait(handles.utilities);


% --- Outputs from this function are returned to the command line.
function varargout = utilities_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in V3toV23.
function V3toV23_Callback(hObject, eventdata, handles)
% hObject    handle to V3toV23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname]=uigetfile('*.mat','Select model');
if filename~=0
      load([pathname,filename],'coord','facet','scale','symplanes')
      coordinates=coord;
      %add first column for facets
      a=facet;
      b(:,2:6)=a;
      x=1:size(facet,1);
      b(:,1)=x';
      facet=b;
      %save file
      modelname=filename(1:length(filename)-4);
      newdir=[];
      answer=inputdlg('Input name for model directory','Save model as Version 2.3');
      newdir=answer{1,:};
      if not(isempty(newdir))
        cd models
        [suc,msg]=mkdir(newdir);
        if isempty(msg)
            cd(newdir);
            save('coordinates','coordinates','facet','scale');
            save('facet','coordinates','facet','scale');
            cd('..');
            cd('..');    
        else
            rep=questdlg('Directory already exists. Replace?','Warning','Yes','No','No');
            switch rep
                case 'Yes'
                    cd(newdir);
                    save('coordinates','coordinates','facet','scale');
                    save('facet','coordinates','facet','scale');
                    cd('..');
                    cd('..');    
                
                case 'No'
                    cd('..');
            end %switch

        end %if isempty(msg)  
    end %if not(isempty(newdier))
end%if filename~=0

% --- Executes on button press in V23toV3.
function V23toV3_Callback(hObject, eventdata, handles)
% hObject    handle to V23toV3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname]=uigetfile('*.mat','Select model');
if filename~=0
      load([pathname,filename],'coordinates','facet','scale')
      coord=coordinates;
      %add first column for facets
      facet=facet(:,2:6);
      symplanes=[0 0 0];
      %save file
      for i=1:size(facet,1)
        comments{i,1}='Model Surface';
        matrl{i,1}='PEC';
        matrl{i,2}=[0 0 0 0 0];
      end
      modelname=filename(1:length(filename)-4);
      [filename pathname]=uiputfile('*.mat','Name of Version 3 model',modelname);
      if filename~=0
        save([pathname, filename],'coord','facet','scale','symplanes','comments','matrl');
      end
 end
 

% --- Executes on button press in V3toNG.
function V3toNG_Callback(hObject, eventdata, handles)
% hObject    handle to V3toNG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname]=uigetfile('*.mat','Select model');
if filename~=0
      load([pathname,filename],'coord','facet','scale','symplanes')
      coordinates=coord;
      %add first column for facets
      a=facet;
      b(:,2:6)=a;
      x=1:size(facet,1);
      b(:,1)=x';
      facet=b;
      %save file
      modelname=filename(1:length(filename)-4);
      newdir=[];
      answer=inputdlg('Input name for model directory','Save model as Non GUI Version');
      newdir=answer{1,:};
      if not(isempty(newdir))
        cd models
        [suc,msg]=mkdir(newdir);
        if isempty(msg)
            cd(newdir);
            save('coordinates.m','coordinates','-ascii');
            save('facets.m','facet','-ascii');
            cd('..');
            cd('..');    
        else
            rep=questdlg('Directory already exists. Replace?','Warning','Yes','No','No');
            switch rep
                case 'Yes'
                    cd(newdir);
                    save('coordinates.m','coordinates','-ascii');
                    save('facets.m','facet','-ascii');
                    cd('..');
                    cd('..');    
                
                case 'No'
                    cd('..');
            end %switch

        end %if isempty(msg)  
    end %if not(isempty(newdier))
end%if filename~=0

% --- Executes on button press in NGtoV3.
function NGtoV3_Callback(hObject, eventdata, handles)
% hObject    handle to NGtoV3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname]=uigetfile('*.m','Select model');
if filename~=0
      load([pathname,'coordinates.m'],'coordinates')
      coord=coordinates;
      load([pathname,'facets.m'],'facets')
      %add first column for facets
      facet=facets(:,2:6);
      symplanes=[0 0 0];
      scale=1;
     for i=1:size(facet,1)
       comments{i,1}='Model Surface';
       matrl{i,1}='PEC';
       matrl{i,2}=[0 0 0 0 0];
     end
%save file
      modelname=filename(1:length(filename)-4);
      [filename pathname]=uiputfile('*.mat','Name of Version 3 model',modelname);
      if filename~=0
        save([pathname, filename],'coord','facet','scale','symplanes','comments','matrl');
      end
 end

% --- Executes on button press in ImportACAD.
function ImportSTL_Callback(hObject, eventdata, handles)
% hObject    handle to ImportACAD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% CAD2MATDEMO, a demonstration of importing 3D CAD data into Matlab.
% SLT import function from Matlab Central  
% by Don Riley (www.mathworks.com downloaded 11/2009)
% uses function rndread(...) which follows
[filename, pathname]=uigetfile('*.stl','Select Stereo-Lithographic model');
fid=fopen([pathname,filename]);
if filename~=0
% Read the CAD data file:

 modelname=fgetl(fid);
 disp(['Importing STL model name: ',modelname])
 disp('Working...')
 lnn=0;
 fct=0;
 nv=0;
 nod=0;
 ntri=1;
 scale=1;
 while ~feof(fid)
            sin=fgetl(fid);
            lnn=lnn+1;
            S=strfind(sin,'vertex');
            K=strrep(sin,'vertex',' ');  % get rid of string leaving only numbers
            if S>0
                nv=nv+1;     % counting all nodes
                nod=nod+1;   % counting nodes in a triangle
                B=sscanf(K,'%f');  % extract numbers from string
                A(nv,:)=B;
                x(ntri,nod)=B(1);
                y(ntri,nod)=B(2);
                z(ntri,nod)=B(3);
                Nv(ntri,nod)=nv;     % node indices of triangle ntri
            end
            if nod==3, nod=0; ntri=ntri+1; end
 end
 fclose(fid);
% remove duplicate nodes -- from Francis Esmonde-White, May 2010  
 [V, indexm, indexn] =  unique(A, 'rows');
 F = indexn(Nv);
 disp(['CAD file ' filename ' data is read'])
  facet=F;
  coord=V;
% Then add surface illumination, surface resistivity, etc.
  facet(:,4)=1;
  facet(:,5)=0;
  scale=1;
  symplanes=[0,0,0];
  for i=1:size(facet,1)
    comments{i,1}='Model Surface';
    matrl{i,1}='PEC';
    matrl{i,2}=[0 0 0 0 0];
  end
%number of vertices and facets
nvert=size(coord,1);
ntria=size(facet,1);
%coordinates of all vertices
xpts = coord(:,1)*scale;
ypts = coord(:,2)*scale;
zpts = coord(:,3)*scale;
%nodes of all facets
node1 = facet(:,1); 	
node2 = facet(:,2); 
node3 = facet(:,3);
%store node of each vertex to the vind array
for i  = 1:ntria 
			pts = [node1(i) node2(i) node3(i)];
			vind(i,:) = pts;       
end
iplt=input('Do you want to plot the object (y/n)? ','s');
if iplt=='y' | iplt=='Y'
    figure(2)
    clf;
    xlabel('X'),ylabel('Y'),zlabel('Z')
    x = xpts; 	y = ypts; 	z = zpts;
    % define X,Y,Z arrays and plot them 
      for i = 1:ntria
         X = [x(vind(i,1)) x(vind(i,2)) x(vind(i,3)) x(vind(i,1))];
    	 Y = [y(vind(i,1)) y(vind(i,2)) y(vind(i,3)) y(vind(i,1))];
	     Z = [z(vind(i,1)) z(vind(i,2)) z(vind(i,3)) z(vind(i,1))];
         plot3(X,Y,Z,'b')
		 if i == 1
     			hold on
         end
      end      
      axis equal   
      title(['Triangular Surface of ',modelname,' Model']);
	  xlabel('x');  ylabel('y');    zlabel('z');
end
  %save coord, facet, scale to file
  [FILENAME, PATHNAME, FILTERINDEX] = uiputfile('*.mat','Input name of file to save data');
  if FILENAME~=0
    save([PATHNAME FILENAME],'coord','facet','scale','symplanes','comments','matrl');
  end
end

% --- Executes on button press in pdetoolmesh.
function pdetoolmesh_Callback(hObject, eventdata, handles)
% hObject    handle to pdetoolmesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname]=uigetfile('*.mat','Select P E T Mesh File');
if filename~=0
  load([pathname,filename],'p','e','t');
  p(3,:)=0;
  coord=p';
  facet=t(1:3,:)';
  facet(:,4)=1;
  facet(:,5)=0;
  scale=1;
  symplanes=[0,0,0];
for i=1:size(facet,1)
  comments{i,1}='Model Surface';
  matrl{i,1}='PEC';
  matrl{i,2}=[0 0 0 0 0];
end
  %save coord, facet, scale to file
  [FILENAME, PATHNAME, FILTERINDEX] = uiputfile('*.mat','Input name of file to save data');
  if FILENAME~=0
    save([PATHNAME FILENAME],'coord','facet','scale','symplanes','comments','matrl');
   end
end


% --- Executes on button press in ImportFacet.
function ImportFacet_Callback(hObject, eventdata, handles)
% hObject    handle to ImportFacet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% distances less than eps are considered the same
epspts=1e-2;    
% iverb=0 is verbose mode -- progress displayed
iverb=1;

[filename, pathname]=uigetfile('*.facet;*.dem','Select input file');
if filename~=0
     fid=fopen([pathname,filename]);
     linedat=fgetl(fid); 
     coment=sscanf(linedat,'%c');
     linedat=fgetl(fid); 
     nparts=sscanf(linedat,'%f');
% keep track of total number of faces and vertices
      nvtl=0;
      nftl=0;
      if iverb==0
        disp(['File header: ',coment])
        disp(['number of parts: ',num2str(nparts)])
      end
      txt = ['Importing model . . .'];         
      hwait=waitbar(0,txt);
      pause(0.1);     
   for npart=1:nparts
        linedat=fgetl(fid); 
        part_type=sscanf(linedat,'c');
        linedat=fgetl(fid); 
        nmir=sscanf(linedat,'%f');
         if nmir~=0, disp('error: structure is mirrored -- cannot handle this file'); end
        linedat=fgetl(fid); 
        nv(npart)=sscanf(linedat,'%f');
        nverts=nv(npart);
        if iverb==0
          disp(['part number: ',num2str(npart)])
          disp(['       name: ',part_type])
          disp(['   vertices: ',num2str(nv(npart))])
        end
        
% read node table for this subpart
      for n=1:nverts
        linedat=fgetl(fid); 
        D=sscanf(linedat,'%f');
        nn=nvtl+n;
        xx=D(1);
        yy=D(2);
        zz=D(3);
% x,y,z coordinates of node number nn
        X(nn)=xx;
        Y(nn)=yy;
        Z(nn)=zz;
     end        % end of for n=1:nverts
% loop through subparts  
        linedat=fgetl(fid); 
        nspts=sscanf(linedat,'%f');
       if iverb==0, disp(['number of subparts in current part: ',num2str(nspts)]), end
      for kn=1:nspts
        linedat=fgetl(fid); 
        subpt=sscanf(linedat,'%s');
           if iverb==0, 
             disp(['subpart number: ',num2str(kn)])      
             disp(['          name: ',subpt])
           end
% read: el type, no. faces, no. vertices, em2, vp,vn,ec
% restrictions: em2=0 (one-sided properties)
%               vp=0 (vertex parameters)
%               vn=0 (no normals present)
%               ec=0 (no curvature lines)
        linedat=fgetl(fid); 
        F=sscanf(linedat,'%f');
        % ACAD format has 7 entries here; DEMACO format has only 2
        if size(F,1)==7
            frmt='ACA'; disp('found ACAD format')
        else
            frmt='DEM'; disp('found DEM format')
        end
        if frmt=='ACA', nsides=F(1); nfaces=F(2); nsv=F(3); 
            nem2=F(4); nvp=F(5); nvn=F(6); nec=F(7);
% display if there are problems with ACAD parameters
           if nsides~=3, disp('nontriangular facet encountered'),end
           if nsv~=0, disp('problem: nsv is not zero'),end
           if nem2~=0, disp('problem: EM2 is not zero'),end
           if nvp~=0, disp('problem: VP is not zero'),end
           if nvn~=0, disp('problem: VN is not zero'),end
           if nec~=0, disp('problem: EC is not zero'),end
        end   % end of ACAD section
        if frmt=='DEM', nfaces=F(1); end
% if this is a part nodes=nverts; if this is a subpart nodes=nsv
      for n=1:nfaces
         waitbar((npart*(n-1)+n)/(nparts*nfaces));
         nn=n+nftl;
% read vertex connection list
         linedat=fgetl(fid); 
         P=sscanf(linedat,'%f');
         L=size(P);
             if n==1 
                 if L(1)==4 
                     disp('modified file: no big part numbers or facet numbers')
                 end 
                 if L(1)>4 
                     disp('ignoring big part numbers and facet numbers')
                 end
              end
% DEMACO file has: node1 node2 node3 ICOAT BIGPART TRIANGLE
% ignore the last two
             nde1=P(1); nde2=P(2); nde3=P(3); ncoat=P(4); 
% the 3 nodes of face nn
         node(1,nn)=nde1+nvtl;
         node(2,nn)=nde2+nvtl;
         node(3,nn)=nde3+nvtl;
      end    % end of nfaces loop
      nftl=nftl+nfaces;
      if iverb==0 
        disp(['finished reading subpart number: ',num2str(kn)])      
        disp(['nftl=',num2str(nftl)])
      end
     end    % end of for kn=1:nspts
      nvtl=nvtl+nv(npart);
    end   % end of for npart=1:nparts
      nverts=nvtl;
      nfaces=nftl;
      if iverb==0
          disp(['total number of vertices, faces read=',num2str(nverts),', ',num2str(nfaces)])
      end
    if iverb==0
      % plot the body
      figure(1), clf
      for i=1:nfaces
         x=[X(node(1,i)) X(node(2,i)) X(node(3,i)) X(node(1,i))];
         y=[Y(node(1,i)) Y(node(2,i)) Y(node(3,i)) Y(node(1,i))];
         z=[Z(node(1,i)) Z(node(2,i)) Z(node(3,i)) Z(node(1,i))];
         % plot entire body   
         plot3(x,y,z,'m')
         if i == 1
   %     axis square
           hold on
         end
      end %for
      hold off
  end %iverb
  fclose(fid);
  close(hwait);
 
  h=waitbar(0,'Converting model ...');
  pause(0.1);  
  coord=[X',Y',Z'];
  %check for duplicate vertices and if found slightly adjust them
  a=size(coord,1);
  for i = 1:a-1
      waitbar(i/(a-1));
      for j = i+1:a
          
               if coord(i,:)==coord(j,:)
                        coord(j,:)=coord(j,:)*(1+1e-6);
                end % if
      end % for
  end % for

  facet=[];
  for i=1:nfaces
      if frmt=='DEM'
         facet=[facet
            node(1,i),node(2,i),node(3,i),1,0];
      end
      if frmt=='ACA'
         facet=[facet
            node(1,i),node(3,i),node(2,i),1,0];
      end
  end
  close(h);
  scale=1;
  symplanes=[0 0 0];
for i=1:size(facet,1)
  comments{i,1}='Model Surface';
  matrl{i,1}='PEC';
  matrl{i,2}=[0 0 0 0 0];
end
  [filename, pathname]=uiputfile('*.mat','Select output file name');
  if filename~=0
    save([pathname,filename],'coord','facet','scale','symplanes','comments','matrl');
  end

end%if filename~=0 from uigetfile


% --- Executes on button press in exportmodel.
function exportmodel_Callback(hObject, eventdata, handles)
% hObject    handle to exportmodel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% exports a pofacets 3.0 model to a facet file (ACAD or DEMACO)
% ONLY ONE PART ALLOWED

[filename, pathname]=uigetfile('*.mat','Select model to be exported');
if filename~=0
      load([pathname,filename],'coord','facet');
      [nfaces,nparms]=size(facet);
      [npoints,mparams]=size(coord);
      answer=questdlg('Output to ACAD or DEMACO file?','Select Export File type','ACAD','DEMACO','ACAD');
      switch answer
         case 'ACAD'
             ftype=0;
         case 'DEMACO'
             ftype=1;
      end
      if ftype==0
         [filename2, pathname2]=uiputfile('*.facet','Select output file');
      end
      if ftype==1
         [filename2, pathname2]=uiputfile('*.dem','Select output file');
       
      end
      if filename2~=0
          fid=fopen([pathname2,filename2],'w');
      
         if ftype==0 %ACAD *.facet files
             fprintf(fid,'%s\n','ACADS FACET FILE V3.0 written from POFACETS converter');                              
             fprintf(fid,'%s\n','   1');
             fprintf(fid,'%s\n','  Volume Mesh');         
             fprintf(fid,'%s\n',' 0');
             fprintf(fid,'%s\n',num2str(npoints));
             % enter the node table    
             for i=1:npoints
                 L=num2str(coord(i,1:3));
                 fprintf(fid,'%12.4f %12.4f %12.4f\n', coord(i,1),coord(i,2),coord(i,3));
             end
             % header for face table
             nsides=3;  % triangular mesh
             nsv=0; % nsv is zero  
             nem2=0; % EM2 is zero 
             nvp=0; % VP is zero 
             nvn=0; % VN is zero 
             nec=0; % EC is zero 
             % all facets lumped into 1 face
             fprintf(fid,'%s\n','   1');
             fprintf(fid,'%s\n','Tri Sheet 0');
             L=num2str([nsides, nfaces, nsv, nem2, nvp, nvn, nec]);
             fprintf(fid,'%s\n',L);
             for i=1:nfaces   
              % ACAD format has 7 entries here; 
               P=num2str(facet(i,1:4));
               % add face parameter for ACAD
               fprintf(fid,'%s\n',P);
             end
         end   % end of ACAD section

        if ftype==1 %DEMACO *.DEM files
             fprintf(fid,'%s\n','DEMACO FACET FILE written from POFACETS converter');                              
             fprintf(fid,'%s\n','   1');
             fprintf(fid,'%s\n','  Volume Mesh');         
             fprintf(fid,'%s\n',' 0');
             fprintf(fid,'%s\n',num2str(npoints));
             % enter the node table    
             for i=1:npoints
                 L=num2str(coord(i,1:3));
                 fprintf(fid,'%12.4f %12.4f %12.4f\n', coord(i,1),coord(i,2),coord(i,3));
             end
             fprintf(fid,'%s\n','  1  ');
             fprintf(fid,'%s\n','only small part');
             % DEMACO format has only 2
             nsides=3;  % triangular mesh
             L=num2str([nfaces, nsides]);
             fprintf(fid,'%s\n',L);
             for i=1:nfaces   
                P=num2str(facet(i,1:3));
                % add face parameter for DEMACO (pofacets doesn't need these
                fprintf(fid,'%s\n',[P,' 0   1  ',num2str(i)]);
             end
        end     
        fclose(fid);
    end %filename2~=0
end %filename~=0

% --- Executes on button press in Clean_file.
function Clean_file_Callback(hObject, eventdata, handles)
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
del=1e-6;  % tolerance on point displacements
idup=0;
  for i=1:nverts
      for n=i+1:nverts
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
end % skip on cancel open original file

% --- Executes on button press in Export_raw.
function Export_raw_Callback(hObject, eventdata, handles)
% hObject    handle to Export_raw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname]=uigetfile('*.mat','Select model to export raw');
if filename~=0
      load([pathname,filename],'coord','facet','scale','symplanes','comments','matrl')
      L=size(facet); nfaces=L(1);
      P=size(coord); nverts=P(1);
      disp(['reading input file: ',filename])
      disp(['number of vertices read: ',num2str(nverts)])
      disp(['number of faces read ',num2str(nfaces)])
      n1=facet(:,1); n2=facet(:,2); n3=facet(:,3); 
      modelname=filename(1:length(filename)-4);
      [filename pathname]=uiputfile('*.raw','Name of raw file for',modelname);
if filename~=0
      fid=fopen([pathname filename],'w');
      fprintf(fid,'%s\n','Object1'); 
      h=waitbar(0,'Generating raw facets ...');
      for i=1:nfaces
        waitbar(i/nfaces,h)
        x1=coord(n1(i),1); y1=coord(n1(i),2); z1=coord(n1(i),3);
        x2=coord(n2(i),1); y2=coord(n2(i),2); z2=coord(n2(i),3);
        x3=coord(n3(i),1); y3=coord(n3(i),2); z3=coord(n3(i),3);
 % matrix of raw triangle data
        T(i,1:9)=[x1,y1,z1,x2,y2,z2,x3,y3,z3];
        fprintf(fid,'%12.4f %12.4f %12.4f %12.4f %12.4f %12.4f %12.4f %12.4f %12.4f\n', ...
            x1,y1,z1,x2,y2,z2,x3,y3,z3);
      end
     close(h);
     fclose(fid);
end   
end % skip on cancel open file   



% --- Executes on button press in Import_raw.
function Import_raw_Callback(hObject, eventdata, handles)
% hObject    handle to Import_raw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% read a *.raw file and write to a pofacets .mat file
% multiple objects allowed

[filename, pathname]=uigetfile('*.raw','Select input raw file');
if filename~=0
     fid=fopen([pathname,filename]);
     ipart=1;
     linedat=fgetl(fid); 
     coment=sscanf(linedat,'%c');
      disp(['Object number ',num2str(ipart),': ',coment])
      txt = ['Importing model . . .'];   
      hwait=waitbar(0,txt);
      pause(0.1);    
      st=0;
      i=0;
      while st==0
            i=i+1;
            linedat=fgetl(fid); 
            P=sscanf(linedat,'%f'); K=size(P);
% this line is another object heading
        if K(1)==0, ipart=ipart+1; disp(['Object number ',num2str(ipart),': ',linedat]); end
% if not an object heading continue reading nodes
        if K(1)==9
% x,y,z coordinates of node number nn
            X(i,1)=P(1);
            Y(i,1)=P(2);
            Z(i,1)=P(3);
            X(i,2)=P(4);
            Y(i,2)=P(5);
            Z(i,2)=P(6);
            X(i,3)=P(7);
            Y(i,3)=P(8);
            Z(i,3)=P(9);
            st=feof(fid);
        end
      end    % end while
      nfaces=i;
      disp(['number of faces: ',num2str(nfaces)])
      disp(['number of nodes: ',num2str(3*nfaces)])
      for i=1:nfaces
          xx=[X(i,1) X(i,2) X(i,3) X(i,1)];
          yy=[Y(i,1) Y(i,2) Y(i,3) Y(i,1)];
          zz=[Z(i,1) Z(i,2) Z(i,3) Z(i,1)]; 
          i1=3*(i-1)+1; 
          coord(i1,1:3)=[X(i,1),Y(i,1),Z(i,1)];
          coord(i1+1,1:3)=[X(i,2),Y(i,2),Z(i,2)];
          coord(i1+2,1:3)=[X(i,3),Y(i,3),Z(i,3)];
          tempfacet(i,1:3)=[i1,i1+1,i1+2];
          iplt=0;
if iplt==1 % plot the body
          figure(1), clf
% plot entire body   
         plot3(xx,yy,zz,'m')
         if i == 1
% axis square
           hold on
           xlabel('x'),ylabel('y'),zlabel('z')
         end
      end 
      hold off
  end 
   close(hwait);

% write pofacets files
  for i=1:nfaces
         facet(i,1:5)=[tempfacet(i,1:3),1,0];
  end
  scale=1;
  symplanes=[0 0 0];
for i=1:size(facet,1)
  comments{i,1}='Model Surface';
  matrl{i,1}='PEC';
  matrl{i,2}=[0 0 0 0 0];
end
  [filename, pathname]=uiputfile('*.mat','Select output pofacets name');
  if filename~=0
    save([pathname,filename],'coord','facet','scale','symplanes','comments','matrl');
  end
end  % skip on cancel open file


% --- Executes on button press in pushbutton18.
function ExportSTL_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% uses function STL_Export which follows

[filename, pathname]=uigetfile('*.mat','Select model to export stl');
if filename~=0
    load([pathname,filename],'coord','facet','scale','symplanes','comments','matrl');
    faces=facet(:,1:3);
    [filename, pathname]=uiputfile('*.stl','Select output stl file name');
    modelname=filename(1:length(filename)-4); 
    STL_Export(coord,faces,filename,modelname);    % using modelname as name of solid

end % skip on cancel open file   

function STL_Export(nodes_file, triangles_file, STL_file_name, solid);
%This is a tool to export 3D graphics from a Tri_Surface file to an ASCII STL file.
% SLT export function from Matlab Central
% by Andreas Richter (www.mathworks.com downloaded 11/2009)
% MODEL MUST HAVE A MINIMUM NUMBER OF TRIANGLES (APPEARS TO BE 4) OR PROBLEMS OCCUR
[node_num,dum]=size(nodes_file);
[triangle_num,dum]=size(triangles_file);
%print the size of the surface data
fprintf (1,'\n');
fprintf (1,'  TRI_SURFACE data:\n');
fprintf (1,'  Number of nodes     = %d\n',node_num);
fprintf (1,'  Number of triangles = %d\n',triangle_num);
ercc=0;
if triangle_num<4, disp('model must have at least 4 triangles'); ercc=1; end

if ercc==0;
%compute the normal vectors without a loop
points_triangles=[nodes_file(triangles_file,1),nodes_file(triangles_file,2),nodes_file(triangles_file,3)];
points_one=points_triangles(1:length(points_triangles)/3,:);
points_two=points_triangles(length(points_triangles)/3+1:length(points_triangles)/3*2,:);
points_three=points_triangles(length(points_triangles)/3*2+1:length(points_triangles),:);
vectors_one=points_two-points_one;
vectors_two=points_three-points_one;
normal_vectors=cross(vectors_one,vectors_two);
norms=repmat(sqrt(sum(normal_vectors.^2,2)),[1,3]);
normalized_normal_vectors=normal_vectors./norms;
%create the output matrix
output=zeros(length(points_one)*4,3);
for i=1:length(points_one)
    output(i*4-3,:)=normalized_normal_vectors(i,:);
    output(i*4-2,:)=points_one(i,:);
    output(i*4-1,:)=points_two(i,:);
    output(i*4,:)=points_three(i,:);
end
output=output';
%write the STL-file (without a loop)
STL_file = fopen (STL_file_name,'wt');
if (STL_file < 0)
    fprintf (1,'\n');
    fprintf (1,'Could not open the file "%s".\n',STL_file_name);
    error ('STL_WRITE - Fatal error!');
end
fprintf (STL_file,'solid %s\n',solid);
fprintf (STL_file, '  facet normal  %14e  %14e  %14e\n    outer loop\n      vertex %14e %14e %14e\n      vertex %14e %14e %14e\n      vertex %14e %14e %14e\n    endloop\n  endfacet\n',output);  
fprintf (STL_file,'endsolid %s\n',solid );
fclose (STL_file);
end

% --- Executes on button press in surface normals
% this portion is extracted from the STL export function, which calculates
% the normals
function ShowNormals_Callback(hObject, eventdata, handles)
% hObject    handle to ShowNormals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global nvert coord scale
global ntria facet
[filename, pathname]=uigetfile('*.mat','Select model to show normals');
if filename~=0
    load([pathname,filename],'coord','facet','scale','symplanes','comments','matrl');
    modelname=' ';
    open('shownorms.fig');
    PlotModel;
    ShowNormals;
    hold on
    %quiver3(xc,yc,zc,nnv(:,1),nnv(:,2),nnv(:,3));
    end % skip on cancel open file 
    
% --- Executes on button press in CircPol.
function CircPol_Callback(hObject, eventdata, handles)
% hObject    handle to CircPol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filenameTM, pathname]=uigetfile('*.mat','Load *.mat results file for TM pol');
if filenameTM~=0
    load([pathname,filenameTM],'Ephscat','Ethscat','phi','theta','freq');
    TT=Ethscat; PT=Ephscat; phi1=phi; theta1=theta; freq1=freq;
    clear Ethscat Ephscat phi theta freq
end % skip on cancel open file 
[filenameTE,pathname]=uigetfile('*.mat','Load *.mat results file for TE pol');
if filenameTE~=0
    load([pathname,filenameTE],'Ephscat','Ethscat','phi','theta','freq');
    TP=Ethscat; PP=Ephscat; phi2=phi; theta2=theta; freq2=freq;
    clear Ethscat Ephscat phi theta
end % skip on cancel open file 

% NOTE: - has been added to Ethscat to agree with Lucernhammer/IEEE
% definition
if filenameTE~=0 & filenameTM~=0  % continue if both files read
if phi1~=phi2 | theta1~=theta2 | freq1~=freq2
    disp('problems: not same data set (angles or frequency')
end

if phi1(1)==phi1(2), cut='p'; end
if theta1(1)==theta1(2), cut='t'; end
disp(['cut is ',cut])
disp(['frequency (GHz): ',num2str(freq)])
wvl=3e8/freq/1e9;
% compute CP using Lucernhammer definitions
RR=.5*((TT-PP)-j*(TP+PT));
LR=.5*((TT+PP)-j*(TP-PT));
RL=.5*((TT+PP)+j*(TP-PT));
LL=.5*((TT-PP)+j*(TP+PT));
RRdb=10*log10(abs(RR).^2*4*pi/wvl^2+1e-10);  % floor set 
RLdb=10*log10(abs(RL).^2*4*pi/wvl^2+1e-10);
LRdb=10*log10(abs(LR).^2*4*pi/wvl^2+1e-10);
LLdb=10*log10(abs(LL).^2*4*pi/wvl^2+1e-10);
% plots
if cut=='t'
figure(3)
clf
plot(phi1,RRdb,'-k',phi1,LRdb,'-r')
xlabel('\phi (deg)'), ylabel('RHCP RCS (dBsm)')
legend('\sigma_R_R','\sigma_L_R')
title(['\theta=',num2str(theta1(1)),'^o'])

figure(4)
clf
plot(phi1,LLdb,'-k',phi1,RLdb,'-r')
xlabel('\phi (deg)'), ylabel('LHCP RCS (dBsm)')
legend('\sigma_L_L','\sigma_R_L')
title(['\theta=',num2str(theta1(1)),'^o'])
end

if cut=='p'
figure(3);
clf
plot(theta1,RRdb,'-k',theta1,LRdb,'-r')
xlabel('\theta (deg)'), ylabel('CP RCS (dBsm)')
legend('\sigma_R_R','\sigma_L_R')
title(['RHCP incident, \phi=',num2str(phi1(1)),'^o'])
figure(4)
clf
plot(theta1,LLdb,'-k',theta1,RLdb,'-r')
xlabel('\theta (deg)'), ylabel('CP RCS (dBsm)')
legend('\sigma_L_L','\sigma_R_L')
title(['LHCP incident, \phi=',num2str(phi1(1)),'^o'])
end

end % skip on cancel open file 
if filenameTE==0 | filenameTM==0, disp('insufficient data entered'); end

% --- Executes on button press in MaxDetectionRange.
function MaxDetectionRange_Callback(hObject, eventdata, handles)
% hObject    handle to MaxDetectionRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%**************************************************************************
%                        by Lalith Karunaratne                            *                                          
%**************************************************************************
clear;

% Enter the following parameters
Pt=input('Enter Transmit Power in Watts: ');
Pr=input('Enter Detection level in dBm: ');
f=input('Enter Frequency in Hz: ');
Gdb=input('Enter Antenna Gain in dB: ');
dBsm=input('Enter RCS in dBsm: ');
%**************************************************************************
c=3e8; % speed of light
lambda=c/f; %Wavelength = c/f
disp ('');
    rcs=10^(dBsm/10); % dBm = 10 log (rcs)
    G=10^(Gdb/10);
    Pr=(10^((Pr-30)/10)); % dBm to Watts conversion
    Max_Range=(Pt*G^2*lambda^2*rcs/(4*pi)^3/Pr)^(1/4)/(1000); ;
disp ('**********************************************************');
    disp(['--> Max_Detection_Range: ', num2str(Max_Range),' km'])                                                



function varargout = graphworks(varargin)
% filename: graphworks.m
% matrl change added 4/2015
% Project: POFACETS
% Description: This file contains the functions of the graphworks figure
% Author:  Filippos Chatzigeorgiadis
% Date:   September 2004
% Place: NPS
% Last modifed: Sep 04 (v.3.0)
% GRAPHWORKS M-file for graphworks.fig
%      GRAPHWORKS, by itself, creates a new GRAPHWORKS or raises the existing
%      singleton*.
%
%      H = GRAPHWORKS returns the handle to a new GRAPHWORKS or the handle to
%      the existing singleton*.
%
%      GRAPHWORKS('Property','Value',...) creates a new GRAPHWORKS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to graphworks_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      GRAPHWORKS('CALLBACK') and GRAPHWORKS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in GRAPHWORKS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help graphworks

% Last Modified by GUIDE v2.5 16-Jul-2004 19:06:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @graphworks_OpeningFcn, ...
                   'gui_OutputFcn',  @graphworks_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before graphworks is made visible.
function graphworks_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for graphworks
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global coord
global facet
global attach
global modelname
coord=[];coord1=[];coord2=[];
facet=[];facet1=[];facet2=[];
attach=0;
modelname='New';






% UIWAIT makes graphworks wait for user response (see UIRESUME)
% uiwait(handles.graphworks);


% --- Outputs from this function are returned to the command line.
function varargout = graphworks_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in rotate.
function rotate_Callback(hObject, eventdata, handles)
% hObject    handle to rotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global coord coord1 coord2
global attach

prompt{1}='Rotation Angle around Z axis (degrees)';
prompt{2}='Rotation Angle around Y axis (degrees)';
prompt{3}='Rotation Angle around X axis (degrees)';
defaultans={'0','0','0'};
answer=inputdlg(prompt,'Input Rotation Angles',1,defaultans);
if not(isempty(answer))
    a=str2num(answer{1})*pi/180;
    b=str2num(answer{2})*pi/180;
    c=str2num(answer{3})*pi/180;
    ca=cos(a);sa=sin(a);cb=cos(b);sb=sin(b);cc=cos(c);sc=sin(c);
    T=[cb 0 -sb; 0 1 0; sb 0 cb]*[ca sa 0; -sa ca 0; 0 0 1]*[1 0 0;0 cc sc;0 -sc cc];
    if attach==0
      for i=1:size(coord1,1)
          coord1(i,:)=(T*coord1(i,:)')';
      end
      coord=coord1;
      cla;
      PlotModel;
      checkgrid;
    elseif attach==1
       for i=1:size(coord2,1)
          coord2(i,:)=(T*coord2(i,:)')';
       end
       coord=[coord1;coord2];
       cla;
       PlotModel;  
       checkgrid;
  end %attach==0
end


% --- Executes on button press in sphere.
function sphere_Callback(hObject, eventdata, handles)
% hObject    handle to sphere (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global coord facet scale symplanes comments matrl
global coord1 facet1 scale1 symplanes1 comments1 matrl1
global coord2 facet2 scale2 symplanes2 comments2 matrl2
global attach

prompt{1}='Sphere Radius';
prompt{2}='Number of points in circle';
defaultans={'1','20'};
answer=inputdlg(prompt,'Input Sphere Parameters',1,defaultans);
if not(isempty(answer))
    R=str2num(answer{1});
    N=str2num(answer{2});
    if attach==0
        [coord1,facet1,scale1,symplanes1,comments1,matrl1]=posphere(R,R,R,N);
    elseif attach==1
       [coord2,facet2,scale2,symplanes2,comments2,matrl2]=posphere(R,R,R,N);
   end % if attach
   arrangearrays;
end


% --- Executes on button press in ellipsoid.
function ellipsoid_Callback(hObject, eventdata, handles)
% hObject    handle to ellipsoid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global coord facet scale symplanes comments matrl
global coord1 facet1 scale1 symplanes1 comments1 matrl1
global coord2 facet2 scale2 symplanes2 comments2 matrl2
global attach

prompt{1}='Ellipsoid Radius in X';
prompt{2}='Ellipsoid Radius in Y';
prompt{3}='Ellipsoid Radius in Z';
prompt{4}='Number of points in circle';
defaultans={'1','2','3','20'};
answer=inputdlg(prompt,'Input Ellipsoid Parameters',1,defaultans);
if not(isempty(answer))
    XR=str2num(answer{1});
    YR=str2num(answer{2});
    ZR=str2num(answer{3});
    N=str2num(answer{4});
    if attach==0
        [coord1,facet1,scale1,symplanes1,comments1,matrl1]=posphere(XR,YR,ZR,N);
    elseif attach==1
       [coord2,facet2,scale2,symplanes2,comments2,matrl2]=posphere(XR,YR,ZR,N);
   end %if attach==0;
   arrangearrays;
end


% --- Executes on button press in clearall.
function clearall_Callback(hObject, eventdata, handles)
% hObject    handle to clearall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=questdlg('Everything will be erased','Are you sure?','Yes','No','No');
switch a,
    case 'Yes'
        cla reset;
        attach=0;
        buttonset1('off');
end


% --- Executes on button press in print.
function print_Callback(hObject, eventdata, handles)
% hObject    handle to print (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function buttonset1(txt);
%changes the status of button set 1
        set(findobj(gcf,'Tag','attachmodel'),'Enable',txt);
        set(findobj(gcf,'Tag','clearall'),'Enable',txt);
        set(findobj(gcf,'Tag','rotate'),'Enable',txt);
        set(findobj(gcf,'Tag','move'),'Enable',txt);
        set(findobj(gcf,'Tag','changesize'),'Enable',txt);
        set(findobj(gcf,'Tag','editsymmetry'),'Enable',txt);
        set(findobj(gcf,'Tag','displaysymmetry'),'Enable',txt);
        set(findobj(gcf,'Tag','savemodel'),'Enable',txt);
        set(findobj(gcf,'Tag','print'),'Enable',txt');
        set(findobj(gcf,'Tag','addcomments'),'Enable',txt);
        set(findobj(gcf,'Tag','editmaterial'),'Enable',txt'); 
        set(findobj(gcf,'Tag','viewcomments'),'Enable',txt'); 
        set(findobj(gcf,'Tag','viewmaterial'),'Enable',txt'); 
        
function buttonset2(txt);
%changes the status of button set 2
        set(findobj(gcf,'Tag','rotate'),'Enable',txt);
        set(findobj(gcf,'Tag','move'),'Enable',txt);
        set(findobj(gcf,'Tag','changesize'),'Enable',txt);
        set(findobj(gcf,'Tag','attachdone'),'Enable',txt');
        set(findobj(gcf,'Tag','addcomments'),'Enable',txt);
        set(findobj(gcf,'Tag','editmaterial'),'Enable',txt'); 
        set(findobj(gcf,'Tag','viewcomments'),'Enable',txt'); 
        set(findobj(gcf,'Tag','viewmaterial'),'Enable',txt'); 


% --- Executes on button press in box.
function box_Callback(hObject, eventdata, handles)
% hObject    handle to box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global coord facet scale symplanes comments matrl
global coord1 facet1 scale1 symplanes1 comments1 matrl1
global coord2 facet2 scale2 symplanes2 comments2 matrl2
global attach

prompt{1}='Length';
prompt{2}='Width';
prompt{3}='Height';
prompt{4}='Angle between Length and Width';
prompt{5}='Angle between Height and Z axis (degrees)';
prompt{6}='Angle between Projection of Height and X axis (degrees)';
defaultans={'1','1','1','90','0','0'};
answer=inputdlg(prompt,'Input Box Parameters',1,defaultans);
if not(isempty(answer))
    L=str2num(answer{1});
    W=str2num(answer{2});
    H=str2num(answer{3});
    ALW=str2num(answer{4});
    ATH=str2num(answer{5});
    APHI=str2num(answer{6});
    if attach==0
        [coord1,facet1,scale1,symplanes1,comments1,matrl1]=poboxes(L,W,H,ALW,ATH,APHI);
    elseif attach==1
       [coord2,facet2,scale2,symplanes2,comments2,matrl2]=poboxes(L,W,H,ALW,ATH,APHI);
     end %if attach==0;
     arrangearrays;
end


% --- Executes on button press in move.
function move_Callback(hObject, eventdata, handles)
% hObject    handle to move (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global coord coord1 coord2
global attach

prompt{1}='Distance in X axis';
prompt{2}='Distance in Y axis';
prompt{3}='Distance in Z axis';
defaultans={'1','1','1'};
answer=inputdlg(prompt,'Input Move Distances',1,defaultans);
if not(isempty(answer))
    x=str2num(answer{1});
    y=str2num(answer{2});
    z=str2num(answer{3});
   if attach==0
      for i=1:size(coord1,1)
          coord1(i,:)=coord1(i,:)+[x y z];
      end
      coord=coord1;
      cla;
      PlotModel;
      checkgrid;
   elseif attach==1
       for i=1:size(coord2,1)
          coord2(i,:)=coord2(i,:)+[x y z];
       end
       coord=[coord1;coord2];
       cla;
       PlotModel;
       checkgrid;
  end %attach==0
end


% --- Executes on button press in changesize.
function changesize_Callback(hObject, eventdata, handles)
% hObject    handle to changesize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global coord coord1 coord2
global attach

prompt{1}='Magnification in X axis';
prompt{2}='Magnification in Y axis';
prompt{3}='Magnification in Z axis';
defaultans={'1','1','1'};
answer=inputdlg(prompt,'Input Magnification Factors',1,defaultans);
if not(isempty(answer))
    x=str2num(answer{1});
    y=str2num(answer{2});
    z=str2num(answer{3});
   if attach==0
      for i=1:size(coord1,1)
          coord1(i,:)=coord1(i,:).*[x y z];
      end
      coord=coord1;
      cla;
      PlotModel;
      checkgrid;
   elseif attach==1
       for i=1:size(coord2,1)
          coord2(i,:)=coord2(i,:).*[x y z];
       end
       coord=[coord1;coord2];
       cla;
       PlotModel;
       checkgrid;
  end %attach==0
end


% --- Executes on button press in trapezoid.
function trapezoid_Callback(hObject, eventdata, handles)
% hObject    handle to trapezoid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global coord facet scale symplanes comments matrl
global coord1 facet1 scale1 symplanes1 comments1 matrl1
global coord2 facet2 scale2 symplanes2 comments2 matrl2
global attach

prompt{1}='Base';
prompt{2}='Width';
prompt{3}='Angle 1 (degrees)';
prompt{4}='Angle 2 (degrees)';
prompt{5}='Height';
defaultans={'5','1','90','45','1'};
answer=inputdlg(prompt,'Input Trapezoid Parameters',1,defaultans);
if not(isempty(answer))
    BB=str2num(answer{1});
    W=str2num(answer{2});
    A1=str2num(answer{3});
    A2=str2num(answer{4});
    H=str2num(answer{5});
    if attach==0
        [coord1,facet1,scale1,symplanes1,comments1,matrl1]=potrapezoids(BB,W,A1,A2,H);
    elseif attach==1
       [coord2,facet2,scale2,symplanes2,comments2,matrl2]=potrapezoids(BB,W,A1,A2,H);
   end %if attach==0;
   arrangearrays;
end



% --- Executes on button press in fuselage.
function fuselage_Callback(hObject, eventdata, handles)
% hObject    handle to fuselage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global coord facet scale symplanes comments matrl
global coord1 facet1 scale1 symplanes1 comments1 matrl1
global coord2 facet2 scale2 symplanes2 comments2 matrl2
global attach

prompt{1}='Main Fuselage Length';
prompt{2}='Radome Length';
prompt{3}='Fuselage Radius';
prompt{4}='Number of Points in Fuselage Circle';
prompt{5}='Number of Points in Radome Curve';
defaultans={'5','1','1','20','6'};
answer=inputdlg(prompt,'Input Fuselage Parameters',1,defaultans);
if not(isempty(answer))
    MFL=str2num(answer{1});
    RL=str2num(answer{2});
    R=str2num(answer{3});
    N=str2num(answer{4});
    M=str2num(answer{5});
    if attach==0
        [coord1,facet1,scale1,symplanes1,comments1,matrl1]=pofuselage(MFL,RL,R,N,M);
    elseif attach==1
       [coord2,facet2,scale2,symplanes2,comments2,matrl2]=pofuselage(MFL,RL,R,N,M);
   end %if attach==0;
   arrangearrays;
end


% --- Executes on button press in cone.
function cone_Callback(hObject, eventdata, handles)
% hObject    handle to cone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global coord facet scale symplanes comments matrl
global coord1 facet1 scale1 symplanes1 comments1 matrl1
global coord2 facet2 scale2 symplanes2 comments2 matrl2
global attach

prompt{1}='Base Radius';
prompt{2}='Cone Height';
prompt{3}='Number of Points in Circle';
prompt{4}='Include Base?';
defaultans={'1','3','20','Yes'};
answer=inputdlg(prompt,'Input Cone Parameters',1,defaultans);
if not(isempty(answer))
    R=str2num(answer{1});
    H=str2num(answer{2});
    N=str2num(answer{3});
    base=answer{4};
    if attach==0
        [coord1,facet1,scale1,symplanes1,comments1,matrl1]=pocones(R,H,N,base);
    elseif attach==1
       [coord2,facet2,scale2,symplanes2,comments2,matrl2]=pocones(R,H,N,base);
   end %if attach==0;
   arrangearrays;
end


% --- Executes on button press in cylinder.
function cylinder_Callback(hObject, eventdata, handles)
% hObject    handle to cylinder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global coord facet scale symplanes comments matrl
global coord1 facet1 scale1 symplanes1 comments1 matrl1
global coord2 facet2 scale2 symplanes2 comments2 matrl2
global attach

prompt{1}='Cylinder Radius';
prompt{2}='Cylinder Height';
prompt{3}='Number of Points in Circle';
prompt{4}='Include Top Base?';
prompt{5}='Include Bottom Base?';
defaultans={'1','3','20','Yes','Yes'};
answer=inputdlg(prompt,'Input Cylinder Parameters',1,defaultans);
if not(isempty(answer))
    R=str2num(answer{1});
    H=str2num(answer{2});
    N=str2num(answer{3});
    ctop=answer{4};
    cbottom=answer{5};
    if attach==0
        [coord1,facet1,scale1,symplanes1,comments1,matrl1]=pocylinder(R,H,N,ctop,cbottom);
    elseif attach==1
       [coord2,facet2,scale2,symplanes2,comments2,matrl2]=pocylinder(R,H,N,ctop,cbottom);
   end %if attach==0;
   arrangearrays;
end


% --- Executes on button press in loadmodel.
function loadmodel_Callback(hObject, eventdata, handles)
% hObject    handle to loadmodel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global coord facet scale symplanes comments matrl
global coord1 facet1 scale1 symplanes1 comments1 matrl1
global coord2 facet2 scale2 symplanes2 comments2 matrl2
global attach modelname

[filename, pathname]=uigetfile('*.mat','Select model');
if filename~=0
      load([pathname,filename],'coord','facet','scale','symplanes','comments','matrl');
      if attach==0
          coord1=coord;facet1=facet;scale1=scale;symplanes1=symplanes;comments1=comments;matrl1=matrl;
      else
          coord2=coord;facet2=facet;scale2=scale;symplanes2=symplanes;comments2=comments;matrl2=matrl;
      end
      modelname=filename(1:length(filename)-4);
      arrangearrays;
end


% --- Executes on button press in attachmodel.
function attachmodel_Callback(hObject, eventdata, handles)
% hObject    handle to attachmodel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global attach

attach=1;
%deactivate some buttons
buttonset1('off');
%All shape and load buttons become dark green
col=[0.502 0 0.251];
set(findobj(gcf,'Tag','sphere'),'ForegroundColor',col);
set(findobj(gcf,'Tag','ellipsoid'),'ForegroundColor',col);
set(findobj(gcf,'Tag','cylinder'),'ForegroundColor',col);
set(findobj(gcf,'Tag','cone'),'ForegroundColor',col);
set(findobj(gcf,'Tag','fuselage'),'ForegroundColor',col);
set(findobj(gcf,'Tag','box'),'ForegroundColor',col);
set(findobj(gcf,'Tag','ogive'),'ForegroundColor',col);
set(findobj(gcf,'Tag','trapezoid'),'ForegroundColor',col);
set(findobj(gcf,'Tag','loadmodel'),'ForegroundColor',col);
%----------------------------------------------------


% --- Executes on button press in attachdone.
function attachdone_Callback(hObject, eventdata, handles)
% hObject    handle to attachdone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global coord facet scale symplanes comments matrl
global coord1 facet1 scale1 symplanes1 comments1 matrl1
global coord2 facet2 scale2 symplanes2 comments2 matrl2
global attach

attach=0;

%activate buttons
buttonset1('on');
%deactivate attachdone
set(findobj(gcf,'Tag','attachdone'),'Enable','off');
%color back to normal
col=[0 0 0.502];
set(findobj(gcf,'Tag','sphere'),'ForegroundColor',col);
set(findobj(gcf,'Tag','ellipsoid'),'ForegroundColor',col);
set(findobj(gcf,'Tag','cylinder'),'ForegroundColor',col);
set(findobj(gcf,'Tag','cone'),'ForegroundColor',col);
set(findobj(gcf,'Tag','fuselage'),'ForegroundColor',col);
set(findobj(gcf,'Tag','box'),'ForegroundColor',col);
set(findobj(gcf,'Tag','trapezoid'),'ForegroundColor',col);
set(findobj(gcf,'Tag','loadmodel'),'ForegroundColor',col);
set(findobj(gcf,'Tag','ogive'),'ForegroundColor',col);
%Check for duplicate vertices
%if found simply make a slight change to one of the vertices 

for i = 1:size(coord1,1)
      for j = 1:size(coord2,1)
               if coord1(i,:)-coord2(j,:)==[0 0 0]
                        coord2(j,:)=coord2(j,:)*(1+1e-6);
                end % if
      end % for
end % for

coord=[coord1;coord2]; 
facet1=facet;
coord1=coord;
comments1=comments;
matrl1=matrl;

%------ Checkgrid function
function checkgrid;
%update grid as appropriate

h_radio = findobj(gcf,'Tag','Grid'); 
if get(h_radio,'Value') == 1
        grid on;
else
         grid off;
end
%--------------------------


% --- Executes on button press in savemodel.
function savemodel_Callback(hObject, eventdata, handles)
% hObject    handle to savemodel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global coord facet scale symplanes comments matrl


[filename, pathname]=uiputfile('*.mat','Select file name','NewModel');
      if filename~=0
          save([pathname,filename],'coord','facet','scale','symplanes','comments','matrl');
      end  
%-------------------------------


% --- Executes on button press in ogive.
function ogive_Callback(hObject, eventdata, handles)
% hObject    handle to ogive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global coord facet scale symplanes comments matrl
global coord1 facet1 scale1 symplanes1 comments1 matrl1
global coord2 facet2 scale2 symplanes2 comments2 matrl2
global attach

prompt{1}='Ogive Radius in X';
prompt{2}='Ogive Radius in Y';
prompt{3}='Ogive Radius in Z';
prompt{4}='Number of points in circle';
defaultans={'1','2','3','20'};
answer=inputdlg(prompt,'Input Ogive Parameters',1,defaultans);
if not(isempty(answer))
    XR=str2num(answer{1});
    YR=str2num(answer{2});
    ZR=str2num(answer{3});
    N=str2num(answer{4});
    if attach==0
        [coord1,facet1,scale1,symplanes1,comments1,matrl1]=poogive(XR,YR,ZR,N);
    elseif attach==1
       [coord2,facet2,scale2,symplanes2,comments2,matrl2]=poogive(XR,YR,ZR,N);
   end %if attach==0;
   arrangearrays;
end

% Array assignments for model manipulation
function arrangearrays
global coord facet scale symplanes comments matrl
global coord1 facet1 scale1 symplanes1 comments1 matrl1
global coord2 facet2 scale2 symplanes2 comments2 matrl2
global attach

if attach==0
        coord=coord1;facet=facet1;scale=scale1;symplanes=symplanes1;comments=comments1;matrl=matrl1;
        cla;
        PlotModel;
        buttonset1('on');
    elseif attach==1
       newstart=size(coord1,1);
       coord=[coord1;coord2];
       facet2(:,1:3)=facet2(:,1:3)+newstart;
       facet=[facet1;facet2];
       matrl=matrl1;
       comments=comments1;
       st=size(facet1,1);
       for i=1:size(facet2,1)
           comments{st+i,1}=comments2{i,1};
           matrl{st+i,1}=matrl2{i,1};
           matrl{st+i,2}=matrl2{i,2};
       end
       cla;
       PlotModel;
       checkgrid;
       buttonset2('on');
    end %if attach==0;


% --- Executes on button press in addcomments.
function addcomments_Callback(hObject, eventdata, handles)
% hObject    handle to addcomments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global coord facet scale symplanes comments matrl
global coord1 facet1 scale1 symplanes1 comments1 matrl1
global coord2 facet2 scale2 symplanes2 comments2 matrl2
global attach

prompt{1}='Comment';
answer=inputdlg(prompt,'Input Part Description',1);
if not(isempty(answer))
  if attach==0
      for i=1:size(facet1,1)
          comments1{i,1}=answer{1};
      end
      comments=comments1;
  else
      for i=1:size(facet2,1)
          comments2{i,1}=answer{1};
      end
      st=size(facet1,1);
       for i=1:size(facet2,1)
           comments{st+i,1}=comments2{i,1};
       end
  end
end


% --- Executes on button press in viewcomments.
function viewcomments_Callback(hObject, eventdata, handles)
% hObject    handle to viewcomments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global attach comments comments2
if attach==0
    openvar comments
else
    openvar comments2
end

% --- Executes on button press in viewmaterial.
function viewmaterial_Callback(hObject, eventdata, handles)
% hObject    handle to viewmaterial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global attach comments comments2

%first open comments files (helpful)
if attach==0
    openvar comments
else
    openvar comments2
end
%next open matlist figure
openfig('MatList.fig');
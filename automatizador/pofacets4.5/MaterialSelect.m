function varargout = MaterialSelect(varargin)
% filename: materialselect.m
% Project: POFACETS
% Description: This  file contains the functions of the
% materialselect figure
% Author:  Filippos Chatzigeorgiadis
% Date:   September 2004
% Place: NPS
% Last modifed: Sep 04 (v.3.0)

% MATERIALSELECT M-file for MaterialSelect.fig
%      MATERIALSELECT, by itself, creates a new MATERIALSELECT or raises the existing
%      singleton*.
%
%      H = MATERIALSELECT returns the handle to a new MATERIALSELECT or the handle to
%      the existing singleton*.
%
%      MATERIALSELECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MATERIALSELECT.M with the given input arguments.
%
%      MATERIALSELECT('Property','Value',...) creates a new MATERIALSELECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MaterialSelect_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MaterialSelect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MaterialSelect

% Last Modified by GUIDE v2.5 10-Mar-2004 11:00:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MaterialSelect_OpeningFcn, ...
                   'gui_OutputFcn',  @MaterialSelect_OutputFcn, ...
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


% --- Executes just before MaterialSelect is made visible.
function MaterialSelect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MaterialSelect (see VARARGIN)

% Choose default command line output for MaterialSelect
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MaterialSelect wait for user response (see UIRESUME)
% uiwait(handles.MaterialSelect);


% --- Outputs from this function are returned to the command line.
function varargout = MaterialSelect_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function Materialname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Materialname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

global materials
load materials
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
for i=1:size(materials,2)
    mname{i}=materials(i).name;
end
set(gcbo,'String',mname);



% --- Executes on selection change in Materialname.
function Materialname_Callback(hObject, eventdata, handles)
% hObject    handle to Materialname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Materialname contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Materialname
global materials
a=get(gcbo,'Value');
set(findobj(gcf,'Tag','relperm'),'String',num2str(materials(a).er));
set(findobj(gcf,'Tag','losstan'),'String',num2str(materials(a).tande));
set(findobj(gcf,'Tag','mureal'),'String',num2str(materials(a).mpr));
set(findobj(gcf,'Tag','muimag'),'String',num2str(materials(a).m2pr));


% --- Executes during object creation, after setting all properties.
function relperm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to relperm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global materials
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(gcbo,'String',num2str(materials(1).er));





% --- Executes during object creation, after setting all properties.
function losstan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to losstan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global materials
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(gcbo,'String',num2str(materials(1).tande))




% --- Executes during object creation, after setting all properties.
function Materialtype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Materialtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
clear layers;
typelist{1}='PEC';
typelist{2}='Composite';
typelist{3}='Composite Layer on PEC';
typelist{4}='Multiple Layers';
typelist{5}='Multiple Layers on PEC';
set(gcbo,'String',typelist);


% --- Executes on selection change in Materialtype.
function Materialtype_Callback(hObject, eventdata, handles)
% hObject    handle to Materialtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Materialtype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Materialtype
global layers
a=get(gcbo,'Value');
if a==1
    set(findobj(gcf,'Tag','Thickness'),'Enable','off');
    set(findobj(gcf,'Tag','Materialname'),'Enable','off');    
    set(findobj(gcf,'Tag','addlayer'),'Enable','off');   
    layers=[];
elseif a==2 | a==3
    set(findobj(gcf,'Tag','Thickness'),'Enable','on');
    set(findobj(gcf,'Tag','Materialname'),'Enable','on'); 
    set(findobj(gcf,'Tag','addlayer'),'Enable','off');    
    layers=[];
elseif a==4 | a==5
    set(findobj(gcf,'Tag','Thickness'),'Enable','on');
    set(findobj(gcf,'Tag','Materialname'),'Enable','on'); 
    set(findobj(gcf,'Tag','addlayer'),'Enable','on');    
end

% --- Executes during object creation, after setting all properties.
function muimag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to muimag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global materials
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(gcbo,'String',num2str(materials(1).m2pr))



% --- Executes during object creation, after setting all properties.
function mureal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mureal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global materials
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(gcbo,'String',num2str(materials(1).mpr))





% --- Executes during object creation, after setting all properties.
function Thickness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Thickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on button press in Close.
function Close_Callback(hObject, eventdata, handles)
% hObject    handle to Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global materials attach facet1 facet2 facet matrl1 matrl2 matrl layers

typelist{1}='PEC';
typelist{2}='Composite';
typelist{3}='Composite Layer on PEC';
typelist{4}='Multiple Layers';
typelist{5}='Multiple Layers on PEC';

answer=questdlg('Update Model with New Values?','Update?','Yes','No','Yes');
    switch answer
      case 'Yes'
        atype=get(findobj(gcf,'Tag','Materialtype'),'Value');
        rperm=str2num(get(findobj(gcf,'Tag','relperm'),'String'));
        ltan=str2num(get(findobj(gcf,'Tag','losstan'),'String'));
        realmu=str2num(get(findobj(gcf,'Tag','mureal'),'String'));
        imagmu=str2num(get(findobj(gcf,'Tag','muimag'),'String'));
        athickness=str2num(get(findobj(gcf,'Tag','Thickness'),'String'));
        if attach==0 | attach==3 %full model or region of facets (manual design)
             if attach==0
               siz=size(facet1,1);
             else 
               siz=size(facet,1);
             end
             for i=1:siz
                matrl1{i,1}=typelist{atype};
                if atype<4
                   matrl1{i,2}=[rperm ltan realmu imagmu athickness];
                else
                   matrl1{i,2}=layers;  
                end
             end
             if attach==0 %applies to full model
               matrl=matrl1;
             elseif attach==3 % applies to a region of facets (only through manual design)
                i1=str2num(get(findobj(gcf,'Tag','firstfacet'),'String'));
                i2=str2num(get(findobj(gcf,'Tag','lastfacet'),'String'));    
                if i1<=i2
                   for i=i1:i2
                     matrl{i,1}=matrl1{i,1};
                     matrl{i,2}=matrl1{i,2};
                   end
                else
                  errordlg('First Facet must be Less than Last Facet','Input Status','Error');
                end
             end       
       elseif attach==1 %attach=1: applies to model being attached
          for i=1:size(facet2,1)
            matrl2{i,1}=typelist{atype};
            if atype<4
                 matrl2{i,2}=[rperm ltan realmu imagmu athickness];
            else
                 matrl2{i,2}=layers;  
            end
          end
          st=size(facet1,1);
          for i=1:size(facet2,1)
           matrl{st+i,1}=matrl2{i,1};
           matrl{st+i,2}=matrl2{i,2};
          end
      end%if attach==0|attach==3
                   
   end %switch
close(gcf);



function Thickness_Callback(hObject, eventdata, handles)
% hObject    handle to Thickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Thickness as text
%        str2double(get(hObject,'String')) returns contents of Thickness as a double


% --- Executes on button press in addlayer.
function addlayer_Callback(hObject, eventdata, handles)
% hObject    handle to addlayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global layers
rperm=str2num(get(findobj(gcf,'Tag','relperm'),'String'));
ltan=str2num(get(findobj(gcf,'Tag','losstan'),'String'));
realmu=str2num(get(findobj(gcf,'Tag','mureal'),'String'));
imagmu=str2num(get(findobj(gcf,'Tag','muimag'),'String'));
athickness=str2num(get(findobj(gcf,'Tag','Thickness'),'String'));

layers=[layers rperm ltan realmu imagmu athickness];

    
% --- Executes on button press in Help.
function Help_Callback(hObject, eventdata, handles)
% hObject    handle to Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function lastfacet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lastfacet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global facet attach

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

if attach==3%enebled only on manual design
  set(hObject,'Enable','on'); 
  set(hObject,'String',num2str(size(facet,1)));
else
  set(hObject,'String','All');
end 


function lastfacet_Callback(hObject, eventdata, handles)
% hObject    handle to lastfacet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lastfacet as text
%        str2double(get(hObject,'String')) returns contents of lastfacet as a double


% --- Executes during object creation, after setting all properties.
function firstfacet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firstfacet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global attach
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
if attach==3%enabled only on manual design
  set(hObject,'Enable','on');
  set(hObject,'String','1');
else
  set(hObject,'String','All');
end

function firstfacet_Callback(hObject, eventdata, handles)
% hObject    handle to firstfacet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of firstfacet as text
%        str2double(get(hObject,'String')) returns contents of firstfacet as a double


% --- Executes on button press in Displaycomments.
function Displaycomments_Callback(hObject, eventdata, handles)
% hObject    handle to Displaycomments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global comments
openvar comments;


% --- Executes during object creation, after setting all properties.
function Displaycomments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Displaycomments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global attach
if attach==3%enabled only on manual design
  set(hObject,'Enable','on');
end






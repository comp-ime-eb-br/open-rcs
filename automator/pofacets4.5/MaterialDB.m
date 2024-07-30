function varargout = MaterialDB(varargin)
% filename: materialdb.m
% Project: POFACETS
% Description: This  function contains the functions
% of the materialdb figure 
% Author:  Filippos Chatzigeorgiadis
% Date:   September 2004
% Place: NPS
% Last modifed: Sep 04 (v.3.0)
% MATERIALDB M-file for MaterialDB.fig
%      MATERIALDB, by itself, creates a new MATERIALDB or raises the existing
%      singleton*.
%
%      H = MATERIALDB returns the handle to a new MATERIALDB or the handle to
%      the existing singleton*.
%
%      MATERIALDB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MATERIALDB.M with the given input arguments.
%
%      MATERIALDB('Property','Value',...) creates a new MATERIALDB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MaterialDB_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MaterialDB_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MaterialDB

% Last Modified by GUIDE v2.5 10-Mar-2004 10:47:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MaterialDB_OpeningFcn, ...
                   'gui_OutputFcn',  @MaterialDB_OutputFcn, ...
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


% --- Executes just before MaterialDB is made visible.
function MaterialDB_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MaterialDB (see VARARGIN)

% Choose default command line output for MaterialDB
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MaterialDB wait for user response (see UIRESUME)
% uiwait(handles.MaterialDB);


% --- Outputs from this function are returned to the command line.
function varargout = MaterialDB_OutputFcn(hObject, eventdata, handles)
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


function relperm_Callback(hObject, eventdata, handles)
% hObject    handle to relperm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of relperm as text
%        str2double(get(hObject,'String')) returns contents of relperm as a double
global materials
a=get(findobj(gcf,'Tag','Materialname'),'Value');
materials(a).er=str2num(get(findobj(gcf,'Tag','relperm'),'String'));



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


function losstan_Callback(hObject, eventdata, handles)
% hObject    handle to losstan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of losstan as text
%        str2double(get(hObject,'String')) returns contents of losstan as a double
global materials
a=get(findobj(gcf,'Tag','Materialname'),'Value');
materials(a).tande=str2num(get(findobj(gcf,'Tag','losstan'),'String'));


% --- Executes on button press in New.
function New_Callback(hObject, eventdata, handles)
% hObject    handle to New (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global materials
prompt{1}='Name';
prompt{2}='Relative Permittivity';
prompt{3}='Loss Tangent';
prompt{4}='Relative Real Magnetic Permeability';
prompt{5}='Relative Imaginary Magnetic Permeability';
answer=inputdlg(prompt,'Input New Material Data',1);
if not(isempty(answer))
  a=size(materials,2)+1;
  materials(a).name=answer{1};
  materials(a).er=num2str(answer{2});
  materials(a).tande=num2str(answer{3});
  materials(a).mpr=num2str(answer{4});
  materials(a).m2pr=num2str(answer{5});

  for i=1:size(materials,2)
      mname{i}=materials(i).name;
  end
  set(findobj(gcf,'Tag','Materialname'),'String',mname);
  set(findobj(gcf,'Tag','Materialname'),'Value',a);
  set(findobj(gcf,'Tag','relperm'),'String',answer{2});
  set(findobj(gcf,'Tag','losstan'),'String',answer{3});
  set(findobj(gcf,'Tag','mureal'),'String',answer{4});
  set(findobj(gcf,'Tag','muimag'),'String',answer{5});

end

% --- Executes on button press in Close.
function Close_Callback(hObject, eventdata, handles)
% hObject    handle to Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global materials
%Sort list by name
siz=size(materials,2);
%names stored to vector b
for i=1:siz
   b{i}=materials(i).name;
end
%sort names
b=sort(b);
%rearrange contents of materials struct to c struct
for i=1:siz
    for j=1:siz
        switch materials(j).name
            case b(i)
               c(i)=materials(j);
       end
   end
end
%update materials struct
materials=c;

save('materials.mat','materials');
close(gcf);


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
set(gcbo,'String',num2str(materials(1).m2pr));


function muimag_Callback(hObject, eventdata, handles)
% hObject    handle to muimag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of muimag as text
%        str2double(get(hObject,'String')) returns contents of muimag as a double
global materials
a=get(findobj(gcf,'Tag','Materialname'),'Value');
materials(a).m2pr=str2num(get(findobj(gcf,'Tag','muimag'),'String'));


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
set(gcbo,'String',num2str(materials(1).mpr));


function mureal_Callback(hObject, eventdata, handles)
% hObject    handle to mureal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mureal as text
%        str2double(get(hObject,'String')) returns contents of mureal as a double
global materials
a=get(findobj(gcf,'Tag','Materialname'),'Value');
materials(a).mpr=str2num(get(findobj(gcf,'Tag','mureal'),'String'));


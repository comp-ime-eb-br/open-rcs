function varargout = mfreq(varargin)
% MFREQ M-file for mfreq.fig
%      MFREQ, by itself, creates a new MFREQ or raises the existing
%      singleton*.
%
%      H = MFREQ returns the handle to a new MFREQ or the handle to
%      the existing singleton*.
%
%      MFREQ('Property','Value',...) creates a new MFREQ using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to mfreq_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      MFREQ('CALLBACK') and MFREQ('CALLBACK',hObject,...) call the
%      local function named CALLBACK in MFREQ.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mfreq

% Last Modified by GUIDE v2.5 17-Feb-2023 10:55:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mfreq_OpeningFcn, ...
                   'gui_OutputFcn',  @mfreq_OutputFcn, ...
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


% --- Executes just before mfreq is made visible.
function mfreq_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for mfreq
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mfreq wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mfreq_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function thslider_Callback(hObject, eventdata, handles)
% hObject    handle to thslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

th=floor(get(hObject,'Value'));
set(findobj(gcf,'Tag','thshow'),'String',num2str(th));


% --- Executes on slider movement.
function phslider_Callback(hObject, eventdata, handles)
% hObject    handle to phslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

ph=floor(get(hObject,'Value'));
set(findobj(gcf,'Tag','phshow'),'String',num2str(ph));





function fstart_Callback(hObject, eventdata, handles)
% hObject    handle to fstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fstart as text
%        str2double(get(hObject,'String')) returns contents of fstart as a double


% --- Executes during object creation, after setting all properties.
function ithslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ithslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function ithslider_Callback(hObject, eventdata, handles)
% hObject    handle to ithslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
ith=floor(get(hObject,'Value'));
set(findobj(gcf,'Tag','ithshow'),'String',num2str(ith));


% --- Executes during object creation, after setting all properties.
function iphslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iphslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function iphslider_Callback(hObject, eventdata, handles)
% hObject    handle to iphslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

iph=floor(get(hObject,'Value'));
set(findobj(gcf,'Tag','iphshow'),'String',num2str(iph));


% --- Executes during object creation, after setting all properties.
function thshow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thshow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function thshow_Callback(hObject, eventdata, handles)
% hObject    handle to thshow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thshow as text
%        str2double(get(hObject,'String')) returns contents of thshow as a double
gp=get(findobj(gcf,'Tag','groundplane'),'Value');
if gp==1
    lim=89;
else
   lim=360;
end
th=str2num(get(findobj(gcf,'Tag','thshow'),'String'));
if th>lim
    txt=['Theta angle can be between 0 and ',num2str(lim),' degrees for ground plane use.'];
    set(findobj(gcf,'Tag','thshow'),'String','0');
    set(findobj(gcf,'Tag','thslider'),'Value',0);
    errordlg(txt,'Angle Status', 'error');
end
val=str2num(get(findobj(gcf,'Tag','thshow'),'String'));
set(findobj(gcf,'Tag','thslider'),'Value',val);


% --- Executes during object creation, after setting all properties.
function phshow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phshow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function phshow_Callback(hObject, eventdata, handles)
% hObject    handle to phshow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phshow as text
%        str2double(get(hObject,'String')) returns contents of phshow as a double
val=str2num(get(findobj(gcf,'Tag','phshow'),'String'));
set(findobj(gcf,'Tag','phslider'),'Value',val);


% --- Executes during object creation, after setting all properties.
function ithshow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ithshow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function ithshow_Callback(hObject, eventdata, handles)
% hObject    handle to ithshow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ithshow as text
%        str2double(get(hObject,'String')) returns contents of ithshow as a double
gp=get(findobj(gcf,'Tag','groundplane'),'Value');
if gp==1
    ulim=89;
    llim=-89;
else
    ulim=360;
    llim=0;
end
ith=str2num(get(findobj(gcf,'Tag','ithshow'),'String'));
if ith>ulim | ith<llim
    txt=['Theta angle can be between ',num2str(llim),' and ',num2str(ulim),' degrees for ground plane use.'];
    set(findobj(gcf,'Tag','ithshow'),'String','0');
    set(findobj(gcf,'Tag','ithslider'),'Value',0);
    errordlg(txt,'Angle Status', 'error');
end
val=str2num(get(findobj(gcf,'Tag','ithshow'),'String'));
set(findobj(gcf,'Tag','ithslider'),'Value',val);

% --- Executes during object creation, after setting all properties.
function iphshow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iphshow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function iphshow_Callback(hObject, eventdata, handles)
% hObject    handle to iphshow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iphshow as text
%        str2double(get(hObject,'String')) returns contents of iphshow as a double
val=str2num(get(findobj(gcf,'Tag','iphshow'),'String'));
set(findobj(gcf,'Tag','iphslider'),'Value',val);


% --- Executes on button press in groundplane.
function groundplane_Callback(hObject, eventdata, handles)
% hObject    handle to groundplane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of groundplane


% --- Executes during object creation, after setting all properties.
function relativeperm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to relativeperm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function relativeperm_Callback(hObject, eventdata, handles)
% hObject    handle to relativeperm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of relativeperm as text
%        str2double(get(hObject,'String')) returns contents of relativeperm as a double


% --- Executes on button press in checkpec.
function checkpec_Callback(hObject, eventdata, handles)
% hObject    handle to checkpec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkpec

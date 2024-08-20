function varargout = Polargraph(varargin)
% filename: polargraph.m
% Project: POFACETS
% Description: This  function implements functions 
% of the polargraph figure
% Author:  Filippos Chatzigeorgiadis
% Date:   September 2004
% Place: NPS
% Last modifed: Sep 04 (v.3.0)

% POLARGRAPH M-file for Polargraph.fig
%      POLARGRAPH, by itself, creates a new POLARGRAPH or raises the existing
%      singleton*.
%
%      H = POLARGRAPH returns the handle to a new POLARGRAPH or the handle to
%      the existing singleton*.
%
%      POLARGRAPH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POLARGRAPH.M with the given input arguments.
%
%      POLARGRAPH('Property','Value',...) creates a new POLARGRAPH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Polargraph_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Polargraph_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Polargraph

% Last Modified by GUIDE v2.5 09-Jan-2017 17:13:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Polargraph_OpeningFcn, ...
                   'gui_OutputFcn',  @Polargraph_OutputFcn, ...
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


% --- Executes just before Polargraph is made visible.
function Polargraph_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Polargraph (see VARARGIN)

% Choose default command line output for Polargraph
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Polargraph wait for user response (see UIRESUME)
%uiwait(handles.polargraph);



% --- Outputs from this function are returned to the command line.
function varargout = Polargraph_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in replot.
function replot_Callback(hObject, eventdata, handles)
% hObject    handle to replot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global thetadeg phideg RCSth RCSph dynr

 if max(max(phideg))==min(min(phideg)) %phi cut
       polardb(thetadeg,RCSth,RCSph,dynr,1,min(min(phideg)));
   elseif max(max(thetadeg))==min(min(thetadeg)) %theta cut
       polardb(phideg,RCSth,RCSph,dynr,2,min(min(thetadeg)));
   else 
       cut=get(findobj(gcf,'Tag','phicut'),'Value')+2*get(findobj(gcf,'Tag','thetacut'),'Value');
       if cut==1 %phi cut
          indexphi=floor(get(findobj(gcf,'Tag','phislider'),'Value'));
          cutangle=phideg(indexphi,1);
          polardb(thetadeg(1,:),RCSth(indexphi,:),RCSph(indexphi,:),dynr,cut,cutangle);
       end
       if cut==2 %theta cut   
          indextheta=floor(get(findobj(gcf,'Tag','thetaslider'),'Value'));
          cutangle=thetadeg(1,indextheta);    
          polardb(phideg(:,1),RCSth(:,indextheta),RCSph(:,indextheta),dynr,cut,cutangle);
      end
 end

% --- Executes during object creation, after setting all properties.
function phislider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phislider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
global thetadeg phideg 

usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
  %phi cut
 if max(max(phideg))==min(min(phideg)) %phi cut
       set(hObject,'Enable','off');
   elseif max(max(thetadeg))==min(min(thetadeg)) %theta cut
       set(hObject,'Enable','off');
   else 
       set(hObject,'Enable','on');%activate controls and set range of values
        set(hObject,'Min',1);
       set(hObject,'Max',size(phideg,1));
       set(hObject,'Value',1.0);
   end


% --- Executes on slider movement.
function phislider_Callback(hObject, eventdata, handles)
% hObject    handle to phislider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global thetadeg phideg 

indexphi=floor(get(hObject,'Value'));
phic=phideg(indexphi,1);
set(findobj(gcf,'Tag','showphi'),'String',num2str(phic));


% --- Executes during object creation, after setting all properties.
function showphi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to showphi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global thetadeg phideg 
%phi cut
 if max(max(phideg))==min(min(phideg)) %phi cut
       set(findobj(gcf,'Tag','showphi'),'String','');
    elseif max(max(thetadeg))==min(min(thetadeg)) %theta cut
       set(findobj(gcf,'Tag','showphi'),'String','');
    else 
       set(findobj(gcf,'Tag','showphi'),'String',num2str(phideg(1,1)));
   end


% --- Executes during object creation, after setting all properties.
function thetaslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thetaslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
global thetadeg phideg 

usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
  %phi cut
 if max(max(phideg))==min(min(phideg)) %phi cut
       set(hObject,'Enable','off');
   elseif max(max(thetadeg))==min(min(thetadeg)) %theta cut
       set(hObject,'Enable','off');
   else 
       set(hObject,'Enable','on');%activate controls and set range of values
       set(hObject,'Min',1);
       set(hObject,'Max',size(thetadeg,2));
       set(hObject,'Value',1.0);
   end



% --- Executes on slider movement.
function thetaslider_Callback(hObject, eventdata, handles)
% hObject    handle to thetaslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global thetadeg phideg 

indextheta=floor(get(hObject,'Value'));
thetac=thetadeg(1,indextheta);
set(findobj(gcf,'Tag','showtheta'),'String',num2str(thetac));


% --- Executes during object creation, after setting all properties.
function showtheta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to showtheta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global thetadeg phideg 
%phi cut
 if max(max(phideg))==min(min(phideg)) %phi cut
       set(findobj(gcf,'Tag','showtheta'),'String','');
    elseif max(max(thetadeg))==min(min(thetadeg)) %theta cut
       set(findobj(gcf,'Tag','showtheta'),'String','');
    else 
       set(findobj(gcf,'Tag','showtheta'),'String',num2str(thetadeg(1,1)));
   end


% --- Executes during object creation, after setting all properties.
function rangeslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rangeslider (see GCBO)
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
function rangeslider_Callback(hObject, eventdata, handles)
% hObject    handle to rangeslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global dynr

dynr=floor((get(hObject,'Value'))/10)*10;;
set(findobj(gcf,'Tag','dynrange'),'String',num2str(dynr));
replot_Callback;

% --- Executes during object creation, after setting all properties.
function dynrange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dynrange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global dynr

dynr=60;
set(hObject,'String',num2str(dynr));




% --- Executes on button press in phicut.
function phicut_Callback(hObject, eventdata, handles)
% hObject    handle to phicut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of phicut
set(findobj(gcf,'Tag','phicut'),'Value',1);
set(findobj(gcf,'Tag','thetacut'),'Value',0);

% --- Executes on button press in thetacut.
function thetacut_Callback(hObject, eventdata, handles)
% hObject    handle to thetacut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of thetacut

set(findobj(gcf,'Tag','phicut'),'Value',0);
set(findobj(gcf,'Tag','thetacut'),'Value',1);


% --- Executes during object creation, after setting all properties.
function phicut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phicut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global thetadeg phideg 


  %phi cut
 if max(max(phideg))==min(min(phideg)) %phi cut
       set(hObject,'Enable','off');
   elseif max(max(thetadeg))==min(min(thetadeg)) %theta cut
       set(hObject,'Enable','off');
   else 
       set(hObject,'Enable','on');%activate controls and set range of values
       set(hObject,'Value',1);
   end


% --- Executes during object creation, after setting all properties.
function thetacut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thetacut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global thetadeg phideg 
  %phi cut
 if max(max(phideg))==min(min(phideg)) %phi cut
       set(hObject,'Enable','off');
   elseif max(max(thetadeg))==min(min(thetadeg)) %theta cut
       set(hObject,'Enable','off');
   else 
       set(hObject,'Enable','on');%activate controls and set range of values
       set(hObject,'Value',0);
   end


% --- Executes on key press with focus on polargraph and none of its controls.
function polargraph_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to polargraph (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key release with focus on polargraph and none of its controls.
function polargraph_KeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to polargraph (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)

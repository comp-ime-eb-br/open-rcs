function varargout = LinearPlot(varargin)
% filename: linearplot.m
% Project: POFACETS
% Description: This file contains the functions of
% the linearplot figure
% Author:  Filippos Chatzigeorgiadis
% Date:   September 2004
% Place: NPS
% Last modifed: Sep 04 (v.3.0)
% LINEARPLOT M-file for LinearPlot.fig
%      LINEARPLOT, by itself, creates a new LINEARPLOT or raises the existing
%      singleton*.
%
%      H = LINEARPLOT returns the handle to a new LINEARPLOT or the handle to
%      the existing singleton*.
%
%      LINEARPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LINEARPLOT.M with the given input arguments.
%
%      LINEARPLOT('Property','Value',...) creates a new LINEARPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LinearPlot_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LinearPlot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LinearPlot

% Last Modified by GUIDE v2.5 01-Feb-2017 09:52:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LinearPlot_OpeningFcn, ...
                   'gui_OutputFcn',  @LinearPlot_OutputFcn, ...
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


% --- Executes just before LinearPlot is made visible.
function LinearPlot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LinearPlot (see VARARGIN)

% Choose default command line output for LinearPlot
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LinearPlot wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LinearPlot_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function dynslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dynslider (see GCBO)
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
function dynslider_Callback(hObject, eventdata, handles)
% hObject    handle to dynslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

ax=axis;
drange=5*floor(get(hObject,'Value')/5);
axis([ax(1) ax(2) ax(4)-drange ax(4)]);
set(findobj(gcf,'Tag','dynshow'),'String',num2str(drange));


% --- Executes during object creation, after setting all properties.
function dynshow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dynshow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject,'String','60');


% --- Executes on button press in polarplot.
function polarplot_Callback(hObject, eventdata, handles)
% hObject    handle to polarplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

openfig('polargraph.fig');


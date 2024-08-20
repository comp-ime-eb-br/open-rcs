function varargout = MatList(varargin)
% filename: matlist.m
% Project: POFACETS
% Description: This file contains the functions of
% the matlist figure
% Author:  Filippos Chatzigeorgiadis
% Date:   September 2004
% Place: NPS
% Last modifed: Sep 04 (v.3.0)
% MATLIST M-file for MatList.fig
%      MATLIST, by itself, creates a new MATLIST or raises the existing
%      singleton*.
%
%      H = MATLIST returns the handle to a new MATLIST or the handle to
%      the existing singleton*.
%
%      MATLIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MATLIST.M with the given input arguments.
%
%      MATLIST('Property','Value',...) creates a new MATLIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MatList_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MatList_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MatList

% Last Modified by GUIDE v2.5 16-Jul-2004 20:09:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MatList_OpeningFcn, ...
                   'gui_OutputFcn',  @MatList_OutputFcn, ...
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


% --- Executes just before MatList is made visible.
function MatList_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MatList (see VARARGIN)

% Choose default command line output for MatList
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MatList wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MatList_OutputFcn(hObject, eventdata, handles)
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

global attach facet facet2 matrl matrl2
if attach==0
    ntria=size(facet,1);
else
    ntria=size(facet2,1);
end
nfacet=1+floor(ntria*get(hObject,'Value'));
set(findobj(gcf,'Tag','dynshow'),'String',num2str(nfacet));
if attach==0
    mater=matrl;
else
    mater=matrl2;
end
set(findobj(gcf,'Tag','MatType'),'String',mater{nfacet,1});
material=mater{nfacet,2};
layers=size(material,2)/5;

%up to 6 layers can be shown
for lay=1:min(layers,6)
    for ind=1:5
        index=(lay-1)*5+ind;
        tag=['edit',num2str(index+1)];
        set(findobj(gcf,'Tag',tag),'Visible','on')
        set(findobj(gcf,'Tag',tag),'String',num2str(material(index)));
    end
end
if index<30
    for ind=index+1:30
        tag=['edit',num2str(ind+1)];
        set(findobj(gcf,'Tag',tag),'Visible','off');
    end
end
        


% --- Executes during object creation, after setting all properties.
function dynshow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dynshow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject,'String','1');






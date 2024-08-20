function varargout = mainscreen(varargin)

% filename: mainscreen.m   ONLY TWO PICS
% Project: POFACETS
% Description: This  file contains the functions
% of the mainscreen figure
% Author:  Filippos Chatzigeorgiadis
% Date:   March 2012
% Place: NPS
% Last modifed: Sep 04 (v.4.0)
% MAINSCREEN M-file for mainscreen.fig
%      MAINSCREEN, by itself, creates a new MAINSCREEN or raises the existing
%      singleton*.
%
%      H = MAINSCREEN returns the handle to a new MAINSCREEN or the handle to
%      the existing singleton*.
%
%      MAINSCREEN('Property','Value',...) creates a new MAINSCREEN using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to mainscreen_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      MAINSCREEN('CALLBACK') and MAINSCREEN('CALLBACK',hObject,...) call the
%      local function named CALLBACK in MAINSCREEN.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mainscreen

% Last Modified by GUIDE v2.5 18-Jul-2004 12:34:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mainscreen_OpeningFcn, ...
                   'gui_OutputFcn',  @mainscreen_OutputFcn, ...
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


% --- Executes just before mainscreen is made visible.
function mainscreen_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for mainscreen
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mainscreen wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mainscreen_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in CalcMono.
function CalcMono_Callback(hObject, eventdata, handles)
% hObject    handle to CalcMono (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 answer=questdlg('Calculate RCS versus ...','Select RCS Calculation Type','Angle','Frequency','Angle');
     switch answer
         case 'Angle'
             openfig('monostatic.fig');
                        
         case 'Frequency'
             openfig('mfreq.fig');
             set(findobj(gcf,'Tag','text33'),'Visible','off');
             set(findobj(gcf,'Tag','text35'),'Visible','off');
             set(findobj(gcf,'Tag','ithshow'),'Visible','off');
             set(findobj(gcf,'Tag','iphshow'),'Visible','off');
             set(findobj(gcf,'Tag','ithslider'),'Visible','off');
             set(findobj(gcf,'Tag','iphslider'),'Visible','off'); 
      end


% --- Executes during object creation, after setting all properties.
function leftpic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to leftpic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate leftpic
axes(findobj('Tag','leftpic'));
a=['pics\10.jpg'];
imshow('pics\10.jpg');


% --- Executes during object creation, after setting all properties.
function rightpic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rightpic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%% Hint: place code in OpeningFcn to populate rightpic
axes(findobj('Tag','rightpic'));
a=['pics\11.jpg'];
imshow('pics\11.jpg');


% --- Executes on button press in CalcBistatic.
function CalcBistatic_Callback(hObject, eventdata, handles)
% hObject    handle to CalcBistatic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 answer=questdlg('Calculate RCS versus ...','Select RCS Calculation Type','Angle','Frequency','Angle');
     switch answer
         case 'Angle'
             openfig('bistatic.fig');
                        
         case 'Frequency'
             openfig('mfreq.fig');
          
      end

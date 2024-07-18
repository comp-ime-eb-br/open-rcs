function varargout = design(varargin)

if nargin > 0  % Check if there are input arguments

    % If input arguments are provided, check if the first argument is 'OpenFile'
    if strcmpi(varargin{1}, 'OpenFile') && nargin == 3
        % If 'OpenFile' is provided and there are three input arguments, 
        % load the file specified by the second and third arguments
        
        % Extract the directory path and filename from input arguments
        directory = varargin{2};
        filename = varargin{3};
        
        % Load the file
        OpenFile(directory, filename)
        
        % Perform any necessary operations with the loaded data
        
    else
        error('Invalid input arguments.');
    end

else
    % If no input arguments are provided, launch the GUI
    
    fig = openfig(mfilename,'reuse');
    % Generate a structure of handles to pass to callbacks, and store it.
    handles = guihandles(fig);
    guidata(fig, handles);
    
    if nargout > 0
        varargout{1} = fig;
    end

end




% --------------------------------------------------------------------
function varargout = close_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.close.
global changed

if changed==1
    a=questdlg('The model was changed. Do you want to save the changes?','Save Model?','Yes','No','Yes');
    switch a
      case 'Yes'
        modl('Save');
    end
end
close(gcf);


% --- Executes on button press in designfacets.
function designfacets_Callback(hObject, eventdata, handles)
% hObject    handle to designfacets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global facet changed
msgbox('Input the node number for each facet. When done, close the Array Editor, select the Design Figure from the Taskbar and press the Check Facets button','Design Facets','help');
uiwait;
openvar('facet');
open('hlpgui.fig');
S = char(helpfacettxt);set(findobj(gcf,'Tag','ListB'),'String',S);
changed=1;

% --- Executes on button press in displaymodel.
function displaymodel_Callback(hObject, eventdata, handles)
% hObject    handle to displaymodel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global coord nvert modelname
global ntria facet scale

open('showmodel.fig');  
PlotModel;



% --- Executes on button press in inputvertices.
function inputvertices_Callback(hObject, eventdata, handles)
% hObject    handle to inputvertices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global coord changed
msgbox('Input the coordinates of the vertices. When done, close the Array Editor, select the Design Figure from the Taskbar and Press the Check Vertices button','Input Vertices','help');
uiwait;
openvar('coord');
open('hlpgui.fig');
S = char(helpcoordtxt);set(findobj(gcf,'Tag','ListB'),'String',S);
changed=1;



% --- Executes on button press in checkvertices.
function checkvertices_Callback(hObject, eventdata, handles)
% hObject    handle to checkvertices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global nvert coord modelname;

hobj=gcf;

%first close any open help windows
 h_figs = get(0,'children');
	 for fig = h_figs'
		  if strcmp(get(fig,'Tag'),'hlpgui');
           close(fig);
		  end
	 end
 

open('MsgComputing.fig');
txt = ['Checking Vertices of ',modelname,' model . . .'];         
set(findobj(gcf,'Tag','Msg'),'String',txt); 
pause(0.1);   
     
nvert=size(coord,1);
valid=0;
for i = 1:(nvert-1)
      for j = (i+1):nvert
               if coord(i,:) == coord(j,:)
                    close(gcf);
            		errordlg('Duplicate vertex coordinates!', 'Coordinate Status', 'error');
                  valid = 1;            
                  break;
               end % if
      end % for
      if valid == 1
               break;
      end % if              
end % for

      
if valid == 0
    set(findobj(hobj,'Tag','designfacets'),'Enable','on');
    set(findobj(hobj,'Tag','checkfacets'),'Enable','on');
    set(findobj(hobj,'Tag','addcomments'),'Enable','on');
    set(findobj(hobj,'Tag','editmaterial'),'Enable','on');
    set(findobj(hobj,'Tag','Scale'),'Enable','on');
    set(findobj(hobj,'Tag','Rs'),'Enable','on');
    set(findobj(hobj,'Tag','Save'),'Enable','on');
    close(gcf);
  	msgbox('Coordinates valid, press Design Facets button to continue.','Coordinate Status', 'help');
end
      

% --- Executes on button press in checkfacets.
function checkfacets_Callback(hObject, eventdata, handles)
% hObject    handle to checkfacets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ntria facet modelname comments matrl

%first close any open help windows
 h_figs = get(0,'children');
	 for fig = h_figs'
		  if strcmp(get(fig,'Tag'),'hlpgui');
           close(fig);
		  end
	 end
hobj=gcf;     
ntria=size(facet,1);

open('MsgComputing.fig');
txt = ['Checking Facets of ',modelname,' model . . .'];         
set(findobj(gcf,'Tag','Msg'),'String',txt); 
pause(0.1); 

% check for duplicate nodes in a single facet
valid=0;
for i = 1: ntria	 
      	if facet(i,1) == facet(i,2) | facet(i,1) == facet(i,3) ...
               		 | facet(i,2) == facet(i,3)
            close(gcf);
            errordlg('Duplicate nodes for the same facet number!','Node Status', 'error');
            valid = 1;                 
            break;
        end % if                      
end % for
  
% check for duplicate set of nodes on all facets
if valid == 0
    for i = 1:(ntria-1)	 
        for j = (i+1): ntria
               if facet(i,:) == facet(j,:)
               	   close(gcf);
                   errordlg('Duplicate set of nodes for at least 2 facets!','Node Status', 'error');
                  valid = 1;
                  break
               end % if
        end % for
        if valid == 1
          	break;
      	end % if
    end % for
end % if          
  
if valid == 0
       set(findobj(hobj,'Tag','displaymodel'),'Enable','on');
       close(gcf);
switch modelname
    case 'New'
       for i=1:size(facet,1)
           comments{i,1}='Model Surface';
           matrl{i,1}='PEC';
           matrl{i,2}=[0 0 0 0 0];
       end
end
       msgbox('All nodes, illumination, and resistivity values valid.  Click View Model button.','Facet Configuration Status', 'help');
end                       




% --- Executes during object creation, after setting all properties.
function Scale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Scale_Callback(hObject, eventdata, handles)
% hObject    handle to Scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Scale as text
%        str2double(get(hObject,'String')) returns contents of Scale as a double
global scale
scale = str2num(get(findobj(gcf,'Tag','Scale'),'String'));


% --- Executes during object creation, after setting all properties.
function Rs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Rs_Callback(hObject, eventdata, handles)
% hObject    handle to Rs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Rs as text
%        str2double(get(hObject,'String')) returns contents of Rs as a double

global facet
a=questdlg('This Rs value will affect all facets. Do you want to continue?','Are you sure?','Yes','No','No');
switch a,
    case 'Yes'
        facet(:,5) = str2num(get(findobj(gcf,'Tag','Rs'),'String'));
 
    otherwise
        set(findobj(gcf,'Tag','Rs'),'String','0');

end

%executes when the Open  is selected in the menu
function OpenFile(pathname,filename)

global coord nvert modelname symplanes comments matrl
global ntria facet scale changed


%[filename, pathname] = uigetfile('*.mat','Select model');

if filename~=0
      load([pathname,filename],'coord','facet','scale','symplanes','comments','matrl')
      modelname=filename(1:length(filename)-4);
      changed=0;
   %set(findobj(gcf,'Tag','Save'),'Enable','on');
   %set(findobj(gcf,'Tag','inputvertices'),'enable','on');
   %set(findobj(gcf,'Tag','checkvertices'),'enable','on');
   %hobj=gcf;
   %a=questdlg('Perform Checks (Time consuming for large models) ?','Are you sure?','Yes','No','No');
    a='No';%modificado
switch a,
    case 'Yes'
   
open('MsgComputing.fig');
txt = ['Checking Vertices of ',modelname,' model . . .'];         
set(findobj(gcf,'Tag','Msg'),'String',txt); 
pause(0.1);   

% Perform checks on model
%check vertices
nvert=size(coord,1);
valid=0;
for i = 1:(nvert-1)
      for j = (i+1):nvert
               if coord(i,:) == coord(j,:)
                    %close(gcf); %close Msgcomputing
                    txt=['Duplicate vertex coordinates for vertex ',num2str(i),' and ',num2str(j)];
            		errordlg(txt, 'Coordinate Status', 'error');
                  valid = 1;            
                  break;
               end % if
      end % for
      if valid == 1
               break;
      end % if              
end % for

if valid==0

    %check facets
    ntria=size(facet,1);
    % check for duplicate nodes in a single facet

    for i = 1: ntria	 
      	if facet(i,1) == facet(i,2) | facet(i,1) == facet(i,3) ...
               		 | facet(i,2) == facet(i,3)
            close(gcf); %close Msgcomputing
            txt=['Duplicate nodes for the facet number ',num2str(i)];
            errordlg(txt,'Node Status', 'error');
            valid = 1;                 
            break;
        end % if                      
    end % for
  
    % check for duplicate set of nodes on all facets
    if valid == 0
     for i = 1:(ntria-1)	 
        for j = (i+1): ntria
               if facet(i,:) == facet(j,:)
                close(gcf); %close Msgcomputing   
                txt=['Duplicate set of nodes for facets ',num2str(i),' and ',num2str(j)];
               	errordlg(txt,'Node Status', 'error');
                  valid = 1;
                  break
               end % if
        end % for
        if valid == 1
          	break;
      	end % if
     end % for
    end % if          
end %if 

if valid == 0
       set(findobj(hobj,'Tag','displaymodel'),'Enable','on');
       close(gcf); %close Msgcomputing
       open('showmodel.fig');
       PlotModel;
end 
  
case 'No'
    open('showmodel.fig');
    PlotModel;
    linha = plot([1 2 3], [2 4 3], 'r', 'LineWidth', 2, 'Tag', 'MinhaLinha');
end %switch
end% if filename~=0


% --- Executes on button press in addcomments.
function addcomments_Callback(hObject, eventdata, handles)
% hObject    handle to addcomments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global facet comments changed
prompt{1}='Number of first facet';
prompt{2}='Number of last facet';
prompt{3}='Comment';
defaultans={'1',num2str(size(facet,1)),''};
answer=inputdlg(prompt,'Input Range of Facets and Comment',1,defaultans);
if not(isempty(answer))
    i1=str2num(answer{1});
    i2=str2num(answer{2});
    if i1<=i2
        for i=i1:i2
            comments{i,1}=answer{3};
        end
        changed=1;
    else
        errordlg('First facet number must be less than Last','Input status','error');
    end
end

% --- Executes on button press in editmaterial.
function editmaterial_Callback(hObject, eventdata, handles)
% hObject    handle to editmaterial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global attach changed
%set attach=3 to energize facet number in Materialselect figure
attach=3;
open('materialselect.fig');
changed=1;

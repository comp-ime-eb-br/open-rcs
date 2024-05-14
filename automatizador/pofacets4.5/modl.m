function modl(action)
% filename: modl.m  
% Project: POFACETS
% Description: This function implements the functionalities of the
%		SHOWMODEL GUI to enhance user view of the model geometry. 
% Author:  Prof. David C. Jenn, Elmo E. Garrido Jr. and Filippos
% Chatzigeorgiadis
% Date:  12 February 2004
% Place: NPS

global nvert coord scale symplanes comments matrl
global ntria facet modelname changed

switch(action)
      
   case 'LVerts' 
      val_LVert  = get(findobj(gcf,'Tag','LVerts'),'Value');
      val_LFacet = get(findobj(gcf,'Tag','LFaces'),'Value');
		PlotModel;
        azim = str2num(get(findobj(gcf,'Tag','Azim'),'String')); 
        elev = str2num(get(findobj(gcf,'Tag','Elev'),'String')); 
        view([azim elev])   
		if val_LVert == 1
         if val_LFacet == 1 	% Label Vertices and Facets
            LabelVertices;
            LabelFacets;           
         else					
				LabelVertices;
         end
      else 
         if val_LFacet == 1	% Label Facets Only
            LabelFacets;             
         end
      end
      
      h_radio = findobj(gcf,'Tag','Grid'); 
      if get(h_radio,'Value') == 1
         grid on;
      else
         grid off;
      end
      
   case 'LFaces'
      val_LFacet = get(findobj(gcf,'Tag','LFaces'),'Value');
      val_LVert  = get(findobj(gcf,'Tag','LVerts'),'Value');
		PlotModel;
        azim = str2num(get(findobj(gcf,'Tag','Azim'),'String')); 
        elev = str2num(get(findobj(gcf,'Tag','Elev'),'String')); 
        view([azim elev])   
        if val_LFacet == 1
         if val_LVert == 1 	% Label Vertices and Facets
            LabelFacets;
            LabelVertices;           
         else					
            LabelFacets;
         end
      else 
         if val_LVert == 1	% Label Facets Only
            LabelVertices;
         end
      end                              
      
      h_radio = findobj(gcf,'Tag','Grid'); 
      if get(h_radio,'Value') == 1
         grid on;
      else
         grid off;
      end

   case 'Grid' 
      h_radio = findobj(gcf,'Tag','Grid'); 
      if get(h_radio,'Value') == 1
         grid on;
      else
         grid off;
      end
                  
   case 'Azim' 
      h_azim = findobj(gcf,'Tag','Azim'); 
      azim_str = get(h_azim,'String'); 
      azim = getAzimuth(azim_str); 
      set(h_azim,'String',num2str(azim));
      
   case 'Elev' 
      h_elev = findobj(gcf,'Tag','Elev'); 
      elev_str = get(h_elev,'String'); 
      elev = getElevation(elev_str); 
      set(h_elev,'String',num2str(elev));      
      
   case 'Viewpoint' 
      azim = str2num(get(findobj(gcf,'Tag','Azim'),'String')); 
      elev = str2num(get(findobj(gcf,'Tag','Elev'),'String')); 
      view([azim elev])      
      
   case 'Print'
          
        %print the figure    
      	h_figs = get(0,'children');
		for fig = h_figs'
 			if strcmp(get(fig,'Tag'),'showmodel')  
               figure(fig);  
               print;
               break;
         	end         	
         end
      
         % output coordinates and facets in text file
          helpdlg('Coordinates and facets will be stored in a text (*.m) file. The user can view, edit and print this file using the standard MATLAB text editor');
         [filename, pathname]=uiputfile('*.m','Input file name',[modelname,'.m']);
         if filename~=0
           save([pathname,filename],'coord','facet','scale','symplanes','-ASCII','-TABS');
         end
         
      
         
   case 'Save'
      [filename, pathname]=uiputfile('*.mat','Select file name',modelname);
      if filename~=0
          save([pathname,filename],'coord','facet','scale','symplanes','comments','matrl');
           modelname=filename(1:length(filename)-4);
           changed=0;
      end  
      
  case 'SymEdit'
     msgbox('Input the coordinates of three points to define a symmetry plane. Each row contains coordinates of one point. When done, close the Array Editor, select the showmodel Figure from the Taskbar and Press the Display button','Input Symmetry Plane(s)','help');
     uiwait;
     openvar('symplanes');
     open('hlpgui.fig');
     S = char(helpsymtxt);set(findobj(gcf,'Tag','ListB'),'String',S);
     changed=1;

      
  case 'SymDisplay'
     %first close any open help windows
     h_figs = get(0,'children');
	 for fig = h_figs'
		  if strcmp(get(fig,'Tag'),'hlpgui');
           close(fig);
		  end
	 end
     
      %check if symmetry planes where defined by 3 points each
      valid=0;
      if mod(size(symplanes,1),3)~=0
          valid=1;
          helpdlg('Error. Each symmetry plane must be defined by three points. Please edit the points again');
      end
      if valid==0
          PlotModel;
      end

  case 'Close'
    if changed==1
      a=questdlg('The model was changed. Do you want to save the changes?','Save Model?','Yes','No','Yes');
      switch a
        case 'Yes'
          modl('Save');
      end
    end
    close(gcf);  
end % switch
   

   
% Routine to label vertices of the model 
function LabelVertices

global nvert coord scale
global ntria facet

nvert=size(coord,1);
ntria=size(facet,1);
	
   x = coord(:,1)*scale;
   y = coord(:,2)*scale;
   z = coord(:,3)*scale;
   % 3 : plot the corresponding vertex numbers
   hold on
   for i = 1:nvert
      text(x(i)-max(x)/20,y(i)-max(y)/20,z(i),num2str(i));
   end    
   hold off

% Routine to label the facets of the model 
function LabelFacets

global nvert coord scale
global ntria facet

nvert=size(coord,1);
ntria=size(facet,1);

    x = coord(:,1)*scale;
 	y = coord(:,2)*scale;
 	z = coord(:,3)*scale;
 	
  	node1 = facet(:,1);
 	node2 = facet(:,2);
 	node3 = facet(:,3);
 	% 6 : Compute centroid of face number i
   h = zeros(ntria);
   hold on
   for i = 1:ntria            
     	xav = (x(node1(i)) + x(node2(i)) + x(node3(i))) / 3;
     	yav = (y(node1(i)) + y(node2(i)) + y(node3(i))) / 3;
     	zav = (z(node1(i)) + z(node2(i)) + z(node3(i))) / 3;            
     	h(i) = text(xav,yav,zav,num2str(i));   
   end    
   hold off  
   
   % validates azimuth angle entered
function o_ang = getAzimuth(ang_str)
   
   temp = str2num(ang_str);
   if (isempty(temp)) | (temp < -360) | (temp > 360)
      errordlg('Enter an azimuth angle between -360 and 360 degrees.', ...
         		'Azimuth Angle Status', 'error');
      temp = -37.5; % default azimuth 
   elseif (ang_str == 'i' | ang_str == 'j')
      errordlg('Enter an azimuth angle between -360 and 360 degrees.', ...
         		'Azimuth Angle Status', 'error');
      temp = -37.5; 
   end 
   o_ang = temp;
% end getAzimuth  

   % validates elevation angle entered
function o_ang = getElevation(ang_str)
   
   temp = str2num(ang_str);
   if (isempty(temp)) | (temp < -360) | (temp > 360)
      errordlg('Enter an elevation angle between -360 and 360 degrees.', ...
         		'Elevation Angle Status', 'error');
      temp = 30; % default elevation 
   elseif (ang_str == 'i' | ang_str == 'j')
      errordlg('Enter an elevation angle between -360 and 360 degrees.', ...
         		'Elevation Angle Status', 'error');
      temp = 30; 
   end 
   o_ang = temp;
% end getElevation  

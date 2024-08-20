function surfl(action)
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
        ShowNormals;
        hold on

        azim = str2num(get(findobj(gcf,'Tag','Azim'),'String')); 
        elev = str2num(get(findobj(gcf,'Tag','Elev'),'String')); 
        view([azim elev])   
		if val_LVert == 1
         if val_LFacet == 1 	% Label Vertices and Facets
            LabelVertices;
            LabelFacets; hold on
            ShowNormals;
         else					
				LabelVertices; hold on
                ShowNormals;
         end
      else 
         if val_LFacet == 1	% Label Facets Only
            LabelFacets;  hold on
            ShowNormals;
         end
        end
      
   case 'LFaces'
      val_LFacet = get(findobj(gcf,'Tag','LFaces'),'Value');
      val_LVert  = get(findobj(gcf,'Tag','LVerts'),'Value');
		PlotModel;
        ShowNormals;
        hold on

        azim = str2num(get(findobj(gcf,'Tag','Azim'),'String')); 
        elev = str2num(get(findobj(gcf,'Tag','Elev'),'String')); 
        view([azim elev])   
        if val_LFacet == 1
         if val_LVert == 1 	% Label Vertices and Facets
            LabelFacets;
            LabelVertices; hold on
            ShowNormals;
         else					
            LabelFacets; hold on
            ShowNormals;
         end
      else 
         if val_LVert == 1	% Label Facets Only
            LabelVertices; hold on
            ShowNormals;
         end
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
      
  case 'Close'
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


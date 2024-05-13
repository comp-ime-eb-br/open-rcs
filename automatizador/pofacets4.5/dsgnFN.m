function dsgnFN(command_str)
% filename: dsgnFN.m
% Project: POFACETS
% Description: This function clears sets values to the program's
%                global variables and sets up the design unit figure
% Author:  Filippos Chatzigeorgiadis
% Date:  12 February 2004
% Place: NPS
%
% 	DESIGN 
%  -- File 
%     -- New

global coord facet modelname scale symplanes

%initial values to global variables
coord=[0,0,0];
facet=zeros(1,5);
symplanes=[0 0 0];
scale=1;
modelname='New';
%Enable first two buttons and disable all elsee
set(findobj(gcf,'Tag','inputvertices'),'enable','on');
set(findobj(gcf,'Tag','checkvertices'),'enable','on');
set(findobj(gcf,'Tag','designfacets'),'Enable','off');
set(findobj(gcf,'Tag','checkfacets'),'Enable','off');
set(findobj(gcf,'Tag','Scale'),'Enable','off');
set(findobj(gcf,'Tag','Rs'),'Enable','off');
set(findobj(gcf,'Tag','Save'),'Enable','off');
msgbox('To Star Press the Input Vertices button.','New Model Design', 'help');
      
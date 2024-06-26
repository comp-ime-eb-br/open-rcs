function C = helpcoordtxt
% filename: helpcoordtxt.m
% Project: POFACETS
% Description:  This program contains the the text displayed in the 
%       Input Vertices Help GUI.
% Author:  Filippos Chatzigeorgiadis
% Date: September 2004
% Place: NPS 
%
 C = {'The coordinates of the facets of a model can be manually entered'; ...
       'using MATLAB''s array editor.'; ...
       ' '; ...
       'For each vertex three columns are available, corresponding to the'; ...
       'x, y and z coordinates of each vertex. For example,'; ... 
       'a vertex located at the origin is represented as  0 0 0 and'; ...
       'a second vertex measuring fifty meters in the y-axis from the origin'; ...
       'is represented as  0 50 0.'; ...
       ' '; ...
       'The number assigned to each vertex for use in the facet design'; ...
       'is the same with the row number displayed at the left of the'; ...
       'coordinates. The user does not assign numbers to the vertices.'; ...
       ' '; ...
       'If the user needs to modify the total number of vertices in'; ...
       'a model, this is accomplished by directly modifying the number'; ...
       'of rows displayed on the top of the array editor. Notice that a'; ...
       'reduction in the number of rows results in loss of all the excess'; ...
       'vertices. An increase in the number of rows results in all-zeros'; ...
       'vertices added at the bottom of the array.'; ...
       ' '; ...
       'The total number of columns must be always 3.'};

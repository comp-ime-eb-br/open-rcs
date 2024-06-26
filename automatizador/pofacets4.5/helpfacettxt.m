function C = helpfacettxt
% filename: helpfacettxt.m
% Project: POFACETS
% Description:  This program contains the text displayed in the Design 
%		Facets Help GUI.
% Author:  Prof. David C. Jenn, Elmo E. Garrido Jr and Filippos
% Chatzigeorgiadis
% Date: September 2004
% Place: NPS
%
 C = {'The description of the facets of a model can be manually entered'; ...
       'using MATLAB''s array editor.'; ...
       ' '; ...
       'For each facet five columns are available.'; ...
       ' '; ...
       'The first 3 columns correspond to the three vertex  numbers which'; ...
       'define the facet.  The vertices  comprising the facet'; ...
       'should  be ordered in a right-hand or  counter clockwise sense  where'; ...
       'the normal to the facet is the direction of illumination.'; ...
       ' '; ...
       'The fourth column corresponds to the Illumination value of the facet'; ...
       'If this value is 0, the facet is allowed  to be  illuminated from'; ...
       'both sides. If this value is 1, if the facet will only be illuminated'; ...
       'from its front side, as defined by the sequency of its vertices.'; ...
       ' '; ...
       'The fifth column corresponds to the facet''s Surface Resistivity value'; ...
       'This value is normalized to the free space value of 377 ohms. For a'; ...
       'surface resistivity value of 0, the facet is a Perfect Electric'; ...
       'Conductor (PEC). A large value(several thousand) in this column';...
       'will make the facet transparent.'; ...
       ' '; ...
       'The number assigned to each facet is the same with the row number'; ...
       'displayed at the left of each row. The user does not assign numbers'; ...
       'to the facets.'; ...
       ' '; ...
       'If the user needs to modify the total number of facets in'; ...
       'a model, this is accomplished by directly modifying the number'; ...
       'of rows displayed on the top of the array editor. Notice that a'; ...
       'reduction in the number of rows results in loss of all the excess'; ...
       'facets. An increase in the number of rows results in all-zeros'; ...
       'facets added at the bottom of the array.'; ...
       ' '; ...
       'The total number of columns must be always 5.'};

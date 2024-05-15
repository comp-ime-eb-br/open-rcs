function C = helpmandestxt
% filename: helpmandestxt.m
% Project: POFACETS
% Description:  This program contains the text displayed in the Manual Model Design
%			Help GUI.
% Author:  Filippos Chatzigeorgiadis
% Date: September 2004
% Place: NPS
%
C  = {'The Manual Model Design GUI allows a user to manually enter'; ...
      'all the data that are necessary to model a target using'; ...
      'triangular facet. The GUI can be used to design a new model'; ...
      'or edit an existing model'; ...
      ' '; ...
      'Menu File New - Use this menu option to create a new model.'; ...
      'The buttons will be gradually activated as more data are'; ...
      'entered and checked. The model can be saved at any time,'; ...
      'regardless of whether it is complete or not.'; ...
      ' '; ...
      'Menu File Open - Use this menu option to load and edit an'; ...
      'existing model. Model files are stored in the Models'; ...
      'directory. The model is loaded, displayed, and all buttons'; ...
      'are activated.'; ...
      ' '; ...
      'Input Vertices Button  - Use this button to enter the'; ...
      'coordinates of the vertices of the model. A help screen'; ...
      'will appear, explaining how the coordinates are entered.'; ...
      ' '; ...
      'Check Vertices Button  - Use this button to check the'; ...
      'validity of the coordinates of the vertices of the model.'; ...
      'When designing a new model, this step must be completed to'; ...
      'activate the Design Facets button.'; ...
      ' '; ...
      'Design Facets Button  - Use this button to enter the'; ...
      'vertices of the facets of the model. A help screen'; ...
      'will appear, explaining how the facets are designed.'; ...
      ' '; ... 
      'Check Facets Button  - Use this button to check the'; ...
      'validity of the design of the facets of the model.'; ...
      'When designing a new model, this step must be completed to'; ...
      'activate the Display Model button.'; ...
      ' ';
      'Display Model Button  - Use this button to display the'; ...
      'model geometry, edit and view its symmetry planes.'; ...
      ' '; ...
      'Model Scale Edit box - The value entered in this box'; ...
      'defines the scale of the model. It is strongly suggested to keep'; ...
      'its value equal to 1.'; ...
      ' ';
      'Rs (relative) Edit box - The value entered in this box'; ...
      'is automatically copied to the surface resistivity column'; ...
      '(i.e., column 5 of all the facets. Surface resistivity'; ...
      'values must be normalized to free space impedance (377 Ohms).'; ...
      ' '; ...
      'Add Comments Button - Allows the user to enter a description'; ...
      'for the facets of the model'; ...
      ' '; ...
      'Edit Material Button - Allows the user to select material or'; ...
      'layers of materials to be applied to the facets of the model'; ...
      ' '; ...
      'Save Button - Saves the model data. User is also prompted to'; ...
      'save the model, if changes have occured and have not been saved'; ...
      ' '};
function monofreq(action)
% filename: mono.m
% Project: POFACETS
% Description: This program implements the functionalities of the Calculate
%			Monostatic RCS GUI for a range of frequencies. 
% Author:  Prof. David C. Jenn, Elmo E. Garrido Jr. and Filippos
% Chatzigeorgiadis
% Date:   14 August 2000
% Place: NPS
% Last modifed: Feb 04 (v.3.0)

global C
global coord nvert modelname symplanes matrl comments
global ntria facet scale changed

C = 3*10^8;	% speed of light in m/sec

switch(action)
   
         
   case 'FStart'
      h_fstart = findobj(gcf,'Tag','FStart'); 
      fstart_str = get(h_fstart,'String'); 
      fstart = getFStart(fstart_str); 
      set(h_fstart,'String',num2str(fstart));
      
   case 'FStop'
      h_fstop = findobj(gcf,'Tag','FStop'); 
      fstop_str = get(h_fstop,'String'); 
      fstop = getFStop(fstop_str); 
      set(h_fstop,'String',num2str(fstop));

   case 'Delf'
      h_delf = findobj(gcf,'Tag','Delf');
      delf_str = get(h_delf,'String'); 
      delf = getDelf(delf_str);
      set(h_delf,'String',num2str(delf)); 
      

   case 'LRegion'
      h_Lt = findobj(gcf,'Tag','LRegion');
      Lt_str = get(h_Lt,'String'); 
      Lt = getLRegion(Lt_str);
      set(h_Lt,'String',num2str(Lt));    
      
   case 'NTerms'
      h_Nt = findobj(gcf,'Tag','NTerms');
      Nt_str = get(h_Nt,'String'); 
      Nt = getNTerms(Nt_str);
      set(h_Nt,'String',num2str(Nt)); 
      
 	case 'i_pol'    
      h_ipol = findobj(gcf,'Tag','IncPolar'); 
      val = get(h_ipol,'Value');
      if val == 1
         Et = 1;
         Ep = 0;
      else
         Et = 0;
         Ep = 1;
      end
      
      case 'ground'    
          gp=get(findobj(gcf,'Tag','groundplane'),'Value');
          if gp==1
              set(findobj(gcf,'Tag','checkpec'),'Enable','on');
               %make sure that theta goes from 0 to 90 deg only
              th=str2num(get(findobj(gcf,'Tag','thshow'),'String'));
              ith=str2num(get(findobj(gcf,'Tag','ithshow'),'String'));             
              showdlg=0;
              if th>89 | th<0
                  set(findobj(gcf,'Tag','thshow'),'String','0');
                  set(findobj(gcf,'Tag','thslider'),'Value',0);
                  showdlg=1;
              end    
              if ith>89 | ith<-89
                   set(findobj(gcf,'Tag','ithshow'),'String','0');
                    set(findobj(gcf,'Tag','ithslider'),'Value',0);
                   showdlg=1;
              end      
              set(findobj(gcf,'Tag','thslider'),'Max',89);
              set(findobj(gcf,'Tag','ithslider'),'Max',89);
              set(findobj(gcf,'Tag','ithslider'),'Min',-89);
              
              if showdlg==1
                  errordlg('Theta angle can be between 0 and 89 degrees and Theta Incidence agnle between -89 and 89 degrees for ground plane use.','Angle Status', 'error');
              end
          else
              ith=str2num(get(findobj(gcf,'Tag','ithshow'),'String'));             
              if ith<0
                   set(findobj(gcf,'Tag','ithshow'),'String','0');
                   set(findobj(gcf,'Tag','ithslider'),'Value',0);
              end
                         
              set(findobj(gcf,'Tag','thslider'),'Max',360);
              set(findobj(gcf,'Tag','ithslider'),'Max',360);
              set(findobj(gcf,'Tag','ithslider'),'Min',0);
              set(findobj(gcf,'Tag','checkpec'),'Enable','off');
              set(findobj(gcf,'Tag','relativeperm'),'Enable','off');
              set(findobj(gcf,'Tag','relpermtext'),'Enable','off');
          end
     
     case 'PEC'    
          pec=get(findobj(gcf,'Tag','checkpec'),'Value');
          if pec==0
              set(findobj(gcf,'Tag','relativeperm'),'Enable','on');
              set(findobj(gcf,'Tag','relpermtext'),'Enable','on');
          else
              set(findobj(gcf,'Tag','relativeperm'),'Enable','off');
              set(findobj(gcf,'Tag','relpermtext'),'Enable','off');
          end

  case 'Corr'
      h_corr = findobj(gcf,'Tag','Corr');
      corr_str = get(h_corr,'String');
      corr = getCorr(corr_str,C);
      set(h_corr,'String',num2str(corr));
  
   case 'Std'
      h_Std = findobj(gcf,'Tag','Std');
      std_str = get(h_Std,'String');
      std = getStd(std_str,C);
      set(h_Std,'String',num2str(std));
   
	case 'LoadFile'    
      design('OpenFile',gcbo,[],guidata(gcbo));     
      uiwait;
      txt=['Calculation of RCS for the ',modelname,' model'];
      set(findobj(gcf,'Tag','figtitle'),'String',txt);    
      set(findobj(gcf,'Tag','Calculate'),'Enable','on');    
      set(findobj(gcf,'Tag','groundplane'),'Enable','on');
          
   case 'Calculate'
      CalcFreq;
                
   case 'Close' 
      close(gcf);
      
   case 'Print'
      h_figs = get(0,'children');
		for fig = h_figs'
			if strcmp(get(fig,'Tag'),'mfreq')  
               figure(fig);  
               print;
               break;
         end
      end                   
      
      
 end % switch
   
   
% validates starting frequency
function o_fstart = getFStart(start)    
  fig=gcf;
  temp1 = str2num(start);
   temp2 = str2num(get(findobj(gcf,'Tag','FStop'),'String'));
  if (isempty(temp1)) | (temp1 < 0.1) | (temp1 > 30)
     errordlg('Enter a Starting Frequency between 0.1 and 30 GHz.','Frequency Status', 'error');
     temp = 0.1; %default start value 
  elseif temp1 == temp2 % fstop  = fstart
		set(findobj(gcf,'Tag','Delf'),'String',num2str(1));
        msgbox('For same start and end frequencies, step is set to 1 GHz.','Same Frequencies','help');
  elseif temp2 < temp1      %  stop less than start angle
     errordlg('Starting frequency is greater than ending frequency!','Frequency Status','error'); 
     temp1 = 0.1; % default start 
  elseif (start == 'i' | start == 'j')
      errordlg('Enter a Starting Frequency between 0.1 and 30 GHz.','Frequency Status', 'error');
      temp1 = 0.1; % default start value
  end 
  
  
  o_fstart = temp1;
  % end getFStart  
  
% validates ending frequency
function o_fstop = getFStop(stop)   
  fig=gcf;
  temp1 = str2num(stop);
  temp2 = str2num(get(findobj(gcf,'Tag','FStart'),'String'));
       
  if (isempty(temp1)) | (temp1 < 0.1) | (temp1 > 30)
     errordlg('Enter a Ending Frequency between 0.1 and 30 GHz.','Frequency Status', 'error');
     temp1 = 30; % default stop freq
  elseif temp1 == temp2 % fstop  = fstart
		set(findobj(gcf,'Tag','Delf'),'String',num2str(1));
        msgbox('For same start and end frequencies, step is set to 1 GHz.','Same Frequencies','help');
  elseif temp2 > temp1      %  stop less than start angle
     errordlg('Starting frequency is greater than ending frequency!','Frequency Status','error'); 
     temp1 = 30; % default stop 
  elseif (stop == 'i' | stop == 'j')
      errordlg('Enter a Ending Frequency between 0.1 and 30 GHz.','Frequency Status', 'error');
     temp1 = 30; % default stop freq
 end 

  
  o_fstop = temp1;
  % end getFStop  
 
  
% validates frequency step
function o_delf = getDelf(inc)    
   temp3 = str2num(inc);
   temp1 = str2num(get(findobj(gcf,'Tag','FStart'),'String'));
   temp2 = str2num(get(findobj(gcf,'Tag','FStop'),'String'));
   del = temp2 - temp1;
   
   if temp1 == temp2 % fstart = fstop
      if temp3 ~= 1
         msgbox('For same start and end frequencies, step is set to 1 GHz.','Same Frequencies','help');
         del = 1;  % default value for same frequencies
      end
   elseif isempty(temp3) | (temp3 <= 0) | (temp3 > del)
      errordlg('Enter a step value less than the diference between starting and ending frequencies.', ...
         		'Frequency Status', 'error');     
      del = 0.1;  % default step
   elseif (inc == 'i' | inc == 'j')
      errordlg('Enter a step value less than the diference between starting and ending frequencies.', ...
         		'Frequency Status', 'error');   
      del = 0.1; % default step
   else         
      del = temp3;
   end % if
   o_delf = del;
  % end getDelf  
  


% validates Length of Taylor Series
function o_Lt = getLRegion(str)    
  
  	temp = str2num(str);
   if (isempty(temp)) | (temp <= 0) | (temp > 1)
      errordlg('Enter length of region between 0 and 1.', ...
         		'Taylor Series Region', 'error');
     temp = 1e-5; % default length of Taylor series region
   end 
   o_Lt = temp;
% end getLRegion  
   
% validates Number of Terms in Taylor Series    
function o_Nt = getNTerms(str)   
  
   temp = str2num(str);
   if (isempty(temp)) | (floor(temp) <= 0)      
      errordlg('Enter a positive integer for the number of terms in the Taylor series.',...
         		'Taylor Series Terms', 'error');
      temp = 5; % default number of terms in Taylor series 
   elseif  floor(temp) > 10
      msgbox('Monostatic RCS computation for number of terms greater than 10 may take some time.',...
         	 'Taylor Series Terms','help');
      temp = floor(temp);
   end 
   o_Nt = temp;
% end getNTerms  
 
     
% validates correlation entered
function o_Corr = getCorr(str,C)     
	freq = str2num(get(findobj(gcf,'Tag','Freq'),'String'));
   wave   = C/(freq * 10^9);
   
  	temp = str2num(str);
     
   if (isempty(temp)) | (temp < 0)   
   	temp = 0;	% default value for smooth surface
      errordlg('Enter a correlation distance from 0 to any positive value.', ...
         		'Correlation Distance Status', 'error');     
  	elseif (str == 'i' | str == 'j')
      errordlg('Enter a correlation distance from 0 to any positive value.', ...
           		  'Correlation Distance Status', 'error');
      temp = 0; % default value for smooth surface
  	elseif temp >= wave
        warndlg('Suggest that this value be smaller than the wavelength.', ...
           		 'Correlation Distance Status','warn');
      temp = temp;
  	end 
  	o_Corr = temp;
  	% end getCorr  
  
% validates standard deviation entered
function o_Std = getStd(str,C)     
	freq = str2num(get(findobj(gcf,'Tag','Freq'),'String')); 
   wave   = C/(freq * 10^9);

  	temp = str2num(str);
     
   if (isempty(temp)) | (temp < 0) 
      errordlg('Enter a standard deviation from 0 to any positive value.', ...
           		  'Standard Deviation Status', 'error');   
     	temp = 0; % default std. dev.
  	elseif (str == 'i' | str == 'j')
      errordlg('Enter a standard deviation from 0 to any positive value.', ...
           		  'Standard Deviation Status', 'error');    
     	temp = 0; % default std. dev.
  	elseif temp > (0.1*wave)
      warndlg('Value entered is valid but extremely high.', ...
           		 'Standard Deviation Status','warn');
      temp = temp;
  	end 
  	o_Std = temp;
   % end getStd
   
   
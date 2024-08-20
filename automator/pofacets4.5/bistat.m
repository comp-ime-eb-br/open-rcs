function bistat(action)
% filename: bistat.m
% Project: POFACETS
% Description: This program implements the functionalities of the Calculate
%			Bistatic RCS GUI
% Author:  Prof. David C. Jenn and Elmo E. Garrido Jr.
% Date:   31 August 2000 (update 6/15 some popups removed and defaults changed)
% Place: NPS
% Last modifed: Feb 04 (v.3.0)
% !!!!!!! scale factor in 116/117 added !!!!!!!!!!!!!!!!!!

global C
global coord nvert modelname symplanes
global ntria facet scale changed

C = 3*10^8;	% speed of light in m/sec

switch(action)
   
   case 'iTheta'   
      h_itheta = findobj(gcf,'Tag','iTheta'); 
      itheta_str = get(h_itheta,'String'); 
      itheta = getiAngle(itheta_str,1); 
      set(h_itheta,'String',num2str(itheta));

   case 'iPhi'
      h_iphi = findobj(gcf,'Tag','iPhi'); 
      iphi_str = get(h_iphi,'String'); 
      iphi = getiAngle(iphi_str,2); 
      set(h_iphi,'String',num2str(iphi));

   case 'TStart'
      h_tstart = findobj(gcf,'Tag','TStart'); 
      tstart_str = get(h_tstart,'String'); 
      tstart = getTStart(tstart_str); 
      set(h_tstart,'String',num2str(tstart));
      
   case 'TStop'
      h_tstop = findobj(gcf,'Tag','TStop'); 
      tstop_str = get(h_tstop,'String'); 
      tstop = getTStop(tstop_str); 
      set(h_tstop,'String',num2str(tstop));

   case 'Delt'
      h_delt = findobj(gcf,'Tag','Delt');
      delt_str = get(h_delt,'String'); 
      delt = getDelt(delt_str);
      set(h_delt,'String',num2str(delt));     
           
   case 'PStart'
      h_pstart = findobj(gcf,'Tag','PStart'); 
      pstart_str = get(h_pstart,'String'); 
      pstart = getPStart(pstart_str); 
      set(h_pstart,'String',num2str(pstart));

   case 'PStop'
      h_pstop = findobj(gcf,'Tag','PStop'); 
      pstop_str = get(h_pstop,'String'); 
      pstop = getPStop(pstop_str); 
      set(h_pstop,'String',num2str(pstop));

   case 'Delp'
      h_delp = findobj(gcf,'Tag','Delp');
      delp_str = get(h_delp,'String'); 
      delp = getDelp(delp_str);
      set(h_delp,'String',num2str(delp));     

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
       
   case 'Freq'
      h_freq = findobj(gcf,'Tag','Freq');
      freq_str = get(h_freq,'String'); 
      freq = getFreq(freq_str);
      set(h_freq,'String',num2str(freq));     
      
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
      txt=['Calculation of Bistatic RCS for the ',modelname,' model'];
      set(findobj(gcf,'Tag','figtitle'),'String',txt);    
      set(findobj(gcf,'Tag','Calculate'),'Enable','on');     
      set(findobj(gcf,'Tag','groundplane'),'Enable','on');    
      coord=coord*scale;  % rescale according to scale
      scale=1;    % reset scale factor to 1 now that coordinates are changed
    case 'ground'    
          gp=get(findobj(gcf,'Tag','groundplane'),'Value');
          if gp==1
              set(findobj(gcf,'Tag','checkpec'),'Enable','on');
               %make sure that theta goes from 0 to 90 deg only
              th0=str2num(get(findobj(gcf,'Tag','TStart'),'String'));
              th1=str2num(get(findobj(gcf,'Tag','TStop'),'String'));
              th2=str2num(get(findobj(gcf,'Tag','iTheta'),'String'));
              showdlg=0;
              if th0>89
                  set(findobj(gcf,'Tag','TStart'),'String','0');
                  set(findobj(gcf,'Tag','TStop'),'String','89');
                  showdlg=1;
              end    
              if th1>89
                   set(findobj(gcf,'Tag','TStop'),'String','89');
                   showdlg=1;
              end      
              if (th2>89) | (th2<-89) 
                   set(findobj(gcf,'Tag','iTheta'),'String','0');
                   showdlg=1;
              end 
              if showdlg==1
                  errordlg('Theta angle can be between 0 and 89 degrees and Theta Incidence agnle between -89 and 89 degrees for ground plane use.','Angle Status', 'error');
              end
          else
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

      
   case 'Calculate'
       CalcBistat;    
      
          
   case 'Close'       
       close(gcf);
                
                  
   case 'Print'
      h_figs = get(0,'children');
		for fig = h_figs'
         if strcmp(get(fig,'Tag'),'bistatic')
            figure(fig);  
            print;
            break;
         end
      end   
      
end % switch


% validates theta and phi incident angle entered
function o_iang = getiAngle(ang_str,angletype)
   fig=gcf;
   temp = str2num(ang_str);
   if (isempty(temp)) | (temp < -360) | (temp > 360)
      errordlg('Enter an incident angle between -360 and +360 degrees.', ...
         		'Incident Angle Status', 'error');
      temp = 45; % default incident angle
   elseif (ang_str == 'i' | ang_str == 'j')
      errordlg('Enter an incident angle between -360 and +360 degrees.', ...
         		'Incident Angle Status', 'error');
      temp = 45; % default incident angle
   end 
 if angletype==1
  grpl=get(findobj(fig,'Tag','groundplane'),'Enable');
  switch grpl
      case 'on'
        gp=get(findobj(fig,'Tag','groundplane'),'Value');
        if (gp==1) & ((temp>89) | (temp<-89)) 
          errordlg('Theta Incidence angle can be between -89 and 89 degrees for ground plane use.','Angle Status', 'error');
          temp=0; %default agnle
        end
  end
end
 
  o_iang = temp;
% end getiAngle  
      
% validates theta starting angle
function o_tstart = getTStart(start)    
  fig=gcf;
  temp1 = str2num(start);
  temp2 = str2num(get(findobj(gcf,'Tag','TStop'),'String'));
  if (isempty(temp1)) | (temp1 < -360) | (temp1 > 360)
     errordlg('Enter a Theta Starting angle between -360 and 360 degrees.','Angle Status', 'error');
     temp = 0; % default theta start angle
  elseif temp1 == temp2 % tstop angle = tstart angle
		set(findobj(gcf,'Tag','Delt'),'String',num2str(1));
    %  msgbox('For a theta-cut, increment is set to 1 degree.','Theta-Cut Set','help');
  elseif temp2 < temp1      % theta stop less than theta start angle
     errordlg('Theta starting angle is greater than ending angle!','Angle Status','error'); 
     temp1 = 0; % default theta start angle   
    
 elseif (start == 'i' | start == 'j')
     errordlg('Enter a Theta Starting angle between -360 and 360 degrees.','Angle Status', 'error');
     temp1 = 0; % default theta start angle
  end 
  
  grpl=get(findobj(fig,'Tag','groundplane'),'Enable');
  switch grpl
      case 'on'
        gp=get(findobj(fig,'Tag','groundplane'),'Value');
        if (gp==1) & (temp1>89)
          errordlg('Theta angle can be between 0 and 89 degrees for ground plane use.','Angle Status', 'error');
          temp1=0; %default agnle
        end
  end
  
  o_tstart = temp1;
% end getTStart  

% validates theta ending angle
function o_tstop = getTStop(stop)   
  fig=gcf;
  temp1 = str2num(stop);
  temp2 = str2num(get(findobj(gcf,'Tag','TStart'),'String'));
       
  if (isempty(temp1)) | (temp1 < -360) | (temp1 > 360)
     errordlg('Enter a Theta Ending angle between starting angle and 360 degrees.','Angle Status', 'error');
     temp1 = 180; % default theta stop angle
  elseif temp1 == temp2 % tstop angle = tstart angle
		set(findobj(gcf,'Tag','Delt'),'String',num2str(1));
    %  msgbox('For a theta-cut, increment is set to 1 degree.','Theta-Cut Set','help');
  elseif temp2 > temp1      % theta stop less than theta start angle
     errordlg('Theta starting angle is greater than ending angle!','Angle Status','error'); 
     temp1 = 180; % default theta stop angle   
  elseif (stop == 'i' | stop == 'j')
     errordlg('Enter a Theta Ending angle between -360 and 360 degrees.', ...
        		  'Angle Status', 'error');
     temp1 = 180; % default theta ending angle
  end 
  grpl=get(findobj(fig,'Tag','groundplane'),'Enable');
  switch grpl
      case 'on'
      gp=get(findobj(fig,'Tag','groundplane'),'Value');
      if (gp==1) & (temp1>89)
        errordlg('Theta angle can be between 0 and 89 degrees for ground plane use.','Angle Status', 'error');
        temp1=89; %default agnle
      end
  end
  
  
  o_tstop = temp1;
  % end getTStop  
  
% validates theta increment angle
function o_delt = getDelt(inc)    
   temp3 = str2num(inc);
   temp1 = str2num(get(findobj(gcf,'Tag','TStart'),'String'));
   temp2 = str2num(get(findobj(gcf,'Tag','TStop'),'String'));
   del = temp2 - temp1;
   
   if temp1 == temp2 % tstart = tstop
      if temp3 ~= 1
      %   msgbox('For a theta-cut, increment is set to 1 degree.', ...
       %     	 'Theta-Cut Set','help');
         del = 1;  % default value for theta-cut
      end
   elseif isempty(temp3) | (temp3 <= 0) | (temp3 > del)
      errordlg('Enter an increment angle less than the diference between starting and ending angles.', ...
         		'Angle Status', 'error');     
      del = 1;  % default theta increment angle
   elseif (inc == 'i' | inc == 'j')
      errordlg('Enter an increment angle less than the difference between starting and ending angle.', ...
         		'Angle Status', 'error');
      del = 1; % default theta increment angle
   else         
      del = temp3;
   end % if
   o_delt = del;
  % end getDelt  
  
% validates phi starting angle
function o_pstart = getPStart(str) 
  
  temp1 = str2num(str);
  temp2 = str2num(get(findobj(gcf,'Tag','PStop'),'String'));
  if (isempty(temp1)) | (temp1 < -360) | (temp1 > 360)
     errordlg('Enter a Phi Starting angle between -360 and 360 degrees.', ...
        		  'Angle Status', 'error');
     temp1 = 0; % default phi start angle
  elseif temp1 == temp2 % pstop angle = pstart angle 
		set(findobj(gcf,'Tag','Delp'),'String',num2str(1));
    %  msgbox('For a phi-cut, increment is set to 1 degree.', ...
     %    	 'Phi-Cut Set','help');        
  elseif temp2 < temp1   % phi start greater than phi stop angle
     errordlg('Phi ending angle is less than starting angle!', ...
        		  'Angle Status','error'); 
     temp1 = 0; % default phi start angle
  elseif (str == 'i' | str == 'j')
     errordlg('Enter a Phi Starting angle between -360 and 360 degrees.', ...
        		  'Angle Status', 'error');
     temp1 = 0; % default phi start angle
  end 
  o_pstart = temp1;
  % end getPStart  
  
% validates phi ending angle 
function o_pstop = getPStop(stop)  
  
  temp1 = str2num(stop);
  temp2 = str2num(get(findobj(gcf,'Tag','PStart'),'String'));
  
  if (isempty(temp1)) | (temp1 < -360) | (temp1 > 360)
     errordlg('Enter a Phi ending angle between starting angle and 360 degrees.', ...
        		  'Angle Status', 'error');
     temp1 = 180; % default phi stop angle
  elseif temp1 == temp2 % pstop angle = pstart angle 
		set(findobj(gcf,'Tag','Delp'),'String',num2str(1));
    %  msgbox('For a phi-cut, increment is set to 1 degree.', ...
         %	 'Phi-Cut Set','help');        
  elseif temp2 > temp1   % phi start greater than phi stop angle
     errordlg('Phi ending angle is less than starting angle!', ...
        		  'Angle Status','error'); 
     temp1 = 180; % default phi ending angle
  elseif (stop == 'i' | stop == 'j')
     errordlg('Enter a Phi ending angle between -360 and 360 degrees.', ...
        		  'Angle Status', 'error');
     temp1 = 180; % default phi ending angle
  end 
  o_pstop = temp1;
  % end getPStop  
  
  % validates phi increment angle
function o_delp = getDelp(inc)   
  temp3 = str2num(inc);
  temp1 = str2num(get(findobj(gcf,'Tag','PStart'),'String'));
  temp2 = str2num(get(findobj(gcf,'Tag','PStop'),'String'));
  del = temp2 - temp1;
   
  if temp1 == temp2
     if (temp3 ~= 1)
      %  msgbox('For a phi-cut, increment is set to 1 degree.', ...
       %    		'Phi-Cut Set','help');
        del = 1;  % default value for phi-cut
     end
  elseif isempty(temp3) | (temp3 <= 0) | (temp3 > del)
     errordlg('Enter an increment angle less than the diference between starting and ending angles.',...
        		  'Angle Status', 'error');         
     del = 3;  % default phi increment
  elseif (inc == 'i' | inc == 'j')
     errordlg('Enter an increment angle less than the diference between starting and ending angles.', ...
     			  'Angle Status', 'error');     
     del = 1; % default phi increment angle
  else
     del = temp3;
  end % if
  o_delp = del;
  % end getDelp  

   
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
      msgbox('Bistatic RCS computation for number of terms greater than 10 may take some time.',...
         	 'Taylor Series Terms','help');
      temp = floor(temp);
   end 
   o_Nt = temp;
% end getNTerms  
 
% validates frequency entered  
function o_Freq = getFreq(str)    
  
  	temp = str2num(str);
  	if (isempty(temp)) | (temp <= 0)      
        errordlg('Enter a positive frequency in Gigahertz.', ...
           		  'Frequency Status', 'error');
     	temp = 0.3; % default frequency 300 MHz  
  	elseif  temp > 10^5  % 100 THz
        errordlg('Laser radars have not been designed in this frequency range.', ...
           		  'Frequency Status', 'error');
     	temp = 0.3;
  	end 
  	o_Freq = temp;
% end getFreq  
     
% validates correlation entered
function o_Corr = getCorr(str,C)     
	freq = str2num(get(findobj(gcf,'Tag','Freq'),'String'));
   wave   = C/(freq * 10^9);

  	temp = str2num(str);
     
   if (isempty(temp)) | (temp < 0)   
   	temp = 0;	% default value for smooth surfaces
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
      errordlg('Enter a standard deviation from 0 (smooth) to any positive value.', ...
         		'Standard Deviation Status', 'error');   
     	temp = 0; % default std. dev.      
   elseif (str == 'i' | str == 'j')
      errordlg('Enter a standard deviation from 0 (smooth) to any positive value.', ...
           		'Standard Deviation Status', 'error');    
     	temp = 0; % default std. dev.
  	elseif temp > (0.1*wave)  
      warndlg('Value entered is valid but extremely high.', ...
         	  'Standard Deviation Status','warn');
      temp = temp;
  	end 
  	o_Std = temp;
% end getStd
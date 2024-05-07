function set_params_values(method,param_list)
% filename: mono.m
% Project: POFACETS
% Description: This program implements the functionalities of the Calculate
%			Monostatic RCS GUI and computes the monostatic RCs of a selected model.
% Author:  Prof. David C. Jenn, Elmo E. Garrido Jr. and Filippos
% Chatzigeorgiadis
% Date:   14 August 2000 (updated 6/15 warnings eliminated/default values changed)
% Place: NPS
% Last modifed: Feb 04 (v.3.0)
% !!!!!!! scale factor in 124/125 added 
 
global C
global coord nvert modelname symplanes matrl comments
global ntria facet scale changed

C = 3*10^8;	% speed of light in m/sec
if numel(param_list) == 12 && strcmpi(method,'monostatic')
   [input_model, freq_str, corr_str, delstd_str, i_pol_str, rs_str, pstart_str, pstop_str, delp_str, tstart_str, tstop_str, delt_str] = param_list{:};
elseif numel(param_list) == 14 && strcmpi(method,'bistatic')
   [input_model, freq_str, corr_str, delstd_str, i_pol_str, rs_str, pstart_str, pstop_str, delp_str, tstart_str, tstop_str, delt_str,itheta_str,iphi_str] = param_list{:};
   h_itheta = findobj(gcf,'Tag','iTheta'); 
   itheta = getiAngle(itheta_str,1); 
   set(h_itheta,'String',num2str(itheta));

   h_iphi = findobj(gcf,'Tag','iPhi'); 
   iphi = getiAngle(iphi_str,2); 
   set(h_iphi,'String',num2str(iphi));

else
   error('Metódo não coerente com a quantidade de termos passados')
end    
    h_tstart = findobj(gcf,'Tag','TStart'); 
      tstart = getTStart(tstart_str); 
      set(h_tstart,'String',num2str(tstart));
      
      h_tstop = findobj(gcf,'Tag','TStop');
      tstop = getTStop(tstop_str); 
      set(h_tstop,'String',num2str(tstop));

    if delt_str > 0
      h_delt = findobj(gcf,'Tag','Delt');
      delt = getDelt(delt_str);
      set(h_delt,'String',num2str(delt));     
    end 

      h_pstart = findobj(gcf,'Tag','PStart');
      pstart = getPStart(pstart_str);
      set(h_pstart,'String',num2str(pstart));

      h_pstop = findobj(gcf,'Tag','PStop'); 
      pstop = getPStop(pstop_str);
      set(h_pstop,'String',num2str(pstop));
    
    if delp_str > 0 
        h_delp = findobj(gcf,'Tag','Delp');
        delp = getDelp(delp_str);
        set(h_delp,'String',num2str(delp));     
    end

      h_Lt = findobj(gcf,'Tag','LRegion');
      Lt = getLRegion('1e-5');
      set(h_Lt,'String',num2str(Lt));    
      
      h_Nt = findobj(gcf,'Tag','NTerms');
      Nt = getNTerms('5');
      set(h_Nt,'String',num2str(Nt)); 
      
      val = str2num(i_pol_str)+1;
      if val == 1
         Et = 1;
         Ep = 0;
      else
         Et = 0;
         Ep = 1;
      end
      
      h_freq = findobj(gcf,'Tag','Freq');
      freq = getFreq(freq_str);
      set(h_freq,'String',num2str(freq));     

      h_corr = findobj(gcf,'Tag','Corr');
      corr = getCorr(corr_str,C);
      set(h_corr,'String',num2str(corr));

      h_Std = findobj(gcf,'Tag','Std');
      std = getStd(delstd_str,C);
      set(h_Std,'String',num2str(std));
                     
   
% validates theta starting angle
function o_tstart = getTStart(start)    
  fig=gcf;
  temp1 = str2num(start);
  temp2 = str2num(get(findobj(gcf,'Tag','TStop'),'String'));
  if (isempty(temp1)) | (temp1 < -360) | (temp1 > 360)
     errordlg('Enter a Theta Starting angle between -360 and 360 degrees.','Angle Status', 'error');
     temp = 0; % default theta start angle
  elseif temp1 == temp2 % tstop angle = tstart angle   ANNOYING WARNING REMOVED
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
          temp1=0; %default angle
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
  elseif temp1 == temp2 % tstop angle = tstart angle  ANNOYING WARNING REMOVED
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
         %msgbox('For a theta-cut, increment is set to 1 degree.', ...
            	 %'Theta-Cut Set','help');
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
     %    	 'Phi-Cut Set','help');        
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
       % msgbox('For a phi-cut, increment is set to 1 degree.', ...
           		%'Phi-Cut Set','help');
        del = 1;  % default value for phi-cut
     end
  elseif isempty(temp3) | (temp3 <= 0) | (temp3 > del)
     errordlg('Enter an increment angle less than the diference between starting and ending angles.',...
        		  'Angle Status', 'error');         
     del = 1;  % default phi increment
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
      msgbox('Monostatic RCS computation for number of terms greater than 10 may take some time.',...
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
     	temp = 0.3; % default frequency used 
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
   
   
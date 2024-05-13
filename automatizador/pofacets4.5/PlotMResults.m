% read MResults file from POFACETS
clear
fname='TentResults.m';
V=importdata(fname);  %,'theta','phi','freq','Sth','Sph','Reth','Ieth','Reph','Ieph','-ASCII')
Th=V(1,:)+90;
Ph=V(2,:);
RCSthdb=V(4,:);
RCSphdb=V(5,:);
plt=1;
if Th==Th(1); plt=0; disp(['theta cut, theta= ',num2str(Th(1))]); end  
if Ph==Ph(1); plt=1; disp(['phi cut, phi= ',num2str(Ph(1))]); end 
figure(1)
if plt==0  % phi cut 
    plot(Ph,RCSthdb,Ph,RCSphdb)
    xlabel('\phi, Deg')
    ylabel('RCS, dBsm')
    %legend('\sigma_\theta','\sigma_\phi')
    title(['\theta = ',num2str(Th(1)),'^o'])
    axis([0,180,0,50])
    grid on
end
if plt==1  % theta cut
    plot(Th,RCSthdb,Th,RCSphdb)
    xlabel('\theta, Deg')
    ylabel('RCS, dBsm')
    %legend('\sigma_\theta','\sigma_\phi')
    title(['\phi = ',num2str(Ph(1)),'^o'])
    axis([0,180,0,50])
    grid on
end
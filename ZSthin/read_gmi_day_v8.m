function [time,sst,wspdLF,wspdMF,vapor,cloud,rain]=read_gmi_day_v8(data_file)
% [time,sst,wspdLF,wspdMF,vapor,cloud,rain]=read_gmi_day_v8(data_file);
%
% this subroutine reads compressed or uncompressed RSS GMI daily byte maps
% (version-8.1)
%
% input arguments:
% data_file = the full path and name of the uncompressed data file
%
% the function returns these products:
%   [mingmt,sst,wspdLF,wspdMF,vapor,cloud,rain,wspdAW,wdir]
%   mingmt is gmt time in hours
%   sst  is surface water temperature at depth of about 1 mm in deg C
%   wspdLF is 10 meter surface wind in m/s made using 10.7 GHz channel and above, low frequency channels
%   wspdMF is 10 meter surface wind in m/s made using 18.7 GHz channel and above, medium frequency channels
%   vapor is atmospheric water vapor in millimeters
%   cloud is liquid cloud water in millimeters
%   rain  is rain rate in millimeters/hour
%   wspdAW is 10 meter surface wind for all weather conditions made using 3 algorithms
%   wdir is wind direction oceanographic convention, blowing North = 0 in degrees
%
%  The center of the first cell of the 1440 column and 720 row map is at 0.125 E longitude and -89.875 latitude.
%  The center of the second cell is 0.375 E longitude, -89.875 latitude.
% 		XLAT=0.25*ILAT-90.125
%		XLON=0.25*ILON-0.125
%
% For detailed data description, see 
% http://www.remss.com/amsr/amsr_data_description.html
%
% Remote Sensing Systems
% support@remss.com

xscale=[.1, 0.15,0.2,0.2,0.3, 0.01,0.1];
offset=[0.,-3.0 ,0.0,0.0,0.0,-0.05,0.0];
xdim=1440;ydim=720;tdim=2;numvar=7;
mapsiz=xdim*ydim*tdim;

if ~exist(data_file,'file')
   disp(['file not found: ' data_file]);
   time=[];sst=[];wspdLF=[];wspdMF=[];vapor=[];cloud=[];rain=[];
   return;
end;

if ~isempty(regexp(data_file,'.gz', 'once'))
    data_file=char(gunzip(data_file));
end

fid=fopen(data_file,'rb');
data=fread(fid,mapsiz*numvar,'uint8');
fclose(fid);
disp(data_file);
map=reshape(data,[xdim ydim numvar tdim]);

for i=1:numvar
    tmp=map(:,:,i,:);
    ia=find(tmp<=250);tmp(ia)=tmp(ia)*xscale(i)+offset(i);
    map(:,:,i,:)=tmp;
end;

time=squeeze(map(:,:,1,:));
sst=squeeze(map(:,:,2,:));
wspdLF=squeeze(map(:,:,3,:));
wspdMF=squeeze(map(:,:,4,:));
vapor=squeeze(map(:,:,5,:));
cloud=squeeze(map(:,:,6,:));
rain=squeeze(map(:,:,7,:));

return;
end

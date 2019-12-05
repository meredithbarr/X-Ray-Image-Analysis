%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meredith Barr
% Nov 12 2019
%
% This FUNCTION indexes the output data files from RadSeg_HPC.m for a given
% set of scan numbers.
%
% Inputs: scans (array of scan numbers to index)
% Outputs: data (struct containing data formatted for plotting by 'overlay'
% set of functions)
%
% Dependencies: (1) smooth_diff.m by Jianwen Luo, available at:
% https://uk.mathworks.com/matlabcentral/fileexchange/6170-smooth-differentiation
% (2) output of RadSeg_laptop.m: "scan.mat"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[data]=index_rad_data(scans)
%index input vars to arrays by scan number
for scan=scans
    %load input vars
    filename=sprintf('%i.mat',scan);
    IV=load(filename);
    %modify input vars
    IVm.scan=scan;
    IVm.t=IV.t-IV.timeheat(1)/60; %slice time stamps in mins
    IVm.CSA=smoothdata(IV.solidcomp*100/IV.solidcomp(1)-100,'movmean',round(length(IVm.t)/20)); % percent change in bed CSA
    IVm.vol=smoothdata(IV.solidcomp_3d*100/IV.solidcomp_3d(1)-100,'movmean',round(length(IVm.t)/20)); % percent change in estimated bed volume
    IVm.APV=smoothdata(IV.APVn*100/IV.APVn(1)-100,'movmean',round(length(IVm.t)/20)); % percent change in bed APV
    IVm.dCSA=filter(-smooth_diff(round(length(IVm.t)/15)),1,IVm.CSA)/(IVm.t(2)-IVm.t(1)); % rate of bed CSA change (%/min)
    IVm.dvol=filter(-smooth_diff(round(length(IVm.t)/15)),1,IVm.vol)/(IVm.t(2)-IVm.t(1)); % rate of estimated bed volume change (%/min)
    IVm.dAPV=filter(-smooth_diff(round(length(IVm.t)/15)),1,IVm.APV)/(IVm.t(2)-IVm.t(1)); % rate of bed APV change (%/min)
    IVm.temptime=transpose(cat(1,(IV.timeheat-IV.timeheat(1))/60,...
        (IV.timecool-IV.timeheat(1))/60)); %time array for temp array in mins
    IVm.temp=transpose(cat(1,IV.tempheat,IV.tempcool)); %temperature in C
    %find start of hold at peak temp
    IVm.peaktemp=round(max(IVm.temp),2,'significant');
    atpeak=IVm.temp>=IVm.peaktemp;
    %initialize loop counter and return value
    loop=0;
    holdstart=0;
    for i=1:length(atpeak)
        loop=loop+1;
        if atpeak(i)==1 && holdstart==0
            holdstart=loop;
        end
    end
    IVm.hold=[IVm.temptime(holdstart),(IV.timeheat(end)-IV.timeheat(1))/60];
    %append modified vars to data structure
    if scan==scans(1)
        data=IVm;
    else
        data(end+1)=IVm;
    end
    %clear generic vars
    clearvars IV IVm filename atpeak holdstart
end
end
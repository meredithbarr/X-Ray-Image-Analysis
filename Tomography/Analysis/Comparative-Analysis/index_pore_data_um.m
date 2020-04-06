%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meredith Barr
% Nov 13 2019
%
% This FUNCTION indexes the output data files from RadSeg_laptop.m for a
% given set of scan numbers.
%
% Inputs: scans (array of scan numbers to index)
% Outputs: data (struct containing data formatted for plotting by 'overlay'
% set of functions)
% Dependencies: pore_data_um_scan.mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[data]=index_pore_data_um(scans)
%index input vars to arrays by scan number
for scan=scans
    %load input vars
    filename=sprintf('pore_data_um_%i.mat',scan);
    IV=load(filename);
    %modify input vars
    IVm.scan=scan;
    IVm.distance=IV.pores_dist;
    IVm.volume=IV.pores_volume;
    %append modified vars to data structure
    if scan==scans(1)
        data=IVm;
    else
        data(end+1)=IVm;
    end
    %clear generic vars
    clearvars IV IVm filename
end
end

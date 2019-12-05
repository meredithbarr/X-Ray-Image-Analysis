%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meredith Barr
% Oct 15 2019
% 
% This is a SCRIPT that calls the FUNCTION pd3d.m to analyze the 
% distribution of pores within particles or beds from segmented tomograms.
%
% Inputs: scans, slice_range
%
% Outputs: no vars, files: pore_data_um_scan.mat (pores_dist, pores_volume),
% pore_data_pix_scan_region.mat (cc, pores_props, edges_x, edges_y,
% edges_z)
%
% Dependencies: input_params_scan.mat, pore mask slices, solid mask slices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clearvars

%% Manual data entry
%Input scans to analyse
scans=[];

%Input standard region length
srl=1231-1; %1231 pixels = 2 mm

%Input slice ranges
slice_range(scans(1),:)=[];
slice_range(scans(2),:)=[];
slice_range(scans(3),:)=[];
slice_range(scans(4),:)=[];
slice_range(scans(5),:)=[];
%etc

%% Run function on all scans
%set up parallel processing
myCluster = parcluster('local');
myCluster.NumWorkers = 48; %set NumWorkers property for local profile
saveProfile(myCluster); %save updated local profile
pool = parpool('local',48);
pool.IdleTimeout=Inf; %set IdleTimeout to infinity 

%run the function for each scan
for s=scans
    pd3d(s,slice_range(s,:));
end

%close parallel processing
delete(gcp('nocreate'));

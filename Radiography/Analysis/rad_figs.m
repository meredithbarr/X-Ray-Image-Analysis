%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meredith Barr
% Nov 12 2019
%
% This SCRIPT plots radiograph data figures using the 'overlay' set of
% functions, which call the 'plot' set of functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Section 1: import and index data
clearvars

%set scan numbers
scans=[119272,119282,119284,119286,119288,119290,119293,119295,119297];

data=index_rad_data(scans);

%% make figures
CSAoverlay(data);
voloverlay(data);
APVoverlay(data);
dCSAoverlay(data);
dvoloverlay(data);
dAPVoverlay(data);

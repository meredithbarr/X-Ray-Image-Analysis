%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meredith Barr
% Nov 13 2019
%
% This SCRIPT plots pore distribution figures by calling the 'overlay' set
% of functions which call the 'plot' set of functions.
%
% Dependencies: index_pore_data_um.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Section 1: import and index data
clearvars

%set scan numbers
scans=[119308,119313,119314,119316,119318,119320,119322,119324,119326,...
    119328,119330,119331,119332,119333,119334,119335,119336,119337,...
    119338,119339];

data=index_pore_data_um(scans);

%% make figures
data=pore_totvol_dist_overlay(data);
pore_conc_bar_overlay(data);
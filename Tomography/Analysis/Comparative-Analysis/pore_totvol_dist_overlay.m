%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meredith Barr
% Nov 12 2019
%
% This 'overlay' FUNCTION calls the 'plot' set of functions to overlay
% plots of pore distribution data. It is called by tomo_figs.m
%
% Inputs: data (struct output by 'plot' set of functions)
% Outputs: figure and image files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[data]=pore_totvol_dist_overlay(data)
% Treatment comarison plots
% Raw Almond Shells
data=pore_totvol_dist_plot(data,'Raw almond shells',[119322,119336,119334],...
    {'Untreated'...
    'Water-soaked','NaOH-soaked'},...
    'Pre-treatment');
% Raw Walnut Shells
data=pore_totvol_dist_plot(data,'Raw walnut shells',[119324,119337,119335],...
    {'Untreated'...
    'Water-soaked','NaOH-soaked'},...
    'Pre-treatment');
% Almond shell Chars
data=pore_totvol_dist_plot(data,'Almond shell chars',[119316,119333,119331],...
    {'Untreated'...
    'Water-soaked','NaOH-soaked'},...
    'Pre-treatment');
% Walnut Shell Chars
data=pore_totvol_dist_plot(data,'Walnut shell chars',[119314,119332,119330],...
    {'Untreated'...
    'Water-soaked','NaOH-soaked'},...
    'Pre-treatment');

% Treatment comarison plots
% Almond Shells
data=pore_totvol_dist_plot(data,'Treated almond shells',[119336,119333,119334,119331],...
    {'Water-soaked - raw','Water-soaked - pyrolysed',...
    'NaOH-soaked - raw','NaOH-soaked - pyrolysed'},...
    'Treatment');
% Walnut Shells
data=pore_totvol_dist_plot(data,'Treated walnut shells',[119337,119332,119335,119330],...
    {'Water-soaked - raw','Water-soaked - pyrolysed',...
    'NaOH-soaked - raw','NaOH-soaked - pyrolysed'},...
    'Treatment');

% Feedstock comparison plots
% Untreated
data=pore_totvol_dist_plot(data,'Untreated',[119322,119324,119316,119314],...
    {'Raw almond shells','Raw walnut shells'...
    'Almond shell chars','Walnut shell chars'},...
    'Material');
% Water-soaked
data=pore_totvol_dist_plot(data,'Water-soaked',[119336,119337,119333,119332],...
    {'Raw almond shells','Raw walnut shells'...
    'Almond shell chars','Walnut shell chars'},...
    'Material');
% NaOH-soaked
data=pore_totvol_dist_plot(data,'NaOH-soaked',[119334,119335,119331,119330],...
    {'Raw almond shells','Raw walnut shells'...
    'Almond shell chars','Walnut shell chars'},...
    'Material');

% Temp comparison plots
% Almond Shells
data=pore_totvol_dist_plot(data,'Untreated almond shells',[119322,119318,119326,119316],...
    {'Raw','250\circC',...
    '350\circC','450\circC'},...
    'Peak pyrolysis temperature');
% Walnut Shells
data=pore_totvol_dist_plot(data,'Untreated walnut shells',[119324,119320,119328,119314],...
    {'Raw','250\circC',...
    '350\circC','450\circC'},...
    'Peak pyrolysis temperature');
end

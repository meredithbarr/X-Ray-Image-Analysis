%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meredith Barr
% Nov 12 2019
%
% This 'overlay' FUNCTION calls the 'plot' set of functions to overlay
% plots of radiograph data. It is called by rad_figs.m
%
% Inputs: data (struct output by 'plot' set of functions)
% Outputs: figure and image files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[]=APVoverlay(data)
% Treatment comarison plots
APVplot(data,'Treated Nut Shells',[119297,119293,119295,119282],...
    {'Water-soaked Almond Shells','NaOH-soaked Almond Shells'...
    'Water-soaked Walnut Shells','NaOH-soaked Walnut Shells'},...
    'Feedstock & Pre-treatment');

% Temp comparison plots
APVplot(data,'Untreated Nut Shells',[119284,119286,119290,119288],...
    {'Almond Shells - 250\circC','Almond Shells - 350\circC',...
    'Walnut Shells - 250\circC','Walnut Shells - 350\circC'},...
    'Feedstock & Peak Temperature');
end

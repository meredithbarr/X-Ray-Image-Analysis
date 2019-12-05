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
function[]=pore_conc_bar_overlay(data)
%%  plots
%%% Pre-treatment comparison plot
pore_conc_bar(data,'Pretreatment','Feedstock pre-treatment',...
    [119322,119336,119334,119316,119333,119331,119324,119337,119335,119314,119332,119330],...
    {'Untreated','Water-soaked','NaOH-soaked'},...
    {'Raw almond shells','Almond shell chars'...
    'Raw walnut shells','Walnut shell chars'},...
    '',[0.7,0.87,0.54;... %light green
    0.2, 0.63, 0.17;... %green
    0.65, 0.81, 0.9;... %light blue
    0.12, 0.47, 0.71],0); %blue

%%% Temp comparison plot
pore_conc_bar(data,'Temperature','Peak pyrolysis temperature',...
    [119322,119318,119326,119316,119324,119320,119328,119314],...
    {'Raw','250 \circC','350 \circC','450 \circC'},...
    {'Untreated almond shells','Untreated walnut shells'},...
    '',[0.2, 0.63, 0.17;... %green
    0.12, 0.47, 0.71],1); %blue);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meredith Barr
% Nov 13 2019
%
% This 'plot' FUNCTION plots pore distribution data according to inputs.
% It is called by the 'overlay' set of functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[data]=pore_totvol_dist_plot(data,figtitle,incscans,leglabels,legtitle)
figure;
%set line colors
color=[0.12, 0.47, 0.71;... %blue
    0.2, 0.63, 0.17;... %green
    1, 0.5, 0;... %orange
    0.89, 0.1, 0.11;... %red
    0.42, 0.24, 0.6]; %purple

%retrieve indices of input scans in data struct
%initialize loop counter
loop=0;
for scan=incscans
    loop=loop+1;
    for i=1:length(data)
        if data(i).scan==scan
            index(loop)=i;
        end
    end
end

%clean up
clearvars loop scan

% process data into plottable format
% iterate through scans
for i=index
    %remove outlier pores
    %create positions array of pore volumes to include (exclude pores greater than 1 std dev above the mean pore volume)
    %this is to exclude any large connected networks of pores, for which centroid distance to a surface would not be meaningful
    positions_include=data(i).volume<=(mean(data(i).volume+std(data(i).volume)));
    
    %find the total pore volume in each bin

    %iterate through bins

    %set number of bins and max distance (set to maximum particle size: 2 mm)
    binmax=2000; %um
    bins=200;
    %initialize loop vars
    limit_low=0;
    pvi=zeros(bins,1);
    dist=zeros(bins,1);
    totvol=zeros(bins,1);
    maximum=zeros(bins,1);
    med=zeros(bins,1);
    data(i).bins_label=zeros(bins,1);

    for b=1:bins
        %set bin limits
        limit_high=limit_low+binmax/bins;
        %find pores in bin
        positions_low=data(i).distance>=limit_low;
        positions_high=data(i).distance<limit_high;
        % sum volume in bin (y values)
        pvi(b)=sum(data(i).volume.*positions_include.*positions_low.*positions_high);
        
        % x values for area plots
        dist(b)=mean(limit_low,limit_high);
        % bin labels for bar plots
        data(i).bins_label(b)=compose("%0.0f-%0.0f",[limit_low,limit_high]);
        % iterate the lower limit
        limit_low=limit_high;
    end    
    
    %index results to data struct
    data(i).x=dist;
    %normalise and smooth data
    data(i).y=smoothdata(pvi.*100./sum(pvi),'loess',50);
    
    %find plot local maximum
    [peaks,locs]=findpeaks(data(i).y);
    maxplotmax=1; %MANUAL ENTRY NECESSARY: enter maximum "plotmax" from data struct after running all scans, then rerun
    data(i).plotmax=(max(peaks)-100/bins)/maxplotmax; 
    %-100/bins makes this deviation from equal distribution, /maxplotmax normalises by
    %the maximum local max, considering all scans
end
    
%plot data
%initialize loop counter
loop=0;
for i=index
    loop=loop+1;
    ar=plot(data(i).x,data(i).y,'Color',color(loop,:));
    hold on;
end

%axis limits and labels
title(figtitle);
ylabel({'Percentage of total pore volume in 10 \mum band (%)'});
xlabel('Distance from particle surface (\mum)');
axis tight
ax=axis;
ax(3)=0;
ax(4)=100/bins*2; %set so that central line of plot indicates equal distribution
axis(ax);

%add horizontal line at equal distribution value
yline(100/bins,'LineStyle','--');

%check if legend is specified
if length(leglabels)>1
    %make legend
    lgd=legend(leglabels);
    lgd.Location='southeast';
    lgd.Box='off';
    lgd.Title.String = legtitle;
end

%save figure
figname=sprintf('%s_pore_totvol_dist',figtitle);
savefig(figname);
saveas(gcf,figname,'epsc');
saveas(gcf,figname,'svg');

hold off
end

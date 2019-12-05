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
%greyscale palette
% color=[.8,.8,.8;...
%     .6,.6,.6;...
%     .4,.4,.4;...
%     .2,.2,.2];

%colorful palette
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

% process data into plotable format
% iterate through scans
for i=index
    %remove outlier pores
    %create positions array of pore volumes to include (get rid of pores
    %>100000 um3)
    %positions_include=data(i).volume<=200000;
    positions_include=data(i).volume<=(mean(data(i).volume+std(data(i).volume)));
    
    %find the total pore volume in each bin

    %iterate through bins

    %set number of bins and max distance (set to max distance measured, 
    % but could instead be set to 2000 um because greater distances
    % must be due to a cropping error (cell is 4mm ID))
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
%         totvol(b)=smoothdata(sum(data(i).volume.*positions_include.*positions_low.*positions_high)...
%             /sum(positions_include.*positions_low.*positions_high),'movmedian',50); %removes outliers
        %maximum(b)=max(data(i).volume.*positions_include.*positions_low.*positions_high);
        
        % x values for area plots
        dist(b)=mean(limit_low,limit_high);
        % bin labels for bar plots
        data(i).bins_label(b)=compose("%0.0f-%0.0f",[limit_low,limit_high]);
        % iterate the lower limit
        limit_low=limit_high;
    end    
    
    %index results to data struct
    data(i).x=dist;
    %normalize data
    data(i).y=smoothdata(pvi.*100./sum(pvi),'loess',50);
    %data(i).y=smoothdata(pvi,'loess',50);
    %data(i).y=smooth(avg,50); %smooths the curve
    %data(i).y=pvi.*100./sum(pvi);
    
    %find plot local maximum
    [peaks,locs]=findpeaks(data(i).y);
    data(i).plotmax=(max(peaks)-0.5)/.3654; 
    %-.5 makes this deviation from random distribution, .3654 normalizes by
    %max local maximum from all scans
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
ylabel({'Percentage of total pore volume in 100 \mum band (%)'});
xlabel('Distance from particle surface (\mum)');
axis tight
ax=axis;
ax(3)=0;
ax(4)=100/bins*2; %set so that central line of plot indicates random distribution
axis(ax);

%add horizontal line a 0.5 (even distribution)
yline(0.5,'LineStyle','--');

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

% %plot maxima
% figure;
% 
% %re-index plot maxima
% %initialize loop counter
% loop=0;
% for i=index
%     loop=loop+1;
%     pm(loop)=data(i).plotmax;
%     hold on;
% end
% 
% labels=categorical(leglabels,leglabels); %repeat keeps original order
% b=bar(labels,pm);
% b.FaceColor='flat';
% b.CData(1:length(labels),:)=color(1:length(labels),:);
% ylim([0,1]);
% ylabel('Degree of Pore Concentration');
% title(figtitle);
% 
% %save figure
% figname=sprintf('%s_pore_totvolmax_dist',figtitle);
% savefig(figname);
% saveas(gcf,figname,'epsc');
% 
% hold off
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meredith Barr
% Nov 13 2019
%
% This 'plot' FUNCTION plots pore distribution data according to inputs.
% It is called by the 'overlay' set of functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[]=pore_conc_bar(data,figtitle,xtit,incscans,xlab,...
    leglabels,legtitle,color,sneakyparam)

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
%plot maxima
figure;

%re-index plot maxima
for m=1:length(incscans)/length(xlab)
    loop=0;
    for i=index(length(xlab)*(m-1)+1:length(xlab)*m)
        loop=loop+1;
        pm(loop,m)=data(i).plotmax;
        hold on;
    end
end

% plot bar chart
labels=categorical(xlab,xlab); %repeat keeps original order
b=bar(labels,pm,'FaceColor','flat');
% set bar colors
if sneakyparam==1
    b(1).CData(1,:)=[0.7,0.87,0.54];... %light green for raw sample
    b(1).CData(2,:)=color(1,:);
    b(1).CData(3,:)=color(1,:);
    b(1).CData(4,:)=color(1,:);
    b(2).CData(1,:)=[0.65,0.81,0.9]; %light blue for raw sample
    b(2).CData(2,:)=color(2,:);
    b(2).CData(3,:)=color(2,:);
    b(2).CData(4,:)=color(2,:);   
else
    for n=1:size(pm,2)
        b(n).CData=color(n,:);
    end
end
ylim([0,1]);
% tha=char(10752);
% yl=sprintf('Degree of Pore Concentration, %c',tha); %character not printing as of 18/11/2019
yl=char(['Degree of pore concentration,  ']);
ylabel(yl)
if isempty(xtit)==0
    xlabel(xtit);
end
%make legend
if sneakyparam==0
    lgd=legend(leglabels);
    lgd.Location='northwest';
    lgd.Box='off';
    lgd.Title.String = legtitle;
end

%save figure
figname=sprintf('%s_pore_conc_bar',figtitle);
savefig(figname);
saveas(gcf,figname,'epsc');
saveas(gcf,figname,'svg');

hold off
end

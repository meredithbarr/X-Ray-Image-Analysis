%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meredith Barr
% Nov 12 2019
%
% This 'plot' FUNCTION plots radiograph data accoring to input parameters.
% It is called by the 'overlay' set of functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[]=APVplot(data,figtitle,incscans,leglabels,legtitle)
%set both axes to black
fig=figure;
set(fig,'defaultAxesColorOrder',[[0 0 0];[0 0 0]]);

%set line colors
color=[0.12, 0.47, 0.71;...
    0.89, 0.1, 0.11;...
    0.12, 0.47, 0.71;...
    0.89, 0.1, 0.11];

%set line styles
style={'-','-','--','--'};

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

%plot data
%initialize loop counter
loop=0;
for i=index
    loop=loop+1;
    plot(data(i).t,data(i).APV,'Color',color(loop,:),'LineStyle',string(style(loop)))
    hold on;
end

%axis and axis labels
%title(figtitle);
ylabel({'Percent change in normalised APV of biomass bed (%)'});
xlabel('Time (min)');
axis tight
hold on

%add vertical lines 
%index hold data
%initialize loop counter
loop=0;
for i=index
    loop=loop+1;
    holdstart(loop)=data(i).hold(1);
    holdend(loop)=data(i).hold(2);
end

%average like values of holdstart
%initialize output element index (e)
e=1;
for i=1:loop
    %check for repeats in holdstart
    dif=abs(holdstart-holdstart(i));
    repeats_log=dif<5;
    repeats_ind=find(repeats_log);
    loopcount=0;
    for r=repeats_ind
        loopcount=loopcount+1;
        repeats(loopcount)=holdstart(r);
    end
    if i>1
        %check for repeats in hsm (output array)
        dif_hsm=abs(hsm-holdstart(i));
        repeats_log_hsm=dif_hsm<5;
        repeats_hsm=find(repeats_log_hsm,1);
    else
        repeats_hsm=[];
    end
    if isempty(repeats_ind)==0 && isempty(repeats_hsm)==1
        hsm(e,:)=[mean(repeats),i];
        e=e+1;
    elseif isempty(repeats_ind)==1 && isempty(repeats_hsm)==1
        hsm(e,:)=[holdstart(i),i];
        e=e+1;
    end
end

%cleanup after loop
clearvars repeats repeats_hsm repeats_ind repeats_log repeats_log_hsm dif dif_hsm

%average like values of holdend
%initialize output element index (e)
e=1;
for i=1:loop
    %check for repeats in holdstart
    dif=abs(holdend-holdend(i));
    repeats_log=dif<5;
    repeats_ind=find(repeats_log);
    loopcount=0;
    for r=repeats_ind
        loopcount=loopcount+1;
        repeats(loopcount)=holdend(r);
    end
    if i>1
        %check for repeats in hsm (output array)
        dif_hem=abs(hem-holdend(i));
        repeats_log_hem=dif_hem<5;
        repeats_hem=find(repeats_log_hem,1);
    else
        repeats_hem=[];
    end
    if isempty(repeats_ind)==0 && isempty(repeats_hem)==1
        hem(e,:)=[mean(repeats),i];
        e=e+1;
    elseif isempty(repeats_ind)==1 && isempty(repeats_hem)==1
        hem(e,:)=[holdend(i),i];
        e=e+1;
    end
end

%cleanup after loop
clearvars repeats repeats_hem repeats_ind repeats_log repeats_log_hem dif dif_hem

%draw lines
if size(hsm,1)>1
    for i=1:size(hsm,1)
        xline(hsm(i,1),'LineStyle',':','Color',color(hsm(i,2),:));
        xline(hem(i,1),'LineStyle',':','Color',color(hem(i,2),:));
    end
else
    for i=1:size(hsm,1)
        xline(hsm(i,1),'LineStyle',':','Color',[0 0 0]);
        xline(hem(i,1),'LineStyle',':','Color',[0 0 0]);
    end    
end
    
%check if legend is specified
if length(leglabels)>1
    %make legend
    lgd=legend(leglabels);
    lgd.Location='southwest';
    lgd.Box='off';
    lgd.Title.String = legtitle;
end

%save figure
figname=sprintf('%s_APV',figtitle);
savefig(figname);
saveas(gcf,figname,'epsc');
end
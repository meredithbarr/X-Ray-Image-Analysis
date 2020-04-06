%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meredith Barr
% August 8th 2019
% This SCRIPT segments radiographs input as a .tif stack, analyses
% these segmentations, and plots the results.
% Section 6: data analysis is dependent on a set of .xlsx reactor control
% files.
%
% Instructions: (1) run in setupmode=1 (2) run in setupmode=0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SETUP

setupmode=input('Enter setup mode?');

if setupmode==1
    clearvars
    setupmode=1;
    
    %Prompt for file info
    imagefilenum=input('enter image file number as an integer >>>');
    controlfile=input('enter heating control file name as char including .xlsx >>>');
    controlfilecool=input('enter cooling control file name as char including .xlsx >>>');
    sample=input('enter sample treatment and material as char >>>');

    disp('Unpacking file...');
    %index the aligned tiff file (aligned using ImageJ Template Matching plugin)
    imagefile=sprintf('%d.tif',imagefilenum);
    imarray=loadtiff(imagefile);
    
    %initialize adjustment params
    wallthresh=0.38;
    meshthresh=0.47;
    islandparam=10000;
    closeparam=17;
    diamondsize=13;
    whiteislands=1000;
    se90size=26;
    se0size=16;
    
else
    %load adjuted params
    filename=sprintf('%i_params.mat',imagefilenum);
    load(filename);
end

%Find number of images / depth of stack
dims=size(imarray);
stack=dims(3);
clearvars dims

%% Section 1: eliminate the quartz tube

%start iterating through the stack of images
disp('beginning segmentation');

%initialize i (stack position)
i=1;
while i<=stack
%in setup mode only consider first and last slice
if setupmode==1
if or(i==1,i==stack)
    else
        i=stack;
end
end
    
im=imarray(:,:,i);
dims=size(im);

%define the tube walls as 0
B=imbinarize(im,wallthresh);
s=strel('line',100,90);
B=imclose(B,s);
B=imcomplement(B);
B=imclose(B,s);
B=imcomplement(B);
tubeonly=immultiply(B,im);

%setup threshold for defining tube walls
if setupmode==1
    imshow(B)
    adjust=input('adjust wall highlight threshold?');
    while adjust==1
        disp(compose("current threshold: %.3f",wallthresh));
        wallthresh=input('enter new threshold:');
        
        % rerun thresholding
        B=imbinarize(im,wallthresh);
        s=strel('line',100,90);
        B=imclose(B,s);
        B=imcomplement(B);
        B=imclose(B,s);
        B=imcomplement(B);
        tubeonly=immultiply(B,im);
        
        imshow(B)
        adjust=input('adjust wall highlight threshold?');
    end
end

%clean up memory
clearvars B im s adjust

%Define everything outside tube walls as 0
% LHS
height=dims(1);
%find the first non-zero pixel from the LHS in each row
clearvars frame h w
frame(:,:)=zeros(dims(1),dims(2));
for h=1:height
    width=dims(2);
    w=1;
while w <= width
    if tubeonly(h,w)~=0
        width=w;
    else
        frame(h,w)=1;
    end
    w=w+1;
end
end
tubeonlydouble=im2double(tubeonly);
whiteframe=imadd(frame,tubeonlydouble);

%black out pixels until the first black pixel from the LHS
clearvars walls h w
walls(:,:)=ones(dims(1),dims(2));
LHSwall=zeros(dims(1),1);
for h=1:height
    width=dims(2);
    w=1;
while w <= width
    if whiteframe(h,w)==0
        width=w;
        LHSwall(h)=width;
    else
        walls(h,w)=0;
    end
    w=w+1;
end
end

whiteframedouble=im2double(whiteframe);
tube=immultiply(walls,whiteframedouble);

%clean up for memory
clearvars whiteframe whiteframedouble tubeonly tubeonlydouble

% Repeat both steps for the RHS

%find the first non-zero pixel from the RHS in each row
clearvars frame h w
frame(:,:)=zeros(dims(1),dims(2));
for h=1:height
    width=dims(2);
    w=width;
    one=1;
while w >= one
    if tube(h,w)~=0
        one=w;
    else
        frame(h,w)=1;
    end
    w=w-1;
end
end
tubedouble=im2double(tube);
whiteframeRHS=imadd(frame,tubedouble);

%black out pixels until the first black pixel from the RHS
clearvars walls h w
walls(:,:)=ones(dims(1),dims(2));
RHSwall=zeros(dims(1),1);
for h=1:height
    width=dims(2);
    w=width;
    one=1;
while w >= one
    if whiteframeRHS(h,w)==0
        one=w;
        RHSwall(h)=one;
    else
        walls(h,w)=0;
    end
    w=w-1;
end
end

whiteframeRHSdouble=im2double(whiteframeRHS);
tubenowalls=immultiply(walls,whiteframeRHSdouble);

%clean up memory
clearvars tube tubedouble whiteframeRHS whiteframeRHSdouble walls frame...
    h w height width one

%% Section 2: Remove wire mesh

%remove mesh liberally
B=imbinarize(tubenowalls,meshthresh);
%remove islands
B=imcomplement(B);
B=bwareaopen(B,islandparam);
B=imcomplement(B);
BWtubenomesh=B;
tubenomesh=immultiply(BWtubenomesh,tubenowalls);

%setup threshold for defining wire mesh
if setupmode==1
    imshow(tubenomesh)
    adjust=input('adjust mesh removal threshold?');
    while adjust==1
        disp(compose("current mesh threshold: %.3f, island removal parameter: : %.3f",...
            [meshthresh,islandparam]));
        inpt=input('enter new thresholds {,}:');
        [meshthresh,islandparam]=inpt{:};
        
        % rerun thresholding
        B=imbinarize(tubenowalls,meshthresh);
        %remove islands
        B=imcomplement(B);
        B=bwareaopen(B,islandparam);
        B=imcomplement(B);
        BWtubenomesh=B;
        tubenomesh=immultiply(BWtubenomesh,tubenowalls);
        
        imshow(tubenomesh)
        adjust=input('adjust mesh removal threshold?');
    end
end

%clean up memory
clearvars B C tubenowalls adjust

%% Section 3: Segment gas vs solid

%harvest edges from image
[~, threshold] = edge(tubenomesh, 'sobel');
fudgeFactor = .21;
BWs = edge(tubenomesh,'sobel', threshold * fudgeFactor);

%close to fill in lighter areas of bed
BWclose = imclose(BWs,true(closeparam));

%erode away lines
se=strel('diamond',diamondsize);
BWerode = imerode(BWclose,se);
BWerode = imerode(BWerode,se);

%erase white islands
BWw=bwareaopen(BWerode,whiteislands);

% fill holes in bed
BWfill=imfill(BWw,'holes');

% dilate image
se90 = strel('line', se90size, 90);
se0 = strel('line', se0size, 0);
BWdil=imdilate(BWfill,[se90 se0]);
solid=imdilate(BWdil,[se90 se0]);

%% Section 4: Analyse regions

%define regions
cell=BWtubenomesh;
gas=imsubtract(cell,solid);
gas=imbinarize(gas);
gas=bwareaopen(gas,500);

%find composition
solidcomp(i)=bwarea(solid)/bwarea(cell);
gascomp(i)=bwarea(gas)/bwarea(cell);

%find average pixel value of bed as a proxy measure of porosity and bed packing density
bedonly=immultiply(tubenomesh,solid);
APV=mean2(nonzeros(bedonly));
%normalize by tube APV to account for image to image variation (results in much smoother data)
tubenobed=immultiply(tubenomesh,gas);
APVgas=mean2(nonzeros(tubenobed));
APVn(i)=APV/APVgas;

%estimate volume from CSA
%find diameter of tube and bed for each row
%tube diameter
tube_diam=sum(cell,2);

%bed diameter
%count number of white pixels in each row
bed_diam=sum(solid,2);

nbd=nonzeros(bed_diam);
ntd=nonzeros(tube_diam);
sb=length(nbd);
st=length(ntd);
if sb<st
    tube_diam_short=ntd(1:sb);
    bed_diam_short=nbd(1:sb);
else
    tube_diam_short=ntd(1:st);
    bed_diam_short=nbd(1:st);
end

CSAtovol=nonzeros(bed_diam_short)./nonzeros(tube_diam_short);
solidcomp_3d(i)=mean(CSAtovol.^2);

%% Section 5: Create graphics

% Outlined bed
% BWoutline = bwperim(solid,8);
% Segout = tubenomesh; 
% Segout(BWoutline) = 255;

%Masked bed and gas
gasdouble=im2double(gas);
soliddouble=im2double(solid);
gasgrey=gasdouble.*2;
label=imadd(gasgrey,soliddouble);
rgb = labeloverlay(tubenomesh, label);

%tune segmentation parameters
if setupmode==1
    imshow(rgb)
    adjust=input('adjust params?');
    while adjust==1
        disp(compose...
            ("closeparam: %.3f, diamondsize: %.3f, whiteislands: %.3f, dilate vertical: %.3f, dilate horizontal: %.3f",...
            [closeparam,diamondsize,whiteislands,se90size,se0size]));
        inpt=...
            input('enter new thresholds {,,,,}:');
        [closeparam,diamondsize,whiteislands,se90size,se0size]=inpt{:};
        
        % rerun thresholding
        %harvest edges from image
        [~, threshold] = edge(tubenomesh, 'sobel');
        fudgeFactor = .21;
        BWs = edge(tubenomesh,'sobel', threshold * fudgeFactor);

        %close to fill in lighter areas of bed
        BWclose = imclose(BWs,true(closeparam));

        %erode away lines
        se=strel('diamond',diamondsize);
        BWerode = imerode(BWclose,se);
        BWerode = imerode(BWerode,se);

        %erase white islands
        BWw=bwareaopen(BWerode,whiteislands);

        % fill holes in bed
        BWfill=imfill(BWw,'holes');

        % dilate image
        se90 = strel('line', se90size, 90);
        se0 = strel('line', se0size, 0);
        BWdil=imdilate(BWfill,[se90 se0]);
        solid=imdilate(BWdil,[se90 se0]);
        
        %% Section 4: Analyse regions

        %define regions
        cell=BWtubenomesh;
        gas=imsubtract(cell,solid);
        gas=imbinarize(gas);
        gas=bwareaopen(gas,500);

        %find composition
        solidcomp(i)=bwarea(solid)/bwarea(cell);
        gascomp(i)=bwarea(gas)/bwarea(cell);

        %find average pixel value bed as a proxy measure of porosity
        bedonly=immultiply(tubenomesh,solid);
        APV=mean2(nonzeros(bedonly));
        %normalize by tube APV
        tubenobed=immultiply(tubenomesh,gas);
        APVgas=mean2(nonzeros(tubenobed));
        APVn(i)=APV/APVgas;

        %estimate volume from CSA
        %find diameter of tube and bed for each row
        %tube diameter
        tube_diam=RHSwall-LHSwall;

        %bed diameter
        %count number of white pixels in each row
        bed_diam=sum(solid,2);

        nbd=nonzeros(bed_diam);
        ntd=nonzeros(tube_diam);
        sb=length(nbd);
        st=length(ntd);
        if sb<st
            tube_diam_short=ntd(1:sb);
            bed_diam_short=nbd(1:sb);
        else
            tube_diam_short=ntd(1:st);
            bed_diam_short=nbd(1:st);
        end

        CSAtovol=nonzeros(bed_diam_short)./nonzeros(tube_diam_short);
        solidcomp_3d(i)=mean(CSAtovol.^2);

        %% Section 5: Create graphics

        % Outlined bed
        % BWoutline = bwperim(solid,8);
        % Segout = tubenomesh; 
        % Segout(BWoutline) = 255;

        %Masked bed and gas
        gasdouble=im2double(gas);
        soliddouble=im2double(solid);
        gasgrey=gasdouble.*2;
        label=imadd(gasgrey,soliddouble);
        rgb = labeloverlay(tubenomesh, label);
        
        imshow(rgb)
        adjust=input('adjust params?');
    end
end

%save adjustment params
filename=compose("%i_params.mat",imagefilenum);
save(filename,'wallthresh','meshthresh','islandparam','closeparam','diamondsize','whiteislands','se90size','se0size');

%clean up memory
clearvars BWclose BWerode BWfill BWdil BWs BWw fudgeFactor se se0 se90...
    threshold adjust

%save masked images
%as .tif
filename=compose("%d_%d.tif",[imagefilenum,i]);
imwrite(rgb,filename)

%as .gif
filename=compose("%i_masked.gif",imagefilenum);
[imind,cm] = rgb2ind(rgb,256);
if i == 1
  imwrite(imind,cm,filename,'gif','DelayTime',0.1,'Loopcount',inf);
else
  imwrite(imind,cm,filename,'gif','DelayTime',0.1,'WriteMode','append');
end

progress=compose("%d/%d image(s) complete",[i,stack]);
disp(progress);

%clean up memory (end of image processing)
clearvars dims gasgrey label rgb progress

%interate i and end stack loop
i=i+1;
end
%reset i to stack depth
i=i-1;
disp('segmentation complete');

%clean up memory
clearvars wallthresh meshthresh islandparam closeparam diamondsize...
    whiteislands se90size se0size

if setupmode==0

%% Section 6: Data analysis
disp('beginning analysis');

%create a time axis assuming every 10 images were harvested for the aligned
%tiff stack
t=linspace(1,stack*50/60,stack);
%Read temperature history from control files
%read heating file
peaktemp=xlsread(controlfile,'','B4'); %[degrees C]
timerip=xlsread(controlfile,'','A:A'); %[seconds]
temprip=xlsread(controlfile,'','B:B'); %[degrees C]
temprip=temprip(8:size(temprip));
tempheatlog=temprip>=30;
remove=size(timerip)-sum(tempheatlog)+1;
tempheat=temprip(remove:size(temprip));
timeheat=timerip(remove:size(timerip));
%read cooling file
timecoolrip=xlsread(controlfilecool,'','A:A'); %[seconds]
TH=timeheat(size(timeheat));
timecool=timecoolrip+TH(1);
tempcool=xlsread(controlfilecool,'','B:B'); %[degrees C]

%clean up memory
clearvars timerip temprip timecoolrip TH
disp('analysis complete');
disp('making figures');

%make figure
figure
% CSA: Cross-Sectional Area
subplot(2,1,1);
yyaxis left
plot(t,solidcomp*100,t,solidcomp_3d*100);
title({'Percentage of Void Cross-Sectional Area and Estimated',...
    'Percentage of Void Volume Occupied by Pyrolysing Solid Bed'});
xlabel('Time (min)');
ylabel('Percent occupied (%)');
ylim([0 100])
yyaxis right
plot(timeheat/60,tempheat,'-',timecool/60,tempcool,'-');
ylabel('Temperature (\circC)')
lgd=legend('Cross-Sectional Area','Volume');
lgd.Location='south';
lgd.Box='off';

hold

% APV: Average Pixel Value
subplot(2,1,2);
yyaxis left
plot(t,APVn);
title({'Normalised Average Radiograph Intensity of Pyrolysing Solid Bed'});
xlabel('Time (min)');
ylabel('Normalised Intensity');
%ylim([0 1])
yyaxis right
plot(timeheat/60,tempheat,'-',timecool/60,tempcool,'-');
ylabel('Temperature (\circC)')

sgtitle(compose("Feedstock: %s",sample));

%save figure and data
filename=compose("%i.fig",imagefilenum);
savefig(filename);
filename=compose("%i_figure.tif",imagefilenum);
saveas(gcf,filename);
filename=compose("%i.mat",imagefilenum);
save(filename,'timeheat','tempheat','timecool','tempcool','t','APVn','solidcomp','solidcomp_3d');

% %% Section 7: Animation
% %Save raw images as gif
% filename=compose("%i.gif",imagefilenum);
% for n=1:i
%     [imind,cm] = gray2ind(imarray(:,:,n),256);
%       if n == 1
%           imwrite(imind,cm,filename,'gif','DelayTime',0.1,'Loopcount',inf);
%       else
%           imwrite(imind,cm,filename,'gif','DelayTime',0.1,'WriteMode','append');
%       end
% end
disp('figures complete');
end

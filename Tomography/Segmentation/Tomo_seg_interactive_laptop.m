%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meredith Barr
% August 18th 2019
%
% This script segments tomograms of raw and pyrolysed nut shells into
% solid, pores, and exterior. It outputs solid and pore mask images as
% .tiff files, which are used as input for a variety of analyses including
% pore distribution (pore_dist_looper.m).
%
% Instructions: (1) run in setupmode=1 (2) comment out all "%for setup"
% lines and uncomment all "%for looping" lines (3) set scan numbers below
% (4) run
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%input scan number
%scan=str2num(getenv('SGE_TASK_ID')); %for HPC

%for scan=[119330,119332,119334,119336] %for looping
    
scan=119336; %for setup

%setup mode
setupmode=input('enter setup mode?'); %for setup
%setupmode=0; %for looping

% load input params and begin parallel processing in not in setup mode
% also define slice ranges based on mode
if setupmode==0
    filename=sprintf('%i/input_params_%i.mat',[scan,scan]);
    IP=load(filename);
    
    %set up parallel processing
    w=4; %for laptop, number of cores
    %w=str2num(getenv('NSLOTS')); %for HPC
    pool = parpool('local', w);
    pool.IdleTimeout=Inf;
    
    %define slice range
    slicerange=1:2120; %all slices
    %slicerange=285:1247; %specific slice range
else
    slicerange=[1060,1,1700]; %first attempt version
    %slicerange=[378,418,512]; %problem slices version
end

%begin slice loop
for n=slicerange %for setup
%parfor n=slicerange %for looping
    if setupmode==0
        %assign input parameters
        crop=IP.crop;
        xdisp=IP.xdisp;
        ydisp=IP.ydisp;
        finemask_close=IP.finemask_close;
        finemask_dilate=IP.finemask_dilate;
        finemask_noise=IP.finemask_noise;
        fudgeFactor=IP.fudgeFactor;
        roughmask_dilate=IP.roughmask_dilate;
        roughmask_erode=IP.roughmask_erode;
        roughmask_holes=IP.roughmask_holes;
    end
    
    %get filename from scan number
    if (n-1)<10
        slice=compose("0000%i",n-1);
    elseif (n-1)<100
        slice=compose("000%i",n-1);
    elseif (n-1)<1000
        slice=compose("00%i",n-1);
    else
        slice=compose("0%i",n-1);
    end
    filename=compose("%s/tomo_%s_%s.tiff",[scan,scan,slice]);
    im_raw=imread(filename);
    imdouble=im2double(im_raw);

    %% Cropping the image

    %get image properties
    dims=size(im_raw);

    imageSizeX = dims(1);
    imageSizeY = dims(2);
    [columnsInImage rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);

    if setupmode==1 && n==1060
        %initialize vars
        repeat=1;
        xdisp=0;
        ydisp=0;
        crop=0;
        while repeat==1
            message=sprintf('current displacements {xdisp,ydisp}: {%i, %i}',...
                [xdisp,ydisp]);
            disp(message);
            new=input('input new {xdisp,ydisp}:');
            [xdisp,ydisp]=new{:};
            %run section
                % Create the circle in the image
                centerX = dims(1)/2+xdisp;
                centerY = dims(2)/2+ydisp;
                if dims(1)<dims(2)
                    radius = dims(1)/2;
                else
                    radius = dims(2)/2;
                end
                circle = (rowsInImage - centerY).^2 ...
                    + (columnsInImage - centerX).^2 <= (radius-340-crop/2).^2;
                circ_small=(rowsInImage - centerY).^2 ...
                    + (columnsInImage - centerX).^2 <= (radius-343-crop/2).^2;
                circ_smaller=(rowsInImage - centerY).^2 ...
                    + (columnsInImage - centerX).^2 <= (radius-346-crop/2).^2;
                circ_smallest=(rowsInImage - centerY).^2 ...
                    + (columnsInImage - centerX).^2 <= (radius-340-crop).^2;
                circ_large=(rowsInImage - centerY).^2 ...
                    + (columnsInImage - centerX).^2 <= (radius-337-crop/2).^2;
                circ_larger=(rowsInImage - centerY).^2 ...
                    + (columnsInImage - centerX).^2 <= (radius-334-crop/2).^2;
                circ_perim_double=imsubtract(circ_large,circ_small);
                circ_perim=logical(circ_perim_double);
                big_perim_double=imsubtract(circ_larger,circ_smaller);
                big_perim=logical(big_perim_double);

                im=immultiply(im_raw,circle);
                %end of section
            imshow(im)
            repeat=input('change x/y displacement?');
        end
        crop=input('input max displacement from alignment');
            %run section
            % Create the circle in the image
            centerX = dims(1)/2+xdisp;
            centerY = dims(2)/2+ydisp;
            if dims(1)<dims(2)
                radius = dims(1)/2;
            else
                radius = dims(2)/2;
            end
            circle = (rowsInImage - centerY).^2 ...
                + (columnsInImage - centerX).^2 <= (radius-340-crop/2).^2;
            circ_small=(rowsInImage - centerY).^2 ...
                + (columnsInImage - centerX).^2 <= (radius-343-crop/2).^2;
            circ_smaller=(rowsInImage - centerY).^2 ...
                + (columnsInImage - centerX).^2 <= (radius-346-crop/2).^2;
            circ_smallest=(rowsInImage - centerY).^2 ...
                + (columnsInImage - centerX).^2 <= (radius-340-crop).^2;
            circ_large=(rowsInImage - centerY).^2 ...
                + (columnsInImage - centerX).^2 <= (radius-337-crop/2).^2;
            circ_larger=(rowsInImage - centerY).^2 ...
                + (columnsInImage - centerX).^2 <= (radius-334-crop/2).^2;
            circ_perim_double=imsubtract(circ_large,circ_small);
            circ_perim=logical(circ_perim_double);
            big_perim_double=imsubtract(circ_larger,circ_smaller);
            big_perim=logical(big_perim_double);

            im=immultiply(im_raw,circle);
            %end of section

            %save tuned input parameters
            filename=sprintf('%i/input_params_%i.mat',[scan,scan]);
            save(filename,'xdisp','ydisp','crop');
    else
        %run section
        % Create the circle in the image
        centerX = dims(1)/2+xdisp;
        centerY = dims(2)/2+ydisp;
        if dims(1)<dims(2)
            radius = dims(1)/2;
        else
            radius = dims(2)/2;
        end
        circle = (rowsInImage - centerY).^2 ...
            + (columnsInImage - centerX).^2 <= (radius-340-crop/2).^2;
        circ_small=(rowsInImage - centerY).^2 ...
            + (columnsInImage - centerX).^2 <= (radius-343-crop/2).^2;
        circ_smaller=(rowsInImage - centerY).^2 ...
            + (columnsInImage - centerX).^2 <= (radius-346-crop/2).^2;
        circ_smallest=(rowsInImage - centerY).^2 ...
            + (columnsInImage - centerX).^2 <= (radius-340-crop).^2;
        circ_large=(rowsInImage - centerY).^2 ...
            + (columnsInImage - centerX).^2 <= (radius-337-crop/2).^2;
        circ_larger=(rowsInImage - centerY).^2 ...
            + (columnsInImage - centerX).^2 <= (radius-334-crop/2).^2;
        circ_perim_double=imsubtract(circ_large,circ_small);
        circ_perim=logical(circ_perim_double);
        big_perim_double=imsubtract(circ_larger,circ_smaller);
        big_perim=logical(big_perim_double);

        im=immultiply(im_raw,circle);
        %end of section
    end

    %% Making rough mask

    %adjust roughmask params
    if setupmode==1
        %initialize params
        repeat=1;
        if n==1060
            fudgeFactor=1.1;
            roughmask_dilate=50;
            roughmask_holes=10000;
            roughmask_erode=40;
        end
        while repeat==1
            message=sprintf(...
                'Current roughmask params {fudge factor, dilation, hole size thresh, erosion}: {%i, %i, %i, %i}'...
                ,[fudgeFactor,roughmask_dilate,roughmask_holes,roughmask_erode]);
            disp(message);
            new=input('input new roughmask params {fudge factor, dilation, hole size thresh, erosion}:');
            [fudgeFactor,roughmask_dilate,roughmask_holes,roughmask_erode]=new{:};
                %run section
                %select particle edges
                [~,threshold]=edge(im,'sobel');
                BW=edge(im,'sobel',threshold*fudgeFactor);

                %remove circle perimeter
                BWdouble=im2double(BW);
                BWdouble=BWdouble.*imcomplement(circ_perim_double);

                %select roughmask
                roughmask=imdilate(BWdouble,true(roughmask_dilate));
                roughmask=roughmask+circ_perim_double;
                roughmask=logical(roughmask);
                roughmask=im2double(roughmask);
                roughmask=imcomplement(roughmask);
                roughmask=bwareaopen(roughmask,roughmask_holes);
                roughmask=imcomplement(roughmask);
                roughmask=imerode(roughmask,true(roughmask_erode));
                roughmask=roughmask.*imcomplement(circ_perim_double);

                %fill holes
                roughmask_logical=logical(roughmask);
                rough=immultiply(roughmask_logical,im);
                %end of section
            imshowpair(im,rough,'montage')
            repeat=input('adjust roughmask params?');
        end
        %save tuned input parameters
        filename=sprintf('%i/input_params_%i.mat',[scan,scan]);
        save(filename,'fudgeFactor','roughmask_dilate','roughmask_holes','roughmask_erode','-append');
    else
        %run section
        %select particle edges
        [~,threshold]=edge(im,'sobel');
        BW=edge(im,'sobel',threshold*fudgeFactor);

        %remove circle perimeter
        BWdouble=im2double(BW);
        BWdouble=BWdouble.*imcomplement(circ_perim_double);

        %select roughmask
        roughmask=imdilate(BWdouble,true(roughmask_dilate));
        roughmask=roughmask+circ_perim_double;
        roughmask=logical(roughmask);
        roughmask=im2double(roughmask);
        roughmask=imcomplement(roughmask);
        roughmask=bwareaopen(roughmask,roughmask_holes);
        roughmask=imcomplement(roughmask);
        roughmask=imerode(roughmask,true(roughmask_erode));
        roughmask=roughmask.*imcomplement(circ_perim_double);

        %fill holes
        roughmask_logical=logical(roughmask);
        rough=immultiply(roughmask_logical,im);
        %end of section
    end

    %% Making fine mask from rough mask
    if setupmode==1
        %initialize variables
        if n==1060
            finemask_dilate=2;
            finemask_close=2;
            finemask_noise=200;
        end
        repeat=1;
        while repeat==1
            message=sprintf(...
                'Current finemask params {dilation, closing (increase these to keep lacy regions), grey noise in pores}: {%i, %i, %i}'...
                ,[finemask_dilate,finemask_close,finemask_noise]);
            disp(message);
            new=input('input new finemask params {dilation, closing (increase these to keep lacy regions), grey noise in pores}:');
            [finemask_dilate,finemask_close,finemask_noise]=new{:};    
                %run section
                thresh=graythresh(rough);
                ff2=1.92;
                solid_mask=imbinarize(rough,ff2*thresh);

                solid=immultiply(im,solid_mask);

                %select internal pores and close external pores
                %increasing these params helps keep very lacy regions
                fine_mask0=imdilate(solid_mask,true(finemask_dilate));
                fine_mask0=imclose(fine_mask0,true(finemask_close));

                %add border and fill holes in fine particle mask
                fine_mask0=imadd(fine_mask0,circ_perim);
                fine_mask_logical=logical(fine_mask0);
                fine_mask0=im2double(fine_mask_logical);

                fine_mask=imcomplement(fine_mask0);
                fine_mask=bwareaopen(fine_mask,5000);
                fine_mask=imcomplement(fine_mask);

                fine=immultiply(imdouble,fine_mask);

                %find solid within fine mask
                thresh=graythresh(fine);
                ff2=1.76;
                solid_fine_mask=imbinarize(fine,ff2*thresh);
                %erode away grey noise in larger pores
                solid_fine_mask=bwareaopen(solid_fine_mask,finemask_noise);
                solid_fine_mask=immultiply(solid_fine_mask,imcomplement(circ_perim));
                solid_fine_mask=logical(solid_fine_mask);

                solid_fine=immultiply(im,solid_fine_mask);

                %crop data
                solid_fine_mask=im2double(solid_fine_mask);
                solid_fine_mask=solid_fine_mask.*circ_smallest;
                solid_fine_mask=logical(solid_fine_mask);
                %end of section
            imshowpair(im,solid_fine,'montage');
            repeat=input('adjust finemask params?');
        end
        %save tuned input parameters
        filename=sprintf('%i/input_params_%i.mat',[scan,scan]);
        save(filename,'finemask_dilate','finemask_close','finemask_noise','-append');
    else
        %run section
        thresh=graythresh(rough);
        ff2=1.92;
        solid_mask=imbinarize(rough,ff2*thresh);

        solid=immultiply(im,solid_mask);

        %select internal pores and close external pores
        %increasing these params helps keep very lacy regions
        fine_mask0=imdilate(solid_mask,true(finemask_dilate));
        fine_mask0=imclose(fine_mask0,true(finemask_close));

        %add border and fill holes in fine particle mask
        fine_mask0=imadd(fine_mask0,circ_perim);
        fine_mask_logical=logical(fine_mask0);
        fine_mask0=im2double(fine_mask_logical);

        fine_mask=imcomplement(fine_mask0);
        fine_mask=bwareaopen(fine_mask,5000);
        fine_mask=imcomplement(fine_mask);

        fine=immultiply(imdouble,fine_mask);
        
        %find solid within fine mask
        thresh=graythresh(fine);
        ff2=1.76;
        solid_fine_mask=imbinarize(fine,ff2*thresh);
        %erode away grey noise in larger pores
        solid_fine_mask=bwareaopen(solid_fine_mask,finemask_noise);
        solid_fine_mask=immultiply(solid_fine_mask,imcomplement(circ_perim));
        solid_fine_mask=logical(solid_fine_mask);

        solid_fine=immultiply(im,solid_fine_mask);

        %crop data
        solid_fine_mask=im2double(solid_fine_mask);
        solid_fine_mask=solid_fine_mask.*circ_smallest;
        solid_fine_mask=logical(solid_fine_mask);
        %end of section
    
        %setupmode is now complete, in computemode continue on
        
        %save solid mask image files
        filename=compose("%i/%i_solid_%i.tiff",[scan,scan,n]);
        imwrite(solid_fine_mask,filename,'tiff', 'Compression','none');
    
        %% Making pore mask

        %select internal pores and close external pores
        closed_solid0=imadd(solid_fine_mask,circ_perim);
        closed_solid_logical=logical(closed_solid0);
        closed_solid0=im2double(closed_solid_logical);

        %close smaller pores
        closed_solid=imdilate(closed_solid0,true(4));
        closed_solid=imcomplement(closed_solid);
        closed_solid=bwareaopen(closed_solid,500);
        closed_solid=imcomplement(closed_solid);

        %remove circle and close large pores to avoid closing edges between
        %particles
        closed_solid=closed_solid.*imcomplement(big_perim);
        closed_solid=logical(closed_solid);
        closed_solid=imcomplement(closed_solid);
        closed_solid=bwareaopen(closed_solid,5000);
        closed_solid=imcomplement(closed_solid);
        closed_solid=imerode(closed_solid,true(4));

        closed=immultiply(im,closed_solid);

        %imshowpair(closed_solid,solid_fine,'montage');

        %subtract to resolve pores
        pore_mask=imsubtract(closed_solid,solid_fine_mask);
        pore_mask=pore_mask==1;

        pore=immultiply(imdouble,pore_mask);

        %imshowpair(im,solid_fine_mask,'montage')

        %crop data
        pore_mask=im2double(pore_mask);
        pore_mask=pore_mask.*circ_smallest;
        pore_mask=logical(pore_mask);

        filename=compose("%i/%i_pores_%i.tiff",[scan,scan,n]);
        imwrite(pore_mask,filename,'tiff', 'Compression','none');

        %imshowpair(im,solid_fine_mask,'montage')

        s(n)=bwarea(solid_fine_mask);
        p(n)=bwarea(pore_mask);

        progress=compose("%d/2120 image(s) complete",n);
        disp(progress);
    end
end

%clear vars after parallel loop
clearvars slice filename dims imageSizeX imageSizeY radius circ_small circle...
        columnsInImage rowsInImage centerX centerY circ_large...
        circ_larger circ_smaller roughmask roughmask_logical threshold...
        BW BWdouble thresh ff2 solid fine_mask0 solid_mask fine_mask...
        fine_mask_logical fine solid_fine filename closed_solid0 closed...
        closed_solid_logical pore_mask_logical pore closed_solid...
        circ_perim circ_perim_double filename big_perim big_perim_double...
        circ_smallest progress im imdouble solid_fine_mask pore_mask

if setupmode==0
    pore_volume=sum(p)/(sum(s)+sum(p));

    %save data
    filename=sprintf('%i/seg_output_%i.mat',[scan,scan]);
    save(filename,'s','p','pore_volume');
    
    %end parallel processing
    delete(pool);
end

clearvars
%end %for looping

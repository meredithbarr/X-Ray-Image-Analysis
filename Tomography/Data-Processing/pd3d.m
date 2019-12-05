%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meredith Barr
% Nov 7 2019
% 
% This is a FUNCTION to analyze distribution of pores within particles or
% beds from segmented tomographs.
% 
% Inputs: scan, slice_range
%
% Outputs: no vars, files: pore_data_um_scan.mat (pores_dist, pores_volume),
% pore_data_pix_scan_region.mat (cc, pores_props, edges_x, edges_y,
% edges_z)
%
% Dependencies: input_params_scan.mat, pore mask slices, solid mask slices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[]=pd3d(scan,slice_range)

%import scan params
filename=sprintf('%i/input_params_%i.mat',[scan,scan]);
IP=load(filename);

%iterate through regions
num_regions=size(slice_range);
num_regions=num_regions(1);
for region=1:num_regions
    clearvars pores_props cc
    
    %iterate through slices
    parfor slice_norm=1:slice_range(region,2)-slice_range(region,1)+1
        
        %import input params
        crop=IP.crop;
        xdisp=IP.xdisp;
        ydisp=IP.ydisp;
        
        %normalize slices for indexing
        slice=slice_norm+slice_range(region,1)-1;

        %% Section 1: make 3d edge and pore masks
        %open solid mask    
        solidfilename=sprintf('%i/%i_solid_%i.tiff',[scan,scan,slice]);
        solid=imread(solidfilename);
        solid=double(solid);
        
        %open pore mask
        poresfilename=sprintf('%i/%i_pores_%i.tiff',[scan,scan,slice]);
        pores=imread(poresfilename);
        pores=double(pores);
        
        % add pore and solid masks to create particle mask
        particles=imadd(solid,pores);

        %create border circle
        dims=size(solid);
        [columnsInImage,rowsInImage] = meshgrid(1:dims(1), 1:dims(2));
        centerX = dims(1)/2+xdisp;
        centerY = dims(2)/2+ydisp;
        if dims(1)<dims(2)
            radius = dims(1)/2;
        else
            radius = dims(2)/2;
        end
        circle=(rowsInImage - centerY).^2 ...
        + (columnsInImage - centerX).^2 <= (radius-340-crop-1).^2;
        circle=double(circle);
        
        %find particle edges
        edges=edge(particles);

        %subtract edges created by border circle (crop edge mask)
        edges_noborder(:,:,slice_norm)=immultiply(edges,circle);

        %crop pores mask
        pores_cropped(:,:,slice_norm)=immultiply(pores,circle);

        %end the slice loop
    end
    
    fprintf('Scan %i: slice loop %i/%i complete\n',[scan,region,num_regions]);
    
    clearvars pores edges particles_noborder particles solid_withborder solid

    %label individual pores
    pores_cropped=logical(pores_cropped);
    cc=bwconncomp(pores_cropped,6);

    %compute pore volumes
    pores_props=regionprops3(cc, 'Volume','Centroid','SurfaceArea');

    %definde edge coordinates
    [edges_x,edges_y,edges_z]=find(edges_noborder);
    
    clearvars pores_cropped edges_noborder

    %% Section 2: iterate through each pore computing minimum distance to an edge
    pores_dist_pix=zeros(cc.NumObjects,1);
    parfor p=1:cc.NumObjects
        %compute distance to nearest edge
        %find all distances from centroid to edges and then choose minimum
        pores_centroid=pores_props.Centroid;
        pores_coordinates=pores_centroid(p,:);
        %iterate through edge coordinates computing distances
        dist=zeros(length(edges_x),1);
        for i=1:length(edges_x)
            dist_x=abs(pores_coordinates(1)-edges_x(i));
            dist_y=abs(pores_coordinates(2)-edges_y(i));
            dist_z=abs(pores_coordinates(3)-edges_z(i));
            dist(i)=sqrt(dist_x^2+dist_y^2+dist_z^2);
        end
        pores_dist_pix(p)=min(dist);
    end
    
    fprintf('Scan %i: pore loop %i/%i complete\n',[scan,region,num_regions]);
    
    %cleanup after parallel loop
    clearvars pores_centroid dist_x dist_y dist_z dist
    
    %convert distances to micrometers
    voxel=1.625; %um per pixel
    if region>1
        pores_dist=cat(1,pores_dist,pores_dist_pix.*voxel);
        pores_volume=cat(1,pores_volume,pores_props.Volume.*voxel^3);
    else
        pores_dist=pores_dist_pix.*voxel;
        pores_volume=pores_props.Volume.*voxel^3;
    end
    clearvars pores_dist_pix
    
    if region==num_regions
        %save pore data (for easy plotting)
        filename=sprintf('pore_data_um_%i.mat',scan);
        save(filename,'pores_volume','pores_dist','-v7.3');
    end
    
    %save 
    filename=sprintf('pore_data_pix_%i_region%i.mat',[scan,region]);
    save(filename,'cc','pores_props','edges_x','edges_y','edges_z','-v7.3');
    
    %cleanup after saving data
    clearvars edges_x edges_y edges_z

    %end the region loop
    fprintf('Scan %i: region %i/%i complete\n',[scan,region,num_regions]);
end

%end function
end
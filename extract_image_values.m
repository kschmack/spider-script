function [TS,XYZ,XYZmm] = extract_image_values(imagelist,mask)
% extracts image values from a mask
% TS            - n x m matrix with n values (voxels) for m images
% XYZ           - n x 3 vector with n coordinate triplets (vector space)
% XYZmm         - n x 3 vector with n coordinate triplets (world space)
% imagelist     - list of images 
% mask          - full path to binary mask image 

%% load mask
strct=spm_vol(mask);
[M XYZmm]=spm_read_vols(strct);
[x y z] = ind2sub(size(M),1:length(M(:)));
XYZ=[x;y;z];

%% get images
% select in-mask voxels
XYZ=XYZ(:,M(:)>0);
XYZmm=XYZmm(:,M(:)>0);

% check dimensions and orientation of mask and first image
check=spm_vol(imagelist{1});
diff=abs(check.mat-strct.mat);
if sum(diff(:)>2)>0 || ~isequal(check.dim,strct.dim)
    error('Mask and images do not have the same orientation or dimension.')
end

% get data
TS=spm_get_data(imagelist,XYZ);









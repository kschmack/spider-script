clear;
sublist=[4:10,12:23,25:26,30:39];
exclude=[8,15,23,32,36];
sublist(ismember(sublist,exclude))=[];

for sub=sublist
    filelist{sub==sublist}=sprintf('/Volumes/ZIMTZICKE/spider/data/spi_mri_0_0%02.0f/searchlite/realign/s05waccmincha_invflo_vs_invspi_off_radius08mm_spi_mri_0_0%02.0f.nii\n',sub,sub);
end



center=[   15.0000   38.0000   17.0000]'; %50 -38 -14.8

radius=5/2;
for sub=1:length(sublist)
    
%     if sum(cellfun(@isstr,masklist))>1
%         strct=spm_vol(masklist{sub});
%         [M mxyzmm]=spm_read_vols(strct);
%         %     mxyzmm=mxyzmm(M~=0);
%         [x y z] = ind2sub(size(M),1:length(M(:)));
%         mxyz = [x;y;z];
%         mxyzmm=mxyzmm(:,M(:)~=0);
%         mxyz=mxyz(:,M(:)~=0);
%     else
        [x y z]=meshgrid(1:100,1:100,1:100);
        XYZ=[x(:)';y(:)';z(:)'];
        O=ones(1,length(XYZ));
        o =  (sum((XYZ-center*O).^2) <= radius^2);
        mxyz=XYZ(:,o);
        mxyzmm=[];
%     end
    % data
    Vim=spm_vol(filelist{sub});
    [T]=spm_get_data(Vim,mxyz);
    data{sub}=T;
    xyz{sub}=mxyz;
    xyzmm{sub}=mxyzmm;    
end
acc=cell2mat(data)'+50;
acc=reshape(cell2mat(data),171,26)
questfile=fullfile('..','spss','quest_cfs.xls');
[questdata questlegende]=xlsread(questfile);
questdata=questdata(ismember(questdata(:,1),sublist),:);
saf=questdata(:,strcmp(questlegende,'SAF'));


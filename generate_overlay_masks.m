direx={'/Volumes/ZIMTZICKE/spider/groupstat/25sub_no33no36/searchlight_realign_vector_rad08_smo03/vis/'};
    %'/Volumes/ZIMTZICKE/spider/groupstat/25sub_no33no36/loc/'}%,...
   % '/Volumes/ZIMTZICKE/spider/groupstat/25sub_no33no36/maineffects/invisiblestimuli/',...
   % '/Volumes/ZIMTZICKE/spider/groupstat/25sub_no33no36/maineffects/visiblestimuli/',...
   % '/Volumes/ZIMTZICKE/spider/groupstat/25sub_no33no36/maineffects/allstimuli/'};
images={'*05unc.img','*001unc.img','*05fwe.img'};
%images={'mask.img'};
mask={'fuslatmidocctemp_bilateral.nii','latmidocctemp_bilateral.nii','fus_bilateral.nii','temp.nii','occ.nii','occtemp.nii'};

for d=1:length(direx);
    for im=1:length(images);
        inim=dir(fullfile(direx{d},images{im}));
        Vi(1)=spm_vol(fullfile(direx{d},inim.name));
        for m=1:length(mask);
            Vi(2)=spm_vol(fullfile('/Volumes/ZIMTZICKE/spider/rawmask/',mask{m}));
            
            [a str1 c]=fileparts(mask{m});
            str1(strfind(str1,'_bilateral'):end)='';
            [a str2 c]=fileparts(inim.name);
            
            Vo.fname=fullfile('/Volumes/ZIMTZICKE/spider/mask/',sprintf('%s_%s_25SUB.nii',str1,str2));
            Vo.dim=Vi(1).dim;
            Vo.dt=Vi(1).dt;
            Vo.dt(1)=4;
            Vo.mat=Vi(1).mat;
            Vo.descrip='spm - algebra';
            
            flags{1}=[0];flags{2}=[0];flags{3}=[1];
            dmtx=0;
            f='i1.*i2';
            
            spm_imcalc(Vi,Vo,f,flags);
        end
    end
end
clear;
for subject=33:39;%[30];  %[4:7,9:10,12:19]
    names{1}='objects';onsets{1}=[]; durations{1}=[];
    names{2}='scrambled';onsets{2}=[]; durations{2}=[];
    
        
    %load resfile
    resname=['E:\spider\data\spi_mri_0_0' sprintf('%02.0f',subject)  '\behav\loc_mri_0_0' sprintf('%02.0f',subject) '.res'];
    s=load(resname);
    
    % cut off scanner trigger
    s(s(:,2)==0,:)=[];
    blockindex=s(find(abs([1;diff(s(:,1))])),1);
    blockstart=s(find(abs([1;diff(s(:,1))])),3);
    blockend=s(find(abs([diff(s(:,1));1])),3);
    blockdur=blockend-blockstart;
%     if abs(24400-blockdur>500)
%         error('Something''''s wrong!')
%     end
    blockstart=blockstart-blockstart(1);

    for k=1:2
        onsets{k}=blockstart(blockindex==k)./1000;
        durations{k}=blockdur(blockindex==k)./1000;
    end
    
    filename=(['E:\spider\data\spi_mri_0_0' sprintf('%02.0f',subject)  '\behav\behavloc_mri_0_0' sprintf('%02.0f',subject) '.mat']);
    save(filename, 'names', 'onsets', 'durations')
end

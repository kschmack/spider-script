strlist={'*-00141-000141-01.hdr','*-00141-000141-01.img','*-00142-000142-01.hdr','*-00142-000142-01.img'};
for subject=4:7;
    
    for run=1:8
        
        %load resfile
        s=load(['C:\Dokumente und Einstellungen\kschmack\Desktop\spider\data\spi_mri_0_00' num2str(subject) '\behav\spi_mri_0_00' num2str(subject) '_0' num2str(run) '.res']);
        scans=(s(end,4)-s(1,4))/2500;
        fprintf('Sub %d Run %d\t%d scans\n',subject,run,ceil(scans))
        %         rootpath=fullfile('C:','Dokumente und Einstellungen','kschmack',...
        %             'Desktop','spider','data',sprintf('spi_mri_0_0%02.0f',subject),...
        %             'fMRI',sprintf('run%02.0f',run));
        %         for str=strlist
        %         deletefile=dir(fullfile(rootpath,str{1}));
        %         deletepath=fullfile(rootpath,deletefile(1).name);
        %         delete(deletepath);
        %         end


    end
end
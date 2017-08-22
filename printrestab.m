choice = questdlg('Please choose an option for correction:','Mask selection',...
    'none','SVC','SVC');

switch choice
    case 'SVC'
        fid=fopen(fullfile('temp.txt'),'w');
        prv=pwd;
        fprintf(fid,'%s\n',SPM.swd)
        cd(['..' filesep 'rawmask']);
        %[files d] = uigetfile('*','Select the Maskfiles','MultiSelect','on');
        files={'26sub_no36p001.img','26sub_no36p05fwe.img','fus_bilateral.nii','latmidocctemp_bilateral.nii'};

        cd(prv);
        for f=1:length(files)
            mask=files{f};
            restab=ks_VOI(SPM,xSPM,hReg,fullfile(['..' filesep 'rawmask'],mask));
            fprintf(fid,'%s\n',restab.tit)
            sigindex=find(cellfun(@(x) x<.001,restab.dat(:,11)));
            for s=sigindex';
                fprintf(fid,[restab.fmt{1,9} '\t' restab.fmt{1,5} '\t' restab.fmt{1,7} '\t' restab.fmt{1,11} '\t' restab.fmt{1,end} '\n'],restab.dat{s,9}, restab.dat{s,5},restab.dat{s,7}, restab.dat{s,11}, restab.dat{s,end})
            end
        end
        
    case 'none'
        fid=fopen(fullfile('temp.txt'),'w');
        %labeltab = gin_det_dlabels_ks('List',xSPM,hReg,16,4);
        restab=ks_VOI(SPM,xSPM,hReg,fullfile(SPM.swd,'mask.img'));
        fprintf(fid,'%s\n',restab.tit)
        %sigindex=find(cellfun(@(x) x<.001,restab.dat(:,11)));
        sigindex=find(cellfun(@(x) x<.05,restab.dat(:,7)));

        for s=sigindex';
            fprintf(fid,[restab.fmt{1,9} '\t' restab.fmt{1,5} '\t' restab.fmt{1,7} '\t' restab.fmt{1,11} '\t' restab.fmt{1,end} '\t'],restab.dat{s,9}, restab.dat{s,5},restab.dat{s,7}, restab.dat{s,11}, restab.dat{s,end})
            [label distance]=gin_det_dlabels_ks(restab.dat{s,end});
            for l=1:length(label)
               fprintf(fid,'%s\t%2.2f',label(l).Nom,distance(l));
               if l<length(label);fprintf(fid,'\n\t\t\t\t\t\t');
               else fprintf(fid,'\n');
               end
            end
            %fprintf(fid,'\n');
%             clusterindex=find(cellfun(@(x)
%             isequal(x,restab.dat{s,end}),labeltab.dat(:,1)));
%             for c=clusterindex';
%                 fprintf(fid,[labeltab.fmt{2} '\t' labeltab.fmt{3} '\n'],labeltab.dat{c,2},labeltab.dat{c,3});
%                 fprintf(fid,'\t\t\t\t\t\t');
%             end
        end
        
end

fclose(fid)

fclose all;
% function main()
close all
clear all
load matchedrecords_healthy

% n_url='https://physionet.org/physiobank/database/mimic2wdb/RECORDS-neonates';
% n_records=strsplit(urlread(n_url));
% n_urld='https://physionet.org/physiobank/database/mimic2wdb/matched/s';

c={};

allpatients=cell(1,length(matchedrecords_healthy_numerics));


%1-5,12
%31,34,43,
for i=[1:19]%length(n_records)
    
    maxIter=200;
    
    if(isempty(find(i==[1,2,3,4,5,12,31,34,43])))   
        
        try
            %record=matchedsid_sepsis(i);
            
            %     recFile=urlread(strcat(n_urld,record,'/RECORDS'));%list of all files in record
            fprintf('patient %d \n',i)
            %     if ~isempty(strfind(recFile,'n'))
            %s23626/s23626-3444-08-16-12-35n
            
            info_n=wfdbdesc(strcat('/mimic2wdb/matched/',matchedrecords_healthy_numerics{i}));
            strcat('/mimic2wdb/matched/',matchedrecords_healthy_numerics{i})
            [tm_n,sig_n]=rdsamp(strcat('/mimic2wdb/matched/',matchedrecords_healthy_numerics{i}),[]);
            
            
            
            info=wfdbdesc(strcat('/mimic2wdb/matched/',matchedrecords_healthy_waveforms{i}));
            
            sigLength=info(1).LengthSamples;
            
            numIter=floor(sigLength/1E5);
            
            tic
            tm=[];
            sig=[];
            
            if numIter ~= 0
                for iter=1:numIter
                    try
                        [tm_temp,sig_temp]=rdsamp(strcat('/mimic2wdb/matched/',matchedrecords_healthy_waveforms{i}),[],1E5*iter,1E5*(iter-1)+1);
                        tm=[tm; tm_temp];
                        sig=[sig; sig_temp];
                    catch er
                        
                    end
                    
                    fprintf('iter=%d \n',iter)
                    %soundsc(ones(1,1000),1000)
                    if(iter>maxIter)
                        break
                    end
                end
                
                [tm_temp,sig_temp]=rdsamp(strcat('/mimic2wdb/matched/',matchedrecords_healthy_waveforms{i}),[],sigLength,1E5  *numIter+1);
                tm=[tm; tm_temp];
                sig=[sig; sig_temp];
                
            else
                [tm, sig]=rdsamp(strcat('/mimic2wdb/matched/',matchedrecords_healthy_waveforms{i}),[],sigLength);
            end
            
            toc
            
            patient_data=struct('sid',[],'Time_n',tm_n,'HR',[],'SpO2',[],'Resp_n',[],'NBP_sys',[],'NBP_dias',[], 'NBP_mean',[],'Time',tm,'II',[],'III',[],'V',[],'aVR',[],'Resp',[],'Pleth',[]);
            sidWhole=matchedrecords_healthy_numerics{i};
            patient_data.sid=sidWhole(1:6);
            CH=length(info_n);
            for ch=1:CH
                switch info_n(ch).Description
                    case 'HR'
                        patient_data.HR=sig_n(:,ch);
                    case 'SpO2'
                        patient_data.SpO2=sig_n(:,ch);
                    case 'RESP'
                        patient_data.Resp_n=sig_n(:,ch);
                    case 'NBP Sys'
                        patient_data.NBP_sys=sig_n(:,ch);
                    case 'NBP Dias'
                        patient_data.NBP_dias=sig_n(:,ch);
                    case 'NBP Mean'
                        patient_data.NBP_mean=sig_n(:,ch);
                end
            end
            
            
            CH=length(info);
            for ch=1:CH
                switch info(ch).Description
                    case 'II'%put v in later
                        patient_data.II=sig(:,ch);
                    case 'III'
                        patient_data.III=sig(:,ch);
                    case 'V'
                        patient_data.V=sig(:,ch);
                    case 'AVR'
                        patient_data.aVR=sig(:,ch);
                    case 'RESP'
                        patient_data.Resp=sig(:,ch);
                    case 'PLETH'
                        patient_data.Pleth=sig(:,ch);
                end
            end
            
            
            allpatients{i}=patient_data;
        catch err
            disp(err.identifier);
        end
    end
end
%end

save('PatientData_healthy_1to19','-v7.3')
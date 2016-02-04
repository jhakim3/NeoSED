function [HR,RR,HRV,RRV,SpO2] = metricExtract(patient)%patient is an individual patient

plethVec = patient.Pleth;
respVec = patient.Resp;

[~,plethLocs]=findpeaks(plethVec);
[~,respLocs]=findpeaks(respVec);

windowSize=100;
logVarPleth = formLogVarVec(plethLocs,windowSize);
logVarResp = formLogVarVec(respLocs,windowSize);

%filtering

%MAX CUTOFF VALUE is empirical
maxCutoff = 10;
processedPleth = applyFilter(logVarPleth,maxCutoff);
processedResp = applyFilter(logVarResp,maxCutoff);

HRV=processedPleth;
RRV=processedResp;


%%%%%Yu code

patient_SpO2=patient.SpO2;
window_size=5; 
SpO2_AAC=zeros(1,length(patient_SpO2)-2*window_size+1);
for i=window_size:length(patient.SpO2)-window_size
    max_SpO2=ones(length(window_size*2+1),1).*100;
    SpO2_AAC(i)=nansum(max_SpO2-patient_SpO2(i-window_size+1:i+window_size));
    
end


SpO2 = SpO2_AAC;
RR=patient.Resp_n;
HR=patient.HR;


%%%%%
end

function logVarVec = formLogVarVec(locs, windowSize)
    logVarVec=zeros(1,length(locs)-windowSize);
    for i=windowSize+1:length(locs)
        temp=zeros(1,length(windowSize));
        for j=i:-1:i-windowSize+1
            temp(i-j+1)=locs(j)-locs(j-1);
        end
        logVarVec(i)=log(var(temp));
    end

end

function filtered = applyFilter(logVarVec, threshold)
    filtered = logVarVec(logVarVec<threshold);
end
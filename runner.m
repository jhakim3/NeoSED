%% loading patient data
%load 'Patient_Data_final'

numPatients=length(allpatients_v3);

X=[];
L=[];
Y_patientwise=ones(1,numPatients);
Y_patientwise(10:20)=0;


Y=[];

for i=1:numPatients
    i
    [HR,RR,HRV,RRV,SpO2]=metricExtract(allpatients_v3{i});
    X_add=lengthEqualizer(HR,RR,HRV,RRV,SpO2);
    %X_add=[HR_le,RR_le,HRV_le,SpO2_le];
    X=[X X_add];
    HR_le=X_add(1,:);
    L_add=length(HR_le);
    L=[L L_add];
    Y_add=Y_patientwise(i)*ones(L_add,1);
    Y=[Y; Y_add];
end 



%% Fitting
[B,dev,stats] = glmfit(X',Y,'binomial');
Phat = 1./(1+exp(-[ones(size(X',1),1) X']*B));
[thresh] = test_performance(Phat, Y);


%% Testing
allpatients_test=cell(1,2);
j=0;
for i=4:5;
    j=j+1;
    allpatients_test{j}=allpatients_v3{i};
end

X_test=[];
L_test=[];
Y_test_patientwise=Y_patientwise(4:5);
Y_test=[];

for i=length(allpatients_test)
    [HR,RR,HRV,RRV,SpO2]=metricExtract(allpatients_test{i});
    X_add=lengthEqualizer(HR,RR,HRV,RRV,SpO2);
    %X_add=[HR_le,RR_le,HRV_le,SpO2_le];
    X_test=[X_test X_add];
    HR_le=X_add(1,:);
    L_add=length(HR_le);
    L_test=[L_test L_add];
    
    L_add=length(HR_le);
    L=[L L_add];
    Y_add=Y_test_patientwise(i)*ones(L_add,1);
    Y_test=[Y_test; Y_add];
end 

Phat_test = 1./(1+exp(-[ones(size(X_test',1),1) X_test']*B));



Phat_test_cell=mat2cell(Phat_test,L_test,1);
for k=1:length(L_test)
    Phat_test_patientwise(k)=mean(Phat_test_cell{k});
end

Y_test_patientwise_bestguess = Phat_test_patientwise>thresh;
Y_test_bestguess = Phat_test>thresh;

PercentCorrect = (1 - sum(abs(Y_test_patientwise-Y_test_patientwise_bestguess))/length(Y_test_patientwise))*100; 
%Sensitivity:
Sensitivity = sum(Y_test_patientwise.*Y_test_patientwise_bestguess)/sum(Y_test_patientwise);
%Specificity:
Specificity=sum(~Y_test_patientwise.*~Y_test_patientwise_bestguess)/sum(~Y_test_patientwise);
fprintf('Result: PercentCorrect %d\nSensitivity %d -- Specificity %d', PercentCorrect, Sensitivity,Specificity)
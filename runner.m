% loading patient data
%load 'Patient_Data_final'

numPatients=length(allpatients_v3);

X=[];
L=[];
Y_patientwise=ones(1,numPatients);
Y_patientwise(1:38)=0;

Y=[];

testlist=[4,5,14,15,16,17,18,19];

for i=1:65
%for i=36:41

    tic
    try
        [HR,HRV,SpO2]=metricExtract(allpatients_v3{i});
        X_add=lengthEqualizer(HR,HRV,SpO2);
        %X_add=[HR_le,RR_le,HRV_le,SpO2_le];
        X=[X X_add];
        HR_le=X_add(1,:);
        L_add=length(HR_le);
        L=[L L_add];
        Y_add=Y_patientwise(i)*ones(L_add,1);
        Y=[Y; Y_add];
    catch err
        disp(err.message)
    end
    
    fprintf('%d ',i);
    toc
end

X=X(1:2,:);


%% Fitting
[B,dev,stats] = glmfit(X',Y,'binomial');
Phat = 1./(1+exp(-[ones(size(X',1),1) X']*B));
[thresh] = test_performance(Phat, Y);


%% Testing


testlist=[37,38,39,40];


allpatients_test=cell(1,length(testlist));
j=0;
for i=testlist;
    j=j+1;
    allpatients_test{j}=allpatients_v3{i};
end

X_test=[];
L_test=[];
Y_test_patientwise=Y_patientwise(testlist);
Y_test=[];

patlengths=zeros(length(testlist),1);

for i=1:length(allpatients_test)
    try
        i
        [HR,HRV,SpO2]=metricExtract(allpatients_test{i});
        X_add=lengthEqualizer(HR,HRV,SpO2);
        %X_add=[HR_le,RR_le,HRV_le,SpO2_le];
        X_test=[X_test X_add];
        HR_le=X_add(1,:);
        L_add=length(HR_le);
        L_test=[L_test L_add];
        
        L_add=length(HR_le);
        L=[L L_add];
        Y_add=Y_test_patientwise(i)*ones(L_add,1);
        Y_test=[Y_test; Y_add];
        patlengths(i)=L_add;
    catch err
        disp(err.message)
    end
end

X_test=X_test(1:2,:);

Phat_test = 1./(1+exp(-[ones(size(X_test',1),1) X_test']*B));


j=1;
Phat_test_patientwise = zeros(length(testlist),1);
for i=1:length(testlist)
    
    j
    
    temp=Phat_test(j:j+patlengths(i)-1);
    
    Phat_test_patientwise(i)=nanmean(temp);
    j=patlengths(i)+1;
end

Phat_test_patientwise = Phat_test_patientwise';

Y_test_patientwise_bestguess = Phat_test_patientwise>thresh;
Y_test_bestguess = Phat_test>thresh;

PercentCorrect = (1 - sum(abs(Y_test_patientwise-Y_test_patientwise_bestguess))/length(Y_test_patientwise))*100;
%Sensitivity:
Sensitivity = sum(Y_test_patientwise.*Y_test_patientwise_bestguess)/sum(Y_test_patientwise);
%Specificity:
Specificity=sum(~Y_test_patientwise.*~Y_test_patientwise_bestguess)/sum(~Y_test_patientwise);
fprintf('Result: PercentCorrect %.0f\nSensitivity %.0f -- Specificity %.0f\n', PercentCorrect, Sensitivity,Specificity)

[~]=test_performance(Phat_test_patientwise,Y_test_patientwise);
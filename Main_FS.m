function []=Main_FS()
clear all;
clc;
[dataset,Targets]=choose_DS1( );
%%................normalize data....................
% data_mean=mean(input);
%  sigma11=sqrt(var(input,1));
%  input_1=bsxfun(@minus,input,data_mean);
%  dataset=bsxfun(@rdivide,input_1,sigma11);
%%.............................................. 

ds_1=dataset;
targets=Targets;
 %% ................reduction data ..................
  Gain_obj=fsInfoGain(ds_1,targets);
  weights=Gain_obj.W;
  [~,m]=sort(weights,'descend');
  index=m(1:7000);
  ds=ds_1(:,index);
      
       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%................... Cross Validation .................
 for r=1:20
[Fold]=DOB_SCV(ds,targets,5);
for i=1:5
    Train=[];
    mask=1:5;
    Test=Fold{i};
    mask(i)=0;
    mask=nonzeros(mask);
    for j=1:length(mask)
        Train=[Train,Fold{mask(j)}];
    end
    
    ds_Train=ds(Train,:);
    Targets_Train=targets(Train);
    ds_Test=ds(Test,:);
    Targets_Test=targets(Test);
    %%..............initial parameters............
    [n,d]=size(ds_Train);
    [~,sigma,V]=svd(ds_Train);
    H=sigma*V';
    teta=weights;
    W=rand(d,n);
    D_1=sqrt(diag(W'*W));
    D_2=1./D_1;
    D=diag(D_2);
    W_old=W*D;
    beta=10^6;
    max_iteration=100;
    iter=1;
    Data=ds_Train'*ds_Train;
    T=teta*teta';
    %%............................................
    while iter~=max_iteration
        iter=iter+1;
             
      S=Data*H'+beta*W_old-T*W_old;
      M= Data*W_old*H*H'+beta*(W_old*W_old'*W_old);
      F=S./M;
      W_new=F.*W_old;
      D_1=sqrt(diag(W_new'*W_new));
      D_2=1./D_1;
      D=diag(D_2);
      W_old=W_new*D;
      H=sigma*inv(X*W*sigma)X;
        
    end
    
    Candidates=sqrt(sum((W_new.^2),2));
    [~,Index]=sort(Candidates,'descend');
    Final_Subset=Index(1:n);
    R=size(Final_Subset);
    %%..................... Evaluation..................
    ds_train=ds_Train(:,Final_Subset);
    targets_train=Targets_Train;
    ds_test= ds_Test(:,Final_Subset);
    targets_test=Targets_Test;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
       [svm_acc(r,i),nb_acc(r,i),dt_acc(r,i),knn_acc(r,i),svm_sen(r,i),svm_spe(r,i),...
        nb_sen(r,i),nb_spe(r,i),dt_sen(r,i),dt_spe(r,i),knn_sen(r,i),knn_spe(r,i),...
        svm_gmean(r,i),nb_gmean(r,i),dt_gmean(r,i),knn_gmean(r,i)]=classifier...
        (ds_train,targets_train,ds_test,targets_test);
    end
    end
    svm=mean(mean(svm_acc));knn=mean(mean(knn_acc));dt=mean(mean(dt_acc));nb=mean(mean(nb_acc));
    svm_sen=mean(mean(svm_sen));knn_sen=mean(mean(knn_sen));dt_sen=mean(mean(dt_sen));nb_sen=mean(mean(nb_sen));
    svm_spe=mean(mean(svm_spe));knn_spe=mean(mean(knn_spe));dt_spe=mean(mean(dt_spe));nb_spe=mean(mean(nb_spe));
    svm_gmean=mean(mean(svm_gmean));knn_gmean=mean(mean(knn_gmean));dt_gmean=mean(mean(dt_gmean));nb_gmean=mean(mean(nb_gmean));
    
     result=({'KNN Classifier','SVM Classifier','D-Tree Classifier','After FS-Bayes Classifier';...
        knn,svm,dt,nb;...
        'knn_sen','knn_spe','svm_sen','svm_spe';...
        knn_sen,knn_spe,svm_sen,svm_spe;...
        'nb_sen','nb_spe','dt_sen','dt_spe';...
        nb_sen,nb_spe,dt_sen,dt_spe;...
        'knn_gmean','svm_gmean','nb_gmean','dt_gmean';...
        knn_gmean,svm_gmean,nb_gmean,dt_gmean;...
        'Features',size(dataset,2),'After-FS',R});
    xlswrite(strcat('classifier','.xlsx'),result);
end



function [svm_acc,knn_acc,dt_acc,nb_acc,svm_sen,svm_spe,knn_sen,knn_spe,nb_sen,nb_spe,dt_sen,dt_spe,svm_gmean,knn_gmean,nb_gmean,dt_gmean]=classifier(ds_train,targets_train,ds_test,targets_test)






%% SVM
svm_obj=fitcsvm(ds_train,targets_train);
svm_y=svm_obj.predict(ds_test);
obj_cp=classperf(targets_test,svm_y);
svm_acc=obj_cp.CorrectRate;
svm_sen=obj_cp.Sensitivity;
svm_spe=obj_cp.Specificity;
svm_gmean=sqrt(svm_sen*svm_spe);

%% KNN
knn_obj=fitcknn(ds_train,targets_train);
knn_y=knn_obj.predict(ds_test);
obj_cp=classperf(targets_test,knn_y);
knn_acc=obj_cp.CorrectRate;
knn_sen=obj_cp.Sensitivity;
knn_spe=obj_cp.Specificity;
knn_gmean=sqrt(knn_sen*knn_spe);


%% C45
dt_obj=fitctree(ds_train,targets_train);

dt_y=dt_obj.predict(ds_test);
obj_cp=classperf(targets_test,dt_y);
dt_acc=obj_cp.CorrectRate;
dt_sen=obj_cp.Sensitivity;
dt_spe=obj_cp.Specificity;
dt_gmean=sqrt(dt_sen*dt_spe);


%% Naive-Bayes

  O1 = fitcnb(ds_train,targets_train);
 C1 = O1.predict(ds_test);

 obj_cp=classperf(targets_test,C1);
nb_acc=obj_cp.CorrectRate;
nb_sen=obj_cp.Sensitivity;
nb_spe=obj_cp.Specificity;
nb_gmean=sqrt(nb_sen*nb_spe) ;
       


end

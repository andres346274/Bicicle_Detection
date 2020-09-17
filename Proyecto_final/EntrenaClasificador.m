function y = EntrenaClasificador(Xtrain, Xval, Ytrain, Yval)

    % Xtrain, Ytrain, Xval e Yval tienen que tener el mismo n�mero de filas
    Xtrain=Xtrain';
    Ytrain=Ytrain';
    Xval=Xval';
    Yval=Yval';

    % Modelo con 1 vecino 
    modelo_knn = fitcknn(Xtrain,Ytrain,'NumNeighbors',5,'Standardize',1);

    % Modelo con SVM
    modelo_svm = fitcsvm(Xtrain,Ytrain);

    % Comprobamos los modelos comparandolos con nuestra carpeta de
    % validacion para seleccionar el que seria el mejor modelo
    prediccion1=predict(modelo_knn,Xval');
    prediccion2=predict(modelo_svm,Xval');

    [~,~,~,AUC1] = perfcurve(Yval,prediccion1,1);
    [~,~,~,AUC2] = perfcurve(Yval,prediccion2,1);

    if AUC1 > AUC2
        y = model_knn;
    else
        y = model_svm;
    end

end

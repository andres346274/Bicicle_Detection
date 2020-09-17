% clasifica('/Users/mariainigo/Desktop/TDI/Proyecto_final/train','/Users/mariainigo/Desktop/TDI/Proyecto_final/validation','/Users/mariainigo/Desktop/TDI/Proyecto_final/test')
function y = clasifica(directorio_train,directorio_val,directorio_test)

%%% Lee directorios
Ims_train = dir([directorio_train,'/*.jpg']);
Ims_val = dir([directorio_val,'/*.jpg']);
Ims_test = dir([directorio_test, '/*.jpg']); 

%%% Obtener descriptores para imagenes de entrenamiento
Xtrain=ones(4,length(Ims_train));
Ytrain=ones(1,length(Ims_train));
Xval=ones(4,length(Ims_val));
Yval=ones(1,length(Ims_val));
Xtest=ones(4,length(Ims_test));

% Leemos las imagenes del directorio Im_train
for i=1:length(Ims_train)  
    %%% Lee imagen
    M = imread([directorio_train '/'  Ims_train(i).name]);

        %%% Extraccion de caracteristicas.
     	Xtrain(:,i)= ExtraeCaracteristicas(M);

        % Hallamos si pertenecen a nuestro directorio 
        TF=contains([directorio_train Ims_train(i).name],'146_');

        if TF==1
             Ytrain(i)=1;
        else
             Ytrain(i)=-1;
        end
end

for i=1:size(Xtrain)
    Xtrain(i,:)=Xtrain(i,:)/norm(Xtrain(i,:));
    Xtrain(i,:)=(Xtrain(i,:)*2-1);
end

% Normalizacion de matrices de caracteristicas
for i=1:length(Ims_test)
    M = imread([directorio_test '/' Ims_test(i).name]);
    Xtest(:,i) = ExtraeCaracteristicas(M);
end
for i=1:size(Xtest)
    Xtest(i,:)=Xtest(i,:)/norm(Xtest(i,:));
    Xtest(i,:)=(Xtest(i,:)*2-1);
end
 
% Diagramas de dispersion
DiagramaDeDispersion(Xtrain,Ytrain);

% Leemos las imagenes del directorio Im_val
for i=1:length(Ims_val)  
    %%% Lee imagen
    M = imread([directorio_val '/'  Ims_val(i).name]);

        %%% Extraccion de caracteristicas.
     	Xval(:,i)= ExtraeCaracteristicas(M);

        % Hallamos si pertenecen a nuestro directorio 
        TF=contains([directorio_val Ims_val(i).name],'146_');

        if TF==1
             Yval(i)=1;
        else
             Yval(i)=-1;
        end
end

for i=1:size(Xval)
    Xtrain(i,:)=Xtrain(i,:)/norm(Xtrain(i,:));
    Xtrain(i,:)=(Xtrain(i,:)*2-1);
end

%%% Entrenar el clasificador
 modelo = EntrenaClasificador(Xtrain, Xval, Ytrain, Yval); 
 
%%% Obtener descriptores para ima�genes de test
 for i=1:length(Ims_test)  
    %%% Lee imagen
    M = imread([directorio_test '/' Ims_test(i).name]);
    pattern ='.';
    TF = startsWith(M,pattern);
    if TF~=1
    	%%% Extraccion de caracteristicas.
    	Xtest(:,i) = ExtraeCaracteristicas(rotate_M);
    end
end
 
 %%% Aplicar el clasificador
y = Clasificacion(Xtest,modelo,Ytrain); 
end


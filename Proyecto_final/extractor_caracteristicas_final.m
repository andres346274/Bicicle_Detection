clear all
close all
clc

 I = imread('033_0015.jpg');
 I = im2double(I);
 figure('Name','imagen original');
 imshow(I);
 
 % Compruebo el tamaño de mi imagen para determinar si esta en blanco y negro y RGB
 size_image = size(I);
 if length(size_image)==3
    gray_image_I = rgb2gray(I);
 else
    gray_image_I = I;
 end
 
 % Quito el posible ruido de mi imagen 
 h = fspecial('gaussian');
 gray_image_gaussian_I = imfilter(gray_image_I, h);
 
 % Alineamos la imagen con los ejes
 rotate_I = imrotate(gray_image_gaussian_I,-1,'bilinear','crop');
 figure('Name','imagen a nivel de grises');
 imshow(gray_image_gaussian_I);
 figure('Name','imagen orientada');
 imshow(rotate_I); 
 
 % Definir bordes, pero primero aplico un Ostu para eliminar bordes
 % innecesarios del fondo de la imagen
 level_image= graythresh(rotate_I);
 OtsuBW=im2bw(rotate_I,level_image);
 border_I = edge(OtsuBW,'canny');
 
 % Dilato la imagen para juntar los posibles huecos en las lineas
 dilate_operator_1 = strel('square',2);
 B = imdilate(border_I,dilate_operator_1);
 figure('Name','bordes dilatados');
 imshow(border_I);
 
% Defino la imagen que vamos a usar, simplemente por si la cambiamos que baste con unicamente cambiar este valor.
imagen_usada_circulos = B;
 
% Detectar circulos
[centers, radii, metric] = imfindcircles(imagen_usada_circulos,[20 600],'Method','twostage','Sensitivity',0.80);
[rad_x,rad_y] = size(radii);
f1=rad_x;
figure('Name','Circulos en la imagen');
imshow(imagen_usada_circulos,[])
viscircles(centers, radii,'EdgeColor','b');
% Imagen utilizada:
image_radios = gray_image_I;

% Tamaño de ruedas parecido
    centro_1=[0 0];
    centro_2=[0 0];
    f2=0;
   for r1=1:length(radii)
        for r2=1:length(radii)
            distancia_puntos = sqrt((centers(r1,1)-centers(r2,1))^2 + (centers(r1,2)-centers(r2,2))^2);
            if(radii(r1,1)*0.7<radii(r2,1) && radii(r2,1)<radii(r1,1)*1.3)&&((centers(r1,1)~=centers(r2,1))||(centers(r1,2)~=centers(r2,2))) %&& (radii(r1,1)>size_image(1,2)) && (radii(r2,1)>size_image(1,2)))
                if((distancia_puntos>(0.8*4*radii(r2,1))) && (distancia_puntos<(1.2*4*radii(r2,1))))
                    centro_1 = centers(r1,:);
                    centro_2 = centers(r2,:);
                    diferencia = sqrt((centro_1(1,1)-centro_2(1,1))^2+(centro_1(1,2)-centro_2(1,2))^2);
                    f2=diferencia;
                end
            end
        end
    end
% Buscamos que el tamaño de las ruedas se parezca
centro_1=[0 0];
centro_2=[0 0];
f3 = 0;
%meteremos una condicion de numero de ruedas detectado para el caso de que
%nos detecte la condicion de las ruedas, que solo nos diga que tenemos 2
%circulos, los detectados como ruedas, sino, simplemente pondra esta
%variable como todos los circulos detectados.
numero_de_ruedas_detectado = 0;
for r1=1:length(radii)
   for r2=1:length(radii)
       distancia_puntos = sqrt((centers(r1,1)-centers(r2,1))^2 + (centers(r1,2)-centers(r2,2))^2);
        if(radii(r1,1)*0.7<radii(r2,1) && radii(r2,1)<radii(r1,1)*1.3)&&((centers(r1,1)~=centers(r2,1))||(centers(r1,2)~=centers(r2,2))) %&& (radii(r1,1)>size_image(1,2)) && (radii(r2,1)>size_image(1,2)))
            if((distancia_puntos>(0.8*4*radii(r2,1))) && (distancia_puntos<(1.2*4*radii(r2,1))))
            centro_1 = centers(r1,:);
            centro_2 = centers(r2,:);
            distancia_puntos_final = distancia_puntos;
            r1_cogido = r1;
            r2_cogido = r2;
            f3 = sqrt((centro_1(1,1)-centro_2(1,1))^2+(centro_1(1,2)-centro_2(1,2))^2);
            numero_de_ruedas_detectado = 2;
            f1=numero_de_ruedas_detectado;
            end
        end
   end
end
if numero_de_ruedas_detectado~=2
    numero_de_ruedas_detectado = rad_x;
end
if numero_de_ruedas_detectado>1
radii = [radii(r1_cogido,1);radii(r2_cogido,1)];
centers = [centers(r1_cogido,:);centers(r2_cogido,:)];
angulo_centros = atand((centro_1(1,2)-centro_2(1,2))/(centro_1(1,1)-centro_2(1,1)));
xy_x = [centro_1(1,1) centro_2(1,1)];
xy_y = [centro_1(1,2) centro_2(1,2)];
figure('Name','segmento que une las ruedas');
imshow(imagen_usada_circulos);
hold on;
plot(xy_x,xy_y,'LineWidth',2,'Color','green');
hold off
end

% Deteccion de radios:
%defino un array (o matriz) donde se me guardara el numero de lineas detectado por
%cada rueda o circunferencia en caso de que no solo medetecte dos ruedas, y
%luego hare la media entre todos sus valores para detectar en numero de
%lineas medio por circunferencia y asi deteminar si se trata de radios o
%no.
array_lineas = zeros(1,numero_de_ruedas_detectado);
for p=1:numero_de_ruedas_detectado
    % Fragmentar la imagen:
    center_J_x = centers(p,1)-radii(p,1);
    center_J_y = centers(p,2)-radii(p,1);
    J = imcrop(image_radios,[center_J_x center_J_y radii(p,1)*2 radii(p,1)*2]);
    J = imresize(J, 5, 'nearest');
    for i=1:100 
        J = medfilt2(J);
    end
    figure('Name','circulos cortados');
    imshow(J,[]);

    % Bordes de las ruedas
    J = imfilter(J, h);
    J = edge(J,'canny');
    dilate_operator_2 = strel('square',5);
    J = imdilate(J,dilate_operator_2);

    figure('Name','bordes de las ruedas dilatados');
    imshow(J);

    % Hough
    [H,T,R] = hough(J);

    % Imprimimos la transformada de Hough
    figure('Name','transformada de Hough de las ruedas');
    imshow(H,[],'XData',T,'YData',R,...
                'InitialMagnification','fit');
     xlabel('\theta'), ylabel('\rho');
     hold on;
     P  = houghpeaks(H,20,'threshold',ceil(0.3*max(H(:))));
     x = T(P(:,2)); y = R(P(:,1));
     plot(x,y,'s','color','white');
     axis on, axis normal, hold on;

    lines = houghlines(J,T,R,P,'FillGap',40,'MinLength',7);
    figure('Name','lineas de hough'); 
    imshow(J); 
    array_lineas(1,p) = length(lines);
    hold on;
    max_len = 0;
   
    for k = 1:length(lines)
       xy = [lines(k).point1; lines(k).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

       % Principios y finales de las lineas
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

       % Vertices del segmento mas grande
       len = norm(lines(k).point1 - lines(k).point2);
       if ( len > max_len)
          max_len = len;
          xy_long = xy;
       end
    end
end
%Ahora calculo la media de todas las lineas detectadas en ruedas o
%circunferencias.
numero_total_de_lineas = 0;
for k=1:numero_de_ruedas_detectado
numero_total_de_lineas = numero_total_de_lineas + array_lineas(1,k);
end
media_de_numero_lineas = numero_total_de_lineas/numero_de_ruedas_detectado;
% Ahora buscare las lineas que esten entre 35 y 55 o -35 y 55 grados con respecto a la linea entre las dos ruedas detectada anteriormente
[H,T,R] = hough(imagen_usada_circulos);

% Imprimimos la transformada de Hough
figure('Name','imagen con las ruedas');
imshow(H,[],'XData',T,'YData',R,...
            'InitialMagnification','fit');
 xlabel('\theta'), ylabel('\rho');
 hold on;
 P  = houghpeaks(H,20,'threshold',ceil(0.3*max(H(:))));
 x = T(P(:,2)); 
 y = R(P(:,1));
 plot(x,y,'s','color','white');
axis on, axis normal, hold on;

lines = houghlines(imagen_usada_circulos,T,R,P,'FillGap',40,'MinLength',7);
figure('Name','hough de la imagen con las ruedas');
imshow(imagen_usada_circulos);
hold on;
max_len = 0;
contador_lineas_angulo = 0;
for k = 1:length(lines)
    angulo_cuerpo_bici = lines(k).theta-angulo_centros;
    angulo_curepo_bici = abs(angulo_cuerpo_bici);
    if (angulo_cuerpo_bici>180)
        angulo_cuerpo_bici = 360 - angulo_cuerpo_bici;
    end
    %Meto una condicion para que me limite el angulo de las rectas:
    if ((angulo_cuerpo_bici>=-55 && angulo_cuerpo_bici<=-35) || (angulo_cuerpo_bici>=35 && angulo_cuerpo_bici<=55))
       xy = [lines(k).point1; lines(k).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
       
       % Grafica de los principios y finales de linea
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

       % Determine the endpoints of the longest line segment
       len = norm(lines(k).point1 - lines(k).point2);
       if (len > max_len)
          max_len = len;
          xy_long = xy;
       end
       contador_lineas_angulo = contador_lineas_angulo + 1;
       f4=contador_lineas_angulo;
    end
end


f2=length(lines);
cvmt = [f1; f2; f3; f4];
normalize=cvmt/norm(cvmt);
 % vector caracteristicas: v=[f1;f2;f3;f3]
clear all
close all
clc

 M = imread('146_0064.jpg');
    M = im2double(M);
    % Compruebo el tamaño de mi imagen para determinar si esta en blanco y negro y RGB
    size_image = size(M);
    if length(size_image)==3
        gray_image_M = rgb2gray(M);
    else
        gray_image_M = M;
    end
    % Quito el posible ruido de mi imagen 
    h = fspecial('gaussian');
    gray_image_gaussian_M = imfilter(gray_image_M, h);
    % Alineamos la imagen con los ejes
    imagen = imrotate(gray_image_gaussian_M,-1,'bilinear','crop');
    
    % Definir bordes, pero primero aplico un Ostu para eliminar bordes innecesarios del fondo de la imagen
    level_image= graythresh(imagen);
    OtsuBW=im2bw(imagen,level_image);
    border_I = edge(OtsuBW,'canny');

    % Dilato la imagen para juntar los posibles huecos en las lineas
    dilate_operator_1 = strel('square',2);
    I_dilated = imdilate(border_I,dilate_operator_1);

    % Detectar circulos de ruedas
    [centers, radii, ~] = imfindcircles(I_dilated,[20 600],'Method','twostage','Sensitivity',0.80);
    [rad_x,~] = size(radii);
    numero_de_ruedas_detectado = rad_x;
    
 
    
    % Tamaño de ruedas parecido
    centro_1=[0 0];
    centro_2=[0 0];
    diferencia=0;
    % Meteremos una condicion de numero de ruedas detectado para el caso de que nos detecte la condicion de las ruedas, que solo nos diga que tenemos 2 circulos, los detectados como ruedas, sino, simplemente pondra esta variable como todos los circulos detectados.
    r1_cogido=1;
    r2_cogido=1;
    detecta_dos_ruedas=0;
    numero_de_ruedas_detectado=0;
  if(length(centers)~=0)
    for r1=1:length(radii)
        for r2=1:length(radii)
            distancia_puntos = sqrt((centers(r1,1)-centers(r2,1))^2 + (centers(r1,2)-centers(r2,2))^2);
            if(radii(r1,1)*0.7<radii(r2,1) && radii(r2,1)<radii(r1,1)*1.3)&&((centers(r1,1)~=centers(r2,1))||(centers(r1,2)~=centers(r2,2))) %&& (radii(r1,1)>size_image(1,2)) && (radii(r2,1)>size_image(1,2)))
                if((distancia_puntos>(0.8*4*radii(r2,1))) && (distancia_puntos<(1.2*4*radii(r2,1))))
                    centro_1 = centers(r1,:);
                    centro_2 = centers(r2,:);
                    r1_cogido = r1;
                    r2_cogido = r2;
                    diferencia = r1/r2;
                    numero_de_ruedas_detectado = 2;
                    detecta_dos_ruedas=1;
                end
            end
        end
    end
    if numero_de_ruedas_detectado~=2
        numero_de_ruedas_detectado = rad_x;
    end
    if detecta_dos_ruedas==1
        radii = [radii(r1_cogido,1);radii(r2_cogido,1)];
        centers = [centers(r1_cogido,:);centers(r2_cogido,:)];
        angulo_centros = atand((centro_1(1,2)-centro_2(1,2))/(centro_1(1,1)-centro_2(1,1))); 
    end
  end
    
    % Detectar radios:
    %defino un array (o matriz) donde se me guardara el numero de lineas detectado por cada rueda o circunferencia en caso de que no solo medetecte dos ruedas, y luego hare la media entre todos sus valores para detectar en numero de lineas medio por circunferencia y asi deteminar si se trata de radios o no.
    array_lineas = ones(1,numero_de_ruedas_detectado);
    media_de_numero_lineas=0;
    if(length(centers)~=0)
    for p=1:numero_de_ruedas_detectado
        % Fragmentar la imagen por radios:
        center_J_x = centers(p,1)-radii(p,1);
        center_J_y = centers(p,2)-radii(p,1);
        J = imcrop(imagen,[center_J_x center_J_y radii(p,1)*2 radii(p,1)*2]);
        J = imresize(J, 5, 'nearest');
        for i=1:100 
            J = medfilt2(J);
        end
        
        % Bordes de las ruedas
        h = fspecial('gaussian');
        J = imfilter(J, h);
        J = edge(J,'canny');
        dilate_operator_2 = strel('square',5);
        J = imdilate(J,dilate_operator_2);        
        
        % Radios de las ruedas
        [H,T,R] = hough(J);
        P  = houghpeaks(H,20,'threshold',ceil(0.3*max(H(:))));
        lines = houghlines(J,T,R,P,'FillGap',40,'MinLength',7); 
        array_lineas(1,p) = length(lines);
    end
    
    %Ahora calculo la media de todas las lineas detectadas en ruedas o circunferencias.
    numero_total_de_lineas = 0;
    for k=1:numero_de_ruedas_detectado
        numero_total_de_lineas = numero_total_de_lineas + array_lineas(1,k);
    end
    media_de_numero_lineas = numero_total_de_lineas/numero_de_ruedas_detectado;
    end

    % Cuerpo de la bici y segmento que une los centros a 35º-55º o -35º-55º 
    contador_lineas_angulo=0;
    if(length(centers)~=0)
    if (detecta_dos_ruedas == 1)
        [H,T,R] = hough(I_dilated);
        P  = houghpeaks(H,20,'threshold',ceil(0.3*max(H(:))));
        lines = houghlines(I_dilated,T,R,P,'FillGap',40,'MinLength',7);
        for k = 1:length(lines)
            angulo_cuerpo_bici = lines(k).theta - angulo_centros;
            angulo_cuerpo_bici = abs(angulo_cuerpo_bici);
            if (angulo_cuerpo_bici>180)
                angulo_cuerpo_bici = 360 - angulo_cuerpo_bici;
            end
            % Condicion para que se limite el angulo de las rectas
            if (((angulo_cuerpo_bici)>=-55)&&((angulo_cuerpo_bici)<=-35)) || (((angulo_cuerpo_bici)>=35)&&((angulo_cuerpo_bici)<=55))
                contador_lineas_angulo = contador_lineas_angulo + 1;
            end
        end
    end
    end
    y=[numero_de_ruedas_detectado; media_de_numero_lineas; contador_lineas_angulo];
%     for k=1:length(y')
%          y(k)=y(k)/norm(y(k)); % Normalizacion de 0 a 1
%          y(k)=(y(k)*2)-1;
%     end    % Normalizacion de -1 a 1
    

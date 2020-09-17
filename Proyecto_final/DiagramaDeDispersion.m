function [x_si,x_no] = DiagramaDeDispersion(Xtrain,Ytrain)
features_ydxs = [1,2];
cont_si = 1;
cont_no = 1;
Xtrain_si=zeros(4,1);
Xtrain_no=zeros(4,1);

 for i=1:length(Xtrain)
    if Ytrain(i)>=0
            Xtrain_si(:,cont_si) = Xtrain(:,i);
            cont_si = cont_si + 1;
    else 
           Xtrain_no(:,cont_no) = Xtrain(:,i);
           cont_no = cont_no + 1;
    end
 end
 
 if length(features_ydxs) == 2
     %Xtrain_si = Xtrain_si(1, :);
     figure
     scatter(Xtrain_si(1,:), Xtrain_si(2, :), 'b*');
     hold on
    % Xtrain_no = Xtrain_no(features_ydxs, :);
     scatter(Xtrain_no(1, :), Xtrain_no(2, :), 'r*');

 x_si = Xtrain_si;
 x_no = Xtrain_no;
 
     %Xtrain_si = Xtrain_si(1, :);
     figure
     scatter(Xtrain_si(1,:), Xtrain_si(3, :), 'b*');
     hold on
    % Xtrain_no = Xtrain_no(features_ydxs, :);
     scatter(Xtrain_no(1, :), Xtrain_no(3, :), 'r*');

       figure
     %Xtrain_si = Xtrain_si(1, :);
     scatter(Xtrain_si(1,:), Xtrain_si(4, :), 'b*');
     hold on
    % Xtrain_no = Xtrain_no(features_ydxs, :);
     scatter(Xtrain_no(1, :), Xtrain_no(4, :), 'r*');
 
      figure
     %Xtrain_si = Xtrain_si(1, :);
     scatter(Xtrain_si(2,:), Xtrain_si(3, :), 'b*');
     hold on
    % Xtrain_no = Xtrain_no(features_ydxs, :);
     scatter(Xtrain_no(2, :), Xtrain_no(3, :), 'r*');
 
      figure
     %Xtrain_si = Xtrain_si(1, :);
     scatter(Xtrain_si(2,:), Xtrain_si(4, :), 'b*');
     hold on
    % Xtrain_no = Xtrain_no(features_ydxs, :);
     scatter(Xtrain_no(2, :), Xtrain_no(4, :), 'r*');
   
      figure
     %Xtrain_si = Xtrain_si(1, :);
     scatter(Xtrain_si(3,:), Xtrain_si(4, :), 'b*');
     hold on
    % Xtrain_no = Xtrain_no(features_ydxs, :);
     scatter(Xtrain_no(3, :), Xtrain_no(4, :), 'r*');
  
 end
end
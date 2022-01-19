clc;close all;clear all

%% Opening and syncronizing the data
% Open generated labels
[time, label]=xlsread('C:\Your route');
label = string(label);
% Open raw sensors data
[datos]=csvread('C:\Your route'); 
%Synchronization
delay_sub1 = 0.666 - 88.61 ;
delay_sub2 = 2.516 - 19.91; 
delay_sub3 = 2.704 - 43.13;
st_sub1 = 8796;
st_sub3 = 4044;
st_sub2 = 1732;
tiempo = datos(:,1)/1000 - datos(1,1)/1000+delay_sub2;
%tiempo = tiempo(975:end);
datos(:,1) = tiempo;
c_datos = datos(st_sub2:60000,:);

%% Interpolate the generated labels
sz_pose = length(time);
new_lab = [];
k=1;
for i=2:sz_pose
    if (label(i-1)~=label(i)) | (i == sz_pose)
        while c_datos(k,1) <= time(i-1)
            new_lab =[new_lab;label(i-1)];
            k = k + 1;
        end
    end
end
parfor j=k:length(c_datos(:,1))
    new_lab =[new_lab; 'NC'];
end

%% Exploring the raw data

limx = [pre_data(6135,1) pre_data(6411,1)];
% Aceleracion
figure;
title("Accelerometer data")
subplot(3,1,1)
plot(tiempo, c_datos(:,2))
title("X")
%xlim(limx)

subplot(3,1,2)
plot(tiempo, datos(:,3))
title("Y")
%xlim(limx)

subplot(3,1,3)
plot(tiempo, c_datos(:,4))
title("Z")
%xlim(limx)
xlabel("Time")
ylabel("Acceleration [m/s]")

% Right Patella data

figure;
plot(c_datos(:,1), c_datos(:,16))
hold on
plot(c_datos(:,1), c_datos(:,15))
xlim([149.346 152])
ylim([1500 5000])
xlabel("Time [s]")
ylabel("Electrical resistance [ohms]")

lin1 = xline(149.994,'--k','Left step');
lin2 = xline(150.626,'--k','Right step / First stride');
lin1.FontSize = 16;
lin2.FontSize = 16;
legend("Right Patella","Left Patella")


%% Armar los datos y guardarlos 
niu_datos = c_datos;
niu_datos = [niu_datos new_lab];
writematrix(niu_datos, "yourroute\Nuevos_sub3.txt")

%% Delete NC 
% The label NC means Not consider, and they're deleted from the raw data 
sz_nlab = size(new_lab);
new_data = [];
new_label = [];
for i=1:sz_nlab
    if (new_lab(i) ~= 'NC') 
        new_data = [new_data; c_datos(i,:)];
        new_label = [new_label; new_lab(i)];
    end
end

%% Preprocessing
% In this section the outliers are replaced, data is normalized between 1 
% and 0, data is filtered and the instances with absent data are deleted too
tic
[pre_data, pre_label] = ausentes_out(c_datos, new_lab);
toc
pre_data2 = outliers_out(pre_data);
pre_data2f = filter_data(pre_data2);
pre_data3 = data_norm(pre_data2f); 

%% Showing preprocessed

limx = [pre_data3(6135,1) pre_data3(6411,1)];
% Aceleracion
figure;
title("Accelerometer data")
subplot(3,1,1)
plot(pre_data3(:,1), pre_data3(:,2))
title("X")
xlim(limx)

subplot(3,1,2)
plot(pre_data3(:,1), pre_data3(:,3))
title("Y")
xlim(limx)

subplot(3,1,3)
plot(pre_data3(:,1), pre_data3(:,4))
title("Z")
xlim(limx)
xlabel("Time")
ylabel("Acceleration [m/s]")

% Sensor de presion rotula derecha

figure;

subplot(2,1,1)
plot(pre_data3(:,1), pre_data3(:,21))
title("Right Patella")
xlim(limx)
subplot(2,1,2)
plot(pre_data3(:,1), pre_data3(:,20))
title("Left Patella")
xlim(limx)

xlabel("Time")
ylabel("Electrical Resistance [ohms]")

%% Saving preprocessed data
niu_datos = [pre_data3 pre_label];
writematrix(niu_datos, "yourroute\sub3_filtrados.txt")
imu_filtrados = [pre_data3(:,1:11) pre_label];
writematrix(imu_filtrados, "yourroute\sub3_imuf.txt")
text_filtrados = [pre_data3(:,[1,12:21]) pre_label];
writematrix(text_filtrados, "yourroute\sub3_textf.txt")

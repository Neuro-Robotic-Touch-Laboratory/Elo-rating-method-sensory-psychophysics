close all;
clear all;
clc;

[y,Fs] = audioread('New Folder\3sec_AAd_41-28_43-98.wav');
[y2,Fs2] = audioread('D:\Muzica\Hits Sound Season Top 100 September-2014\42. Oliver Heldens - Koala (Original Mix).mp3');
t = linspace(0, size(y,1)-1, size(y,1))/Fs;
t2 = linspace(0, size(y2,1)-1, size(y2,1))/Fs2;
figure
subplot(2,1,1)
plot(t2, y2(:,1))
title('L Ch')
grid
subplot(2,1,2)
plot(t2, y2(:,2))
title('R Ch')
grid
xlabel('Time (s)')
sgtitle('Original')


y_no_clicks = y;
y_no_clicks(1:5000,1)=y(1:5000,1)'.*(2.^[-10:0.002:-0.002]);
y_no_clicks(end-4999:end,1)=y(end-4999:end,1)'.*(2.^[-0.002:-0.002:-10]);
y_no_clicks(1:5000,2)=y(1:5000,2)'.*(2.^[-10:0.002:-0.002]);
y_no_clicks(end-4999:end,2)=y(end-4999:end,2)'.*(2.^[-0.002:-0.002:-10]);

%funziona ma allunga più del necessario
% y_no_clicks2(:,1)=[y_no_clicks(:,1); y2(end-52605:end,2)];
% y_no_clicks2(:,2)=[y_no_clicks(:,2); y2(end-52605:end,2)];
%funziona con lunghezza minima, però dipende da una canzone mia
% y_no_clicks2(:,1)=[y_no_clicks(:,1); y2(11660000:11680000,1)];
% y_no_clicks2(:,2)=[y_no_clicks(:,2); y2(11660000:11680000,1)];
%funziona anche solo con gli zeri, tanto meglio
y_no_clicks2(:,1)=[y_no_clicks(:,1); zeros(20000,1)];
y_no_clicks2(:,2)=[y_no_clicks(:,2); zeros(20000,1)];

audiowrite('3sec_41-28_43-98_46-38_55-02_61-86\3sec_AAd_41-28_43-98.wav',y_no_clicks2,Fs);

figure
subplot(2,1,1)
plot(t, y_no_clicks(:,1))
title('L Ch')
grid
subplot(2,1,2)
plot(t, y_no_clicks(:,2))
title('R Ch')
grid
xlabel('Time (s)')
sgtitle('After ‘filloutliers’')


%%

[y,Fs] = audioread('New Folder\3sec_AB_41-28_46-38.wav');
t = linspace(0, size(y,1)-1, size(y,1))/Fs;


y_no_clicks = y;
y_no_clicks(1:5000,1)=y(1:5000,1)'.*(2.^[-10:0.002:-0.002]);
y_no_clicks(end-4999:end,1)=y(end-4999:end,1)'.*(2.^[-0.002:-0.002:-10]);
y_no_clicks(1:5000,2)=y(1:5000,2)'.*(2.^[-10:0.002:-0.002]);
y_no_clicks(end-4999:end,2)=y(end-4999:end,2)'.*(2.^[-0.002:-0.002:-10]);

y_no_clicks2(:,1)=[y_no_clicks(:,1); zeros(20000,1)];
y_no_clicks2(:,2)=[y_no_clicks(:,2); zeros(20000,1)];

audiowrite('3sec_41-28_43-98_46-38_55-02_61-86\3sec_AB_41-28_46-38.wav',y_no_clicks2,Fs);

figure
subplot(2,1,1)
plot(t, y_no_clicks(:,1))
title('L Ch')
grid
subplot(2,1,2)
plot(t, y_no_clicks(:,2))
title('R Ch')
grid
xlabel('Time (s)')
sgtitle('After ‘filloutliers’')


%%

[y,Fs] = audioread('New Folder\3sec_AD_41-28_55-02.wav');
t = linspace(0, size(y,1)-1, size(y,1))/Fs;


y_no_clicks = y;
y_no_clicks(1:5000,1)=y(1:5000,1)'.*(2.^[-10:0.002:-0.002]);
y_no_clicks(end-4999:end,1)=y(end-4999:end,1)'.*(2.^[-0.002:-0.002:-10]);
y_no_clicks(1:5000,2)=y(1:5000,2)'.*(2.^[-10:0.002:-0.002]);
y_no_clicks(end-4999:end,2)=y(end-4999:end,2)'.*(2.^[-0.002:-0.002:-10]);

y_no_clicks2(:,1)=[y_no_clicks(:,1); zeros(20000,1)];
y_no_clicks2(:,2)=[y_no_clicks(:,2); zeros(20000,1)];

audiowrite('3sec_41-28_43-98_46-38_55-02_61-86\3sec_AD_41-28_55-02.wav',y_no_clicks2,Fs);

figure
subplot(2,1,1)
plot(t, y_no_clicks(:,1))
title('L Ch')
grid
subplot(2,1,2)
plot(t, y_no_clicks(:,2))
title('R Ch')
grid
xlabel('Time (s)')
sgtitle('After ‘filloutliers’')



%%

[y,Fs] = audioread('New Folder\3sec_AE_41-28_61-86.wav');
t = linspace(0, size(y,1)-1, size(y,1))/Fs;


y_no_clicks = y;
y_no_clicks(1:5000,1)=y(1:5000,1)'.*(2.^[-10:0.002:-0.002]);
y_no_clicks(end-4999:end,1)=y(end-4999:end,1)'.*(2.^[-0.002:-0.002:-10]);
y_no_clicks(1:5000,2)=y(1:5000,2)'.*(2.^[-10:0.002:-0.002]);
y_no_clicks(end-4999:end,2)=y(end-4999:end,2)'.*(2.^[-0.002:-0.002:-10]);

y_no_clicks2(:,1)=[y_no_clicks(:,1); zeros(20000,1)];
y_no_clicks2(:,2)=[y_no_clicks(:,2); zeros(20000,1)];


audiowrite('3sec_41-28_43-98_46-38_55-02_61-86\3sec_AE_41-28_61-86.wav',y_no_clicks2,Fs);

figure
subplot(2,1,1)
plot(t, y_no_clicks(:,1))
title('L Ch')
grid
subplot(2,1,2)
plot(t, y_no_clicks(:,2))
title('R Ch')
grid
xlabel('Time (s)')
sgtitle('After ‘filloutliers’')

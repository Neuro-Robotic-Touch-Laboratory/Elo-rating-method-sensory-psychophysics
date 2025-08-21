clc;

dirlist=dir('*sec*');

for i=1:size(dirlist,1)

    cd(dirlist(i).name);
    
    list=dir('*.wav');

    for j=1:size(list,1)
        clear y y_no_clicks y_no_clicks2
    
        filename=list(j).name;
        [y,Fs] = audioread(filename);
       
        y_no_clicks = y;
        y_no_clicks(1:5000,1)=y(1:5000,1)'.*(2.^[-10:0.002:-0.002]);
        y_no_clicks(end-4999:end,1)=y(end-4999:end,1)'.*(2.^[-0.002:-0.002:-10]);
        y_no_clicks(1:5000,2)=y(1:5000,2)'.*(2.^[-10:0.002:-0.002]);
        y_no_clicks(end-4999:end,2)=y(end-4999:end,2)'.*(2.^[-0.002:-0.002:-10]);
        
        y_no_clicks2(:,1)=[y_no_clicks(:,1); zeros(20000,1)];
        y_no_clicks2(:,2)=[y_no_clicks(:,2); zeros(20000,1)];
        
%         filename=strcat(strcat(dirlist(i).name,"\0"),list(j).name);
        audiowrite(filename,y_no_clicks2,Fs);

    end
    cd ..\
end



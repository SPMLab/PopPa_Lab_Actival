clearvars
close all
clc

[f1, p1] = uigetfile('*csv'); 

T = readtable(horzcat(p1,'\',f1)); 

Dates = T{:,{'Date'}}; Dates = datevec(Dates); Dates = Dates(:,1:3); 
Times = T{:,{'Time'}}; Times = datevec(datetime(Times)); Times = Times(:,4:end); 

EMA_Event = datetime((horzcat(Dates,Times))); 

hr = 0;
min = 15;
sec = 0;
timeSeg = duration([hr, min, sec]);
Post_EMA_Event = EMA_Event + timeSeg;
Pre_EMA_Event = EMA_Event - timeSeg;

for i = 1:length(EMA_Event)
    row(1,:) = horzcat(datestr(EMA_Event(i)),',', datestr(Pre_EMA_Event(i)), ',', datestr(Post_EMA_Event(i)));
end

writetable(table(EMA_Event, Pre_EMA_Event, Post_EMA_Event, 'VariableNames', {'Event', 'PreEvent', 'PostEvent'}), 'testEMA.csv')

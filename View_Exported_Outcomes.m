clear all
clearvars 
clc 

dIR = dir(uigetdir);

for i = 3:length(dIR) 
    imported_data{i-2,1} = dIR(i).name; 
    imported_data{i-2,2} = {csvread(horzcat(dIR(i).folder, '\', dIR(i).name), 0, 1)}
end 
addpath('/Users/Raw_csv')

clear all
clc

W  =[1,2,3,4,12,19,20,21,23,24,25,28,29,31,32,33,36,39,42,43,45,47,50,51,52,55,57,59,62,65,67,68,70,71,72,73,75];
for iii = 1:length(W)
    w = W(iii);
    DataClean(w);
end
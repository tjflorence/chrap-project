%{
    quick script to run at beginning of experiment
    clears & quits everything 
%}

clc
delete(instrfind)
imaqreset
daqreset
close all
clear all
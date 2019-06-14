%This script is to implement the heterogeneous endogenous effect in Peng (2019)
%The script requires CVX solver which can be downloaded from http://cvxr.com/cvx/doc/index.html

clear all; clc

n = 500;        %# of nodes
p = [0.1,0.1];  %prob of network formation
q = 1;          %# of networks

%generate Erdos Renyi adj matrix
rng(3)  % fix seed
Adj     = networkgenerator(n, p, q, 1);
I       = [1,2,3,4,5]; % influential nodes
M       = Adj(:,:,1); %influential network
eta     = zeros(n,1); %initilize coefficients
eta(I)  = 0.8; %initilize coefficients
beta    = 3; %initilize coefficients
X       = abs(randn(n,1));
ertol   = 1e-5; %erroband

y = (eye(n)-M*diag(eta))\(X*beta+randn(n,1));

[hateta, betaEsts2, V] = estimateHEEM(y, X, M, ertol);
# Heterogeneous-Endogenous-Effects-in-Networks
Matlab code to implement the two stage LASSO process as proposed in [Peng (2019)](https://static1.squarespace.com/static/59c5cb01197aea917f5f20b2/t/5d43ac603f688400011859c4/1564716131476/HeterogeneousEndogenousEffectsinNetworks.pdf)

Code to replicate the empirical application in the paper is in the folder: empirical replication  
    The micro finance dataset is downloaded from https://web.stanford.edu/~jacksonm/Data.html

This package requires CVX solver which can be downloaded from [here](http://cvxr.com/cvx/)

HeterogeneousEndogenousEffects: Main script that executes an example with Erdos Renyi network or Small-World network.

estimateHEEM: Main function that implement the two stage LASSO estimator. 

    - Inputs:  y: outcome of interest. 
               X: exogeneous variable.
               M: adjacency matrix of network.
               ertol: error tolerance for the LASSO estimator.
    - Output:  hateta: debiased estimator.
               betaEsts2: direct two stage LASSO estimator (without debiasing).
               V: standard error of the debiased estimator.
               
               

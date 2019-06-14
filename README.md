# Heterogeneous-Endogenous-Effects-in-Networks
Matlab code to implement the two stage LASSO process as proposed in [Peng (2019)](https://static1.squarespace.com/static/59c5cb01197aea917f5f20b2/t/5c9c0e3f53450a5ff8d86f69/1553731138293/Heterogeneous+Endogenous+Effects+in+Networks.pdf)

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

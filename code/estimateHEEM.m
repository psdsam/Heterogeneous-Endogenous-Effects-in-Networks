function [hateta, betaEsts2, V] = estimateHEEM(y, X, M, ertol)
n = length(y);
% Define lambda grid
lambdas = linspace(0.1,10, 50)*sqrt(log(n)*n);
% prepare X matrix
x             = [];
grp           = [];

xx  = M*diag(X);
xx1 =sum(xx,1);
%find isolates
xx(:,xx1==0)  = [];
x = [x, xx];
grp       = [grp; ones(size(xx,2),1)];

% include the intercept
x = [x, X, ones(size(y))];
grp = [grp;0; 0];

%first stage
SSE1 = zeros(50,1);
for i = 1:length(lambdas)
    SSE1(i) = SQRLCV(x, y, grp, lambdas(i), ertol);
end
[~, se_i1] = min(SSE1);

[betaEsts] = Lasso_cvx(x,  y, grp, lambdas(se_i1), ertol);


%second stage
Y_hat = x*betaEsts;

% prepare Xhat matrix
xhat          = [];
grphat        = [];
padj          = 0;

xxhat  = M*diag(Y_hat);
xhat1 =sum(xxhat,1);
%find isolates
del_idx   = find(xhat1==0);
padj = padj + length(del_idx);
xxhat(:,del_idx)  = [];
xhat = [xhat, xxhat];
grphat    = [grphat; i*ones(size(xx,2),1)];
np = n - padj;

xhat = [xhat, X, ones(size(y))];
grphat = [grphat;0;0];

SSE = zeros(50,1);
for i = 1:length(lambdas)
    SSE(i) = SQRLCV(xhat, y, grp, lambdas(i), ertol);
end
[~, se_i] = min(SSE);

[betaEsts2] = Lasso_cvx(xhat,  y, grphat, lambdas(se_i), ertol);



[hateta, V] = biascorrection(betaEsts2, xhat, x, y, X, M);

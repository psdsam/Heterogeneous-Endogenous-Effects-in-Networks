function THETA = nodewiselasso_lasso(X, lambda)

[a,b] = size(X);
tau   = zeros(b,1);
gamma = zeros(b,b);
parfor i = 1:b
    fprintf('=====process %d======\n', i)
    y        = X(:,i);
    x        = X;
    x(:,i)   = [];
    betaEst  = Lasso_cvx(x, y, ones(b-1,1), lambda, 1e-5);
    gg       = [-betaEst(1:(i-1))',1,-betaEst(i:end)'];
    gamma(i,:) = gg;
    tau(i)   = sum((y-x*betaEst).^2)/a+2*lambda*sum(abs(betaEst));
end

THETA = diag(tau)^(-1)*gamma;

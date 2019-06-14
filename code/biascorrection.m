function [hateta, V] = biascorrection(betaEsts2, xhat, x, y, X, M)

[n, np] = size(xhat);
xhat1 = xhat(:,1:(end-2));  x1 = x(:,1:(end-2));
xhat2 = xhat(:,(end-1):end);

W = (eye(n) - xhat2*((xhat2'*xhat2)\xhat2'));


xhattilde = xhat1'*W*x1;
THETA = nodewiselasso_lasso(xhattilde,sqrt(log(n)/n));
gammab = Lasso_cvx(x1,  X, ones(np-2,1),sqrt(log(n)/n), 1e-5);
gammac = Lasso_cvx(x1,  ones(size(y)), ones(np-2,1),sqrt(log(n)/n), 1e-5);
%bias
B1     = THETA*xhattilde'*xhat1'*W*(y-x1*betaEsts2(1:n))/n;
B2     = -(X-x1*gammab)'*(xhat1 - x1)*betaEsts2(1:n)/((X-x1*gammab)'*X);
B3     = -(ones(size(y))-x1*gammac)'*(xhat1 - x1)*betaEsts2(1:n)/((ones(size(y))-x1*gammac)'*X);

hateta = betaEsts2+[B1;B2; B3];

sigma = mean(((eye(n)-M*diag(hateta(1:(end-2))))*y - [X, ones(size(y))]*hateta((end-1):end)).^2);
V1     = sigma*(THETA*xhattilde'*xhat1'*W)*(W*xhat1*xhattilde*THETA')/n;
V2     = sigma*((X-x1*gammab)'*(X-x1*gammab))/((X-x1*gammab)'*X)^2;
V3     = sigma*((ones(size(y))-x1*gammac)'*(ones(size(y))-x1*gammac))/((ones(size(y))-x1*gammac)'*X)^2;
V = sqrt([diag(V1);diag(V2);diag(V3)]);


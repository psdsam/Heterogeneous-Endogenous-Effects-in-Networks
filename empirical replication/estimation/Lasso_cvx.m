function [betaEst] = Lasso_cvx(X, y, grp, Lambda, errBnd)


X1 = X(:, grp==1);
X2 = X(:, grp==0);
[n,d1] = size(X1);
[n,d2] = size(X2);

cvx_quiet(true);
cvx_begin
    cvx_precision(errBnd);
    variables betaEst1(d1);
    variables betaEst2(d2);
    minimize( sum_square(y - X1 * betaEst1-X2 * betaEst2) + Lambda * norm(betaEst1, 1));
cvx_end


betaEst1(abs(betaEst1)<errBnd) = 0;
betaEst(grp==1) = betaEst1;
betaEst(grp==0) = betaEst2;
betaEst = betaEst';
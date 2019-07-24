function [sse] = SQRLCV(x, y, grp, lambda, ertol)
N   = length(y);
sse = 0;
indices = crossvalind('Kfold',N,10);
for i = 1:10
    xtrain = x(indices~=i,:);
    ytrain = y(indices~=i);
    xCV = x(indices==i,:);
    yCV = y(indices==i);
    
    if max(grp)==1
        [betaEst] = Lasso_cvx(xtrain, ytrain, grp, lambda, ertol);
    else
        [betaEst] = GLasso_cvx(xtrain, ytrain, grp, lambda(1), lambda(2), ertol);
    end
    
    sse = sse + sum((xCV*betaEst-yCV).^2);
end






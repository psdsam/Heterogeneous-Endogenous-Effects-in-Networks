clear all; clc;

W = [1,2,3,4,12,19,20,21,23,24,25,28,29,31,32,33,36,39,42,43,45,47,50,51,52,55,57,59,62,65,67,68,70,71,72,73,75];
q = 8;
SS = zeros(length(W), q);
SS_m = zeros(length(W), q);
SS_debias = zeros(length(W), q);
SS_m_debias = zeros(length(W), q);
abseffect = zeros(length(W), q);
COV = zeros(length(W), 1);
lengthDET = zeros(length(W), 1);
COV_bias = zeros(length(W), 1);
lengthDET_bias = zeros(length(W), 1);
bench = zeros(length(W), 1);
bench_bias = zeros(length(W), 1);
XX = []; YY1 = []; YY2 = []; YY3 = []; YY4 = [];ZZ = [];

for wwidx = 1:length(W)
    w=W(wwidx);
    fprintf('======load village %d ======\n',w)
    loadname1  = sprintf('C:\\Users\\results\\debias_%d.mat', w);
    
    load(loadname1)
    
    hatb = zeros(size(idn));
    hatb(idn==1) = betaEsts2;
    hatb = sum(reshape(hatb(1:(end-2)), n, q), 2);
    
    
    COV(wwidx) = length(intersect(find(hatb~=0), I))/sum(hatb~=0);
    lengthDET(wwidx) = sum(hatb~=0);
    
    bench(wwidx) = length(I)/n;
    
    hateta_con = hateta(hateta~=0);
    pvalue    = normcdf(-abs(hateta_con(1:(end-2)))./sqrt(V(1:(end-2))));
    
    [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(pvalue,0.3,'pdep',1);
    h = [h; 0; 0];
    
    
    heta = zeros(size(idn));
    heta(idn==1) = h;
    heta = sum(reshape(heta(1:(end-2)), n, q), 2);
    COV_bias(wwidx) = length(intersect(find(heta~=0), I))/sum(heta~=0);
    lengthDET_bias(wwidx) = sum(heta~=0);
    
    bench_bias(wwidx) = length(I)/n;
    
    for i = 1:q
        SS(wwidx, i) = sum(unique(grphat(betaEsts2~=0))==i);
        SS_m(wwidx, i) = sum((grphat(betaEsts2~=0))==i);
        SS_debias(wwidx, i) = sum(unique(grphat(h==1))==i);
        SS_m_debias(wwidx, i) = sum((grphat(h==1))==i);
        
        abseffect(wwidx, i) = mean(abs(hateta_con(grphat==i)));
    end
    
    loadname2  = sprintf('C:\\Users\\sidpeng\\Dropbox\\sida file\\empirical\\clean\\Analysis_all_%d.mat', w);
    loadname3  = sprintf('C:\\Users\\sidpeng\\Dropbox\\sida file\\empirical\\network\\Netwroks_%d.mat', w);
    load(loadname2)
    load(loadname3)
    
    XX_tmp = zeros(n, 45);
    for i = 1:n
        xraw_idx = (M(:,1)==house_idx(i));
        XX_tmp(i, :) = work_family(xraw_idx, :);
    end
    
    yy3_tmp = zeros(size(hatb));yy3_tmp(I) = 1;
    YY1 = [YY1; hatb~=0];
    YY2 = [YY2; heta~=0];
    YY3 = [YY3; yy3_tmp];
    XX  = [XX; XX_tmp];
    ZZ  = [ZZ; wwidx*ones(size(hatb))];
end

dummyZ = dummyvar(ZZ);
lm1 = fitlm([XX, dummyZ(:, 2:end)], YY1);
lm2 = fitlm([XX, dummyZ(:, 2:end)], YY2);
lm3 = fitlm([XX, dummyZ(:, 2:end)], YY3);












clear all; clc

W = [1,2,3,4,12,19,20,21,23,24,25,28,29,31,32,33,36,39,42,43,45,47,50,51,52,55,57,59,62,65,67,68,70,71,72,73,75];

q = 8; %#of networks
SS = zeros(length(W), q);


for wwidx = 1:length(W)
    w=W(wwidx);
    fprintf('======processing village %d ======\n',w)
    loadname1  = sprintf('C:\\Users\\clean\\cleanedate_all_%d.mat', w);
    loadname2  = sprintf('C:\\Users\\network\\Netwroks_%d.mat', w);
    load(loadname1)
    load(loadname2)
    
    %group data into households
    house = floor(IDtoPerson/100);
    [house_idx, IH, IP] = unique(house);
    numberofpeople = zeros(size(house_idx));
    for i = 1:length(house_idx)
        numberofpeople(i) = sum(IP==i);
    end
    
    houseRelationships = zeros(length(house_idx), length(house_idx),8);
    
    n = length(house_idx);
    nn= length(IDtoPerson);
    
    %restruct adj matrix
    VillageRelationships  = zeros(nn,nn,q);
    
    %visit go-come
    VillageRelationships(:,:,1) = villageRelationships(:,:,1)+ villageRelationships(:,:,2);
    %firendship
    VillageRelationships(:,:,2) = villageRelationships(:,:,3);
    %meidc
    VillageRelationships(:,:,3) = villageRelationships(:,:,4);
    %keroric go-come
    VillageRelationships(:,:,4) = villageRelationships(:,:,5)+ villageRelationships(:,:,6);
    %borrow money go-come
    VillageRelationships(:,:,5) = villageRelationships(:,:,7)+ villageRelationships(:,:,8);
    %helpdecision
    VillageRelationships(:,:,6) = villageRelationships(:,:,9)+ villageRelationships(:,:,10);
    %templecompany
    VillageRelationships(:,:,7) = villageRelationships(:,:,11);
    %relatives
    VillageRelationships(:,:,8) = villageRelationships(:,:,12);
    
    
    % 1, 2, 4, 5, 8, 6, 3, 7
    %q=2;
    
    for i = 1:n
        ss1 = find(house==house_idx(i));
        for j = 1:n
            ss2 = find(house==house_idx(j));
            for k = 1:q
                if sum(sum(VillageRelationships(ss1,ss2,k)))>0
                    houseRelationships(i,j,k) = 1;
                end
            end
        end
    end
    
    X_raw = zeros(n,6);
    for i = 1:n
        xraw_idx = (M(:,1)==house_idx(i));
        X_raw(i,:) = M(xraw_idx,2:7);
    end
    
    wealth = X_raw(:,1)./X_raw(:,6);
    
    
    d_raw = unique(floor(decision_idx/100));
    i_raw = unique(floor(inj_idx/100));
    I     = [];
    D     = -1*ones(n,1);
    for i = 1:length(i_raw)
        I = [I; find(house_idx==i_raw(i))];
    end
    
    for d = 1:length(d_raw)
        D(house_idx==d_raw(d))=1;
    end
    
    Adj           = houseRelationships;
    
    Adjmatrix     = (sum(Adj,3)~=0);
    
    C = Adj;
    
    % prepare X matrix
    x             = [];
    grp           = [];
    idn           = [];
    wt            = [];
    for i = 1:q
        CC        = C(:,:,i)*diag(numberofpeople);
        cc        = sum(CC,1);
        del_idx   = find(cc==0);
        CC(:,del_idx)  = [];
        x         = [x, CC];
        grp       = [grp; i*ones(size(CC,2),1)];
        idn_1     = house_idx';
        idn_1(del_idx) = [];
        idn       = [idn; idn_1];
    end
    
    y             = D;
    
    
    
    % include the intercept
    x = [x, wealth, ones(size(y))];
    grp = [grp; 0; 0];
    
    SSE1 = zeros(10,1);
    lambdas = linspace(0.001,0.1, 10)*sqrt(log(n)*n);
    for i = 1:length(lambdas)
        SSE1(i) = SQRLCV(x, y, grp, [lambdas(i), lambdas(i)], 1e-5);
    end
    [~, se_i1] = min(SSE1);
    [betaEsts] =  GLasso_cvx(x, y, grp, lambdas(se_i1),lambdas(se_i1), 1e-5);
    
    %second stage
    Y_hat = x*betaEsts;
    
    % prepare Xhat matrix
    xhat          = [];
    grphat        = [];
    idn           = [];
    for i  = 1:q
        xxhat  = Adj(:,:,i)*diag(Y_hat);
        xhat1 =sum(xxhat,1);
        del_idx   = find(xhat1==0);
        xxhat(:,del_idx)  = [];
        xhat = [xhat, xxhat];
        grphat    = [grphat; i*ones(size(xxhat,2),1)];
        idn_tmp =ones(n,1); idn_tmp(del_idx) = 0;
        idn         = [idn; idn_tmp];
    end
    
    xhat = [xhat, wealth, ones(size(y))]; %, ones(size(y))
    grphat = [grphat;0; 0];
    idn = [idn; 1; 1];
    
    SSE = zeros(10,1);
    for i = 1:length(lambdas)
        SSE(i) = SQRLCV(xhat, y, grp, [lambdas(i), lambdas(i)], 1e-5);
    end
    [~, se_i] = min(SSE);
    
    [betaEsts2] =  GLasso_cvx(xhat,  y, grphat, lambdas(se_i),lambdas(se_i), 1e-5);
    
    for i = 1:q
        SS(wwidx, i) = sum(unique(grphat(betaEsts2~=0))==i);
    end
    
    [hateta, V] = biascorrection(betaEsts2, xhat, x, y, wealth, Adj, idn);
    savename  = sprintf('C:\\Users\\results\\debias_%d.mat', w);
    save(savename);
end








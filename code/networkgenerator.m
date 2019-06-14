function Adj = networkgenerator(n, p, q, type)

%generate adjacency matrix using Erdos Renyi (type==1) or small word (type==anythingelse)
Adj = zeros(n,n,q);

if type==1
    for i = 1:q
        for j = 1:n-1
            for jj = j+1:n
                if rand(1,1)<p(i)
                    Adj(j,jj,i) = 1;
                    Adj(jj,j,i) = 1;
                end
            end
        end
    end
else
    for i = 1:q
         Adj(:,:,i) = small_world(n, k, beta);
    end  
end

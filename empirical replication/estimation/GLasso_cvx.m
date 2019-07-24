function [pimat] = GLasso_cvx(x, y, groups, Lambda1, Lambda2, errBnd)
% Square-root sparse group loss 

m = size(unique(groups),1);
[~, t] = size(x);
group_idx   = zeros(m,t);  
group_sizes = zeros(m,1);   

for g=1:m-1
    tmp_logical_idx = groups==g;
    group_idx(g,:) = tmp_logical_idx;
    group_sizes(g) = sum(tmp_logical_idx);
end
%for constant
tmp_logical_idx = groups==0;
group_idx(m,:) = tmp_logical_idx;
group_sizes(m) = 0;

group_idx = logical(group_idx');
not_group_idx = ~group_idx;             
sqr_group_sizes = sqrt(group_sizes);
one_sizes = ones(size(sqr_group_sizes));
one_sizes(m) = 0;

cvx_quiet(true);
cvx_begin
    cvx_precision(errBnd);
    variable pimat_sgl(t,m)
    minimize( sum_square(y - sum(x * pimat_sgl, 2)) + Lambda2 * norms(pimat_sgl,2,1)*sqr_group_sizes+ Lambda1 * norms(pimat_sgl,1,1)*one_sizes)
    subject to
        %pimat_sgl >= 0
        pimat_sgl(not_group_idx) == 0
cvx_end

pimat = full(pimat_sgl);

pimat(abs(pimat)<errBnd) = 0;
pimat = sum(pimat,2);
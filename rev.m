clear;

r='../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_spmTwarp03smooth08_scale_labelscale_linear/temprevearse.mat';
s='../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_spmTwarp03smooth08_scale_labelscale_linear/temp.mat';
rr='../groupstat/25sub_no33no36/searchlite_support_vector_regression_permutation/invflo_vs_invspi_x_SPINDEX_spmTwarp03smooth08_scale_labelscale_linear/temprevearse_rev.mat';

load(r);
k_rev=k;
cr_rev=cr;
mcrp_rev=mcrp;
ncrp_rev=ncrp;
pcrp_rev=pcrp;

save(rr,'k_rev','cr_rev','mcrp_rev','ncrp_rev','pcrp_rev');


load(rr);
load(s);

mcrp_rev(1:k_rev)=mcrp(1:k_rev);
ncrp_rev(1:k_rev)=ncrp(1:k_rev);
pcrp_rev(1:k_rev)=pcrp(1:k_rev);
cr_rev(1:k_rev)=cr(1:k_rev);

cr=cr_rev;
mcrp=mcrp_rev;
ncrp=ncrp_rev;
pcrp=pcrp_rev;

k=length(cr);

save(s,'k','cr','mcrp','ncrp','pcrp')
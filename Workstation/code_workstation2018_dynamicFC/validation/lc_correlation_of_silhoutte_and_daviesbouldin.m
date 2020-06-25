% This script is used to perform correlation analysis between results of silhoutte method and davies-bouldin

daviesbouldin_results = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength20__silhoutte_and_davies-bouldin\daviesbouldin';
silhoutte_results = 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength20__silhoutte_and_davies-bouldin\silhoutte';
cmap = 'D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\cmp_net0point5_pospoint8';
mask_path = '';
net_index_path='D:\My_Codes\lc_rsfmri_tools_matlab\Workstation\code_workstation2018_dynamicFC\visualization\netIndex.mat';
legends = {'Visual', 'SomMot', 'DorsAttn', 'Sal/VentAttn', 'Limbic', 'Control', 'Default'};
%
load (cmap)
c1 = importdata(fullfile(silhoutte_results, 'group_centroids_1.mat'));
c2 = importdata(fullfile(silhoutte_results, 'group_centroids_2.mat'));
c1_db = importdata(fullfile(daviesbouldin_results, ['group_centroids_',num2str(1),'.mat']));
c2_db = importdata(fullfile(daviesbouldin_results, ['group_centroids_',num2str(2),'.mat']));
c3_db = importdata(fullfile(daviesbouldin_results, ['group_centroids_',num2str(3),'.mat']));
c_db{2} = c1_db;
c_db{3} = c2_db;
c_db{4} = c3_db;
c_db{6} = c1_db;
c_db{7} = c2_db;
c_db{8} = c3_db;

coef{2} = corr(c1(:), c_db{2}(:));
coef{3} = corr(c1(:), c_db{3}(:));
coef{4} = corr(c1(:), c_db{4}(:));
coef{6} = corr(c2(:), c_db{6}(:));
coef{7} = corr(c2(:), c_db{7}(:));
coef{8} = corr(c2(:), c_db{8}(:));


count = 1;
for i = 1:8
    subplot(2,4,i)
    if (i==1)
        lc_netplot('-n', c1, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 9);
    elseif (i==5)
        lc_netplot('-n', c2, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 9);
    else
        lc_netplot('-n', c_db{i}, '-ni', net_index_path,'-il',1, '-lg', legends, '-lgf', 9);
    end
%     colormap(brewermap([],'YlGnBu'))
    colormap(cmp_net0point5_pospoint8)
%     colorbar;
    caxis([-0.5,0.8])
    axis square
    title(num2str(coef{i}));
end

% 
% subplot(1,2,1);
% lc_netplot('-n', c1, '-ni', net_index_path);
% colormap(cmp_net0point5_pospoint8)
% colorbar;
% caxis([-0.5,0.8])
% axis square
% subplot(1,2,2);
% lc_netplot('-n', c2, '-ni', net_index_path);
% colormap(cmp_net0point5_pospoint8)
% colorbar;
% caxis([-0.5,0.8])
% axis square
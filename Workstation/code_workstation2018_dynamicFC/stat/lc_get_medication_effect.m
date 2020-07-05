function  lc_get_medication_effect(varargin)
% Perform ANCOVA + FDR correction for functional connectivity matrix.
% INPUTS:
% 	    [--data_dir, -dd]: data directory of dynamic functional connectivity.
% 	    [--demographics_file,-dmf]: File of demographics of participants, demographics includes unique index, group label and covariates.
%       [--contrast, -ctr]: contrast of GLM, refer to NBS for details. E.g., contrast = [1 1 1 1 0 0 0 0];
%       [--suffix_fc, -sfc]: suffix of functional connectivity, default is '.mat'.
%       [--column_id, -cid]: which column is subject unique index, default is 1.
%       [--column_group_label, -cgl]:which column is group label, default is 2.
%       [--columns_covariates, -ccov]: which column(s) is(are) covariate(s), default is [3:end]
%       [--correction_method, -cm]: Multiple correction method (FDR, FWE, None; default is FDR).
% 	    [--correction_threshold, -ct]: Multiple correction threshold (e.g., correction_threshold = 0.05), default is 0.05.
% 	    [--is_save, -is]: If save results, default is 1.
%       [--output_directory, -od]: directiory for saving results, default is current directory.
%       [--output_name, -on]: prefix of output name, default is ''.
% 
% OUTPUTS:F-values, h and p-values.
% EXAMPLE:
  % lc_ancova_for_fc('-dd', 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin\daviesbouldin\610\individual_state3', ...
  % '-dmf', 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\ID_Scale_Headmotion\covariates_737.xlsx', ...
  % '-ctr', [1 1 1 1 0 0 0],...
  % '-cid', 1, '-cgl', 2, '-ccov', [3,4,6],...
  % '-od', 'D:\WorkStation_2018\WorkStation_dynamicFC_V3\Data\results\windowlength17__silhoutte_and_davies-bouldin\daviesbouldin\610\results_state3', ...
  % '-on', 'state3');

% NOTE. Make sure the order of the dependent variables matches the order of the covariances
% Thanks to NBS software.

%% ---------------------------VARARGIN PARSER-------------------------------
if( sum(or(strcmpi(varargin,'--data_dir'),strcmpi(varargin,'-dd')))==1)
    data_dir = varargin{find(or(strcmpi(varargin,'--data_dir'),strcmp(varargin,'-dd')))+1};
else
    data_dir = uigetdir(pwd,'select data_dir of .mat files');
end

if( sum(or(strcmpi(varargin,'--suffix_fc'),strcmpi(varargin,'-sfc')))==1)
    suffix_fc = varargin{find(or(strcmpi(varargin,'--suffix_fc'),strcmp(varargin,'-sfc')))+1};
else
    suffix_fc = '*.mat';
end

if( sum(or(strcmpi(varargin,'--demographics_file'),strcmpi(varargin,'-dmf')))==1)
    demographics_file = varargin{find(or(strcmpi(varargin,'--demographics_file'),strcmp(varargin,'-dmf')))+1};
else
    [demographics_file, path] = uigetfile({'*.xlsx'; '*.txt'; '*.*'},'Select demographics file', pwd,'MultiSelect', 'off');
end
demographics_file = fullfile(path, demographics_file);

if( sum(or(strcmpi(varargin,'--contrast'),strcmpi(varargin,'-ctr')))==1)
    contrast = varargin{find(or(strcmpi(varargin,'--contrast'),strcmp(varargin,'-ctr')))+1};
else
    contrast = input('Enter contrast (such as [1 1 1 1 0 0 0]):');
end

if(sum(or(strcmpi(varargin,'--colnum_id'),strcmpi(varargin,'-cid')))==1)
    colnum_id = varargin{find(or(strcmpi(varargin,'--colnum_id'),strcmp(varargin,'-cid')))+1};
else
    colnum_id = input('Input the column of subject id, such as 1:');
end

if( sum(or(strcmpi(varargin,'--column_group_label'),strcmpi(varargin,'-cgl')))==1)
    column_group_label = varargin{find(or(strcmpi(varargin,'--column_group_label'),strcmp(varargin,'-cgl')))+1};
else
    column_group_label = input('Input the column of group label, such as 2:');
end

if( sum(or(strcmpi(varargin,'--columns_covariates'),strcmpi(varargin,'-ccov')))==1)
    columns_covariates = varargin{find(or(strcmpi(varargin,'--columns_covariates'),strcmp(varargin,'-ccov')))+1};
else
    columns_covariates = input('Enter columns_covariates, such as [3 4 5]:');
end

if( sum(or(strcmpi(varargin,'--correction_method'),strcmpi(varargin,'-cm')))==1)
    correction_method = varargin{find(or(strcmpi(varargin,'--correction_method'),strcmp(varargin,'-cm')))+1};
else
    correction_method = 'FDR';
end

if( sum(or(strcmpi(varargin,'--correction_threshold'),strcmpi(varargin,'-ct')))==1)
    correction_threshold = varargin{find(or(strcmpi(varargin,'--correction_threshold'),strcmp(varargin,'-ct')))+1};
else
    correction_threshold = 0.05;
end

if( sum(or(strcmpi(varargin,'--is_save'),strcmpi(varargin,'-is')))==1)
    is_save = varargin{find(or(strcmpi(varargin,'--is_save'),strcmp(varargin,'-is')))+1};
else
    is_save = 1;
end

if( sum(or(strcmpi(varargin,'--output_directory'),strcmpi(varargin,'-od')))==1)
    output_directory = varargin{find(or(strcmpi(varargin,'--output_directory'),strcmp(varargin,'-od')))+1};
else
    output_directory = uigetdir(pwd, 'Select directory for saving results');
end
if ~exist(output_directory, 'dir')
    mkdir(output_directory);
end

if( sum(or(strcmpi(varargin,'--output_name'),strcmpi(varargin,'-on')))==1)
    output_name = varargin{find(or(strcmpi(varargin,'--output_name'),strcmp(varargin,'-on')))+1};
else
    output_name = input('Input prefix of output name:', 's');
end

test_info = ['ANCOVA-', correction_method, '-threshold_', num2str(correction_threshold)];
%% ---------------------------END VARARGIN PARSER-------------------------------

%% Prepare
% Demographics
[~, ~, suffix] = fileparts(demographics_file);
if strcmp(suffix, '.txt')
    demographics = importdata(demographics_file);
    demographics = demographics.data;
elseif strcmp(suffix, '.xlsx')
    [demographics, ~, ~] = xlsread(demographics_file);
else
    disp('Unspport file type');
    return;
end

% dependent variable, Y
fprintf('Loading FC...\n');
subj = dir(fullfile(data_dir,suffix_fc));
subj = {subj.name}';
subj_path = fullfile(data_dir,subj);
n_subj = length(subj);
for i = 1:n_subj
    onemat = importdata(subj_path{i});
    if i == 1
        mask = triu(ones(size(onemat,1)),1) == 1;
        all_subj_fc = zeros(n_subj,sum(mask(:)));
    end
    onemat = onemat(mask);
    all_subj_fc(i,:)=onemat;
end
fprintf('Loaded data\n');

% match Y and Demographics
% Y and Demographics must have the unique ID that used to mathch them.
ms = regexp( subj, '(?<=\w+)[1-9][0-9]*', 'match' );
nms = length(ms);
subjid = zeros(nms,1);
for i = 1:nms
    tmp = ms{i}{1};
    subjid(i) = str2double(tmp);
end

[Lia,Locb] = ismember(subjid, demographics(:,1));
Locb_matched = Locb(Lia);
cov_matched = demographics(Locb_matched,:);

% Exclude NaN
loc_nan = sum(isnan(cov_matched),2) > 0;
Locb_matched(loc_nan,:) = [];
cov_matched(loc_nan, :) = [];
all_subj_fc(loc_nan, :) = [];

% Group design
group_label = cov_matched(:, 5);
uni_groups = unique(group_label);
n_groups = numel(unique(group_label));
group_design = zeros(size(group_label,1), n_groups);
for i =  1:n_groups
    group_design(:,i) = ismember(group_label, uni_groups(i));
end
design_matrix = cat(2, group_design, cov_matched(:, [2 3 4 6]));

%% Exclude HCs
loc_hc = design_matrix(:,3) == 1;
all_subj_fc(loc_hc,:) = [];
design_matrix(loc_hc,:)= [];
%% ancova using GLM from NBS
perms = 0;
GLM.perms = perms;
GLM.X = design_matrix;
GLM.y = all_subj_fc;
GLM.contrast = [1 -1 0 0 0 0];
GLM.test = 'ttest';
[test_stat,pvalues]=NBSglm(GLM);

%% Multiple comparison correction
if strcmp(correction_method, 'FDR')
    results = multcomp_fdr_bh(pvalues, 'alpha', correction_threshold);
elseif strcmp(correction_method, 'FWE')
    results = multcomp_bonferroni(pvalues, 'alpha', correction_threshold);
else
    fprintf('Please indicate the correct correction method!\n');
end
h_corrected = results.corrected_h;

%% to original space (2d matrix)
Tvalues = zeros(size(mask));
Tvalues(mask) = test_stat;
Tvalues = Tvalues+Tvalues';

Pvalues =  zeros(size(mask));
Pvalues(mask) = pvalues;
Pvalues = Pvalues+Pvalues';

H =  zeros(size(mask));
H(mask) = h_corrected;
H = H+H';

%% save
if is_save
    disp('save results...');
    timenow = strrep(num2str(fix(clock)),' ','');
    output_name_all = strcat(output_name, '_Ttest2_', correction_method, '_Corrected_', num2str(correction_threshold), '.mat');
    
    save (fullfile(output_directory,output_name_all),'test_info','Tvalues','Pvalues','H');
    disp('saved results');
end
fprintf('--------------------------All Done!--------------------------\n');
end
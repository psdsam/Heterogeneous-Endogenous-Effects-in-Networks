
function [] = DataClean(w)
%match survey data
%load village data
surveyperson = csvread(strcat('survey',num2str(w),'.csv'));
gps          = csvread(strcat('gps',num2str(w),'.csv'));
village      = csvread(strcat('village',num2str(w),'.csv'));
leader       = csvread(strcat('locleader',num2str(w),'.csv'));
injection    = csvread(strcat('localleader',num2str(w),'.csv'));
decision     = csvread(strcat('bss',num2str(w),'.csv'));

% align id with surveyperson
inj_idx      = 100*injection(:,1)+injection(:,2);
decision_idx = 100*decision(:,1) + decision(:,2);

%aggragate the number of leaders nominated
nominatedleaders = [leader(:,2);leader(:,3);leader(:,4);leader(:,5)];
nominee          = leader(:,1);
uni_leader       = unique(nominatedleaders);
uni_leader(uni_leader==7777777)  = [];
uni_leader(uni_leader==0)  = [];
work_family = zeros(length(gps),45);

for i = 1:length(gps)
    survey_idx = find(surveyperson(:,1)==gps(i,1));
    person_idx = find(village(:,1)==gps(i,1));
    if ~isempty(survey_idx)
        gps(i,8) = sum(surveyperson(survey_idx, 8)==1);
        gps(i,11) = 1;
        for j = 1:length(survey_idx)
            ll = surveyperson(survey_idx(j), 9);
            if ll~=0
                work_family(i,ll) = 1;
            end
        end
    end
    if ~isempty(person_idx)
        gps(i,9) = nanmean(village(person_idx,4));
        gps(i,10) = sum(person_idx);
    end
end
    
% id, #room, elec, latrine, #worker, age, #person
M = [gps(:,[1,4]), gps(:,6)~=3, gps(:,7)~=3, gps(:,8), gps(:,9), gps(:,10),gps(:,11)];    

savename = sprintf('/Users/clean/Analysis_all_%d.mat', w);
save(savename,'inj_idx','decision_idx','M','uni_leader','work_family')














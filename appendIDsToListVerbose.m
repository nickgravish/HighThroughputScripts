%% Code to append IDs to flight data
cd('/Users/james/Dropbox/Work/Research/Bees/Bumblebees/Foraging experiments/Summer2014/data')
%%
%Currently recovers unique ID for ~2000 flights belonging to 235 different
%bees

% Load in relevant data
% Paths will change

%Load in flight data
if ~isstruct('JamesList') %If JamesList is already loaded, don't load again
    load('~/Dropbox/High Throughput Current/Data/JamesList.mat');
end
%Load in data from scale tracking
load('~/Dropbox/High Throughput Current/Data/scaleDataMaster.mat');

%%
timerange = 20; %Time range to look for tags, in seconds
timerange = timerange / 86400; %Convert time range to days
%%
for aa = 1:length(JamesList)
    
    time = JamesList(aa).datenum; %Get timestamp for current flight
    dir = JamesList(aa).in; %Get flight direction
    
    %% Figure out start and end time to look for identified tags
    if dir == 1
        startTime = time;
        endTime = time + timerange;
    elseif dir == 0
        startTime = time - timerange;
        endTime = time;
    end
    
    %% extract relevant codes and centroids
    relCodes = codesM(codesM.time > startTime & codesM.time < endTime, :);
    relCents = centroidsM(centroidsM.time > startTime & centroidsM.time < endTime, :);
    
    %% Check for a unique code
    if numel(unique(relCodes.number)) == 1 && numel(unique(relCents.file)) == numel(relCents.file)
        %First part checks that there is only one code IDes in the time
        %range, second checks that there is only one centroid per picture
        %in the same time range
        JamesList(aa).ID = unique(relCodes.number);
    else
        JamesList(aa).ID = NaN;
    end
end
%%

IdentifiedList = JamesList(~isnan([JamesList.ID]));  %subset

IDList = [IdentifiedList.ID];  %Get list of IDs

uID = unique(IDList);  %unique IDs

counts = histc(IDList, uID);  %counts

highActivityIDs = uID(counts > 10); %Get list of IDs with more than 20 identified paths
%% Create flight path plots for most identified bees
for bb = 1:numel(highActivityIDs)
    curList = IdentifiedList(IDList == highActivityIDs(bb));
    subplot(8,8,bb);
    %%
    for cc = 1:numel(curList)
        if curList(cc).in == 1
            c = 'r';
        elseif curList(cc).in == 0
            c = 'b';
        end
        figure(1);
        %2d plot
        plot(curList(cc).xyz_spline2(:,1), curList(cc).xyz_spline2(:,2), c);
        
        %3d plot
        %plot3(curList(cc).xyz_spline2(:,1), curList(cc).xyz_spline2(:,2),curList(cc).xyz_spline2(:,3), c);
        hold on;
        %pause(0.5);
        figure(2);
        subplot(5,5,cc);
        plot(curList(cc).rho, c);
    end
    title(highActivityIDs(bb));
    xlim([-50 50]);
    ylim([0 50]);
    axis equal;
end

%%
save('JamesListIDed.mat', 'IdentifiedList', 'highActivityIDs');

%% Calculate basic statistics
if ~isstruct('IdentifiedList')
        load('~/Dropbox/High Throughput Current/Data/JamesListIDed.mat');
end
% % Subset to high activity ids
% IdentifiedList = IdentifiedList(ismember([IdentifiedList.ID], highActivityIDs));

%%
for dd = 1:numel(IdentifiedList);
    
    %Did the bee pass through the hive entrance, within 2.5 cm?
    entr = min(IdentifiedList(dd).rho) < 2.5;
    
    %Total distance, did the bee move at least 30 cm in or out
    rDif = range(IdentifiedList(dd).rho) > 30;
    
    %Write check into structure
    if entr == 1 & rDif == 1
        IdentifiedList(dd).qualCheck = 1;
    else
        IdentifiedList(dd).qualCheck = 0;
    end
    
    IdentifiedList(dd).medVel = nanmedian(IdentifiedList(dd).vel);
    IdentifiedList(dd).radVel = nanmean(diff(IdentifiedList(dd).rho));
    %%
    xyz = IdentifiedList(dd).xyz_spline2;
    xyz = xyz(~isnan(xyz(:,1)),:);
    ends = xyz([1 end],:);
    displ = sqrt(sum(diff(ends).^2));
    pathdist = sum(sqrt(sum(diff(xyz).^2,2)));
    sin = pathdist/displ;
    if sin < 5
        IdentifiedList(dd).sin = sin;
    else 
        IdentifiedList(dd).sin = NaN;
    end

end

%% boxplot by individual
IDlist = IdentifiedList([IdentifiedList.qualCheck] == 1);
subplot(3,1,1);
boxplot(abs([IDlist.radVel]), [IDlist.ID]);
subplot(3,1,2);
boxplot(abs([IDlist.medVel]), [IDlist.ID]);
subplot(3,1,3);
boxplot(3 - abs([IDlist.sin]), [IDlist.ID]);
ylim([0 3]);

%% plot by individual
trial = [];
for ee = 1:length(highActivityIDs)
   curList = IDlist([IDlist.ID] == highActivityIDs(ee));
   subplot(3,1,1);
   plot([curList.medVel], '.');
   hold on
   subplot(3,1,2);
   plot(abs([curList.radVel]), '.');
   hold on
   subplot(3,1,3);
   plot([curList.sin], '.');
   hold on
   trial = [trial;(1:numel(curList))'];
end

%% Create flight path plots for most identified bees
for bb = 1:numel(highActivityIDs)
    curList = IDlist([IDlist.ID] == highActivityIDs(bb));
   figure(1);

    subplot(8,8,bb);
    %%
    for cc = 1:numel(curList)
        if curList(cc).in == 1
            c = 'r';
        elseif curList(cc).in == 0
            c = 'b';
        end
        %2d plot
        plot(curList(cc).xyz_spline2(:,1), curList(cc).xyz_spline2(:,2), c);
        
        %3d plot
        %plot3(curList(cc).xyz_spline2(:,1), curList(cc).xyz_spline2(:,2),curList(cc).xyz_spline2(:,3), c);
        hold on;
        %pause(0.5);
        %figure(2);
        %subplot(8,8,cc);
        %plot(curList(cc).rho, c);
    end
    title(highActivityIDs(bb));
    xlim([-50 50]);
    ylim([0 50]);
    axis equal;
end

%% Get and export individual data
medVel = [];
radVel = [];
sin = [];

for ff = 1:numel(highActivityIDs)
        curList = IDlist([IDlist.ID] == highActivityIDs(ff));
    medVel(ff) = nanmedian([curList.medVel]);
    radVel(ff) = nanmedian([curList.radVel]);
    sin(ff) = nanmedian([curList.sin]);
end

IndData = array2table([highActivityIDs' radVel' medVel' sin']);
IndData.Properties.VariableNames = {'id' 'radVel' 'medVel' 'sin'};
writetable(IndData,'IndividualData.csv');
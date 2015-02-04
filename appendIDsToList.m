%% Code to append IDs to flight data

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

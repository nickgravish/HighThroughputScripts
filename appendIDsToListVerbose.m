%% Code to append IDs to flight data
%  cd('/Users/james/Dropbox/Work/Research/Bees/Bumblebees/Foraging experiments/Summer2014/data')
%%
%Currently recovers unique ID for ~2000 flights belonging to 235 different
%bees

% Load in relevant data
% Paths will change

%Load in flight data
if ~exist('JamesList') %If JamesList is already loaded, don't load again
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
    direction = JamesList(aa).in; %Get flight direction
    
    %% Figure out start and end time to look for identified tags
    if direction == 1 % Outbound
        startTime = time;
        endTime = time - timerange;
    elseif direction == -1 % inbound
        startTime = time + timerange;
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

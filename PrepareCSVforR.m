

%% Matlab script to export processed data to csv for running stats models in R
%  intended output  format 
%  Date, Hour of day, Hive #, Days from introduction, ID of Bee, Post arrangement, Temperature, Windspeed,
%  ... Light level, Tagged or not?, Median flight speed, Median height,
%  ... incoming/outgoing?, Size in JamesImage, Size in tracked, 
%  
%  as far as the data goes, want to only include flights that are above the
%  ground z>0.5cm and that traverse the arena (dist>40cm). 

%% load and process

% load the data and rename the data structure to data 
file = load('/Users/nickgravish/Documents/Research_Share/HighThroughputExperiments/MasterList_ReTrack_20150121.mat');

% this is the line that could vary depending on the masterlist.mat file
% loaded, and will be updated accordingly as SBA tracked data comes in
MasterList = file.MasterList;

HiveList = file.HiveList;
PostList = file.PostList;
Posts = file.Posts;

%% Define some constants for analysis

rhobounds = [10 40]; % the start and stop rho's that trajectories must cover to be included
sampFreq = 309;

%% count number of correctly tracked videos
IsTracked = logical(arrayfun(@(x) iff(isempty(x.SBA_Correct),0,x.SBA_Correct), MasterList));

% Compile post stats
PostNumber = arrayfun(@(x) length(x.xx_postkeepers),Posts);
PostDensity = PostNumber./(1/2)*(pi)*(.5)^2;

%% compute velocity statistics, and polar coordinates
for kk=1:length(MasterList)

    if(IsTracked(kk))
        
        [theta rho z] = cart2pol(MasterList(kk).SBA_xyz_spline2(:,1), MasterList(kk).SBA_xyz_spline2(:,2),...
                                MasterList(kk).SBA_xyz_spline2(:,3));    
                            
        MasterList(kk).rho = rho(1:1199);
        MasterList(kk).theta = theta(1:1199);
        
        MasterList(kk).in = -sign(nanmedian(diff(rho)));
        
        distperstep = sqrt(diff(MasterList(kk).SBA_xyz_spline2(:,1)).^2 + ...
                            diff(MasterList(kk).SBA_xyz_spline2(:,2)).^2 + ...
                            diff(MasterList(kk).SBA_xyz_spline2(:,3)).^2);
        MasterList(kk).vel = distperstep * 300;
        MasterList(kk).velx = diff(MasterList(kk).SBA_xyz_spline2(:,1))* sampFreq;
        MasterList(kk).vely = diff(MasterList(kk).SBA_xyz_spline2(:,2))* sampFreq;
        MasterList(kk).velz = diff(MasterList(kk).SBA_xyz_spline2(:,3))* sampFreq;
        
         
        distperstep = sqrt(diff(MasterList(kk).velx).^2 + ...
                            diff(MasterList(kk).vely).^2 + ...
                            diff(MasterList(kk).velz).^2);
        MasterList(kk).accel = distperstep * sampFreq;
        MasterList(kk).accelx = diff(MasterList(kk).velx) * sampFreq;
        MasterList(kk).accely = diff(MasterList(kk).vely) * sampFreq;
        MasterList(kk).accelz = diff(MasterList(kk).velz) * sampFreq;
        
    else
        MasterList(kk).vel = ones(1199,1)*NaN;
        MasterList(kk).accel = ones(1198,1)*NaN;
        
        MasterList(kk).rho = ones(1199,1)*NaN;
        MasterList(kk).theta = ones(1199,1)*NaN;
    end
    
    kk
end


%% find walkers
for kk=1:length(MasterList)
    
    if(IsTracked(kk))
        rho = MasterList(kk).rho;
        walking(kk) = any(MasterList(kk).SBA_xyz_spline2(rho > 5,3) < 1);
    else
        walking(kk) = 0;
    end
    kk
end

%% Look for runs that traverse the rhobounds distance and that are within the posts arrays
%  compile the median flight speed of these runs

traversalFlag = zeros(length(MasterList),1);

for kk=1:length(MasterList)
    traversalFlag(kk) = 0;
    
    if(IsTracked(kk))
        rho = MasterList(kk).rho;
        ind = 1:1200;
        
        if(MasterList(kk).in==1)
            rho = rho(end:-1:1);
            ind = ind(end:-1:1);
        end
            
        try
            
            home = find((rho(1:end-1)-rhobounds(1)).*(rho(2:end)-rhobounds(1)) < 0,1); % find when first get a distance rhobounds(1) from home
            home = ind(home); % index of when first get a distance rhobounds(1) from home
            away = find((rho(1:end-1)-rhobounds(2)).*(rho(2:end)-rhobounds(2)) < 0,1); % find when first get a distance rhobounds(2) from home
            away = ind(away); % index of when first get a distance rhobounds(1) from home
            
            homeaway = sort([home away]);
            
            MasterList(kk).TraversalSpeed = nanmedian(MasterList(kk).vel(homeaway(1):homeaway(2)));
            MasterList(kk).TraversalHeight = nanmedian(MasterList(kk).SBA_xyz_spline2(homeaway(1):homeaway(2),3));
            traversalFlag(kk) = 1;
%             if(MasterList(kk).inbound==1)
%                 pause;
%             end
        catch
            MasterList(kk).TraversalSpeed = NaN;
        end
    end
    kk
end

%% Median size across all cameras and all frames

for kk=1:length(MasterList)
    
    if(IsTracked(kk))
        majr = MasterList(kk).MajorAxis;
        minr = MasterList(kk).MinorAxis;
        
        majr(majr == -1) = NaN;
        minr(minr == -1) = NaN;
        
        area = pi*majr.*minr;
        area = nanmedian(nanmedian(area));
        
        MasterList(kk).Area = area;
    end
    kk
end

%% Make masterlist and other values for only appropriate flights with a traversalFlag 

idx = IsTracked & ~walking & traversalFlag';

JamesList = MasterList(idx);
HiveList = HiveList(idx);
PostList = PostList(idx);

%% Call ID Code written by James

run ~/Dropbox/High' Throughput Current'/Scripts/appendIDsToListVerbose.m    

%% Call weather data

run ~/Dropbox/High' Throughput Current'/Scripts/appendWeatherToList.m  

%% Prepare hive times info

run ~/Dropbox/High' Throughput Current'/Scripts/createHiveTimes.m

%% export CSV for processing in R

%  Date, Hour of day, Hive #, Days from introduction, ID of Bee, Post arrangement, Temperature, Windspeed,
%  ... Light level, Tagged or not?, Median flight speed, Median height,
%  ... incoming/outgoing?, Size in JamesImage, Size in tracked, 

% only focus on runs where posts were in place
idx = PostList < 9;

J=struct2cell(JamesList(idx));

DateTable        = squeeze(cellfun(@datestr, J(3,1,:),'UniformOutput',false)); % Date is first entry
HourTable        = hour(DateTable);
HiveTable        = HiveList(idx);

% days since start
for kk=1:length(J)
    DaysSince(kk) = datenum(days(datenum(DateTable(kk)) - (hiveTimes(HiveTable(kk),2))));
    
    Temperature(kk) = J{end,1,kk}.temp;
    WindSpeed(kk) = J{end,1,kk}.windspeed;
    LightLevel(kk) = J{end,1,kk}.lux;
    Pressure(kk) = J{end,1,kk}.pressure;
end

tagged = ~isnan([JamesList(idx).ID]);
PostTable = PostList(idx);
SizeOnScale = [JamesList(idx).scaleArea];
SizeInHS = [JamesList(idx).Area];
ID = [JamesList(idx).ID];
Incoming = [JamesList(idx).in];
Height = [JamesList(idx).TraversalHeight];
Speed = [JamesList(idx).TraversalSpeed];

t = table(DateTable, HourTable, HiveTable', DaysSince', PostTable', Temperature', WindSpeed', ...
            LightLevel', Pressure', tagged', SizeOnScale', SizeInHS', ID', Incoming', Height', Speed', ...
            'VariableNames',{'Date';'Hour';'Hive';'TestDays';'Posts';'Temperature';'WindSpeed';...
            'LightLevel';'Pressure';'Tagged';'SizeOnScale';'SizeInHS';'ID';'Incoming';...
            'Height';'Speed';});
  
%% Output the data

% writetable(t, '/Users/nickgravish/Dropbox/high throughput current/Data/DataTable.csv');
    
    















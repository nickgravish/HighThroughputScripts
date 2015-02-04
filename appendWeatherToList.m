%Appends nearest weather log data to each flight trial in 'JamesList' 
%database as a new structure field ('weather').
%Nearest weather log timestamps that fall under selected proximity 
%threshold ('proxthresh') are appended, while those outside proximity 
%are not considered representative of trial, and are therefore registered 
%with 'NaN' values. Default proximity threshold is 30 minutes.


%Load clean flight data
if ~exist('JamesList') %If JamesList is already loaded, don't load again
    load('~/Dropbox/High Throughput Current/Data/JamesList.mat');
end

%Load weather master data
load('~/Dropbox/High Throughput Current/Data/weatherDataMaster.mat');


%%

%Enter threshold (in seconds) for allowable proximity of weather log
proxthresh = 20; %Default value is 20 seconds.

%Create datenum values for each row of weather data
dateNumber = datenum(weatherDataMaster(:,1:6));

%March through each entry in 'JamesList' and find nearest weather log
%Add new field in 'JamesList' with associated weather data
for ii=1:length(JamesList)
    
    target = JamesList(ii).datenum;
    [val,hit] = min(abs(target-dateNumber)); %find nearest weather reading
    
    JamesList(ii).weather.nearestlog = datestr(weatherDataMaster(hit,1:6));
    JamesList(ii).weather.logdatenum = dateNumber(hit);
    JamesList(ii).weather.logproximity = val;

    if val > proxthresh/(60*60*24) % nearest weather log is above threshold
        JamesList(ii).weather.inrange = 1;
        JamesList(ii).weather.lux = NaN;
        JamesList(ii).weather.windspeed = NaN;
        JamesList(ii).weather.winddir = NaN;
        JamesList(ii).weather.temp = NaN;
        JamesList(ii).weather.pressure = NaN;
    else
        JamesList(ii).weather.inrange = 0;
        JamesList(ii).weather.lux = weatherDataMaster(hit,7);
        JamesList(ii).weather.windspeed = weatherDataMaster(hit,8);
        JamesList(ii).weather.winddir = weatherDataMaster(hit,9);
        JamesList(ii).weather.temp = weatherDataMaster(hit,10);
        JamesList(ii).weather.pressure = weatherDataMaster(hit,11);
    end
    
end



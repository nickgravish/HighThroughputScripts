% Create hiveTimes object
hiveTimes = [];
hiveTimes(1:7,1) = 1:7;
hiveTimes(:,2:3) = zeros(7,2);

%Hive 1 times
hiveTimes(1,2) = datenum('27-Jun-2014 16:00:00');
hiveTimes(1,3) = datenum('09-Jul-2014 16:00:00');

%Hive 2 times
hiveTimes(2,2) = datenum('09-Jul-2014 17:00:00');
hiveTimes(2,3) = datenum('30-Jul-2014 15:45:00');

%Hive 3 times
hiveTimes(3,2) = datenum('30-Jul-2014 17:00:00');
hiveTimes(3,3) = datenum('13-Aug-2014 11:00:00');

%Hive 4 times
hiveTimes(4,2) = datenum('13-Aug-2014 19:00:00');
hiveTimes(4,3) = datenum('20-Aug-2014 10:00:00');

%Hive 5 times
hiveTimes(5,2) = datenum('20-Aug-2014 13:50:00');
hiveTimes(5,3) = datenum('10-Sep-2014 12:00:00');

%Hive 6 times
hiveTimes(6,2) = datenum('10-Sep-2014 14:00:00');
hiveTimes(6,3) = datenum('01-Oct-2014 15:00:00');

%Hive 7 times
hiveTimes(7,2) = datenum('03-Oct-2014 10:00:00');
hiveTimes(7,3) = datenum('01-Dec-2014 16:00:00');

save('//Users/james/Dropbox/High Throughput Current/Data/hiveTimes.mat', 'hiveTimes');

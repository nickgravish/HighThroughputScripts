
%% Load in data from scale tracking
if ~exist('centroidsM')
    load('~/Dropbox/High Throughput Current/Data/scaleDataMaster.mat');
end

%% loop through centroids and associate with IDs

% date format is yearmonthdayTtime, will generate a hash value from the 
%    date to store the index of the record in the sparseidxlist hash table
sparseidxlist = sparse(1);

for kk=1:height(centroidsM)
    
    str = centroidsM(kk,1).file{:};
    str = str([5:8 10:18]); % remove 2014, end, and T
    
    idx = str2num(str);
    
    sparseidxlist(idx) = kk;
    kk
end

%% now loop through the codesM, and associate each code with a centroid index

for kk=1:height(codesM)
    
    str = codesM(kk,6).name{:};
    str = str([5:8 10:18]); % remove 2014, end, and T
    
    idx = str2num(str);
    
    centroidIdx = sparseidxlist(idx);
    
    codesMcentroid(kk) = full(centroidIdx);
    kk
end
    
    
    

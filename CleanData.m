
%% Load data

% this is where my master list is stored, but you may nor have access to
% it.
load('/Users/nickgravish/Documents/Research_Share/HighThroughputExperiments/MasterList.mat')

% the useful things to know in the data structure:

% MasterList --
%     name              : Name of the video
%     date              : Date taken in human readable
%     datenum           : Date taken in matlab serial date number
%     intensity         : Mean intensity of the camera views
%     Center            : Center (u, v) coordinates from the 4 cameras. NaN
%                           indicate no observation. Compatible with DLT
%     MajorAxis         : Major ellipse axis        
%     MinorAxis         : Minor ellipse axis
%     Orientation       : Orientatino of the ellipse
%     xyz               : Raw xyz calculated points
%     xyz_spline        : First pass interpolation and spline
%     xyz_spline2       : Second pass with a low pass filter 
%     errs              : Backprojected pixel error
%     CorrectlyTracked  : Boolean flag for correctly tracked (==1)
%     vel               : Magnitude of velocity 
%     velx              : Velocity in x
%     vely              : ... y
%     velz              : ... z
%     accel             : Magnitude of acceleration
%     accelx            : ... x
%     accely            : ... y
%     accelz            : ... z
%     rho               : Polar coordinates r location, centered on enter
%     theta             : polar coord
%     in                : Flag for incoming or outgoing
%     distance          : Total distance traveled
%     pathlength        : Path length of the path traveled



%% List of calibration files for certain dates. Dates given in 
%  /Users/nickgravish/Dropbox/Harvard/HighThroughputExpt/BackgroundNotes.xlsx

CameraCoefficients(3).cal = csvread('/Users/nickgravish/Dropbox/Harvard/HighThroughputExpt/Calibrations/2014-07-25_13.23.02/cal01_DLTcoefs.csv');
CameraCoefficients(4).cal = csvread('/Users/nickgravish/Dropbox/Harvard/HighThroughputExpt/Calibrations/2014-08-14_09.28.53/cal01_DLTcoefs.csv');
CameraCoefficients(5).cal = csvread('/Users/nickgravish/Dropbox/Harvard/HighThroughputExpt/Calibrations/2014-09-27_17.14.37/cal01_DLTcoefs.csv');

CalNum(1:221)                   = 1; % XX Need to fix
CalNum(222:7876)                = 2; % XX Need to fix
CalNum(7877:12286)              = 3;
CalNum(12287:21376)             = 4;
CalNum(21376:length(MasterList))      = 5;

%% List of post files
postdir = '/Users/nickgravish/Dropbox/Harvard/HighThroughputExpt/Bee Foraging Experiments Summer 2014/Post Positions';

Posts(1) = load(fullfile(postdir, 'PostPos_20140703.mat'),'xx_postkeepers','yy_postkeepers');
Posts(2) = load(fullfile(postdir, 'PostPos_20140709.mat'),'xx_postkeepers','yy_postkeepers');
Posts(3) = load(fullfile(postdir, 'PostPos_20140716.mat'),'xx_postkeepers','yy_postkeepers');
Posts(4) = load(fullfile(postdir, 'PostPos_20140723.mat'),'xx_postkeepers','yy_postkeepers');
Posts(5) = load(fullfile(postdir, 'PostPos_20140730.mat'),'xx_postkeepers','yy_postkeepers');
Posts(6) = load(fullfile(postdir, 'PostPos_20140806.mat'),'xx_postkeepers','yy_postkeepers');
Posts(7) = load(fullfile(postdir, 'PostPos_20140813.mat'),'xx_postkeepers','yy_postkeepers');
Posts(8) = load(fullfile(postdir, 'PostPos_20140820.mat'),'xx_postkeepers','yy_postkeepers');
Posts(9) = load(fullfile(postdir, 'PostPos_20140911.mat'),'xx_postkeepers','yy_postkeepers');
Posts(10) = load(fullfile(postdir, 'PostPos_20140919.mat'),'xx_postkeepers','yy_postkeepers');
Posts(11) = load(fullfile(postdir, 'PostPos_20140920.mat'),'xx_postkeepers','yy_postkeepers');
Posts(12) = load(fullfile(postdir, 'PostPos_20140922.mat'),'xx_postkeepers','yy_postkeepers');
Posts(13) = load(fullfile(postdir, 'PostPos_20140924.mat'),'xx_postkeepers','yy_postkeepers');
Posts(14) = load(fullfile(postdir, 'PostPos_20140926.mat'),'xx_postkeepers','yy_postkeepers');
Posts(15) = load(fullfile(postdir, 'PostPos_20141002_updated.mat'),'xx_postkeepers','yy_postkeepers');
Posts(16) = load(fullfile(postdir, 'PostPos_20141010.mat'),'xx_postkeepers','yy_postkeepers');

PostList(1:length(MasterList))        = 1;
PostList(1:186)                 = 1; % Fix
PostList(187:293)               = 1;
PostList(294:2682)              = 2;
PostList(2683:5738)             = 3;
PostList(5826:8497)             = 4;
PostList(8550:10464)            = 5;
PostList(10525:12204)           = 6;
PostList(12288:14107)           = 7;
PostList(14108:18979)           = 8;
PostList(18980:21155)           = 9;
PostList(21156:21375)           = 10;
PostList(21502:22160)           = 11;
PostList(22211:22524)           = 12;
PostList(22525:23317)           = 13;
PostList(23318:24935)           = 14;
PostList(24970:26379)           = 15;
PostList(26380:length(MasterList))    = 16;


%% compute velocity statistics, and polar coordinates

for kk=1:length(MasterList)

    if(~isempty(MasterList(kk).xyz_spline))
        
        [theta rho z] = cart2pol(MasterList(kk).xyz_spline2(:,1), MasterList(kk).xyz_spline2(:,2),...
                                MasterList(kk).xyz_spline2(:,3));    
                            
        MasterList(kk).rho = rho(1:1199);
        MasterList(kk).theta = theta(1:1199);
        
        distperstep = sqrt(diff(MasterList(kk).xyz_spline(:,1)).^2 + ...
                            diff(MasterList(kk).xyz_spline(:,2)).^2 + ...
                            diff(MasterList(kk).xyz_spline(:,3)).^2);
        MasterList(kk).vel = distperstep * 300;
        MasterList(kk).velx = diff(MasterList(kk).xyz_spline(:,1))* sampFreq;
        MasterList(kk).vely = diff(MasterList(kk).xyz_spline(:,2))* sampFreq;
        MasterList(kk).velz = diff(MasterList(kk).xyz_spline(:,3))* sampFreq;
        
         
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


%% count number of correctly tracked videos
IsTracked = logical(arrayfun(@(x) iff(isempty(x.CorrectlyTracked),0,x.CorrectlyTracked), MasterList));

%% count if trajectory is within the post array

for kk=1:length(list)
    
    if(IsTracked(kk))
        [theta rho z] = cart2pol(MasterList(kk).xyz_spline2(:,1), MasterList(kk).xyz_spline2(:,2), MasterList(kk).xyz_spline2(:,3));    
        if(~isempty(z(rho < 40)))
            InPosts(kk) = all(z(rho < 40) > 0 & z(rho < 40) < 15);
        else
            InPosts(kk) = 0;
        end
        
    else
        InPosts(kk) = 0;
    end
    kk
end

%% find walkers

%walking = arrayfun(@(x) iff(isempty(x.vel),Inf,min(x.xyz_spline(:,3))), MasterList);

for kk=1:length(MasterList)
    
    if(IsTracked(kk))
        [theta rho z] = cart2pol(MasterList(kk).xyz_spline2(:,1), MasterList(kk).xyz_spline2(:,2), MasterList(kk).xyz_spline2(:,3));    

        walking(kk) = median(MasterList(kk).xyz_spline(rho > 5,3)) < 1;
    else
        walking(kk) = 0;
    end
    kk
end


%% compute in outs

entranceloc = [0 0 5];
loc_tolerance = 1;


for kk=1:length(MasterList)

    if(~isempty(MasterList(kk).xyz_spline))

        xyz = MasterList(kk).xyz_spline;
        
        distfromenter = sqrt(sum((xyz-repmat(entranceloc,length(xyz),1))'.^2));
        ind = ~isnan(distfromenter);
        time = [0:1:length(distfromenter)-1];
        MasterList(kk).in = -1;
        
        if(nnz(ind) > 10)
        
            ftt = fit(time(ind)', distfromenter(ind)', fittype(@(a,b,x) a*x+b));

            slop(kk) = ftt.a;
            kk

            if(slop(kk) > 0.005)
                MasterList(kk).in = 0;
            elseif(slop(kk) < -0.005)
                MasterList(kk).in = 1;
            end

        end
        
%         clf;
%         plot(distfromenter);
%         hold on;
%         plot(ftt);
%         drawnow;
    end
end

%% compute distance traveled

for kk=1:length(MasterList)
    
    if(~any(all(isnan(MasterList(kk).xyz_spline))))

        xyz = MasterList(kk).xyz_spline;
        ind = find(~isnan(xyz(:,1)));
        dst = sqrt(sum(diff(xyz([ind(1) ind(end)],:)).^2));
        MasterList(kk).distance = dst;
        
        MasterList(kk).pathlength = sum(sqrt(sum(diff(xyz(ind,:)).^2)));
        
    end
    kk
end

%% add in post list to MasterList

for kk=1:length(MasterList)
    MasterList(kk).postnumber = PostList(kk);
end

%%

JamesList = MasterList(IsTracked);

%%

save('JamesList.mat', '-v7.3', 'JamesList','Posts')



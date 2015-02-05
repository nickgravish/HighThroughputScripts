


%% From the table t generated in PrepareCSVForR.m

%% Start with a simple mixed effects model
lme = fitlme(t, 'Speed ~ 1 + Temperature + (1 | Hive)')
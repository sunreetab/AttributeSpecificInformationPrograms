% runSaveData
% Vidhi - 6/11/21

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Choose %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subjectName = 'alpaH'; protocolType = 'FlickeringGratings'; 
% subjectName = 'alpaH'; protocolType = 'NaturalImages'; 
% subjectName = 'kesariH'; protocolType = 'FlickeringGratings'; 
 subjectName = 'kesariH'; protocolType = 'NaturalImages'; 

%%%%%%%%%%%%%%%%%%%% Common Params for all methods %%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%% Choose Method %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

methodName = 'MultiTaper';
methodParams.tapers = [2,3];
methodParams.Fs = 2000;
methodParams.winSize = 0.05;
methodParams.winStep = 0.001;
methodParams.frequencyRangeList = [{[8 12]} {[30 80]} {[150 250]}];
methodParams.factor = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%% Folder Strings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(protocolType,'FlickeringGratings')
    folderSourceString = 'N:\commonData\Non_Standard\RateVsSynchrony';
else
    folderSourceString = 'N:\commonData\Non_Standard\NaturalImages';
end
folderSaveString = 'N:\Projects\AttributeSpecificInformationProject\preMadeData';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get expDates and protocolNames
[expDates,protocolNames] = getExptInformation(subjectName,protocolType);

% Save data for each session
% for i=1:length(expDates)
for i = 1:length(expDates)
    tic 
    expDate = expDates{i};
    protocolName = protocolNames{i};
    disp([subjectName ' ' expDate ' | ' protocolName 'in progress...']);
    saveData(subjectName,expDate,protocolName,protocolType,folderSourceString,folderSaveString,methodName,methodParams);
    toc
end

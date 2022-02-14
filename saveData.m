% We save the following information:
% For LFPs
% 1. Average time-frequency power spectra for each condition (averaged over trials)
% 2. Average power as a function of time in each trial in the frequency ranges specified by methodParams.frequencyRangeList

% For Spikes:
% 1. Number of spikes in timesteps defined by methodParams.winStep, for each trial

function saveData(subjectName,expDate,protocolName,protocolType,folderSourceString,folderSaveString,methodName,methodParams)

gridType='Microelectrode';

% Get Useful Folders
folderDate = fullfile(folderSourceString,'data',subjectName,gridType,expDate);
folderName = fullfile(folderDate,protocolName);
folderExtract = fullfile(folderName,'extractedData');
folderSegment = fullfile(folderName,'segmentedData');
folderLFP = fullfile(folderSegment,'LFP');
folderSpikes = fullfile(folderSegment,'Spikes');

% Get electrodes on which analysis will be done
goodElectrodes = getGoodElectrodes(subjectName);

%Bad Trials Load
if exist(fullfile(folderSegment,'badTrials.mat'), 'file')
    x=load(fullfile(folderSegment,'badTrials.mat'));
    badTrials = x.badTrials;
else
    disp('Bad trials file not found...');
    badTrials = [];
end

% timeVals
x = load(fullfile(folderLFP,'lfpInfo.mat'));
timeVals = x.timeVals;
Fs = round(1/(timeVals(2)-timeVals(1)));
methodParams.Fs = Fs;

% parameterCombinations
parameterCombinations = load(fullfile(folderExtract,'parameterCombinations.mat'));
fBands = methodParams.frequencyRangeList;
numFrequencyBands = length(fBands);

% Make Folders
folderSaveEnergy = [protocolType methodName];
folderSaveSpikes  = [protocolType 'Spikes'];
folderSaveDataEnergy  = fullfile(folderSaveString,folderSaveEnergy,subjectName,expDate,protocolName);
folderSaveDataSpikes   = fullfile(folderSaveString,folderSaveSpikes,subjectName,expDate,protocolName);

makeDirectory(folderSaveDataEnergy);
makeDirectory(folderSaveDataSpikes);

if strcmp(protocolType,'FlickeringGratings') % Counterphasing gratings dataset
    conditionVals = parameterCombinations.tValsUnique;
    numCombinations = length(conditionVals);
    goodPosList = cell(1,numCombinations);
    aPos=1;ePos=1;rPos=1;oPos=5;cPos=7;fPos=1;
    for i=1:numCombinations
        goodPosList{i} = setdiff(parameterCombinations.parameterCombinations{aPos,ePos,rPos,fPos,oPos,cPos,i},badTrials);
    end
    
elseif strcmp(protocolType,'NaturalImages') % Natural Images dataset
    conditionVals = parameterCombinations.fValsUnique;
    numCombinations = length(conditionVals);
    goodPosList = cell(1,numCombinations);
    aPos=1;ePos=1;rPos=1;oPos=1;cPos=1;tPos=1;
    for i=1:numCombinations
        goodPosList{i} = setdiff(parameterCombinations.parameterCombinations{aPos,ePos,rPos,i,oPos,cPos,tPos},badTrials);
    end
end

for i=1:size(goodElectrodes,2)
    elec = goodElectrodes(i);
    disp(['Electrode: ' num2str(elec)]);
    
    % Get Analog Data
    clear analogData; clear analogInfo;
    if exist(fullfile(folderLFP ,['elec' num2str(elec) '.mat']), 'file')
        analogData = load(fullfile(folderLFP ,['elec' num2str(elec) '.mat']));
    else
        analogData = [];
    end
    
    if ~isempty(analogData)
        saveDataFileName = fullfile(folderSaveDataEnergy,['elec' num2str(elec) '_c' num2str(cPos)]);
        
        meanEnergyTF = cell(1,numCombinations); % Mean power
        energyVsT = cell(numCombinations,numFrequencyBands); % EnergyVsTime
        
        for j=1:numCombinations
            goodPos = goodPosList{j};
            
            [S,tSpec,fSpec] = getEnergyData(analogData.analogData(goodPos,:),methodName,methodParams);
            tSpec = tSpec + timeVals(1);
            
            meanEnergyTF{j} = squeeze(mean(S,3));           
            
            for k=1:numFrequencyBands
                fRange = fBands{k};
                fid1 = find(fSpec> fRange(1), 1); fid2 = find(fSpec <= fRange(2), 1, 'last');
                energyVsT{j,k} = squeeze(mean(S(:,fid1:fid2,:),2))';
            end
        end
        save(saveDataFileName,'meanEnergyTF','energyVsT','tSpec','fSpec','conditionVals','fBands');
    end
        
    % Get Spike Data
    clear spikeData; clear spikeInfo;
    if exist(fullfile(folderSpikes,['elec' num2str(elec) '_SID0.mat']), 'file')
        spikeData = load(fullfile(folderSpikes ,['elec' num2str(elec) '_SID0.mat']));
    else
        spikeData = [];
    end
    
    if ~isempty(spikeData)
        saveDataFileName = fullfile(folderSaveDataSpikes,['elec' num2str(elec) '_c' num2str(cPos)]);
        
        sRaster = cell(1,numCombinations);
        for j=1:numCombinations
            goodPos = goodPosList{j};
            xRaster = spikeData.spikeData(:,goodPos);
            [sRaster{j},tRaster] = getSpikeRaster(xRaster,[tSpec(1)-methodParams.winStep/2 tSpec(end)+methodParams.winStep/2],methodParams.winStep);
        end
        save(saveDataFileName,'sRaster','tRaster','conditionVals');
    end
end
end

function[S,t,f] = getEnergyData(X,methodName,methodParams)
if strcmp(methodName,'MultiTaper')
    % MT parameters
    params.tapers   = methodParams.tapers;
    params.pad      = -1;
    params.Fs       = methodParams.Fs;
    params.fpass    = [0 250];
    params.trialave = 0;
    movingwin = [methodParams.winSize methodParams.winStep];
    [S,t,f] = mtspecgramc(X',movingwin,params);
end
end
function[S,tvec] = getSpikeRaster(spikeData, T, dt)
% input spikeData as a cell array of spike times
% T = [T1, T2] = the end points of the big interval
% dt = size of time bins

eps = 0.000001; % tolerance for comparisons

S = zeros(size(spikeData,2), round(diff(T)/dt)); % numTrials x numTimeBins
tvec = zeros(round(diff(T)/dt),1);

t1 = T(1); t2 = T(1) + dt;

ctr = 0;

while abs(t1 - T(2)) > eps
    ctr = ctr + 1;
    S(:, ctr) = getSpikeCounts(spikeData, [t1,t2])';
    tvec(ctr) = 0.5*(t1+t2);
    
    t1 = t2;
    t2 = t2 + dt;
end
end
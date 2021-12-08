% We save the following information:
% For Spikes:
% 1. PSTH (firing rate for each condition, averaged over trials)
% 2. Number of spikes in timesteps defined by methodParams.binSize, for each trial

% For LFPs

% 1. Average time-frequency power spectra for each condition (averaged over trials)
% 2. Average power as a function of time in each trial in the frequency ranges specified by methodParams.frequencyRangeList
% Vidhi Modified - 6/11/21
function saveData(subjectName,expDate,protocolName,protocolType,folderSourceString,folderSaveString,methodName,methodParams)

gridType='Microelectrode';

% Get Useful Folders
folderDate = fullfile(folderSourceString,'data',subjectName,gridType,expDate);
folderName = fullfile(folderDate,protocolName);
folderExtract = fullfile(folderName,'extractedData');
folderSegment = fullfile(folderName,'segmentedData');
folderLFP = fullfile(folderSegment,'LFP');
folderSpikes = fullfile(folderSegment,'Spikes');
% Get electrodes on which analysis will be done - this could be all highRMSElectrodes
% goodElectrodes = getGoodElectrodes(subjectName);

% goodElectrodes = [2, 5, 40, 47, 48,	49,	50,	57,	58,	60,	67,	68,	77,	78]; % kesariH new uelecs
goodElectrodes = [88, 89]; % alpaH remaining ECoG elecs
% goodElectrodes = [43]; % for kesariH
% goodElectrodes = [82, 85, 86, 88, 89]; % for kesariH

%Bad Trials Load
if exist(fullfile(folderSegment,'badTrials.mat'), 'file')
    load(fullfile(folderSegment,'badTrials.mat'));
else
    badTrials = []; % Sunreeta 210921; 
end

% timeVals
x = load(fullfile(folderLFP,'lfpInfo.mat'));
timeVals = x.timeVals;
Fs = round(1/(timeVals(2)-timeVals(1)));
methodParams.Fs = Fs;

% parameterCombinations
x = load(fullfile(folderExtract,'parameterCombinations.mat'));
parameterCombinations = x.parameterCombinations;
fBandName = {'alpha','gamma','highGamma'};
fBands = methodParams.frequencyRangeList;

if strcmp(protocolType,'FlickeringGratings') % Counterphasing gratings dataset
    %%Flickering Gratings Dataset

    folderSaveMTM       = 'FlickeringGratingsMTM';
    folderSaveSpikes    = 'FlickeringGratingsSpikes';
    folderSaveDataMTM   = fullfile(folderSaveString, folderSaveMTM, subjectName, expDate, protocolName);
    folderSaveDataSpikes= fullfile(folderSaveString, folderSaveSpikes, subjectName, expDate, protocolName);

    makeDirectory(folderSaveDataMTM); %making a folder for Multitaper data
    makeDirectory(folderSaveDataSpikes);

   
    aPos=1;ePos=1;rPos=1;oPos=5;cPos=7;fPos=1;

    for k=1:size(goodElectrodes,2)

        Elec = goodElectrodes(k);

        clear analogData; clear analogInfo;

        if exist(fullfile(folderLFP ,['elec' num2str(Elec) '.mat']), 'file')
            load(fullfile(folderLFP ,['elec' num2str(Elec) '.mat']));
            analogDataExists = 1;
        else
            analogDataExists = 0;
        end

        clear spikeData; clear spikeInfo;

        if exist(fullfile(folderSpikes ,['elec' num2str(Elec) '_SID0.mat']), 'file')
            load(fullfile(folderSpikes ,['elec' num2str(Elec) '_SID0.mat']));
            spikeDataExists = 1;
        else
            spikeDataExists = 0;
        end

        for tPos = 1:size(x.tValsUnique,2)
            goodPos = setdiff(x.parameterCombinations{aPos,ePos,rPos,fPos,oPos,cPos,tPos},badTrials);
            if analogDataExists
                X = analogData(goodPos,:);
                [S,tSpec,fSpec] = getEnergyData(X,methodName,methodParams);

            
                factor = methodParams.factor;
                index = factor*floor(size(tSpec,2)/factor);
                TFPlotFolder = fullfile(folderSaveDataMTM,['Elec' num2str(Elec)],'LowResTF');
                makeDirectory(TFPlotFolder);
                TFPlotfileName = ['con_' num2str(length(x.cValsUnique)-1) '_tf_' num2str(x.tValsUnique(tPos)) '.mat'];
                SAvg = avgDownsample(mean(S(:,1:index,:),3),5);
                save(fullfile(TFPlotFolder,TFPlotfileName),'SAvg');
    
                tSpec = tSpec + timeVals(1) -1/Fs;
    
                for i=1:size(fBands,2)
                    fRange = cell2mat(fBands(i));
                    fid1 = find(fSpec> fRange(1), 1); fid2 = find(fSpec <= fRange(2), 1, 'last');
                    Energy = squeeze(mean(S(fid1:fid2,:,:),1))';
                    Rhythm = cell2mat(fBandName(i));
                    EnergyFolder = fullfile(folderSaveDataMTM,['Elec' num2str(Elec)],Rhythm);
                    makeDirectory(EnergyFolder);
                    fileName = ['con_' num2str(length(x.cValsUnique)-1) '_tf_' num2str(x.tValsUnique(tPos)) '.mat'];
                    save(fullfile(EnergyFolder,fileName),'Energy');
                end
            end

            if spikeDataExists
                XRaster = spikeData(:,goodPos);
                [SRaster,tRaster] = getSpikeRaster(XRaster,[tSpec(1)-methodParams.winStep/2 tSpec(end)+methodParams.winStep/2],methodParams.winStep);
            
                RasterFolder = fullfile(folderSaveDataSpikes,['Elec' num2str(Elec)]);
                makeDirectory(RasterFolder);
                save(fullfile(RasterFolder,fileName),'SRaster');
            end

        end
    end
    save(fullfile(folderSaveDataMTM,'tSpec'),'tSpec');
    save(fullfile(folderSaveDataMTM,'fSpec'),'fSpec');
    save(fullfile(folderSaveDataSpikes,'tRaster'),'tRaster');
    
elseif strcmp(protocolType,'NaturalImages') % Natural Images dataset
    %%Natural Images Dataset

    folderSaveMTM = 'NaturalImagesMTM';
    folderSaveSpikes = 'NaturalImagesSpikes';
    folderSaveDataMTM = fullfile(folderSaveString, folderSaveMTM, subjectName, expDate, protocolName);
    folderSaveDataSpikes = fullfile(folderSaveString, folderSaveSpikes, subjectName, expDate, protocolName);
    makeDirectory(folderSaveDataMTM); %making a folder for Multitaper data
    makeDirectory(folderSaveDataSpikes);
    
    
    aPos=1;ePos=1;rPos=1;oPos=1;cPos=1;tPos=1;
    for k=1:size(goodElectrodes,2)
        Elec = goodElectrodes(k);

        clear analogData; clear analogInfo;

        if exist(fullfile(folderLFP ,['elec' num2str(Elec) '.mat']), 'file')
            load(fullfile(folderLFP ,['elec' num2str(Elec) '.mat']));
        end

        clear spikeData; clear spikeInfo;

        if exist(fullfile(folderSpikes ,['elec' num2str(Elec) '_SID0.mat']), 'file')
            load(fullfile(folderSpikes ,['elec' num2str(Elec) '_SID0.mat']));
        end

        for fPos = 1:size(x.fValsUnique,2)
            goodPos = setdiff(x.parameterCombinations{aPos,ePos,rPos,fPos,oPos,cPos,tPos},badTrials);
            X = analogData(goodPos,:);
            XRaster = spikeData(:,goodPos);
            [S,tSpec,fSpec] = getEnergyData(X,methodName,methodParams);

            factor = methodParams.factor;
            index = factor*floor(size(tSpec,2)/factor);
            TFPlotFolder = fullfile(folderSaveDataMTM,['Elec' num2str(Elec)],'LowResTF');
            makeDirectory(TFPlotFolder);
            TFPlotfileName = ['image_' num2str(fPos) '.mat'];
            SAvg = avgDownsample(mean(S(:,1:index,:),3),5);
            save(fullfile(TFPlotFolder,TFPlotfileName),'SAvg');

            tSpec = tSpec + timeVals(1) -1/Fs;
            [SRaster,tRaster] = getSpikeRaster(XRaster,[tSpec(1)-methodParams.winStep/2 tSpec(end)+methodParams.winStep/2],methodParams.winStep);
            for i=1:size(fBands,2)
                fRange = cell2mat(fBands(i));
                fid1 = find(fSpec> fRange(1), 1); fid2 = find(fSpec <= fRange(2), 1, 'last');
                Energy = squeeze(mean(S(fid1:fid2,:,:),1))';
                Rhythm = cell2mat(fBandName(i));
                EnergyFolder = fullfile(folderSaveDataMTM,['Elec' num2str(Elec)],Rhythm);
                makeDirectory(EnergyFolder);
                fileName = ['image_' num2str(fPos) '.mat'];
                save(fullfile(EnergyFolder,fileName),'Energy');
            end
            RasterFolder = fullfile(folderSaveDataSpikes,['Elec' num2str(Elec)]);
            makeDirectory(RasterFolder);
            save(fullfile(RasterFolder,fileName),'SRaster');
        end
    end
    save(fullfile(folderSaveDataMTM,'tSpec'),'tSpec');
    save(fullfile(folderSaveDataMTM,'fSpec'),'fSpec');
    save(fullfile(folderSaveDataSpikes,'tRaster'),'tRaster');
else
    disp(['ProtocolType: ' protocolType ' does not exist']);
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
    [S_transpose,t,f] = mtspecgramc(X',movingwin,params);
    S = pagetranspose(S_transpose); % to get freq X times x trials from times X freq x trials
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

function Y = avgDownsample(X, factor)
% downsample columns of X by factor after averaging 'factor' elements
Y = zeros(size(X,1), size(X,2)/factor);
for i = 1:size(X,1)
    xx = X(i,:);
    xx = mean(reshape(xx, factor, []));
    Y(i,:) = xx;
end
end

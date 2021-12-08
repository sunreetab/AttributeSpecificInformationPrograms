function [RElecs] = getResponseCell(folderSourceString,subjectName,expDate,protocolName,...
    eleclist,downsampleFactor,stimVar,stimulusType,isSpikeData,tRange)

% This is a function which runs on the pre-made data matrices containing
% spike data or high-gamma power in a specific format.It returns the
% response matrix RElecs
% Electrodes need to be specified, and assigned to the
% variable 'eleclist'. The flag variable 'isSpikeData' must be toggled as required
% i.e. 1 if its-spike data or 0 if its LFP/ECoG data. this
% code works for both spike and LFP/ECoG data.The downsampleFactor is the
% factor by which the original time series needs to be downsampled.
% stimulusType: 1 for flickering gratings
%               2 for natural images
% stimVar is a 2 element vector consisting of the start and end of variable associated with stimulus
% conditions. For eg for natural images stimVar can be [1,16] just means
% images are from 1 to 16.
% timeseries is the time values for which spike data and high-gamma power
% is evaluated for. tRange is a two element vector which specifies what
% range of time we want to make the repsonse cell for.
% Vidhi - 03/12/2021

RElecs = cell(length(eleclist),1);
timefolder = fullfile(folderSourceString,subjectName,expDate,protocolName);
for ielec = 1:length(eleclist)
    elecnum = eleclist(ielec);
    if ~isSpikeData
        elecpath = fullfile(folderSourceString,subjectName,expDate,protocolName, ['elec' num2str(elecnum)],'highGamma');
        Varname = 'Energy';
        timeVarname = 'tSpec';
    else
        elecpath = fullfile(folderSourceString,subjectName,expDate,protocolName, ['elec' num2str(elecnum)]);
        Varname = 'SRaster';
        timeVarname = 'tRaster';
    end
    timeseries = load(fullfile(timefolder,[timeVarname '.mat']));
    timeseries = timeseries.(timeVarname);

    tstart = find(timeseries>tRange(1),1); % start time indice
    tend = find(timeseries>tRange(2),1)-1; %end time indice
    stim = stimVar(1):1:stimVar(2);
    RCell = cell(size(stim,2),1);
    
    numConVals = 7; % hard-coded number of contrasts. source: parameterCombinations
    TFValsToUse = [0, 1, 2, 4, 8, 16, 32, 50]; % cps. source: parameterCombinations

    for istim = 1:size(stim,2)
        if stimulusType == 1 % for flickering stimuli
            filename = ['con_' num2str(numConVals - 1)...
                '_tf_' num2str(TFValsToUse(stim(istim))) '.mat'];
        end
        if stimulusType == 2 % for natural images stimuli
            filename = ['image_' num2str(stim(istim)) '.mat'];
        end
        x = load(fullfile(elecpath,filename));
        x = x.(Varname);
        RCell{istim,1} = avgDownsample(x(:,tstart:tend),downsampleFactor);
    end
    RElecs{ielec,1} = RCell;
    
end
end

function Y = avgDownsample(X, factor)
% downsample columns of X by factor after averaging 'factor' elements
cols = (size(X,2)-mod(size(X,2),factor));
Y = zeros(size(X,1),cols/factor);
for i = 1:size(X,1)
    xx = X(i,1:cols);
    xx = mean(reshape(xx, factor, []));
    Y(i,:) = xx;
end
if mod(size(X,2),factor)>0
    t = zeros(size(X,1),1);
    for i = 1:size(X,1)
        t(i) = mean(X(i,cols+1:end));
    end
    Y = [Y t];
end
end
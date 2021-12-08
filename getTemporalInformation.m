function [ITemporalVec] = getTemporalInformation(ResponseCell, optsTemporal, nb, binningOpt, par)
%Pass the response cell with rows as stimuli (i.e. 16 images or 8
%gratings)for each electrode. This function returns a vector of
%time-specific information values where the length of the vector is
%'numstim' i.e. 8 or 16. opt is the option for binning method i.e.
%'eqspace' or 'eqpop'. nb is the number of bins used for creating the
%distribution.
% Vidhi - 28/10/21
% Sunreeta - 04/12/21

numTimeSteps    = size(ResponseCell{1,1},2);
numStimuli      = size(ResponseCell,1);
ITemporalVec    = zeros(1,numStimuli);

for k=1:numStimuli

    STemporal = []; % creating stimulus array
    clear temp
    temp = ResponseCell{k,1};
    % temp is a 2D array of size numTrials x numTimeSteps
    

    for i=1:numTimeSteps

        clear A
        A = i*ones(size(temp,1),1);
        STemporal = cat(1,STemporal,A);

    end
    
    RTemporal = []; % creating response array

    for i=1:numTimeSteps
        clear A
        A = temp(:,i);
        RTemporal = cat(1,RTemporal,A);
    end
    
    
    clear ITemporalRaw ITemporalBs I_time
    
    % passing to buildr function
    [RTemporal, ntTemporal] = buildr(STemporal,RTemporal);
    
    % add nt (number of trials) to parameter 'optsTemporal' struct
    optsTemporal.nt = ntTemporal;
    
    % passing to binr function
    RTemporal = binr(RTemporal, optsTemporal.nt, nb, binningOpt, par);
    
    % passing to entropy function
    [HR_time, HRS] = entropy(RTemporal, optsTemporal, 'HR', 'HRS');
    
    ITemporalRaw = (HR_time - HRS(1,1));
    ITemporalBs = (HR_time - mean(HRS(1,2:optsTemporal.btsp+1),2));
    ITemporal = ITemporalRaw - ITemporalBs;
    ITemporalVec(k) = ITemporal;
    
end
ITemporalVec(ITemporalVec<0) = 0;
end


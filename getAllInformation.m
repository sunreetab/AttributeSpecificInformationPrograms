function [IFormal, IAtt, ITime, ITemporal] = getAllInformation(ResponseCell, opts, nb, binningOpt,responseType)

numElecs = size(ResponseCell,1);
numStimuli = size(ResponseCell{1,1},1);

IFormal= zeros(numElecs,1);
IAtt   = zeros(numElecs,1);
ITime  = zeros(numElecs,1);

ITemporal = zeros(numElecs,numStimuli);


for iElec = 1:numElecs
    
    clear R;
    R = ResponseCell{iElec,1};
    [Rmin, Rmax] = getMinMaxResponseCell(R,responseType); % range parameter for making pmf/histogram
    par = [Rmin, Rmax];
    [IFormal(iElec), IAtt(iElec), ITime(iElec)] = getAttributeInformation(R, ...
                        opts.Formal, opts.Att, opts.Time, ...
                        nb, binningOpt, par);
                    
    ITemporal(iElec,:) = getTemporalInformation(R, opts.Temporal,  nb, binningOpt, par);
                    
    
end

end
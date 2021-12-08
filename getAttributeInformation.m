function [IFormal, IAtt, ITime] = getAttributeInformation(ResponseCell, ...
                        optsFormal, optsAtt, optsTime, ...
                        nb, binningOpt, par)
% add ibtb to path                    
% R_att is the response for the attribute other than time
% Att is temporal freq (R_tf) for Sunreeta

% Sunreeta 10/06/21
% Sunreeta 04/12/21

[SFormal,SAtt,STime,RFormal,RAtt,RTime] = getBuildRMatrix(ResponseCell);

[RFormal, ntFormal] = buildr(SFormal,RFormal);
[RAtt, ntAtt] = buildr(SAtt,RAtt);
[RTime, ntTime] = buildr(STime,RTime);

optsAtt.nt      = ntAtt;
optsTime.nt     = ntTime;
optsFormal.nt   = ntFormal;

RAtt    = binr(RAtt, optsAtt.nt, nb, binningOpt, par);
RTime   = binr(RTime, optsTime.nt, nb, binningOpt, par);
RFormal = binr(RFormal, optsFormal.nt, nb, binningOpt, par);

[HRAtt, HRS] = entropy(RAtt, optsAtt, 'HR', 'HRS');
    IAttRaw     = (HRAtt - HRS(1,1));
    IAttBs      = (HRAtt - mean(HRS(1,2:optsAtt.btsp+1),2));
    IAtt        = IAttRaw - IAttBs;
    
[HRTime, HRS] = entropy(RTime, optsTime, 'HR', 'HRS');
    ITimeTaw    = (HRTime - HRS(1,1));
    ITimeBs     = (HRTime - mean(HRS(1,2:optsTime.btsp+1),2));
    ITime       = ITimeTaw - ITimeBs;
    
[HRFormal, HRS] = entropy(RFormal, optsFormal, 'HR', 'HRS');
    IFormalRaw  = (HRFormal - HRS(1,1));
    IFormalBs   = (HRFormal - mean(HRS(1,2:optsFormal.btsp+1),2));
    IFormal     = IFormalRaw - IFormalBs;
    
    IAtt(IAtt<0) = 0;
    ITime(ITime<0) = 0;
    IFormal(IFormal<0) = 0;
end
function [expDates,protocolNames] = getExptInformation(monkeyName,protocolType)
% Gives the experiment dates and protocol names for associated monkey name
% (alpaH and kesariH) and protocol type (FlickeringGratings and NaturalImages).

if strcmp(monkeyName,'alpaH')
    if strcmp(protocolType,'FlickeringGratings')
        expDates{1} = '290817'; protocolNames{1} = 'GRF_001';
        
    elseif strcmp(protocolType,'NaturalImages')
        expDates{1} = '010817'; protocolNames{1} = 'GRF_001';
        expDates{2} = '080817'; protocolNames{2} = 'GRF_001';
        expDates{3} = '110817'; protocolNames{3} = 'GRF_003';
        expDates{4} = '230817'; protocolNames{4} = 'GRF_001';
        expDates{5} = '240817'; protocolNames{5} = 'GRF_002';
        expDates{6} = '250817'; protocolNames{6} = 'GRF_002';
        expDates{7} = '300817'; protocolNames{7} = 'GRF_002';
        expDates{8} = '310817'; protocolNames{8} = 'GRF_003';
    else
        disp(['ProtocolType: ' protocolType ' does not exist']);
        expDates = []; protocolNames = [];
    end
    
elseif strcmp(monkeyName,'kesariH')
    if strcmp(protocolType,'FlickeringGratings')
        expDates{1} = '010318'; protocolNames{1} = 'GRF_002';
        
    elseif strcmp(protocolType,'NaturalImages')
        expDates{1} = '020118'; protocolNames{1} = 'GRF_001';
        expDates{2} = '030318'; protocolNames{2} = 'GRF_003';
        expDates{3} = '040118'; protocolNames{3} = 'GRF_001';
        expDates{4} = '050118'; protocolNames{4} = 'GRF_003';
        expDates{5} = '050318'; protocolNames{5} = 'GRF_003';
        expDates{6} = '060318'; protocolNames{6} = 'GRF_002';
        expDates{7} = '150118'; protocolNames{7} = 'GRF_001';
        expDates{8} = '170218'; protocolNames{8} = 'GRF_001';
    else
        disp(['ProtocolType: ' protocolType ' does not exist']);
        expDates = []; protocolNames = [];
    end
    
else
    disp(['monkeyName: ' monkeyName ' does not exist']);
        expDates = []; protocolNames = [];
end
end
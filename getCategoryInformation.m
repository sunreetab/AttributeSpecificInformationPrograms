function [expDates,protocolNames,stimVars,icats] = getCategoryInformation(monkeyName,protocolType,Category)
%Gives the experiment dates and  protocol names for an associated category
%of stimuli for each dataset.
% Vidhi - 03/12/2021
if strcmp(monkeyName,'alpaH')
    if strcmp(protocolType,'FlickeringGratings')
        if strcmp(Category,'Contrast100')
            expDates{1} = '290817'; protocolNames{1} = 'GRF_001'; stimVars{1} = [1 8]; icats{1} = 1;
        end
    elseif strcmp(protocolType,'NaturalImages')
        if strcmp(Category,'Flora')
            expDates{1} = '010817' ; protocolNames{1} = 'GRF_001'; stimVars{1} = [17 32]; icats{1} = 1;
            
        elseif strcmp(Category,'Fauna')
            expDates{1} = '300817'; protocolNames{1} = 'GRF_002'; stimVars{1} = [1 16]; icats{1} = 1;
            expDates{2} = '010817'; protocolNames{2} = 'GRF_001'; stimVars{2} = [1 16]; icats{2} = 2;
            
        elseif strcmp(Category,'Texture')
            expDates{1} = '240817'; protocolNames{1} = 'GRF_002'; stimVars{1} = [1 16]; icats{1} = 1;
            expDates{2} = '310817'; protocolNames{2} = 'GRF_003'; stimVars{2} = [1 16]; icats{2} = 2;
            
        elseif strcmp(Category,'Landscape')
            expDates{1} = '240817'; protocolNames{1} = 'GRF_002'; stimVars{1} = [17 32]; icats{1} = 1;
            
        elseif strcmp(Category,'Face')
            expDates{1} = '080817'; protocolNames{1} = 'GRF_001'; stimVars{1} = [1 16]; icats{1} = 1;
            
        else
            disp(['Category: ' Category ' does not exist']);
            Category = [];
        end
    else
        disp(['ProtocolType: ' protocolType ' does not exist']);
        expDates = []; protocolNames = [];
    end
    
elseif strcmp(monkeyName,'kesariH')
    if strcmp(protocolType,'FlickeringGratings')
        if strcmp(Category,'Contrast100')
            expDates{1} = '010318'; protocolNames{1} = 'GRF_002'; stimVars{1} = [1 8]; icats{1} = 1;
        end
    elseif strcmp(protocolType,'NaturalImages')
        if strcmp(Category,'Flora')
            expDates{1} = '060318' ; protocolNames{1} = 'GRF_002'; stimVars{1} = [17 32]; icats{1} = 1;
            
        elseif strcmp(Category,'Fauna')
            expDates{1} = '020118'; protocolNames{1} = 'GRF_001'; stimVars{1} = [1 16]; icats{1} = 1;
            expDates{2} = '060318' ; protocolNames{2} = 'GRF_002'; stimVars{2} = [1 16]; icats{2} = 2;
            
        elseif strcmp(Category,'Texture')
            expDates{1} = '030318'; protocolNames{1} = 'GRF_003'; stimVars{1} = [1 16]; icats{1} = 1;
            expDates{2} = '040118'; protocolNames{2} = 'GRF_001'; stimVars{2} = [1 16]; icats{2} = 2;
            
        elseif strcmp(Category,'Landscape')
            expDates{1} = '030318'; protocolNames{1} = 'GRF_003'; stimVars{1} = [17 32]; icats{1} = 1;
            
        elseif strcmp(Category,'Face')
            expDates{1} = '050318'; protocolNames{1} = 'GRF_003'; stimVars{1} = [1 16]; icats{1} = 1;
            
        else
            disp(['Category: ' Category ' does not exist']);
            Category = [];
        end
    else
        
        disp(['ProtocolType: ' protocolType ' does not exist']);
        expDates = []; protocolNames = [];
    end
else
    disp(['monkeyName: ' monkeyName ' does not exist']);
end
end
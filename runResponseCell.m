% Script for making Response Cell and saving it
% Vidhi - 03/12/2021
% Sunreeta Modified - 05/12/21
clear; clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Choose %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%subjectName = 'alpaH'; protocolType = 'FlickeringGratings';stimulusType=1;
subjectName = 'alpaH'; protocolType = 'NaturalImages';stimulusType=2;
%subjectName = 'kesariH'; protocolType = 'FlickeringGratings';stimulusType=1
%subjectName = 'kesariH'; protocolType = 'NaturalImages'; stimulusType=2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%% Choose epoch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%tRangeS = [0 0.5]; %time range in seconds for which response cell is to be created 
tRangeS = [0 0.25]; %
%tRangeS = [0.25 0.5]; % 

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Choose neural response type %%%%%%%%%%%%%%%%%%

 isSpikeData = 0; responseType = 'lfp';
% isSpikeData = 0; responseType = 'ecog';
% isSpikeData = 1; responseType = 'spikes';

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Choose whether to save ResponseCell %%%%%%%%%%%%%%%%%%

% saveDataFlag = 1;
saveDataFlag = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Params %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


downsampleFactor = 10;% the level of downsampling needed to achived required time resolution

%%%%%%%%%%%%%%%%%%%%%%%%%%%% FolderStrings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if stimulusType == 1
    if isSpikeData == 0
        folderSourceString = 'N:\Projects\AttributeSpecificInformationProject\preMadeData\FlickeringGratingsMTM';
    else
        folderSourceString = 'N:\Projects\AttributeSpecificInformationProject\preMadeData\FlickeringGratingsSpikes';
    end
    Category = {'Contrast100'};

elseif stimulusType == 2
    if isSpikeData == 0
        folderSourceString = 'N:\Projects\AttributeSpecificInformationProject\preMadeData\NaturalImagesMTM';
    else
        folderSourceString = 'N:\Projects\AttributeSpecificInformationProject\preMadeData\NaturalImagesSpikes';
    end
    Category = {'Flora', 'Fauna', 'Texture', 'Landscape', 'Face'};
else
    disp('stimulusType does not exist');
end

folderSaveString = 'N:\Projects\AttributeSpecificInformationProject\preMadeData\ResponseCell';
makeDirectory(folderSaveString);

% load elec list

folderElec = 'N:\Projects\AttributeSpecificInformationProject\preMadeData\ResponseCell';
fileElecName = ['eleclist_' subjectName '_' protocolType '.mat'];
varname = ['eleclist_' subjectName '_' protocolType];
elecs = load(fullfile(folderElec,fileElecName));

if strcmp(responseType,'spikes')
    eleclist = elecs.(varname){1,1};
elseif strcmp(responseType,'lfp')
    eleclist = elecs.(varname){2,1};
elseif strcmp(responseType,'ecog')
    eleclist = elecs.(varname){3,1};
else
    disp('response type does not exist');
end
% making and saving response cells
tic;
for i = 1:size(Category,2)

    [expDates,protocolNames,stimVars,icats] = getCategoryInformation(subjectName,protocolType,Category{1,i});

    for j = 1:size(expDates,2)

        expDate = expDates{1,j};
        protocolName = protocolNames{1,j};
        stimVar = stimVars{1,j};
        icat = icats{1,j};

        ResponseCell = getResponseCell(folderSourceString,subjectName,expDate,protocolName,...
            eleclist,downsampleFactor,stimVar,stimulusType,isSpikeData,tRangeS);

        disp(size(ResponseCell));

        if saveDataFlag

            folderSave = fullfile(folderSaveString,subjectName,responseType,protocolType,Category{1,i});
            makeDirectory(folderSave);
            fileName = ['RCell' num2str(icat) '_' num2str(tRangeS(1)*1000) '_' num2str(tRangeS(2)*1000) 'ms.mat'];
            save(fullfile(folderSave,fileName),'ResponseCell');

        end

        toc;
    end
end
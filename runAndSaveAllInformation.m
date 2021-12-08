% run and save all information values
% for each response cell saved, we will save four information arrays: three
% will be through our first line of analysis (formal, attribute and
% time-specific information); fourth is the "I-temporal" which is the newer
% metric we are using that is more reasonable.
% Sunreeta - 05/12/21
% Vidhi Modified - 05/12/21
clear; clc;
addpath('N:\Projects\AttributeSpecificInformationProject\codes\software');
folderSaveString = 'N:\Projects\AttributeSpecificInformationProject\preMadeData\InfoData';
ResponseCellFolder = 'N:\Projects\AttributeSpecificInformationProject\preMadeData\ResponseCell';

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Choose whether to save ResponseCell %%%%%%%%%%%%%%%%%%

saveDataFlag = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
subjectNameList     = {'alpaH', 'kesariH'};
responseTypeList    = {'spikes', 'lfp', 'ecog'};
stimulusTypeList    = {'FlickeringGratings', 'NaturalImages'};
categoryList        = {'Contrast100', 'Flora', 'Fauna', 'Texture', 'Landscape', 'Face'};
% responseCellNumber  = {'1', '2'};
tRangeListMS        = {[0,500], [0,250], [250,500]};


analysisTypeList    = {'SingleElectrode', 'NaiveAverage', 'LDATimeAverage'};

optsAtt.method  = 'dr';
optsAtt.bias    = 'qe';
optsAtt.btsp    = 10;

optsTime.method = 'dr';
optsTime.bias   = 'qe';
optsTime.btsp   = 10;

optsFormal.method   = 'dr';
optsFormal.bias     = 'qe';
optsFormal.btsp     = 10;

optsTemporal.method = 'dr';
optsTemporal.bias   = 'qe';
optsTemporal.btsp   = 10;

nb = 7;

binningOpt = 'eqspace';

opts.Att        = optsAtt;
opts.Time       = optsTime; 
opts.Formal     = optsFormal;
opts.Temporal   = optsTemporal;
tic;

for iSubjectName = [2,1]
    
    subjectName = subjectNameList{iSubjectName};
    
    for iResponseType = 1:length(responseTypeList)
        
        responseType = responseTypeList{iResponseType};
        
        for iStimulusType = [2,1]
            
            stimulusType = stimulusTypeList{iStimulusType};
            
            if iStimulusType == 1
                % FG
                categoryIDX = 1;
            elseif iStimulusType == 2
                % NI
                categoryIDX = 2:length(categoryList);
            end
            
            for iCategory = categoryIDX
                
                categoryName = categoryList{iCategory};
                
                [~,~,~,catNums] = getCategoryInformation(subjectName,stimulusType,categoryName);
                
                for RespCellNum = 1:length(catNums)
                    
                    for iEpoch = 1:length(tRangeListMS)
                        
                        epoch = tRangeListMS{iEpoch};
                        fileName = ['RCell' num2str(RespCellNum) '_' num2str(epoch(1)) '_' num2str(epoch(2)) 'ms.mat'];
                        
                        filePath = fullfile(ResponseCellFolder, subjectName, responseType, stimulusType, categoryName);
                        
                        R = load(fullfile(filePath, fileName), 'ResponseCell');
                        ResponseCell = R.ResponseCell;
                        
                        numElecs = size(ResponseCell, 1);
                        
                        for iAnalysis = 1:length(analysisTypeList)
                            
                            analysisType = analysisTypeList{iAnalysis};
                            
                            if strcmp(analysisType, 'SingleElectrode')

                                [ResponseCell] = ResponseCell;

                            end
                            
                            if strcmp(analysisType, 'NaiveAverage')
                                
                                [ResponseCell,~] = populationAnalysis(ResponseCell,3,0);
                            
                            end
                            
                            if strcmp(analysisType, 'LDATimeAverage')
                                
                                [ResponseCell,~] = populationAnalysis(ResponseCell,1,0);
                            
                            end    
                            
                            [IFormal, IAtt, ITime, ITemporal] = getAllInformation(ResponseCell, opts, nb, binningOpt, responseType);
                            
                            % save info values
                            if saveDataFlag
                                saveFileName1 = ['IFormal_' num2str(RespCellNum) '_' num2str(epoch(1)) '_' num2str(epoch(2)) 'ms.mat' ];
                                saveFileName2 = ['IAtt_' num2str(RespCellNum) '_' num2str(epoch(1)) '_' num2str(epoch(2)) 'ms.mat' ];
                                saveFileName3 = ['ITime_' num2str(RespCellNum) '_' num2str(epoch(1)) '_' num2str(epoch(2)) 'ms.mat' ];
                                saveFileName4 = ['ITemporal_' num2str(RespCellNum) '_' num2str(epoch(1)) '_' num2str(epoch(2)) 'ms.mat' ];
                                saveFilePath = fullfile(folderSaveString,subjectName,responseType,stimulusType,categoryName,analysisType);
                                makeDirectory(saveFilePath);


                                save(fullfile(saveFilePath,saveFileName1),'IFormal');
                                save(fullfile(saveFilePath,saveFileName2),'IAtt');
                                save(fullfile(saveFilePath,saveFileName3),'ITime');
                                save(fullfile(saveFilePath,saveFileName4),'ITemporal');
                                disp([saveFilePath]);
                                toc;
                            end
                            
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
end

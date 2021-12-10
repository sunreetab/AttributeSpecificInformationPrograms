function goodElectrodes = getGoodElectrodes(subjectName, folderReceptiveFieldData)

if ~exist('folderReceptiveFieldData', 'var')
   folderReceptiveFieldData = 'N:\Programs\DataMAP\ReceptiveFieldData';
end

if strcmp(subjectName, 'alpaH')
    x = load(fullfile(folderReceptiveFieldData,subjectName,[subjectName 'MicroelectrodeRFData.mat']));
    ECoGElecs = [82 84 85 88 89];

elseif strcmp(subjectName, 'kesariH')
        % for kesariH include highRMSElectrodes from the newly active part of the array after Feb/March 2018
    x = load(fullfile(folderReceptiveFieldData,subjectName,[subjectName 'MicroelectrodeRFData_Two.mat']));
    ECoGElecs = [85 86 88 89];
end

goodElectrodes = sort(unique([x.highRMSElectrodes ECoGElecs]));

end
function [ResponseCell] = specifyResponseCell(folderSourceString,SubjectName,ResponseType,ProtocolType,Category,ResponseCellNum,tRange)
%Specifies response cell according to monkey, response type, protocol, category, number and epoch. Then loads it.
%Vidhi - 4/12/21
x = load(fullfile(folderSourceString,SubjectName,ResponseType,ProtocolType,Category,['RCell' num2str(ResponseCellNum) num2str(tRange(1)*1000) '_' num2str(tRange(2)*1000) 'ms.mat']));
ResponseCell = x.ResponseCell;
end
function [StimFormal,StimAtt,StimTime,RFormal,RAtt,RTime] = getBuildRMatrix(ResponseCell)
%Pass the response cell with rows as stimuli (i.e. 16 images or 8
%gratings). This function returns stimulus and response arrays for
%'formal','attribute' and 'time' information calculation respectively

%StimmulusArray

numTimeBins = size(ResponseCell{1,1},2);
StimFormal = [];
n=1;
for i=1:size(ResponseCell,1)
    for t=1:numTimeBins
        temp = ResponseCell{i,1};
        A = n*ones(size(temp(:,t),1),1);
        StimFormal = cat(1,StimFormal,A);
        n = n+1;
    end
end

clear('temp');
StimAtt = [];
n = 1;
for i=1:size(ResponseCell,1)
    temp = ResponseCell{i,1};
    A = n*ones(size(temp,1)*size(temp,2),1);
    StimAtt = cat(1,StimAtt,A);
    n = n+1;
end

clear('temp');
StimTime = [];
temp = cell2mat(ResponseCell);
n = 1;
for i=1:numTimeBins
    A = n*ones(size(temp(:,i),1),1);
    StimTime = cat(1,StimTime,A);
    n = n+1;
end

%Response Array
clear('temp');
RFormal = [];
n = 1;
for i=1:size(ResponseCell,1)
    for t=1:numTimeBins
        temp = ResponseCell{i,1};
        A = temp(:,t);
        RFormal = cat(1,RFormal,A);
        n = n+1;
    end
end

clear('temp');
RAtt = [];
n = 1;
for i=1:size(ResponseCell,1)
    temp = ResponseCell{i,1};
    A = temp(:);
    RAtt = cat(1,RAtt,A);
    n = n+1;
end

clear('temp');
RTime = [];
temp = cell2mat(ResponseCell);
n = 1;
for i=1:numTimeBins
    A = temp(:,i);
    RTime = cat(1,RTime,A);
    n = n+1;
end
end


function [RMin,RMax] = getMinMaxResponseCell(R,responseType)
%gives response cell overall min and max after removing outliers
% Vidhi - 5/12/21
    R = cell2mat(R);
    RMin = min(R,[],'all');
    RMax = max(R,[],'all');
end
function [RoutFinal,W] = populationAnalysis(R_in,Analysis,WeightNormalisation)
%This function does the population analysis on the input cell array 'R_in'
%which is of dimensions Electrodes X 1, where each item is contains
%response from different electrodes in pre-established structure. Weight
%type denotes what kind of LDA weights we require and can have the
%following inputs -
% WeightType can take values 1 or 2 depending on the following
% Analysis   -> 1 = 'LDA Time Avegraged' which gives the weights trained on time
%                   averaged response from each electrode as predictor. Thus here the weight
%                   output will be Electrdoes X 1 in dimension.
%            -> 2 = 'LDA Time Resolved' which gives the weights trained on
%                   response considered from 10ms resolution from each electrode
%                   as predictor. Thus here the weight output will be of
%                   Electrodes X Time in dimension.
%            -> 3 = 'Simple Average' which is naive analysis done to simply avergage the responses
%                   across electrodes. Here the weight output is of Electrodes X 1 dimension with constant 1 in it.
% WeightNormalisation can be 0 or 1 depending on whether weights to be used
% need to be normalised or not.
% Output 'R_out' is weighted averaged cell array output which is of dimensions
% Stimulus X 1 similar to the response of each electrode in input response
% cell array. 'W' is the output that has weights according to the analysis
% chosen.
% Vidhi - 100921
NumElec = size(R_in,1);
NumStim = size(R_in{1,1},1);
if Analysis == 1
    for k = 1:NumElec
        temp = cell2mat(R_in{k,1});
        X(:,k) = mean(temp,2);
    end
    Y = [];
    for i=1:NumStim
        temp = R_in{k,1};
        ONE_mat = i.*ones(size(temp{i,1},1),1);
        Y = cat(1,Y,ONE_mat);
    end
    
    % Implementing LDA
    DISCR=fitcdiscr(X,Y);
    
    % Getting Weights
    Sb = DISCR.BetweenSigma;
    Sw = DISCR.Sigma;
    [V,D] = eig(inv(Sw)*Sb);
    [val,ind] = max(diag(D));
    weight = V(:,ind);
    if WeightNormalisation == 1
        W = (weight.^2)./sum(weight.^2);
    else
        W = weight;
    end
    % Weighted averaging the response matrix and getting it the form needed
    % for next information analysis
    
    ResponseMat = zeros(size(cell2mat(R_in{1,1}),1),size(cell2mat(R_in{1,1}),2),NumElec);
    for k=1:NumElec
        ResponseMat(:,:,k) = cell2mat(R_in{k,1});
    end
    
    for k=1:NumElec
        ResponseMat(:,:,k) = W(k)*ResponseMat(:,:,k);
    end
    ResponseMat_weighted = sum(ResponseMat,3);
    for n=1:NumStim
        trials(n) = size(R_in{1,1}{n,1},1);
    end
    trials = [0,cumsum(trials)];
    R_out = cell(NumStim,1);
    R_out{1,1} = ResponseMat_weighted(1:trials(1),:);
    for n=1:NumStim
        R_out{n,1} = ResponseMat_weighted(trials(n)+1:trials(n+1),:);
    end
    
elseif Analysis == 2
    timesize = size(R_in{1,1}{1,1},2);
    for t = 1:timesize
        for k = 1:NumElec
            temp = cell2mat(R_in{k,1});
            X(:,k) = temp(:,t);
        end
        Y = [];
        for i=1:NumStim
            temp = R_in{k,1};
            ONE_mat = i.*ones(size(temp{i,1},1),1);
            Y = cat(1,Y,ONE_mat);
        end
        
        % Implementing LDA
        DISCR=fitcdiscr(X,Y);
        
        % Getting Weights
        Sb = DISCR.BetweenSigma;
        Sw = DISCR.Sigma;
        [V,D] = eig(inv(Sw)*Sb);
        [val,ind] = max(diag(D));
        weight(:,t) = V(:,ind);
    end
    if WeightNormalisation == 1
        W = (weight.^2)./sum(weight.^2);
    else
        W = weight;
    end
    
    % Weighted averaging the response matrix and getting it the form needed
    % for next information analysis
    
    ResponseMat = zeros(size(cell2mat(R_in{1,1}),1),size(cell2mat(R_in{1,1}),2),NumElec);
    for k=1:NumElec
        ResponseMat(:,:,k) = cell2mat(R_in{k,1});
    end
    
    for k=1:NumElec
        for t=1:timesize
            ResponseMat(:,t,k) = W(k,t)*ResponseMat(:,t,k);
        end
    end
    ResponseMat_weighted = sum(ResponseMat,3);
    for n=1:NumStim
        trials(n) = size(R_in{1,1}{n,1},1);
    end
    trials = [0,cumsum(trials)];
    R_out = cell(NumStim,1);
    R_out{1,1} = ResponseMat_weighted(1:trials(1),:);
    for n=1:NumStim
        R_out{n,1} = ResponseMat_weighted(trials(n)+1:trials(n+1),:);
    end
    
else
    weight = ones(NumElec,1);
    if WeightNormalisation == 1
        W = (weight.^2)./sum(weight.^2);
    else
        W = weight/NumElec;
    end
    % Weighted averaging the response matrix and getting it the form needed
    % for next information analysis
    
    ResponseMat = zeros(size(cell2mat(R_in{1,1}),1),size(cell2mat(R_in{1,1}),2),NumElec);
    for k=1:NumElec
        ResponseMat(:,:,k) = cell2mat(R_in{k,1});
    end
    
    for k=1:NumElec
        ResponseMat(:,:,k) = W(k)*ResponseMat(:,:,k);
    end
    ResponseMat_weighted = sum(ResponseMat,3);
    for n=1:NumStim
        trials(n) = size(R_in{1,1}{n,1},1);
    end
    trials = [0,cumsum(trials)];
    R_out = cell(NumStim,1);
    R_out{1,1} = ResponseMat_weighted(1:trials(1),:);
    for n=1:NumStim
        R_out{n,1} = ResponseMat_weighted(trials(n)+1:trials(n+1),:);
    end
end
RoutFinal{1,1} = R_out;
end


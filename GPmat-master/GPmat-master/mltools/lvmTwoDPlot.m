function [returnVal, txtReturnVal] = lvmTwoDPlot(X, lbl, symbol, doTest, fhandle)

% LVMTWODPLOT Helper function for plotting the labels in 2-D.
% FORMAT
% DESC helper function for plotting an embedding in 2-D with symbols.
% ARG X : the data to plot.
% ARG lbl : the labels of the data point.
% ARG symbol : the symbols to use for the different labels.
%
% SEEALSO : lvmScatterPlot, lvmVisualise
%
% COPYRIGHT : Neil D. Lawrence, 2004, 2005, 2006, 2008

% MLTOOLS

if nargin < 2
    lbl = [];
end
if(strcmp(lbl, 'connect'))
    connect = true;
    lbl = [];
else
    connect = false;
end

if iscell(lbl)
    lblStr = lbl{2};
    lbl = lbl{1};
    labelsString = true;
else
    labelsString = false;
end

if nargin < 3 || isempty(symbol)
    if isempty(lbl)
        symbol = getSymbols(1);
    else
        symbol = getSymbols(size(lbl,2));
    end
end
if nargin > 4 && ~isempty(fhandle)
    axisHand = fhandle;
else
    axisHand = gca;
end
returnVal = [];
textReturnVal = [];
nextPlot = get(axisHand, 'nextplot');
labelNo=1;
deb=1;
for i = 1:(size(X, 1)/15)
    if i == 2
        set(axisHand, 'nextplot', 'add');
    end
%     if ~isempty(lbl)
%         labelNo = find(lbl(i, :));
%     else
%         labelNo = 1;
%     end
    %try
    returnVal = [returnVal; plot(X(deb:15*i, 1), X(deb:15*i, 2), symbol{labelNo}, 'linewidth',1)];
    if labelsString
        textReturnVal = [textReturnVal; text(X(i, 1), X(i, 2), ['   ' lblStr{i}])];
    end
    labelNo = labelNo+1;
    deb=(15*i)+1;
    if connect
        if i>1
            line([X(i-1, 1) X(i, 1)], [X(i-1, 2) X(i, 2)]);
        end
    end
    %catch
    % if strcmp(lasterr, 'Index exceeds matrix dimensions.')
    %  error(['Only ' num2str(length(symbol)) ' labels supported (it''s easy to add more!)'])
    % end
    %end
end

if doTest==1
    % Set up test model
    dataSetNameTest = 'testpoint';
    [Y, lbls] = lvmLoadData(dataSetNameTest);
%     optionsTest = fgplvmOptions('ftc');
%     latentDim = 2;
%     d = size(Y, 2);
%     modelTest = fgplvmCreate(latentDim, d, Y, optionsTest);% cr�ation du model des valeurs de test
    load model.mat; % load the learned model corresponding to the latent space
%     
%     [mean,sigma] = fgplvmPosteriorMeanVar(model, modelTest.X);
%     
    iters=100;
    display=1;
    Xtest = zeros(size(Y, 1),2);
%     modelTest = fgplvmOptimise(modelTest, display, iters);
    for i=1:size(Xtest, 1)
        initXPos = getNearestValue(model.y, Y(i,:));
        Xtest(i,:) = fgplvmOptimisePoint(model, model.X(initXPos,:), Y(i,:), display, iters);
    end
    returnVal = [returnVal; plot(Xtest(:, 1), Xtest(:, 2), '^-', 'linewidth',1)];
end
set(axisHand, 'nextplot', nextPlot);
set(returnVal, 'markersize', 10);
set(returnVal, 'linewidth', 2);
end

function initXPos = getNearestValue(Ymodel, Y)
    ytemp = 0;
    dist = Inf(1);
    for i=1:size(Ymodel,1)
        D = sqrt(sum((Ymodel(i,:) - Y) .^ 2));
        if(D < dist)
            dist = D;
            ytemp = i;
        end
    end
    initXPos = ytemp;
end

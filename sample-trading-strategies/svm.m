function [p, settings] = svm(DATE, OPEN, HIGH, LOW, CLOSE, VOL, exposure, equity, settings)
settings.markets     = {'CASH', 'F_AD', 'F_BO', 'F_BP', 'F_C', 'F_CC', 'F_CD', 'F_CL', 'F_CT', 'F_DX', 'F_EC', 'F_ED', 'F_ES', 'F_FC', 'F_FV', 'F_GC', 'F_HG', 'F_HO', 'F_JY', 'F_KC', 'F_LB', 'F_LC', 'F_LN', 'F_MD', 'F_MP', 'F_NG', 'F_NQ', 'F_NR', 'F_O', 'F_OJ', 'F_PA', 'F_PL', 'F_RB', 'F_RU', 'F_S', 'F_SB', 'F_SF', 'F_SI', 'F_SM', 'F_TU', 'F_TY', 'F_US', 'F_W', 'F_XX', 'F_YM'};
settings.sampleend   = 20170521;
settings.lookback    = 252;
settings.slippage    = 0.05;
settings.budget      = 1000000;
settings.samplebegin = 19900101;

% Customized settings
settings.gap = 5;

    function [n] = nextTrend(CLOSE, gap)
        % Predict trend of next day
        lookback = size(CLOSE, 1);
        X = zeros(lookback - gap, gap);
        
        for i = 1 : lookback - gap
            X(i, :) = CLOSE(i:i+gap-1);
        end
        y = sign(CLOSE(gap+1:lookback) - CLOSE(gap:lookback-1));
        y(y==0) = 1;
        
        SVMModel = fitcsvm(X, y, 'KernelFunction', 'rbf');
        n = predict(SVMModel, CLOSE(end-gap+1:end)');
    end

nMarkets = size(settings.markets, 2);
gap = settings.gap;
p = zeros(1, nMarkets);

for market = 1 : nMarkets
    try
        p(1, market) = nextTrend(CLOSE(:, market), gap);
    catch exception
        p(1, market) = 0;
    end
end
end


function [p, settings] = bollingerBands(DATE, OPEN, HIGH, LOW, CLOSE, VOL, exposure, equity, settings)
settings.markets     = {'CASH', 'F_AD', 'F_BO', 'F_BP', 'F_C', 'F_CC', 'F_CD', 'F_CL', 'F_CT', 'F_DX', 'F_EC', 'F_ED', 'F_ES', 'F_FC', 'F_FV', 'F_GC', 'F_HG', 'F_HO', 'F_JY', 'F_KC', 'F_LB', 'F_LC', 'F_LN', 'F_MD', 'F_MP', 'F_NG', 'F_NQ', 'F_NR', 'F_O', 'F_OJ', 'F_PA', 'F_PL', 'F_RB', 'F_RU', 'F_S', 'F_SB', 'F_SF', 'F_SI', 'F_SM', 'F_TU', 'F_TY', 'F_US', 'F_W', 'F_XX', 'F_YM'};
settings.sampleend   = 20170522;
settings.lookback    = 20;
settings.slippage    = 0.05;
settings.budget      = 1000000;
settings.samplebegin = 19900101;

% Customized settings
settings.n           = 20;
settings.threshold   = 0.4;

    function [upper, lower] = bollingerBands(a, n)
        % Calculate bollinger bands
        sma = nansum(a(end-n+1:end)) / n;
        deviation = std(a(end-n+1:end));
        upper = sma + 2 * deviation;
        lower = sma - 2 * deviation;
    end

nMarkets = size(settings.markets, 2);
threshold = settings.threshold;
n = settings.n;
p = zeros(1, nMarkets);

for market = 1 : nMarkets
    [upperBand, lowerBand] = bollingerBands(CLOSE(:, market), n);
    currentPrice = CLOSE(end, market);

    if currentPrice >= upperBand + (upperBand - lowerBand) * threshold
        p(1, market) = -1;
    elseif currentPrice <= lowerBand - (upperBand - lowerBand) * threshold
        p(1, market) = 1;
    end
end
end


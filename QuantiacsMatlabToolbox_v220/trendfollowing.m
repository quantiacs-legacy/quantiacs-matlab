function [p, settings] = trendfollowing(DATE, OPEN, HIGH, LOW, CLOSE, VOL, exposure, equity, settings)
settings.markets     = {'CASH', 'F_AD', 'F_BO', 'F_BP', 'F_C', 'F_CC', 'F_CD', 'F_CL', 'F_CT', 'F_DX', 'F_EC', 'F_ED', 'F_ES', 'F_FC', 'F_FV', 'F_GC', 'F_HG', 'F_HO', 'F_JY', 'F_KC', 'F_LB', 'F_LC', 'F_LN', 'F_MD', 'F_MP', 'F_NG', 'F_NQ', 'F_NR', 'F_O', 'F_OJ', 'F_PA', 'F_PL', 'F_RB', 'F_RU', 'F_S', 'F_SB', 'F_SF', 'F_SI', 'F_SM', 'F_TU', 'F_TY', 'F_US', 'F_W', 'F_XX', 'F_YM'};
settings.sampleend   = 20131231;
settings.lookback    = 504;

nMarkets = size(CLOSE,2);
periodLong   = 200; %#[150:10:200]#
periodRecent = 40;  %#[20:5:60]#

smaLong   = sum(CLOSE(end-periodLong+1:end,:)) / periodLong;
smaRecent = sum(CLOSE(end-periodRecent+1:end,:)) / periodRecent;

long = smaRecent >= smaLong;

p = zeros(1, nMarkets);
p(long)  = 1;
p(~long) = -1;

end

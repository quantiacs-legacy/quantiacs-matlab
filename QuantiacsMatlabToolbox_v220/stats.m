function [st] = stats(ec)

st = [];
ec = ec(:);
ec = ec(~isnan(ec));

returns = (ec(2:end)-ec(1:end-1)) ./ ec(1:end-1);
returns = returns(:);

volaDaily = std(returns);
volaYearly = sqrt(252) * volaDaily;
    
index = cumprod(1+returns);
indexEnd = index(end);

returnDaily = exp(log(indexEnd)/size(returns,1))-1;

returnYearly = (1+returnDaily)^252-1;
sharpeRatio = returnYearly / volaYearly;

downsideReturns = returns;
downsideReturns(downsideReturns > 0) = 0;
downsideVola = std(downsideReturns);
downsideVolaYearly = downsideVola *sqrt(252);
    
sortino = returnYearly / downsideVolaYearly;
   
highCurve = ec;
for k = 2:size(highCurve)
    if highCurve(k) < highCurve(k-1)
        highCurve(k) = highCurve(k-1);
     end
end
underwater = ec ./ highCurve;
[mi mIx] = min(underwater);
maxDD = 1 - mi;

mX = find(highCurve(1:mIx)== max(highCurve(1:mIx)),1, 'first');
   
mar   = returnYearly / maxDD;


mToP = ec < highCurve;
mToP = [0; mToP; 0];
ixStart   = diff(mToP)==1;
ixEnd     = diff(mToP)==-1;

[maxTimeOffPeak topIx] = max(find(ixEnd) - find(ixStart));
if ~isempty(topIx)
    topIx = topIx(1);

    mtopStart = 1:size(ec);
    mtopEnd   = 1:size(ec);

    mtopStart = mtopStart(ixStart(1:end-1));
    mtopStart = mtopStart(topIx) - 1;

    mtopEnd = mtopEnd(ixEnd(2:end));
    mtopEnd = mtopEnd(topIx);
else
    mtopStart = NaN;
    mtopEnd = NaN;
    maxTimeOffPeak = NaN;
end

st.sharpe              = sharpeRatio;
st.sortino             = sortino;
st.returnYearly        = returnYearly;
st.volaYearly          = volaYearly;
st.maxDD               = maxDD;
st.maxDDBegin          = mX;
st.maxDDEnd            = mIx;
st.mar                 = mar;
st.maxTimeOffPeak      = maxTimeOffPeak;
st.maxTimeOffPeakBegin = mtopStart;
st.maxTimeOffPeakEnd   = mtopEnd;

end
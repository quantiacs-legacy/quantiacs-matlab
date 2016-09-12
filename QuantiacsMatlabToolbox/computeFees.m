function [out, ret, mFee, pFee] = computeFees(equity,manFee,perfFee)
   ret = diff(equity,1) ./ equity(1:end-1);
   ret = ret(:);
   ret = [0; ret];

   tradeDays = ret > 0;
   firstTradeDay = find(tradeDays,1,'first')-1;
   manFeeIx = false(size(ret));
   manFeeIx(firstTradeDay:end) = true;
   ret(manFeeIx) = ret(manFeeIx) - manFee/252;
   
   ret = 1 + ret;
   r = [];
   high = 1;
   last = 1;
   pFee = zeros(size(ret));
   mFee = zeros(size(ret));
   for k = 1:size(ret,1)
       mFee(k) = last * manFee/252 * equity(1);
       if last * ret(k) > high
           iFix = high / last;
           iPerf = ret(k) / iFix;
           pFee(k) = ((iPerf-1) * perfFee * iFix + 1);
           iPerf = 1 + (iPerf - 1) * (1-perfFee);
           r = [r; iPerf * iFix];
       else
           r = [r; ret(k)];
       end
       last = r(end) * last;
       if last > high 
           high = last;
       end
   end
   out = cumprod(r);
   out = out .* equity(1);
   pFee(pFee == 0) = 1;
   pFee = [0; out(1:end-1) .* pFee(2:end) - out(1:end-1)];
   ret = ret - 1;
end
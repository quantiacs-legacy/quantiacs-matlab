function [factsheet] = plotts(res)

    global ress  val1  val2 tsName

    ress = res;
    val1 = 1;
    val2 = 1;
    ss = get(0,'screensize');
    width = 1024;
    height = 600;

    tsName = ress.tsName;
    if ~exist('tsName','var'); tsName = 'Tradingsystem';end


    factsheet = figure('Color',[1 1 1]); %, 'units','normalized','outerposition',[0 0 1 1]
    set(factsheet, 'Position', [(ss(3)/2)-width/2, (ss(4)/2)-height/2, width, height])

    plottt1(1,1);

    value_of_popups = ['fundEquity' res.settings.markets];
    market_popups = [res.settings.markets];
    market_popups(1) = [];

    set(factsheet, 'units','normalized');    
    % Enlarge the screen instead of maximizing it.
    if exist('OCTAVE_VERSION','builtin') ~= 0
      popup1 = uicontrol(factsheet,...
          'Style', 'popupmenu',...
          'units', 'normalized',...
          'String', value_of_popups,...
          'HandleVisibility', 'off',...
          'Position', [0.12 0.96 0.1 0.04],...
          'Callback', {@update_val1_octave});
      popup2 = uicontrol(factsheet,...
          'units', 'normalized',...
          'Style', 'popupmenu',...
          'String', {'Long & Short', 'Long', 'Short'},...
          'HandleVisibility', 'off',...
          'Position', [0.28 0.96 0.1 0.04],...
          'Callback', {@update_val2_octave});
      popup3 = uicontrol(factsheet,...
          'units', 'normalized',...
          'Style', 'popupmenu',...
          'String', market_popups,...
          'HandleVisibility', 'off',...
          'Position', [0.46 0.96 0.1 0.04],...
          'Callback', {@update_val3_octave});
      txt1 = uicontrol(factsheet,...
          'units', 'normalized',...
          'Style', 'text',...
          'String', 'Trading Performance:',...
          'HandleVisibility', 'off',...
          'BackgroundColor', [1 1 1],...
          'Position', [0.0 0.96 0.12 0.04]);
      txt2 = uicontrol(factsheet,...
          'units', 'normalized',...
          'Style', 'text',...
          'String', 'Exposure:',...
          'HandleVisibility', 'off',...
          'BackgroundColor', [1 1 1],...
          'Position', [0.22 0.96 0.06 0.04]);
      txt3 = uicontrol(factsheet,...
          'units', 'normalized',...
          'Style', 'text',...
          'String', 'Markets:',...
          'HandleVisibility', 'off',...
          'BackgroundColor',[1 1 1],...
          'Position', [0.38 0.96 0.08 0.04]);
       button_update = uicontrol(factsheet,...
          'units', 'normalized',...
          'Style', 'pushbutton',...
          'String', 'Update Quantics Toolbox',...
          'HandleVisibility', 'off',...
          'visible', 'off',...
          'Position', [0.8, 0.95, 0.17, 0.05],...
          'BackgroundColor', [27/252 242/252 163/252],...
          'Callback', {@update_octave});
       txt_msg =  uicontrol(factsheet,...
          'units', 'normalized',...
          'Style', 'text',...
          'String', '',...
          'FontWeight','demi',...
          'FontSize',12,...
          'HandleVisibility', 'off',...
          'BackgroundColor',[1 1 1],...
          'Position', [0.56 0.96 0.24 0.04]);



    else
      popup1 = uicontrol('parent',factsheet,...
          'units', 'normalized',...
          'Style', 'popup',...
          'String', value_of_popups,...
          'HandleVisibility', 'off',...
          'Position', [0.08 0.9 0.1 0.1],...
          'Callback', @update_val1_matlab);
      popup2 = uicontrol('parent',factsheet,...
          'units', 'normalized',...
          'Style', 'popup',...
          'String', {'Long & Short', 'Long', 'Short'},...
          'HandleVisibility', 'off',...
          'Position', [0.24 0.9 0.1 0.1],...
          'Callback', @update_val2_matlab);
      popup3 = uicontrol('parent',factsheet,...
          'units', 'normalized',...
          'Style', 'popup',...
          'String', market_popups,...
          'HandleVisibility', 'off',...
          'Position', [0.42 0.9 0.1 0.1],...
          'Callback', @update_val3_matlab);
      txt1 = uicontrol('parent', factsheet,...
          'units', 'normalized',...
          'Style', 'text',...
          'String', 'Trading Performance:',...
          'HandleVisibility', 'off',...
          'BackgroundColor', [1 1 1],...
          'Position', [0.0 0.96 0.08 0.04]);
      txt2 = uicontrol('parent', factsheet,...
          'units', 'normalized',...
          'Style', 'text',...
          'String', 'Exposure:',...
          'HandleVisibility', 'off',...
          'BackgroundColor', [1 1 1],...
          'Position', [0.18 0.96 0.05 0.04]);
      txt3 = uicontrol('parent', factsheet,...
          'units', 'normalized',...
          'Style', 'text',...
          'String', 'Markets:',...
          'HandleVisibility', 'off',...
          'BackgroundColor',[1 1 1],...
          'Position', [0.34 0.96 0.08 0.04]);
      button_submit = uicontrol(factsheet,...
           'units', 'normalized',...
           'Style', 'pushbutton',...
           'String', 'Submit Trading System',...
           'HandleVisibility', 'off',...
           'Position', [0.82, 0.92, 0.125, 0.035],...
           'BackgroundColor', [32/255 181/255 252/255],...
           'Callback', {@submit_matlab});
      button_update = uicontrol('parent', factsheet,...
           'units', 'normalized',...
           'Style', 'pushbutton',...
           'String', 'Update Quantics Toolbox',...
           'HandleVisibility', 'off',...
           'visible', 'off',...
           'Position', [0.82, 0.96, 0.125, 0.035],...
           'BackgroundColor', [27/252 242/252 163/252],...
           'Callback', {@update_matlab});
      txt_msg =  uicontrol('parent', factsheet,...
           'units', 'normalized',...
           'Style', 'text',...
           'String', '',...
           'FontWeight','demi',...
           'FontSize',12,...
           'HandleVisibility', 'off',...
           'Tag','messagebox',...
           'BackgroundColor',[1 1 1],...
           'Position', [0.52 0.96 0.32 0.04]);
     
    end        
    [updateBool mssg] = updateToolbox(false);
    set(txt_msg,'String', mssg);
    if updateBool
        set(button_update,'visible', 'on');
    end  
    
end        

function update_val1_octave(source,event)
        global val1  val2 val3
        val1 = get(source, 'Value');            
        val3 = 0;
        plottt1(val1, val2);
end

function update_val2_octave(source,event)
        global val1  val2 val3
        val2 = get(source, 'Value');      
        if val1 ~= 0
            plottt1(val1, val2);
        else
            plottt2(val2,val3);
        end
end


function update_val3_octave(source,event)
        global val1  val2 val3
        val3 = get(source, 'Value');   
        val1 = 0;
        plottt2(val2,val3);
end

function update_val1_matlab(hObject,eventdata,handles)
        global val1  val2 val3
        val1 = get(hObject, 'Value');            
        val3 = 0;
        plottt1(val1,val2);
end

function update_val2_matlab(hObject,eventdata,handles)
        global val1  val2 val3
        val2 = get(hObject, 'Value');        
        if val1 ~= 0
            plottt1(val1, val2);
        else
            plottt2(val2,val3);
        end
end


function update_val3_matlab(hObject,eventdata,handles)
        global val1  val2 val3
        val3 = get(hObject, 'Value');          
        val1 = 0;
        plottt2(val2,val3);
end


 function submit_matlab(hObject, eventdata, Handles)
    global tsName
    c = clock;
    submitName = tsName;
    for mm = 1:5
        if c(mm) < 10
            submitName = [submitName,'0',num2str(c(mm))];
        else
            submitName = [submitName,num2str(c(mm))];
        end
    end
    success = submit([tsName, '.m'], submitName);
    if success
        txt_msg = findall(gcf,'Tag', 'messagebox');
        subsuccess_str = [submitName, ' submitted successfully!'];
        set(txt_msg,'String', subsuccess_str);
    end
 end
 

function update_matlab(hObject, eventdata, Handles)
    [updateBool2 msg] = updateToolbox(true);
end


function update_octave(source,event)
    [updateBool2 msg] = updateToolbox(true);
end

 
function plottt1(index1, index2)
    global ress 
    
    clf(gcf);

    dateVec = ress.fundDate(ress.settings.lookback:end);
    tsName = ress.tsName;

    if ~exist('tsName','var'); tsName = 'Tradingsystem';end

    xTick = [];
    xTickLabel = {};
    for j = floor(dateVec(1)/10^4):1:floor(dateVec(end)/10^4)
        xTick(end+1) = datenum([j 01 01]);
        xTickLabel{end+1} = num2str(j,'%1.0f');
    end

    Long = ress.marketExposure(ress.settings.lookback-1:end-1,:);       % Exposure lagged by one day
    Short = -ress.marketExposure(ress.settings.lookback-1:end-1,:);
    Long(Long < 0) = 0;
    Short(Short < 0) = 0;
    MultiplierLong = Long;
    MultiplierShort = Short;
    MultiplierLong(MultiplierLong > 0) = 1;
    MultiplierShort(MultiplierShort > 0) = 1;
    returnLong = ress.returns(ress.settings.lookback:end,:) .* MultiplierLong;
    returnShort = ress.returns(ress.settings.lookback:end,:) .* MultiplierShort;
    returnLong = [sum(returnLong,2) returnLong];
    returnShort = [sum(returnShort, 2) returnShort];
    Long = [sum(Long,2) Long];
    Short = [sum(Short,2) Short];
    equity = ress.marketEquity(ress.settings.lookback:end,:);

    dVec = datenum(([floor(dateVec/10^4) floor((mod(dateVec,10^4))/10^2) mod(dateVec,10^2)]));   
    numAnn = (dVec(end) - dVec(1)) / 365;
   
    ec = ress.fundEquity(ress.settings.lookback:end);
    [~, ~, ~, pFee] = computeFees(ec, 0, 0.2);
    pFeeTotal = cumsum(pFee / 2);
    pFeeTotal = max(pFeeTotal(end), 0);
    pFeePerAnno = pFeeTotal / numAnn;

    if index1 == 1

        if index2 == 2
            ec = ress.settings.budget .* cumprod(1+returnLong(:,1));
        elseif index2 == 3
            ec = ress.settings.budget .* cumprod(1+returnShort(:,1));
        end
        
        st = stats(ec);
    
        ec(ec < 1) = 1;
        test = isequal(ec, ones(size(ec)));
        start = log(ec(1));
        maxEc = log(max(ec));
        minEc = log(min(ec));
        step  = (maxEc - minEc) / 8;

        yLower = start - ceil((start - minEc) / step) * step;
        yUpper = start + ceil((maxEc - start) / step) * step;

        yTick = yLower:step:yUpper;
        yTick = exp(yTick);
        yTickLabel = cellfun(@(x) num2str(x,'%1.0f'), num2cell(yTick), 'UniformOutput', false);

        maxDD = NaN(size(ec));
        if st.maxDDEnd - st.maxDDBegin > 0
            maxDD(st.maxDDBegin:st.maxDDEnd) = ec(st.maxDDBegin:st.maxDDEnd);
        end

        maxTOP = NaN(size(ec));
        if st.maxTimeOffPeakEnd - st.maxTimeOffPeakBegin > 0
            maxTOP(st.maxTimeOffPeakBegin:st.maxTimeOffPeakEnd) = ones(1,st.maxTimeOffPeakEnd - st.maxTimeOffPeakBegin +1) .* ec(st.maxTimeOffPeakBegin);
        end

        [~, ~, ~, pFee] = computeFees(ec, 0, 0.2);
        pFeeTotal = cumsum(pFee / 2);
        pFeeTotal = max(pFeeTotal(end), 0);
        pFeePerAnno = pFeeTotal / numAnn;

        axes1 = axes('Parent',gcf,'YTickLabel',yTickLabel,...
            'YTick',yTick,...
            'YScale','log',...
            'YMinorTick','on',...
            'XTickLabel',xTickLabel,...
            'XTick',xTick,...
            'Position',[0.09 0.37 0.663 0.555]);

        xlim(axes1,[min(dVec) max(dVec)]);
        ylim(axes1,[min(ec)/exp((log(max(ec)) - log(min(ec))) * 0.1)-0.01  max(ec)*exp(0.1 * (log(max(ec)) - log(min(ec))))+0.01]);

        box(axes1,'on');
        hold(axes1,'all');

        semilogy(dVec,ec,'Color',[0 0 1]);
        hold on;

        l1 = plot(dVec, maxDD,  'Color', [1 0 0]);
        l2 = plot(dVec, maxTOP, 'Color', [1 0 0], 'LineStyle', ':');

        plot(dVec, ones(size(ec)) * max(ec), 'Color', 'black', 'LineStyle', ':');
        plot(dVec, ones(size(ec)) * min(ec), 'Color', 'black', 'LineStyle', ':');

        text(mean([dVec(1) dVec(end)]), exp(log(min(ec)) + step * 0.15), num2str(min(ec),'%1.0f'));
        text(mean([dVec(1) dVec(end)]), exp(maxEc - step * 0.15), num2str(max(ec),'%1.0f'));

        set(gca,'XTICK', []);
        ylabel('Performance (log)','FontSize',12);

        title(['Factsheet of fundEquity in ', tsName],'FontWeight','demi','FontSize',12);

        [~, ~, ~, pFee] = computeFees(ec, 0, 0.2);
        pFeeTotal = cumsum(pFee / 2);
        pFeeTotal = max(pFeeTotal(end), 0);
        pFeePerAnno = pFeeTotal / numAnn;

        annotation(gcf,'textbox',...
            [0.77 0.4 0.2 0.1],...
            'String',{'Your Income Estimation', '($ 1Mio Investment, 10% performance fee)'},...
            'HorizontalAlignment','center',...
            'FontWeight','demi',...
            'FitBoxToText','off',...
            'VerticalAlignment', 'baseline', ...
            'LineStyle','none');

        annotation(gcf,'textbox',...
            [0.77 0.35 0.12 0.1],...
            'String',{'total $', 'per anno $'},...
            'HorizontalAlignment','right',...
            'FitBoxToText','off',...
            'VerticalAlignment', 'baseline', ...    
            'LineStyle','none');

        annotation(gcf,'textbox',...
            [0.9 0.35 0.05 0.2],...
            'String',{num2str(pFeeTotal,'%1.2f'),num2str(pFeePerAnno,'%1.2f')},...
            'HorizontalAlignment','left',...
            'FitBoxToText','off',...
            'VerticalAlignment', 'baseline', ...    
            'LineStyle','none');

    else
        if index2 == 2
            eq = cumprod(1+returnLong(:,index1));
        elseif index2 ==3
            eq = cumprod(1+returnShort(:,index1));
        else
            eq = equity(:, index1-1);
        end
        colorList = {[0 0 1], [102/255 178/255 255/255], [51/255 255/255 51/255]};
        test = isequal(max(eq), min(eq));
        st = stats(eq);

        start = eq(1);
        maxEq = max(eq);
        minEq = min(eq);
        step  = (maxEq - minEq) / 8;

        if test
            axes1 = axes('Parent',gcf,...
                'XTickLabel',xTickLabel,...
                'XTick',xTick,...
                'Position',[0.09 0.37 0.663 0.555]);

            xlim(axes1,[min(dVec) max(dVec)]);
            box(axes1,'on');
            hold(axes1,'all');

            semilogy(dVec,eq,'Color', colorList{index2});

            text(mean([dVec(1) dVec(end)]), (eq(1) + step * 0.15), num2str(eq(1),'%1.0f'));

        else
            yLower = start - ceil((start - minEq) / step) * step;
            yUpper = start + ceil((maxEq - start) / step) * step;

            yTick = yLower:step:yUpper;
            yTickLabel = cellfun(@(x) num2str(x,'%4.3f'), num2cell(yTick), 'UniformOutput', false);

            axes1 = axes('Parent',gcf,'YTickLabel',yTickLabel,...
                'YTick',yTick,...
                'YMinorTick','on',...
                'XTickLabel',xTickLabel,...
                'XTick',xTick,...
                'Position',[0.09 0.37 0.663 0.555]);

            xlim(axes1,[min(dVec) max(dVec)]);
            ylim(axes1,[minEq maxEq]);

            box(axes1,'on');
            hold(axes1,'all');

            semilogy(dVec,eq,'Color', colorList{index2});
            hold on;

            maxDD = NaN(size(eq));
            if st.maxDDEnd - st.maxDDBegin > 0
                maxDD(st.maxDDBegin:st.maxDDEnd) = eq(st.maxDDBegin:st.maxDDEnd);
            end

            maxTOP = NaN(size(eq));
            if st.maxTimeOffPeakEnd - st.maxTimeOffPeakBegin > 0
                maxTOP(st.maxTimeOffPeakBegin:st.maxTimeOffPeakEnd) = ones(1,st.maxTimeOffPeakEnd - st.maxTimeOffPeakBegin +1) .* eq(st.maxTimeOffPeakBegin);
            end

            l1 = plot(dVec, maxDD,  'Color', [1 0 0]);
            l2 = plot(dVec, maxTOP, 'Color', [1 0 0], 'LineStyle', ':');

            plot(dVec, ones(size(eq)) * max(eq), 'Color', 'black', 'LineStyle', ':');
            plot(dVec, ones(size(eq)) * min(eq), 'Color', 'black', 'LineStyle', ':');

            text(mean([dVec(1) dVec(end)]), (minEq + step * 0.15), num2str(min(eq),'% 4.3f'));
            text(mean([dVec(1) dVec(end)]), (maxEq - step * 0.15), num2str(max(eq),'%4.3f'));

        end


        set(gca,'XTICK', []);
        ylabel('Performance','FontSize',12);

        tx = char(ress.settings.markets(index1-1));
        title(['Factsheet of ', tx(1),'-',tx(3:end),' in ', tsName], 'FontWeight','demi','FontSize',12);

    end

    if ~test

        annotation(gcf,'textbox',...
            [0.77 0.860 0.2 0.1],...
            'String',{'Performance Numbers'},...
            'HorizontalAlignment','center',...
            'FontWeight','demi',...
            'FitBoxToText','off',...
            'VerticalAlignment', 'baseline', ...
            'LineStyle','none');

        annotation(gcf,'textbox',...
            [0.9 0.67 0.05 0.2],...
            'String',{num2str(st.sharpe,'%1.4f'),num2str(st.sortino,'%1.4f'),'',num2str(st.returnYearly,'%1.4f'),num2str(st.volaYearly,'%1.4f'),'',num2str(st.maxDD, '%1.4f'),'',num2str(st.mar, '%1.4f'),'',num2str(st.maxTimeOffPeak,'%7.0f')},...
            'FitBoxToText','off',...
            'VerticalAlignment', 'cap', ...
            'HorizontalAlignment', 'left', ...
            'LineStyle','none');

        annotation(gcf,'textbox',...
            [0.748 0.77 0.15 0.1],...
            'String',{'Sharpe Ratio','Sortino Ratio','','Performance (prc/y)','Volatility (prc/y)','','Maximum Drawdown','','MAR Ratio','','Max Time off peak'},...
            'HorizontalAlignment','right',...
            'FitBoxToText','off',...
            'VerticalAlignment', 'cap', ...    
            'LineStyle','none');

    end

    maxx = max(max(Long(:,index1)), max(Short(:,index1)))*1.1;
    minn = min(min(Long(:,index1)), min(Short(:,index1)))*1.1 - maxx*0.1;
    step  = (maxx - minn) / 4;

    
    if (max(Long(:,index1)) == min(Long(:,index1))) || (max(Short(:,index1)) == min(Short(:,index1)))        
        
        axes2 = axes('Parent',gcf,...
            'XTickLabel',xTickLabel,...
            'XTick',xTick,...
            'Position',[0.09 0.08 0.663 0.260]);

        xlim(axes2,[min(dVec) max(dVec)]);

        set(gca, 'XAxisLocation','top');           
        ylabel('Long/Short','FontSize',12);

        box(axes2,'on');
        hold(axes2,'all');

        l3 = plot(dVec, Long(:,index1),  'Color', [102/255 178/255 255/255]);
        l4 = plot(dVec, Short(:,index1), 'Color', [51/255 255/255 51/255]);

        if test                
            hL = legend([l3, l4],{'Long','Short'});
            set(hL,'Position', [0.85 0.13 0.1 0.1],'Units', 'normalized');
        else
            hL = legend([l1, l2, l3, l4],{'Max Drawdown','Max Time Off Peak','Long','Short'});
            set(hL,'Position', [0.85 0.13 0.1 0.1],'Units', 'normalized');
        end
        
        
    else
        yyTick = minn:step:maxx;
        yyTickLabel = cellfun(@(x) num2str(x,'%4.3f'), num2cell(yyTick), 'UniformOutput', false);


        axes2 = axes('Parent',gcf,'YTickLabel',yyTickLabel,...
            'YTick',yyTick,...
            'YMinorTick','on',...
            'XTickLabel',xTickLabel,...
            'XTick',xTick,...
            'Position',[0.09 0.08 0.663 0.260]);

        xlim(axes2,[min(dVec) max(dVec)]);
        ylim(axes2,[minn maxx]);

        set(gca, 'XAxisLocation','top');           
        ylabel('Long/Short','FontSize',12);

        box(axes2,'on');
        hold(axes2,'all');

        l3 = plot(dVec, Long(:,index1),  'Color', [102/255 178/255 255/255]);
        l4 = plot(dVec, Short(:,index1), 'Color', [51/255 255/255 51/255]);

        hL = legend([l1, l2, l3, l4],{'Max Drawdown','Max Time Off Peak','Long','Short'});
        set(hL,'Position', [0.85 0.13 0.1 0.1],'Units', 'normalized');


    end
    
    if index2 == 2
        set(l4, 'Visible', 'off');
    elseif index2 ==3
        set(l3, 'Visible', 'off');
    end

    linkaxes([axes1, axes2], 'x');
    
end

function plottt2(index2,index3)
    global ress
    
    clf(gcf);
    
    dateVec = ress.fundDate(ress.settings.lookback:end);
    tsName = ress.tsName;

    if ~exist('tsName','var'); tsName = 'Tradingsystem';end

    xTick = [];
    xTickLabel = {};
    for j = floor(dateVec(1)/10^4):1:floor(dateVec(end)/10^4)
        xTick(end+1) = datenum([j 01 01]);
        xTickLabel{end+1} = num2str(j,'%1.0f');
    end

    marketRet = ress.marketReturns(ress.settings.lookback:end,:); 
    if index2 == 3
        mRet = cumprod(1-marketRet(:,index3+1));
    else
        mRet = cumprod(1+marketRet(:,index3+1));
    end

    start = mRet(1);
    maxRet = max(mRet);
    minRet = min(mRet);
    step  = (maxRet - minRet) / 8;    

    yLower = start - ceil((start - minRet) / step) * step;
    yUpper = start + ceil((maxRet - start) / step) * step;

    yTick = yLower:step:yUpper;
    yTickLabel = cellfun(@(x) num2str(x,'%1.0f'), num2cell(yTick), 'UniformOutput', false);

    dVec = datenum(([floor(dateVec/10^4) floor((mod(dateVec,10^4))/10^2) mod(dateVec,10^2)]));   

    axes1 = axes('Parent',gcf,'YTickLabel',yTickLabel,...
        'YTick',yTick,...
        'YScale','log',...
        'YMinorTick','on',...
        'XTickLabel',xTickLabel,...
        'XTick',xTick,...
        'Position',[0.09 0.13 0.663 0.795]);

    xlim(axes1,[min(dVec) max(dVec)]);
    ylim(axes1,[minRet maxRet]);

    box(axes1,'on');
    hold(axes1,'all');

    semilogy(dVec,mRet,'Color',[0 0 1]);
    
    xlabel('Date');
    ylabel('Market Return of');
    
    tx = char(ress.settings.markets(index3+1));
    title(['Reference: Market Return of ', tx(1),'-',tx(3:end)], 'FontWeight','demi','FontSize',12);
    
end

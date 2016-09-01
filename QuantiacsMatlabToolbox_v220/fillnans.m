function out = fillnans(field)

out = field;
theNans = find([false(1, size(out,2)); isnan(out(2:end,:))]);
theNans = theNans(:);

if ~isempty(theNans)
    for i = 1:numel(theNans);
        out(theNans(i)) = out(theNans(i)-1);
    end
end

end
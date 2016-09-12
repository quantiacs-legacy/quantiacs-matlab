function out = fillwith(field, lookup)

out = field;
theNans = find([false(1, size(out,2)); isnan(out(2:end,:))]);
theNans = theNans(:);

if ~isempty(theNans)
    for i = theNans;
        out(i) = lookup(i-1);
    end
end

end
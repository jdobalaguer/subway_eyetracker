function i = tools_softmax(v,t)
    ev = exp(-v/t);
    csev = cumsum(ev);
    r = rand*csev(end);
    for i = 1:length(v)
        if r<csev(i)
            break;
        end
    end
end
function parar(src, event)
    N = length(event.Data(1,:));
    if max(event.Data((N-floor(0.1*src.Rate)):N,3))<1.5E-1
        global data
        global time
        data = event.Data;
        time = event.TimeStamps;
    end
    stop(src);
end
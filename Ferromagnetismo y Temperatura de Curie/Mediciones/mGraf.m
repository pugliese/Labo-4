function Graf = mGraf(x,y)
  l=(length(x)/2507);
  for i=1:l/10
    X=x((i-1)*10*2507+1:(i-1)*10*2507+1254);
    Y=y((i-1)*10*2507+1:(i-1)*10*2507+1254);
    I=plot(X,Y);
    xlimits = xlim ([-2,2])
    ylimits = ylim ([-1,0.4]);
    saveas(gcf,strcat('Figure',num2str(i),'.jpg'))
  endfor
endfunction
for i=1:900
  O(i)=mean(v((i-1)*floor(l/900)+1:min(i*floor(l/900),l)));
  for j=1:1001
    Vo(j+(i-1)*1001)=v(j+(i-1)*1001)-O(i);
  endfor
endfor
Vo(length(v))=v(length(v))-O(900);
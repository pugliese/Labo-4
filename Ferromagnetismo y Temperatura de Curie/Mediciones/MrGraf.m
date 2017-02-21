function [Mr,Tr]=MrGraf(t,H,M,k);
  l=length(H);
  i=1;
  j=1;
  while i<l
    if  H(i) >= k || H(i) <= -k
      i++;
    else
      Mr(j)=M(i);
      Tr(j)=t(i);
      j++;
      i++;
    endif
  endwhile
  plot(Tr,Mr,".");
endfunction


%Find First in each colum with I>0.5
%I muss durch das beaarbeitetw Bild ersetzt werden
n = bscanSize ;
firstoverthresh = zeros(1,n);
for j = 1:n
    firstoverthresh(j) = find(I(:,j)>0.5,1);
end


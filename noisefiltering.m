



img = mscan;

%img_subset = img(:, 1:10:1339450);



fileID = fopen('data/oct_timestamp_2.bin');
A = fread(fileID, Inf, 'uint64');
xTime = (A(end) - A(1)) / (size(A, 1)) / 50 / 1000; %seconds per A-scan
revTime = (1/8.75);
bscanSize = round(revTime / xTime);
fclose(fileID);

N = 20;
img_subset = img(:, 600001:(600000 + N*bscanSize));
%img_subset = imgaussfilt(img_subset, 3);
%img_subset(210:235, :) = medfilt2(img_subset(210:235, :));

P = reshape(img_subset,512,bscanSize,[]) ;
I = P(:,:,7);
I(1:224,:) = 0;


thr = 200; %Grenzwert für den Threshold definiert
%Threshold bei thr bei K
I(I < thr) = 0;
I(I > thr) = 1;
%morphological operator "open"
se = strel('cube',5);
se2 = strel('cube',5)
se3 = strel('cube',10)
se4 = strel('cube',15)
K = imopen(I,se);
J = imclose(K,se2);
L = imclose(K,se3);
M = imclose(K,se4);

Q = L; 
subplot(2,3,1)
colormap gray
imagesc(J)
title('Closed Operation followed by cube 5 Closing')
subplot(2,3,2)
imagesc(L)
title('Closed Operation followed by cube 10 Closing')
subplot(2,3,3)
imagesc(M)
title('Closed Operation followed by cube 15 Closing')
subplot(2,3,4)
imagesc(P(:,:,20))
title('original image ')
subplot(2,3,5)
imagesc(K)
title('Image with just opening operation ')
subplot(2,3,6)
imagesc(P(:,:,20))
title('original image mit threshold ')


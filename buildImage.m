img = mscan;
%img_subset = img(:, 700000:800000);
img_subset = img(:, 1:10:1339450);

img_subset_filtered = imgaussfilt(img_subset, 3);

fileID = fopen('oct_timestamp_2.bin');
A = fread(fileID, 'uint64');
xTime = 50 / (A(end) - A(1)) / (size(A, 1) ) * 1000 %1 millisekunde in Pixel
periodLength = xTime * (1/8.75)
plot(A)
fclose(fileID);

%figure
colormap gray
imagesc(img_subset)
%figure
colormap gray
imagesc(img_subset_filtered)
img = mscan;

%img_subset = img(:, 1:10:1339450);

fileID = fopen('data/oct_timestamp_1.bin');
A = fread(fileID, Inf, 'uint64');
xTime = (A(end) - A(1)) / (size(A, 1)) / 50 / 1000; %seconds per A-scan
revTime = (1/8.75);
bscanSize = round(revTime / xTime);
fclose(fileID);

N = 20;
img_subset = img(:, 600001:(600000 + N*bscanSize));

% remove line artifact
for i = 1:length(img_subset)
    col = img_subset(215:230, i);
    above_mean = mean(col(1:5));
    below_mean = mean(col(11:15));
    col(6:10) = (above_mean + below_mean) / 2;
    img_subset(215:230, i) = col;
end    

%img_subset(1:150, :) = mean(mean(img_subset(1:100, :)));

%img_subset = wiener2(img_subset, [5 5]);
img_subset = imgaussfilt(img_subset, 3);
%img_subset(210:235, :) = medfilt2(img_subset(210:235, :));

%img_subset(img_subset < 200) = 0;
%img_subset(img_subset >= 200) = 1;

cscan = reshape(img_subset, [512, bscanSize, N]);

R = 4;

figure
colormap gray
imagesc(cscan(150:512,:,R))

%max = 0;
%for i = height(img_subset(150, :))
%    row = img_subset(150+i, :);
%    max = max(row);
%    
%    if max > 200 
%        break;
%    end    
%end    

img_edge = edge(imgaussfilt(cscan(150:512,:,R), 5), "Canny", 0.3);
img_edge_int = int8(img_edge);
img_edge_int(img_edge) = 255;
figure
colormap gray
imagesc(img_edge_int)

img_edge_polar = PolarToIm(img_edge_int, 150/512, 1, 1024, 1024);

[r,c] = find(img_edge_polar);
%[z, a, b, alpha] = fitellipse([r,c]);

figure
plot([r,c], 'ro');

figure
colormap gray
imagesc(img_edge_polar)

%[X Y] = pol2cart( cscan(:,:,2));
%S = surf(X,Y,ones(size(X))); 
S = PolarToIm(cscan(:,:,R), 0, 1, 1024, 1024); 
figure
colormap gray
imagesc(S)


close all

fileID = fopen('data/oct_timestamp_1.bin');
timestamps = fread(fileID, Inf, 'uint64');
xTime = (timestamps(end) - timestamps(1)) / (size(timestamps, 1)) / 50 / 1000; %seconds per A-scan
revTime = (1/8.75);
bscanSize = round(revTime / xTime);
fclose(fileID);

figure
colormap gray
imagesc(mscan)

start_index = 650001;
end_index = 950000;
bscan_count = floor((end_index - start_index) / bscanSize);
mscan_subset = mscan(:, start_index:(start_index - 1 + bscan_count * bscanSize));

figure
colormap gray
imagesc(mscan_subset)

% remove line artifact
for i = 1:length(mscan_subset)
    col = mscan_subset(215:230, i);
    above_mean = mean(col(1:5));
    below_mean = mean(col(11:15));
    col(6:10) = (above_mean + below_mean) / 2;
    mscan_subset(215:230, i) = col;
end    

cscan = reshape(mscan_subset, [512, bscanSize, bscan_count]);
clearvars mscan_subset

cscan_polar = zeros(1024, 1024, size(cscan, 3));
ellipse_z = zeros(size(cscan, 3), 2);
ellipse_a = zeros(size(cscan, 3));
ellipse_b = zeros(size(cscan, 3));
ellipse_alpha = zeros(size(cscan, 3));

R = 2;

for i = 1:size(cscan, 3)
    cscan(:,:,i) = imgaussfilt(cscan(:,:,i), 3);
    bscan_smoothed = imgaussfilt(cscan(150:512,:,i), 8);
    %mscan_edge = int8(edge(mscan_smoothed, "Sobel", 1.2));
    bscan_edge = edge(bscan_smoothed, "Canny", 0.35);
    bscan_edge_polar = int8(Polar2Im([zeros(149, bscanSize) ; bscan_edge], 1024, "linear"));
    [r,c] = find(bscan_edge_polar);
    [z, a, b, alpha] = fitellipse([c,r], 'linear', 'constraint', 'trace');
    ellipse_z(i,:) = z;
    ellipse_a(i) = a;
    ellipse_b(i) = b;
    ellipse_alpha(i) = alpha;
    cscan_polar(:,:,i) = Polar2Im(cscan(:,:,i), 1024, "linear");
end

clearvars bscan_smoothed bscan_edge bscan_edge_polar


figure
colormap gray
imagesc(cscan(:,:,R))

%figure
%colormap gray
%imagesc(PolarToIm(cscan(:,:,R), 0, 1, 1024, 1024));

figure
colormap gray
imagesc(cscan_polar(:,:,R))
hold on
plotellipse(ellipse_z(R,:), ellipse_a(R), ellipse_b(R), ellipse_alpha(R));
hold off





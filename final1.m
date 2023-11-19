clc,clearvars

%%% Basic Replication of https://theclassytim.medium.com/using-image-processing-to-count-artillery-craters-in-ukraine-b8768c45309

%% load images
im1 = imread("test images\c1\craters1.jpg");
im12 = imread("test images\c1\craters1 (2).jpg");

%% exploring selection of color channel for greyscale conversion
r = im12(:,:,1);
g = im12(:,:,2);
b = im12(:,:,3);

histr = imhist(r);
histg = imhist(g);
histb = imhist(b);

% Plot color channel histograms
montage({im12(:,:,1),im12(:,:,2),im12(:,:,3)});
title("Color Channel Comparison", "FontSize", 12);
figure
% imhist(r);
% caption = "Red Channel";
% title(caption, "FontSize", 14);
% figure
% imhist(g);
% caption = "Green Channel";
% title(caption, "FontSize", 14);
% figure
% imhist(b);
% caption = "Blue Channel";
% title(caption, "FontSize", 14);
% figure

% looking at these histograms, it seems like there is not much
% looking at the images, it's also not obvious if any color channel is best

% montage({r, g, b}) 


%% examining the histograms

%% comparing options for image binarization
adaptive = imbinarize(rgb2gray(im12), 'adaptive');
global_ = imbinarize(rgb2gray(im12), 'global');

% adaptive seems to have much less noise in the binary image
imshow(adaptive);
caption = "Adaptive (Default) Binarization Algo.";
title(caption, "FontSize", 14);
figure
imshow(global_);
caption = "Global Binarization Algo.";
title(caption, "FontSize", 14);
figure
% imshow(imabsdiff(adaptive, global_));
% montage({adaptive, global_})

%% comparing blur levels
b025 = imgaussfilt(r, 0.25);
b05 = imgaussfilt(r, 0.5);
b1 = imgaussfilt(r, 1);
b25 = imgaussfilt(r,2.5);
b35 = imgaussfilt(r, 3.5);
b5 = imgaussfilt(r, 5);
montage({b025, b05, b1, b25, b35, b5});
caption = "Blur levels: 0.25, 0.5, 1, 2.5, 3.5, 5";
title(caption, "FontSize", 14);
figure
% imshow(b35)

%% attempting binarization with gaussian blur
bim12025 = imbinarize(imgaussfilt(r, 0.25), 'global');
bim1205 = imbinarize(imgaussfilt(r, 0.5), 'global');
bim121 = imbinarize(imgaussfilt(r, 1), 'global');
bim125 = imbinarize(imgaussfilt(r, 5), 'global');

montage({bim12025, bim1205, bim121, bim125})
caption = "Effects of Blur on Binarization: 0.25, 0.5, 1, 5";
title(caption, "FontSize", 14);


% it seems like the higher blur (SD = 1) creates a much less noisy
% binarization. SD=5 seems to reduce noise entirely, but may lose smaller
% craters

%% comparing blurred adaptive binarization vs global binarization
bima12 = imbinarize(imgaussfilt(r,0.5), 'adaptive');
bimg12 = imbinarize(imgaussfilt(r,0.5), 'global');

% montage({bima12, bimg12});

%% just contrast stretch (histeq)
ih = histeq(r);

% montage({r, ih});

% histogram equalization seems to make details more prominent

%% contrast stretch and blur
bh = histeq(b05);

% imhist(b05);
% figure
% imhist(bh);
% figure
% 
% montage({r, b05, ih, bh});

% Does order matter? Is there a difference between contrast stretching
% then blurring and blurring and then contrast stretching?

%% testing if order matters
hb = imgaussfilt(histeq(r), 0.5);

% montage({bh, hb});
% 
% imshow(imabsdiff(hb,bh))
% imshow(imabsdiff(hb,bh) * 10);

% imhist(hb);
% figure
% imhist(bh);
% figure

% we can see from the histograms that blurring creates many more bins, this
% may change the results of the binarization by pushing pixels one way or
% another over the threshold

% looing at these differences, it's clear that there IS a difference,
% although it does seem to be relatively small in magniture. I'm going to
% go with the blur and THEN histogram equalize since intuitively it's better to remove 
% move high frequency noise in earlier steps.

%% attempting binarization with contrast stretch (histeq), but no blur
% just histogram eq, no blur
binh = imbinarize(ih, 'global');

% binarization with contrast stretch THEN blur
binhb = imbinarize(hb, 'global');

% binarization with blur THEN contrast stretch
binbh = imbinarize(bh, 'global');

% montage({binh, binhb, binbh})

% to my eye, histogram equalization and THEN blur looks the clearest

%% manual thresholding 
% various thresholds on blurred and histogram equalized images
mbin10 = imbinarize(bh, 10/255);
mbin35 = imbinarize(bh, 35/255);
mbin50 = imbinarize(bh, 50/255);
mbin75 = imbinarize(bh, 75/255);
mbin100 = imbinarize(bh, 100/255);
mbin150 = imbinarize(bh, 150/255);
mbin200 = imbinarize(bh, 200/255);
mbin225 = imbinarize(bh, 225/255);

% montage({mbin10, mbin35, mbin50, mbin75, mbin100, mbin150, mbin200, mbin225})

% using this manual thresholding, we get two useful outputs. The lowest
% threshold yields dark blobs that may be counted. The highest threshold
% yields the debris halos around the craters, which may be fed into some of
% the crater detection algorithms (such as hough transform?), which tend to
% detect from edges

%% manual thresholding comparison
T = 225/255
% just histogram eq, no blur
mbinh = imbinarize(ih, T);

% binarization with contrast stretch THEN blur
mbinhb = imbinarize(hb, T);

% binarization with blur THEN contrast stretch
mbinbh = imbinarize(bh, T);

montage({mbinh, mbinhb, mbinbh})
title("Order of Operations (Contrast Stretch, Blur)");
figure

% here we can see a clear improvment of both methods that blur and contrast
% stretch over just the contrast stretching.


%% Taking a look at inverted images
% montage({not(mbinh), not(mbinhb), not(mbinbh)})

%% there is more noise in here than I'd like, even in the lowest threshold
%% image. Might be good enough for blob detection though.
% imshow(not(mbin10))

%% working with blobs
blobs = regionprops(not(mbin10));
numel(blobs)

% centroids = cat(1,blobs.Centroid);
% 
% imshow(im12)
% hold on
% plot(centroids(:,1), centroids(:,2), 'b*')
% hold off

% using this, I get 4672 8-connected blobs (if I'm understanding the
% documentation). I neet to constrain this further. Picking up too much
% noise from the field

%% Using morphological processing
% SE4 = strel('square', 4); % i think this will lose many small craters. refer to maxar image resolution
% SE2 = strel('square', 2);
% eroded = imerode(not(mbin10), SE4);
% eroded2 = imerode(not(mbin10), SE2);

% This seems to capture the "small black dot" type craters

SE4 = strel('square', 4); % i think this will lose many small craters. refer to maxar image resolution
SE2 = strel('square', 2);
eroded = imerode(mbin225, SE4);
eroded2 = imerode(mbin225, SE2);

% This method seems to capture the white halo - type craters

% imshow(eroded)

blobse = regionprops(eroded)
numel(blobse)


centroids = cat(1,blobse.Centroid);

% red = im12(:,:,1) + (cast(eroded2, 'uint8') * 255);
% imr = im12;
% imr(:,:,1) = red;
% 
% imshow(imr)
% hold on
% plot(centroids(:,1), centroids(:,2), 'b*')
% hold off

% Re-testing with a stronger blur

mb = imbinarize(histeq(b35), 5/255);
mb2 = imbinarize(histeq(b25), 5/255);

e12 = imerode(mb,SE2);
e14 = imerode(mb, SE4);
e22 = imerode(mb2,SE2);
e24 = imerode(mb2,SE4);


% imshow(not(mb))
% % montage({mb,mb2})
% % montage({e12, e14, e22, e24})
% 
% red = im12(:,:,1) + (cast((histeq(b35) == 0), 'uint8') * 255);
% imr = im12;
% imr(:,:,1) = red;
% 
% imshow(imr)
% hold on
% plot(centroids(:,1), centroids(:,2), 'b*')
% hold off


%% Trying contrast stretch -> blur -> erode
imshow(histeq(im12(:,:,2)))
imshow(histeq(im12(:,:,2)) < 10) % no blur
imshow((imgaussfilt(histeq(im12(:,:,2), 40)) < 10)) % blur before thresholding
% strong blur clears up much of the noise
% imshow(imerode(histeq(im12(:,:,2)) < 10), SE2) % no blur + erode


%% This works!
iot = imgaussfilt(histeq(im12(:,:,2), 40)) < 10;

red = im12(:,:,1) + (cast(iot, 'uint8') * 255);
imr = im12;
imr(:,:,1) = red;
imshow(imr)

% Add centroids (janky)
iotblobs = regionprops(iot)
fprintf("Number of craters: %i\n", numel(iotblobs))
iotcentroids = cat(1,iotblobs.Centroid);

hold on
plot(iotcentroids(:,1), iotcentroids(:,2), 'b*')
hold off


%% Now to improve it with erosion
% eiot = imerode(iot, SE4);
% 
% red = im12(:,:,1) + (cast(iot, 'uint8') * 255);
% imr = im12;
% imr(:,:,1) = red;
% 
% imshow(imr)
% 
% imshow(imr)
% hold on
% plot(centroids(:,1), centroids(:,2), 'b*')
% hold off
% 
% imshow(eiot)


%% Without morphological processing

trimmed = imgaussfilt(histeq(im12(:,:,2), 40)) < 10; % TODO typo here

% imshow(trimmed)
cc = regionprops(trimmed);
ccareas = [cc.Area];

% check to see the distribution of connected component size
histogram(ccareas(find(ccareas < 20))); 

% looking through this histogram, it seems there may be noise left over in
% the form of very small connected components. Testing this with some image
% overlays of centroids

%% Examining the small connected components

inde1 = find(ccareas == 1);
inde2 = find(ccareas == 2);
inde3 = find(ccareas == 3);
indlte5 = find(ccareas <= 5);
indlte10 = find(ccareas <= 10);
indgt5lte10 = find((5 < ccareas) & (ccareas <= 10));


e1 = cc(inde1);
e2 = cc(inde2);
e3 = cc(inde3);
lte5 = cc(indlte5);
lte10 = cc(indlte10);
gt5lte10 = cc(indgt5lte10);

% image comparison
% centroids1 = cat(1,e1.Centroid);
% 
% imshow(im12)
% hold on
% plot(centroids1(:,1), centroids1(:,2), 'b*')
% hold off

% we see that these centroids seem to be mainly false positives. These seem
% to occur mainly in areas where multiple craters overlap, where cloud
% shadows are present, or at the rims of multicolored craters.

% centroids2 = cat(1,e2.Centroid);
% 
% imshow(im12)
% hold on
% plot(centroids2(:,1), centroids2(:,2), 'b*')
% hold off

% centroids3 = cat(1,e3.Centroid);
% 
% imshow(im12)
% hold on
% plot(centroids3(:,1), centroids3(:,2), 'b*')
% hold off

% the centroids of components with area 3 seem to also be mainly false
% positives. These tend to occur in the same places, but also at the edge
% of the image

% Less than 5
centroids5 = cat(1,lte5.Centroid);

imshow(im12)
hold on
plot(centroids5(:,1), centroids5(:,2), 'b*')
hold off

fprintf("Number of components less than area 5: %i\n", length(centroids5));

% looking at centroids of components with area less than or equal to 5
% shows a large collection of false positives, with some true positives.
% Many of these "hits" are clustered inside of larger artillery craters,
% causing an overcounting of shell craters.
% Counting shows us that 75 of the components fall into this category,
% comprising around 25% of the total components. Culling these results in a
% significant increase in the count accuracy.

% Less than 10
centroids10 = cat(1,lte10.Centroid);

imshow(im12)
hold on
plot(centroids10(:,1), centroids10(:,2), 'b*')
hold off

fprintf("Number of components less than area 10: %i\n", length(centroids10));

% Looking at these, we start to see true positives trickle in.

%% Testing areas 5 < area <= 10
centroidsgt510 = cat(1,gt5lte10.Centroid);

imshow(im12)
hold on
plot(centroidsgt510(:,1), centroidsgt510(:,2), 'b*')
hold off

fprintf("Number of components greater than 5 and LTE area 10: %i\n", length(centroidsgt510));

% We see that selecting components between 5 and 10 yields mostly hits on
% actual craters. It does seem like this range also contains some of the
% false positives where multiple hits are assigned to a single crater. 
% Could this be fixed by filling holes? I can test, but I assume it will
% cause other issues by collapsing multiple separate craters into single
% connected components. TODO 
% Next we will look at the complements of these sets of small area components.


%% Looking at the filtered centroids greater than a given area
indgt1 = find(ccareas > 1);
indgt2 = find(ccareas > 2);
indgt3 = find(ccareas > 3);
indgt5 = find(ccareas > 5);
indgt10 = find(ccareas > 10);
gt5 = cc(indgt5);
gt10 = cc(indgt10);

% Testing out components of area 10 and greater
centroidstrimmed10 = cat(1, gt10.Centroid);

imshow(im12)
hold on
plot(centroidstrimmed10(:,1), centroidstrimmed10(:,2), 'b*')
hold off

% fprintf("Number of craters after trim at 10: %i\n", length(centroidstrimmed10));

% Testing out the goldilocks threshold of area 5:
% centroidstrimmed5 = cat(1, gt5.Centroid);
% 
% imshow(im12)
% hold on
% plot(centroidstrimmed5(:,1), centroidstrimmed5(:,2), 'b*')
% hold off
% 
% fprintf("Number of craters after trim at 5: %i\n", length(centroidstrimmed5));

% This cutoff of area 5 seems to result in very few missed craters, with
% far fewer false positives. As we can see, the cutoff of 10 seems to miss
% a larger number of craters, although it does result in fewer
% double-counts.

%% Visualizing the difference by coloring the three thresholds

% definitions for reference:
% lte5 = cc(indlte5);
% gt5lte10 = cc(indgt5lte10);
% indgt10 = find(ccareas > 10);
% gt10 = cc(indgt10);

centroids5 = cat(1,lte5.Centroid); % less than 5
centroidsgt510 = cat(1,gt5lte10.Centroid); % 5 < area <= 10
centroidstrimmed10 = cat(1, gt10.Centroid); % 10 and greater

imshow(im12)
hold on
plot(centroids5(:,1), centroids5(:,2), 'r*')
plot(centroidsgt510(:,1), centroidsgt510(:,2), 'c*')
plot(centroidstrimmed10(:,1), centroidstrimmed10(:,2), 'b*')
title("Cutoff Threshold Experiment: red=lt5, cyan=5-10, blue>10");
hold off
% (my apologies to the colorblind)

% Looking at these results, it's clear that connected components with areas
% between 5 and 10 (cyan) contain mainly true positives. The cyan centroids
% also seem to result in very few double counts. It's also clear that the 
% components with area less than 5 (red) contain almost exclusively false 
% positives. This is my justification for selecting area=5 as my cutoff criteria.

% Comparing counts
fprintf("Number of components less than area 5: %i\n", length(centroids5));
fprintf("Number of components greater than 5 and LTE area 10: %i\n", length(centroidsgt510));
fprintf("Number of craters after trim at 10: %i\n", length(centroidstrimmed10));

% Upon visual inspection, out of the 17 centroids between 5 and 10 (cyan),
% there was one double count, and a
% single potential false positive, although it may have been a
% small-diameter mortar crater.

% Of the 75 centroids under 5 (red), almost all were false positives or
% double counts (often with multiple in a single crater).

% Of the remaining centroids (area > 10), I was not able to identify a
% false positive. There were a small number of missed craters, of which
% most were multiple closely overlapping impacts. However, most overlapping 
% impacts were correctly identified. In particular, one missed crater
% stands out. Near the bottom of the image, there is a pair of two craters
% that are close to each other. Despite the large size and distinct shape
% of the leftmost crater, it is not identified. I hypothesize that this is
% due to the large white halo around this particular crater-- it is
% possible that this debris field caused the two craters to appear as a
% single connected component (TODO test this?). This crater pair issue may
% be a limitation of this detection method, although the method does seem
% to classify most compound craters correctly, exceeding my expectations
% for what would be achievable using simple classical methods. 

%% Missed craters
% Using cropped photos I should examine the type
% of craters that are missed AND compare them to the no filtering, to see
% if all craters are caught. I'd also like to do an analysis of the false
% positives. DONE ABOVE^


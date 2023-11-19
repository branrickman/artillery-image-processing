clc, clearvars;

%% Using the Hough Transform to identify crater rim elipses
load_images;

im12 = imread("test images\c1\craters1 (2).jpg");
img = rgb2gray(im12);
edges = edge(im12(:,:,1),'Canny');

% iot = imgaussfilt(histeq(im12(:,:,2), 40)) < 10;

% [centers, radii, metric] = imfindcircles(iot, [2 10]);
%imshow(edge(im12(:,:,1),'Canny'))
% 
% imshow(iot)
% viscircles(centers(:, :), radii(:), "EdgeColor", "b");


% testing with "halo"  generating 
r = im12(:,:,1);
b05 = imgaussfilt(r, 0.5);
bh = histeq(b05);
mbin225 = imbinarize(bh, 225/255);

% imshow(mbin225)
% [centers, radii, metric] = imfindcircles(mbin225, [5 15]);
% imshow(mbin225)
% viscircles(centers(:, :), radii(:), "EdgeColor", "b");

% maybe this is where morphological methods come in?
SE2 = strel('square', 2);
eroded = imerode(imerode(mbin225, SE2), SE2);
dilated = imdilate(eroded, SE2);


% imshow(im12(:,:,1)) %just red channel
% imshow(dilated);
% [centers, radii, metric] = imfindcircles(dilated, [3 20]);
% % imshow(mbin225)
% viscircles(centers(:, :), radii(:), "EdgeColor", "b");

%% Double Dilation
% imshow(dilated)
% doubledilated = imdilate(imdilate(eroded, SE2), SE2);
% 
% imshow(doubledilated)
% imshow(im12(:,:,1));
% [centers, radii, metric] = imfindcircles(doubledilated, [3 20]);
% viscircles(centers(:, :), radii(:), "EdgeColor", "r", "LineWidth", 0.1, "LineStyle", "-");


%% Limiting to just large craters
doubledilated = imdilate(imdilate(eroded, SE2), SE2);

imshow(doubledilated)
imshow(im12);
[centers, radii, metric] = imfindcircles(doubledilated, [10 30]);
viscircles(centers(:, :), radii(:), "EdgeColor", "r", "LineWidth", 0.1, "LineStyle", "-");

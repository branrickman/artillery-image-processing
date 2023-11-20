clc, clearvars;
%% Using the Circular Hough Transform to Detect Artillery Craters
load_images;

% Select image
image = im2;

imshow(image)
% Experimenting with filtering components and handling dark and light
% separately
input = histeq(image(:,:,3));
SE = strel("square", 2);

light = input > 200; % too noisy-- filter by components
light2 = imerode(light, SE);
light_trimmed = bwareaopen(light2, 10);

dark = input < 20;
% dark2 = imerode(dark, SE);
dark_trimmed = bwareaopen(dark, 5);

extremes = imadd(light_trimmed, dark_trimmed);
[centersl, radiil] = imfindcircles(light_trimmed, [5 30]);
[centersd, radiid] = imfindcircles(dark_trimmed, [5 20]);
centersb = cat(1, centersl, centersd); % combine light and dark
radiib = cat(1, radiil, radiid); % combine light and dark

imshow(image)
% draw light detected circles
viscircles(centersl(:, :), radiil(:), "EdgeColor", "c", "LineWidth", 0.1, "LineStyle", "-");
% draw dark detected circles
viscircles(centersd(:, :), radiid(:), "EdgeColor", "r", "LineWidth", 0.1, "LineStyle", "-");
caption = "Site 2 Full size: Two step, Small Component Culling";
title(caption, "FontSize", 14);
drawnow();

% red mask overlay
% red_mask_overlay = image;
% red_mask_overlay(:,:,1) = red_mask_overlay(:,:,1) + (cast(dark_trimmed, "uint8") * 255);
% 
% blue_mask_overlay = image;
% red_mask_overlay(:,:,3) = red_mask_overlay(:,:,3) + (cast(light_trimmed, "uint8") * 255);
% 
% imshow(red_mask_overlay);
% % draw light detected circles
% viscircles(centersl(:, :), radiil(:), "EdgeColor", "c", "LineWidth", 0.1, "LineStyle", "-");
% % draw dark detected circles
% viscircles(centersd(:, :), radiid(:), "EdgeColor", "r", "LineWidth", 0.1, "LineStyle", "-");
% caption = "Mask Overlay for Small Component Culling";
% title(caption, "FontSize", 14);
% drawnow();
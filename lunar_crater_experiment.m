clc, clearvars;
%% Using the Circular Hough Transform to Detect Artillery Craters
load_images;

% Select image
image = moon1;

imshow(image)
caption1 = "Unedited"
title(caption1, "FontSize", 14);

% Experimenting with separately handling dark and light

% Color channels
montage({moon1(:,:,1), moon1(:,:,2), moon1(:,:,3)});
title("Color Channels", "FontSize", 14);
figure

% Contrast Stretching
input = histeq(image(:,:,3));
imshow(input)
caption2 = "Histeq";
title(caption2, "FontSize", 14);

imhist(image)

SE = strel("square", 2);
light = input > 200; % too noisy-- filter by components
imshow(light);
title("Upper thresholding");


% light2 = imerode(light, SE);
% light_trimmed = bwareaopen(light2, 10);
% 
% dark = input < 20;
% % dark2 = imerode(dark, SE);
% dark_trimmed = bwareaopen(dark, 5);
% 
% extremes = imadd(light_trimmed, dark_trimmed);
% [centersl, radiil] = imfindcircles(light_trimmed, [5 100]);
% [centersd, radiid] = imfindcircles(dark_trimmed, [5 100]);
% centersb = cat(1, centersl, centersd); % combine light and dark
% radiib = cat(1, radiil, radiid); % combine light and dark
% 
% imshow(image)
% % draw light detected circles
% viscircles(centersl(:, :), radiil(:), "EdgeColor", "c", "LineWidth", 0.1, "LineStyle", "-");
% % draw dark detected circles
% viscircles(centersd(:, :), radiid(:), "EdgeColor", "r", "LineWidth", 0.1, "LineStyle", "-");
% caption = "CHT on Lunar Craters";
% title(caption, "FontSize", 14);
% drawnow();
% 
% % red mask overlay
% % red_mask_overlay = image;
% % red_mask_overlay(:,:,1) = red_mask_overlay(:,:,1) + (cast(dark_trimmed, "uint8") * 255);
% % 
% % blue_mask_overlay = image;
% % red_mask_overlay(:,:,3) = red_mask_overlay(:,:,3) + (cast(light_trimmed, "uint8") * 255);
% % 
% % imshow(red_mask_overlay);
% % % draw light detected circles
% % viscircles(centersl(:, :), radiil(:), "EdgeColor", "c", "LineWidth", 0.1, "LineStyle", "-");
% % % draw dark detected circles
% % viscircles(centersd(:, :), radiid(:), "EdgeColor", "r", "LineWidth", 0.1, "LineStyle", "-");
% % caption = "Mask Overlay for Small Component Culling";
% % title(caption, "FontSize", 14);
% % drawnow();
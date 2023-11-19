clc,clearvars;

% Load images
load_images;

image = im4;
% Initial tune: color_channel=2, grey_levels=40, blur_std=0.5, trim_threshold = 10
pre = preprocess(image, 3, 40, 0.5, 40);
% Initial detect_craters tune: lower_size_cutoff=10, upper_size_cutoff=500
centroids = detect_craters(pre, 50, 500);
%% show original
imshow(image);
%% show preprocessing mask
imshow(pre);
%% show overlaid components
red_mask_overlay = image;
red_mask_overlay(:,:,1) = red_mask_overlay(:,:,1) + (cast(pre, "uint8") * 255);
imshow(red_mask_overlay);
caption = "Site 4 Full: Tuned Red Mask";
title(caption, "FontSize", 14);
drawnow();
figure
%% show overlaid centroids
imshow(image)
hold on
plot(centroids(:,1), centroids(:,2), 'b*')
caption = "Site 4 Full: Tuned Centroids";
title(caption, "FontSize", 14);
hold off


function f = preprocess(image, color_channel, grey_levels, blur_std, trim_threshold)
    % Takes in a color image, converts to gray by selecting a color channel,
    % histogram EQ and blurs.
    % Initial tune: color_channel=2, grey_levels=40, blur_std=0.5, trim_threshold = 10
    
    g = image(:,:,color_channel);
    step1 = histeq(g, grey_levels);
    step2 = imgaussfilt(step1, blur_std);%, blur_std);
    step3 = step2 < trim_threshold; %trim high pixel intensity
    f = step3;
end

function f = detect_craters(image, lower_size_cutoff, upper_size_cutoff)
    % Converts a binary image into its connected components, reduced noise
    % by culling small components and returns the centroids of the culled
    % component list.
    
    % Create components
    components = regionprops(image);
    areas = [components.Area];
    
    % Trim small component (small shadows, image noise)
    % Trim large components (forest, cloud/cloud shadow, buildings, roads)
    candidate_indices = find(areas > lower_size_cutoff & areas < upper_size_cutoff);
    
    % Combine
    candidate_components = components(candidate_indices);
%     fprintf("%i ", candidate_indices);
    
    % get centroid list
    centroids = cat(1, candidate_components.Centroid);
    f = centroids;
end
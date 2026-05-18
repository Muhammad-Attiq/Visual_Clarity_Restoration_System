clc; clear; close all;

img = im2double(imread('1.jpg'));

figure('Name','Step 1 - Original Image');
imshow(img);
title('Original Misty Image');

tic;

% -------------------------------------------------
% RGB to LAB
% -------------------------------------------------
lab = rgb2lab(img);

L = lab(:,:,1);
a = lab(:,:,2);
b = lab(:,:,3);

figure('Name','Step 2 - L Channel');
imshow(L, []);
title('L Channel');

% -------------------------------------------------
% Normalize L channel
% -------------------------------------------------
L_norm = mat2gray(L);

figure('Name','Step 3 - Normalized L Channel');
imshow(L_norm);
title('Normalized L Channel');

% -------------------------------------------------
% CLAHE Enhancement
% -------------------------------------------------
L_clahe = adapthisteq(L_norm, ...
    'ClipLimit', 0.02, ...
    'NumTiles', [8 8]);

figure('Name','Step 4 - CLAHE');
imshow(L_clahe);
title('After CLAHE');

% -------------------------------------------------
% Gamma Correction
% -------------------------------------------------
L_gamma = imadjust(L_clahe, [], [], 0.68);

figure('Name','Step 5 - Gamma Correction');
imshow(L_gamma);
title('After Gamma Correction');

% -------------------------------------------------
% Morphological Processing
% -------------------------------------------------
se = strel('disk', 10);

topHat = imtophat(L_gamma, se);

figure('Name','Step 6 - Top Hat');
imshow(topHat);
title('Top Hat Output');

L_morph = L_gamma - topHat;

figure('Name','Step 7 - Morphological Result');
imshow(L_morph);
title('After Morphological Processing');

% -------------------------------------------------
% Gaussian Spatial Filtering
% -------------------------------------------------
L_spatial = imgaussfilt(L_morph, 0.95);

figure('Name','Step 8 - Gaussian Filtering');
imshow(L_spatial);
title('After Gaussian Filtering');

% -------------------------------------------------
% Contrast Stretching
% -------------------------------------------------
L_final = imadjust( ...
    L_spatial, ...
    stretchlim(L_spatial, 0.001), ...
    [0.005 0.995]);

figure('Name','Step 9 - Final Enhanced L');
imshow(L_final);
title('After Contrast Stretching');

% -------------------------------------------------
% LAB to RGB Reconstruction
% -------------------------------------------------
x = cat(3, L_final*100, a*1.28, b*1.28);

result = lab2rgb(x);

figure('Name','Step 10 - LAB to RGB');
imshow(result);
title('Reconstructed RGB Image');

% -------------------------------------------------
% Final Gaussian Smoothing
% -------------------------------------------------
result = imgaussfilt(result, 0.45);

figure('Name','Step 11 - Final Smoothing');
imshow(result);
title('After Final Gaussian Smoothing');

% -------------------------------------------------
% Unsharp Masking
% -------------------------------------------------
h = fspecial('unsharp', 0.5);

result = imfilter(result, h, 'replicate');

figure('Name','Step 12 - Unsharp Masking');
imshow(result);
title('After Sharpening');

% -------------------------------------------------
% Clamp Intensity Values
% -------------------------------------------------
result = min(max(result, 0), 1);

figure('Name','Step 13 - Final Output');
imshow(result);
title('Final Mist Removed Image');

toc;

% -------------------------------------------------
% Comparison Figure
% -------------------------------------------------
figure('Name','Original vs Result');

subplot(1,2,1);
imshow(img);
title('Original Misty Image');

subplot(1,2,2);
imshow(result);
title('Mist Removed');

% -------------------------------------------------
% Save Output
% -------------------------------------------------
imwrite(result, 'mist_removed.jpg');

disp('Mist removal completed.');

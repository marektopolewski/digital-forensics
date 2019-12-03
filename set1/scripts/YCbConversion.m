%%%%%%%%%%%%%%%% Lab 1 / Excercise 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Q1: read the image
im = imread('lena512color.tiff');


%% Q2: separate the image into RGB channels
imR = im(:,:,1); imG = im(:,:,2); imB = im(:,:,3);

% display the separate channels in one figure
figure; colormap('gray'); 
subplot(2,2,1); imshow(im,[]); title('Original RGB')
subplot(2,2,2); imshow(imR,[]); title('Red')
subplot(2,2,3); imshow(imG,[]); title('Green')
subplot(2,2,4); imshow(imB,[]); title('Blue')


%% Q3-Q4: convert the image to Y'CbCr representation
transform_matrix = [ 0.2990   0.5870    0.1140;
                     -0.1687  -0.3313   0.5000;
                     0.5000   -0.4187   -0.0813 ];
                 
% type double is preferred for image processing                 
rgb = double(im);
rgb_size = size(rgb);

% converting into a (512^2 x 3) matrix to allow multiplication
rgb = reshape(rgb, [], 3);

% execute transformation and convert back to original 512x512x3 size
ycbcr = transform_matrix * rgb' + [0 128 128]';
ycbcr = ycbcr';
ycbcr = reshape(uint8(ycbcr), rgb_size);

% display converted image in seprate Y, Cb and Cr channels
imY = ycbcr(:,:,1);
imCb = ycbcr(:,:,2);
imCr = ycbcr(:,:,3);

figure;
subplot(2,2,1); imshow(ycbcr, []); title('YCbCr Image')
axis image;
subplot(2,2,2); imshow(imY, []); title('Y')
axis image;
subplot(2,2,3); imshow(imCb, []); title('Cb') 
axis image;
subplot(2,2,4); imshow(imCr, []); title('Cr') 
axis image;
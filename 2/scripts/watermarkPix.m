%% Q1 Load image
I = imread('lena512gray.pgm');

%% Q2 First two and last two planes
B1 = bitPlane(I,1); B2 = bitPlane(I,2);
B7 = bitPlane(I,7); B8 = bitPlane(I,8);

figure; 
subplot(1,2,1); imshow(I,[]); title('Original')
subplot(1,2,2); imshow(B1+B2+B7+B8,[]); title('Selected bit planes (1,2,7,8)')

%% Q3 Load logo
L = imread('warwick512gray.pgm');

%% Q4 Binarise logo
binL = binarise(L);

%% Q5 Invert bin logo
invL = uint8(~binL);

figure; 
subplot(1,3,1); imshow(L,   []); title('Original image')
subplot(1,3,2); imshow(binL,[]); title('Binary image')
subplot(1,3,3); imshow(invL,[]); title('Inverted binary image')

%% Q6 Embed a watermark in LSB
I2 = watermark(I, invL);

%% Q7 Compute SSIM
sim = ssim(I2, I);
figure; suptitle(['Watermarked image, ssim = ', num2str(sim,4)])
subplot(1,1,1); imshow(I2, []);

%% Q8 Save images as JPG
imwrite(I2, 'lena512gray_wm.jpg'); wm_JPG = imread('lena512gray_wm.jpg');
imwrite(I, 'lena512gray.jpg'); og_JPG = imread('lena512gray_wm.jpg');
sim2 = ssim(bitPlane(wm_JPG,1),bitPlane(og_JPG,1));

% JPG compression does not retain the watermark, ssim=1
figure;
subplot(1,2,1); imshow(bitPlane(og_JPG,1),[]); title('Original JPG LSB plane')
subplot(1,2,2); imshow(bitPlane(wm_JPG,1),[]); title('Watermark JPG LSB plane')
suptitle(['ssim = ', num2str(sim2,4)])

%% Q9 Replace LSB plane of the image with MSB plane of the logo
I3 = watermark(I, bitPlane(L,8));               sim3 = ssim(I3, I);
I4 = watermark(I, uint8(~bitPlane(L,8)*2^7));   sim4 = ssim(I4, I);

figure; suptitle('(Visibly) Watermarked image')
subplot(1,2,1); imshow(I3, []); title(['Non-inverted logo, ssim = ', num2str(sim3,4)])
subplot(1,2,2); imshow(I4, []); title(['Inverted logo, ssim = ', num2str(sim4,4)])



%% HELPER FUNCTIONS
function [bm] = bitPlane(im, n)
% BITPLANE extract (n-1)th bit plane of an image
    bm = bitget(im, n) * 2^(n-1);
end

function [bin] = binarise(im)
% BINARISE convert a greyscale image into a binary image
    minVal = min(min(im)); 
    maxVal = max(max(im)); 
    t = maxVal/2;
    
    bin = im - minVal;
    bin = uint8(bin > t);
end

function [im2] = watermark(im, wm)
% WATERMARK Embed a watermark (pixel domain) in the first bit plane of an image
    B2 = bitPlane(im,2); B3 = bitPlane(im,3); 
    B4 = bitPlane(im,4); B5 = bitPlane(im,5); 
    B6 = bitPlane(im,6); B7 = bitPlane(im,7); B8 = bitPlane(im,8);
    
    im2 = wm + B2 + B3 + B4 + B5 + B6 + B7 + B8;
end
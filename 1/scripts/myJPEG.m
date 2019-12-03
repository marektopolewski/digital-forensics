%% Q1 Import image
image = imread('lena512gray.pgm');
dims = size(image);

%% Q2 Display DCT coefficients
imcoefs = dct2(image);
imcoefsShow = log(abs(imcoefs));

figure;
subplot(1,2,1); imshow(image,[]); title('Original Image')
subplot(1,2,2); imagesc(imcoefsShow); colormap(jet); title('DCT Coefficients')

%% Q3 Remove small DCT coefficients
[imcoefs2, kept_entire] = compressDCT(imcoefs, 150);

imcoefs2Show = log(abs(imcoefs2));
imcoefs2Show(~isfinite(imcoefs2Show)) = 0;

%% Q4 Compute the compression ratio assuming 8-bit fixed-length coding
% both images are 8-bit, so we can just compare number of DCT coefficients
ratio_entire = double(kept_entire) / (dims(1)*dims(2));

%% Q5 Reconstruct image, calculate MSE and SSIM similarity measures
image2 = uint8(idct2(imcoefs2));
mse_entire = immse(image2, image);
ssim_entire = ssim(image2, image);

figure;
suptitle({
    ['Similarirty to original: MSE='  num2str(mse_entire,5) ' SSIM=' num2str(ssim_entire,3)],
    ['Compression ratio: ' num2str(ratio_entire,5)]})
subplot(1,2,1); imshow(image2,[]); title('Compressed Image')
subplot(1,2,2); imagesc(imcoefs2Show); colormap(jet); title('Edited DCT Coefficients')

%% Q6 Apply the block-based 2D DCT, compress each block
block_size = [8 8];
kept_block = 0;
image3 = zeros(dims);

y = 0; 
while y <= dims(1)-block_size(1)
    x = 0;
    while x <= dims(2)-block_size(2)
        I = image(y+1 : y+block_size(1), x+1 : x+block_size(2));
        C = dct2(I);
        
        [C3, kept] = compressDCT(C,4);
        kept_block = kept_block + kept;
        I3 = idct2(C3);
        image3(y+1 : y+block_size(1), x+1 : x+block_size(2)) = I3;
    
        x = x + block_size(2);
    end
    y = y + block_size(1);
end

%% Q7 Copmute the compression ratio
ratio_block = double(kept_block) / (dims(1)*dims(2));

%% Q8 Reconstruct image, calculate MSE and SSIM similarity measures
image3 = uint8(image3);
mse_block = immse(image3, image);
ssim_block = ssim(image3, image);

figure;
suptitle({
    ['Similarirty to original: MSE='  num2str(mse_block,5) ' SSIM=' num2str(ssim_block,3)],
    ['Compression ratio: ' num2str(ratio_block,5)]})
subplot(1,2,1); imshow(image3,[]); title('Block-Compressed Image')
subplot(1,2,2); imagesc(log(abs(dct2(image3)))); colormap(jet); title('DCT Coefficients')

%% Q9 & Q10 Apply the block-based 2D DCT, compress each block
load qtables.mat;

block_size = [8 8];
kept_block_50 = 0; kept_block_90 = 0;

y = 0; 
while y <= dims(1)-block_size(1)
    x = 0;
    while x <= dims(2)-block_size(2)
        I = image(y+1 : y+block_size(1), x+1 : x+block_size(2));
        C = dct2(I);
        
        % quantize coefficients using Q50 matrix
        [C50, kept_50] = quantize(C,Q50);
        kept_block_50 = kept_block_50 + kept_50;
        I50 = idct2(C50);
        image50(y+1 : y+block_size(1), x+1 : x+block_size(2)) = I50;
        
        % quantize coefficients using Q90 matrix
        [C90, kept_90] = quantize(C,Q90);       
        kept_block_90 = kept_block_90 + kept_90;
        I90 = idct2(C90);
        image90(y+1 : y+block_size(1), x+1 : x+block_size(2)) = I90;
        
        x = x + block_size(2);
    end
    y = y + block_size(1);
end

%% Q11 Reconstruct images, copmute MSE, SSIM and compression ratio
image50 = uint8(image50);
mse_block_50 = immse(image50, image);
ssim_block_50 = ssim(image50, image);
ratio_block_50 = double(kept_block_50) / (dims(1)*dims(2));

image90 = uint8(image90);
mse_block_90 = immse(image90, image);
ssim_block_90 = ssim(image90, image);
ratio_block_90 = double(kept_block_90) / (dims(1)*dims(2));

figure;
subplot(1,2,1); imshow(image90,[]);
title({
    ['> Compressed with Q90 <'],
    ['MSE='  num2str(mse_block_90,10)],
    ['SSIM=' num2str(ssim_block_90,3)],
    ['compression ratio: ' num2str(ratio_block_90,5)]})
subplot(1,2,2); imshow(image50,[]);
title({
    ['> Compressed with Q50 <'],
    ['MSE='  num2str(mse_block_50,10)],
    ['SSIM=' num2str(ssim_block_50,3)],
    ['compression ratio: ' num2str(ratio_block_50,5)]})


%% HELPER FUNCTIONS

function [C2,kept] = compressDCT(C, threshold)
    C2 = C; kept = 0;
    dims = size(C);
    
    for y = 1 : dims(1)
        for x = 1 : dims(2)
            if y + x > threshold+1
                C2(y,x) = 0;
            else
                kept = kept + 1;
            end
        end
    end
end

function [FQ, kept] = quantize(F,Q)
    FQ = round(F./Q);
    kept = sum(sum(~(FQ == 0)));
end
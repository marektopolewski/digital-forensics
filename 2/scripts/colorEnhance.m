CC = imread('color_cast.png');
HR = imread('hist_ref.png');

CC_R = CC(:,:,1); EI_R = myHistMatch(CC_R, HR);
CC_G = CC(:,:,2); EI_G = myHistMatch(CC_G, HR);
CC_B = CC(:,:,3); EI_B = myHistMatch(CC_B, HR);
EI = cat(3, EI_R, EI_G, EI_B);

% Display the final result i.e. the enhanced RGB image
figure; imshow(EI,[]); title('Enhanced Image')

% Display 6 normalized hist - RGB channels before and after hist matching
dims = numel(CC_R);
figure; 
subplot(2,3,1); stem(imhist(CC_R)./dims,'Marker','none'); title('R before')
subplot(2,3,2); stem(imhist(CC_G)./dims,'Marker','none'); title('G before')
subplot(2,3,3); stem(imhist(CC_B)./dims,'Marker','none'); title('B before')
subplot(2,3,4); stem(imhist(EI_R)./dims,'Marker','none'); title('R after')
subplot(2,3,5); stem(imhist(EI_G)./dims,'Marker','none'); title('G after')
subplot(2,3,6); stem(imhist(EI_B)./dims,'Marker','none'); title('B after')


function [enhancedImage] = myHistMatch(inputImage, refImage)
    cdf_ii = myCdf(inputImage);
    cdf_ri = myCdf(refImage);

    % source: https://stackoverflow.com/a/26765167
    map_arr = uint8(zeros(size(cdf_ii)));
    for i=1:length(cdf_ii)
        [v,k] = min(abs(cdf_ii(i) - cdf_ri));
        map_arr(i) = k-1;
    end

    enhancedImage = map_arr(uint16(inputImage)+1); % cast to uin16 to allow ind_val=256
     
end

function [cdf] = myCdf(im)
    vals = norm(im);
    cdf = cumsum(vals);
end

function [out] = norm(im)
    hist = imhist(im);
    out = hist/sum(hist);
end
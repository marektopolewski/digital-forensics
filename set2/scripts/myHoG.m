%% Q1 import the image
J = imread('jeep.png');

%% Q2 convert the image to grayscale
J = double(rgb2gray(J));

%% Q3
g = [-1 0 1];
[Gx, Gy, Gmag, Gang] = grad(J, g, 2);

figure;
subplot(1,3,1); imshow(J,[]); title('Original image')
subplot(1,3,2); imshow(Gx,[]); title('Row gradient')
subplot(1,3,3); imshow(Gy,[]); title('Column gradient')
    
figure;
subplot(1,2,1); imshow(Gmag,[]); title('Gradient magnitude')
subplot(1,2,2); imshow(Gang,[]); title('Gradient direction')

%% Q4 Compute the Histogram of Oriented Gradients
g = [-1 0 1];
blockSize = 8;              % tested: 5, 8, 16, 32
bins = 18;                  % tested: 9, 18, 36 (50, 60)
angleRepresentation = 2;    % 1: unsigned 0 to 180, 2: unsigned 0 to 360, 3: signed -180 to 180

I = padToBlock(J,blockSize);
dims = size(I);

hogs = zeros(dims(2)*dims(1)/blockSize^2, bins);
coords = zeros([dims(2)*dims(1)/blockSize^2, 2]);
counter = 1;
for x=1:blockSize:dims(1)
    for y=1:blockSize:dims(2)
        B = I(x : x+blockSize-1, y : y+blockSize-1);
        hog = HOG(B, g, bins, angleRepresentation);
        hogs(counter,:) = hog;
        coords(counter,:,:) = [x y];
        counter = counter + 1;
    end
end

% Find pairwise differences between the HoG's
DM = distMatrix(hogs);

% Find the 5 most similar pairs of image-blocks
min_DM = absMinN(DM,5);
HJ = showMinDiff(J, min_DM, coords, blockSize);

figure;
subplot(2,3,1); imshow(HJ(:,:,1),[]); title(['MSE=' num2str(min_DM(1,1))], 'fontsize', 18)
subplot(2,3,2); imshow(HJ(:,:,2),[]); title(['MSE=' num2str(min_DM(1,2))], 'fontsize', 18)
subplot(2,3,3); imshow(HJ(:,:,3),[]); title(['MSE=' num2str(min_DM(1,3))], 'fontsize', 18)
subplot(2,3,4); imshow(HJ(:,:,4),[]); title(['MSE=' num2str(min_DM(1,4))], 'fontsize', 18)
subplot(2,3,5); imshow(HJ(:,:,5),[]); title(['MSE=' num2str(min_DM(1,5))], 'fontsize', 18)

%% HELPER FUNCTIONS
function I = padToBlock(I,b)
    dims = size(I);
    if mod(dims(1),b)~=0
        pad = b-mod(dims(1),b);
        I = padarray(I,[pad 0],'post');
    end
    if mod(dims(2),b)~=0
        pad = b-mod(dims(2),b);
        I = padarray(I,[0 pad],'post');
    end
end

function [Gx, Gy, Gmag, Gang] = grad(I,g,angMode)
% Compute 4 gradients for a given image 'I' and a derivative kernel 'g'
    dims = size(I);
    Gx = zeros(dims); Gy = zeros(dims);
    I = padarray(I,[2 2], 'replicate', 'post');

    for x=1:dims(1)
        for y=1:dims(2)
            fx = I(x, y:y+length(g)-1);
            fy = I(x:x+length(g)-1, y);

            Gx(x,y) = fx * g.';
            Gy(x,y) = g * fy;
        end
    end
    Gmag = (Gx.^2 + Gy.^2).^0.5;
    Gang = -rad2deg(atan2(Gy, Gx));
    if angMode == 1
        Gang = abs(Gang);           % 1: unsigned  0 to 180
    elseif angMode == 2
        Gang = wrapTo360(Gang);     % 2: unsigned  0 to 360
    elseif angMode == 3             % 3: signed -180 to 180
    end
end

function hog = HOG(I, g, binNum, angMode)
% Compute HoG with 'binNum' bins of image 'I' given a derivative kernel 'g'
    dims = size(I);
    [~, ~, Gmag, Gang] = grad(I, g, angMode);
%     [Gmag, Gang] = imgradient(I);
%     Gang = wrapTo360(Gang);
    hog = zeros([1 binNum]);

    for x=1:dims(1)
        for y=1:dims(2)
            if angMode == 3
                bin = (180 + Gang(x,y)) / (360/binNum);
            else
                bin = Gang(x,y) / (angMode*180/binNum);
            end
            
            if bin ~= binNum
                bin = floor(bin)+1;
            end
            
            hog(bin) = hog(bin) + Gmag(x,y);
        end
    end
end

function DM = distMatrix(M)
% Generate a martix of pairwise distances of a matrix 'M'. For pairs with
% itself, the algorithm assigns 'Nan'.
    N = length(M);
    DM = zeros(N);
    for i=1:N
        for j=1:N
            if  i >= j
                DM(i,j) = NaN;             % ignore pairs with itself
            else
                DM(i,j) = immse(M(i,:),M(j,:)); % calculate MSE otherwise
            end
        end
    end
end

function [h] = absMinN(M, n)
% COEF find 'n' highest values in matrix 'M' (consits of abs values obnly). 
% Values are stored in 1st row, and their corresponding positions in 
% 2nd (col index) and 3rd (row index) rows.
    h = zeros(3,n);
    for i=1:n
        [v_r,k_r] = min(M);                 % row max
        [v_c,k_c] = min(v_r);               % col max of row-max
        
        h(1,i) = v_c;                       % i-th global max
        h(2,i) = k_c; h(3,i) = k_r(k_c);    % i-th max location in matrix
        
        M(k_r,k_c) = NaN;                   % remove from furhter consideration
    end
end

function HJ = showMinDiff(J, M, C, b)
% Displays all N most similar blocks by creating an array of N images with
% highlighted regions that correspond to the selelcted blocks of size 'b'.
    J = padarray(J, [1 1]);
    HJ = zeros([size(J) length(M)]);
    for i=1:length(M)
        block1num = M(2,i); 
        block1x = C(block1num,1); block1y = C(block1num,2);
        block2num = M(3,i);
        block2x = C(block2num,1); block2y = C(block2num,2);
        J2 = J;
        J2(block1x:block1x+b+1, block1y) = 255;
        J2(block1x:block1x+b+1, block1y+b+1) = 255;
        J2(block1x, block1y:block1y+b+1) = 255;
        J2(block1x+b+1, block1y:block1y+b+1) = 255;
        J2(block2x:block2x+b+1, block2y) = 255;
        J2(block2x:block2x+b+1, block2y+b+1) = 255;
        J2(block2x, block2y:block2y+b+1) = 255;
        J2(block2x+b+1, block2y:block2y+b+1) = 255;
        HJ(:,:,i) = J2;
        
%         figure; 
%         subplot(1,2,1); imshow(J(block1x:block1x+b-1, block1y:block1y+b-1),[]);
%         subplot(1,2,2); imshow(J(block2x:block2x+b-1, block2y:block2y+b-1),[]);
    end
end
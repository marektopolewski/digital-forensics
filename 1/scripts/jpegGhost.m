% beach - 70
% plane - 
% boat  - 82-84-92


stepQ = 2;
minQ = 0; maxQ = 100;
% DI = jpeg_ghosts('splicedplane.jpg', 5, 46, 60, stepQ);
% DI = jpeg_ghosts('splicedbeach.jpg', 5, minQ, maxQ, stepQ);
% DI = jpeg_ghosts('splicedsoldier.jpg', 5, minQ, maxQ, stepQ);
DI = jpeg_ghosts('splicedboat.jpg', 5, 80, 100, stepQ);

% dims = size(DI);
% Q = minQ;
% 
% for i=1:dims(3)
%     subplot(2,4,i); imshow(DI(:,:,i), []); title(['Q=' num2str(Q)])
%     Q = Q + stepQ;
% end

function [diffImages] = jpeg_ghosts(file, b, minQ, maxQ, stepQ)
    I = imread(file);
    dims = size(I);
    
    diffImages = zeros(dims(1):dims(2):(maxQ-minQ)/stepQ);
%     SSDs = zeros(1,round((maxQ-minQ)/stepQ));
    counter = 0;
    
    for Q = minQ : stepQ : maxQ
        counter = counter + 1;
        D = zeros(dims(1:2));
        IQ = compress(I, Q);           
        
        for y = 1 : dims(1)
            for x = 1 : dims(2)
                d = double(0);
                for channel=1:3
                  d = d + diff(I, IQ, x, y, b);
                end
                D(y,x) = d/3;
            end
        end
        
        minD = min(min(D)); maxD = max(max(D));
        D = (D - minD) ./ (maxD - minD);
        
        diffImages(:,:,counter) = D;
        figure; imshow(D,[]); title(["Q=" num2str(Q)])
    end
end


function val = diff(I, I2, x, y, b)
    dims = size(I);
    
    if y+b-2 > dims(1) 
        y = y - (y+b-2 - dims(1));
    end
    
    if x+b-2 > dims(2)
        x = x - (x+b-2 - dims(2));
    end
    
    x_end = x + b - 2;
    y_end = y + b - 2;
        
    I_r = I(y:y_end, x:x_end);
    I2_r = I2(y:y_end, x:x_end);
    
    val = sum(sum( (I_r-I2_r) .^2)) / (numel(I_r));
end

function I2 = compress(I, Q)
    imwrite(I, 'temp_compress.jpg', 'Quality', Q);
    I2 = imread('temp_compress.jpg');
end

function val = ssd(C1,C2)
    V = (C1-C2).^2;
    val = mean(sum(sum(V)));
end
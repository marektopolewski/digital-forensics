I = imread('lena512gray.pgm');

I0 = watermark(I, 100, 0.1);    ssim0 = ssim(I0,I);
I1 = watermark(I, 500, 0.1);    ssim1 = ssim(I1,I);
I2 = watermark(I, 1000, 0.1);   ssim2 = ssim(I2,I);
I3 = watermark(I, 1500, 0.1);   ssim3 = ssim(I3,I);
I4 = watermark(I, 100, 0.5);    ssim4 = ssim(I4,I);
I5 = watermark(I, 500, 0.5);    ssim5 = ssim(I5,I);
I6 = watermark(I, 1000, 0.5);   ssim6 = ssim(I6,I);
I7 = watermark(I, 1500, 0.5);   ssim7 = ssim(I7,I);


figure;
subplot(2,4,1); imshow(I0,[]); title(['alpha=0.1, n=100; ssim = '  num2str(ssim0)])
subplot(2,4,2); imshow(I1,[]); title(['alpha=0.1, n=500; ssim = '  num2str(ssim1)])
subplot(2,4,3); imshow(I2,[]); title(['alpha=0.1, n=1000; ssim = ' num2str(ssim2)])
subplot(2,4,4); imshow(I3,[]); title(['alpha=0.1, n=1500; ssim = ' num2str(ssim3)])
subplot(2,4,5); imshow(I4,[]); title(['alpha=0.5, n=100; ssim = '  num2str(ssim4)])
subplot(2,4,6); imshow(I5,[]); title(['alpha=0.5, n=500; ssim = '  num2str(ssim5)])
subplot(2,4,7); imshow(I6,[]); title(['alpha=0.5, n=1000; ssim = ' num2str(ssim6)])
subplot(2,4,8); imshow(I7,[]); title(['alpha=0.5, n=1500; ssim = ' num2str(ssim7)])


function [I2] = watermark(I, n, alpha)
    
    F = dct2(I);
    w = randn(1,n);
    w = (w-mean(w))/std(w);
    
    h = coef(F,n);
    
    wm = 1 + (w(1:length(h)) .* alpha);
    wm = h(1,:) .* wm;
    F2 = F;
    
    for i=1:length(wm)
        c = h(2,i); r = h(3,i);
        F2(r,c) = wm(i);
    end 
    
    I2 = uint8(idct2(F2));
end

function [h] = coef2(m, n)
% COEF find 'n' highest absolute coefficients in matrix 'm'.
% (not including the DC coefficient)
    m = abs(m);
    h = zeros(3,n+1);
    for i=1:n+1
        [v_r,k_r] = max(m);                 % row max
        [v_c,k_c] = max(v_r);               % col max of row-max
        
        h(1,i) = v_c;                       % i-th global max
        h(2,i) = k_c; h(3,i) = k_r(k_c);    % i-th max location in matrix
        
        m(k_r,k_c) = -1;                    % remove from furhter consideration
    end
    h = h(:,2:end);                         % do not include DC coefficient
end

function [h] = coef(m, n)
% COEF find 'n' highest absolute coefficients in matrix 'm'.
% (not including the DC coefficient)
    m_abs = abs(m);
    h = zeros(3,n+1);
    for i=1:n+1
        [v_r,k_r] = max(m_abs);             % row max
        [v_c,k_c] = max(v_r);               % col max of row-max
        
        h(2,i) = k_c; h(3,i) = k_r(k_c);    % i-th max location in matrix
        h(1,i) = m(k_r(k_c),k_c);           % i-th global max
        
        m_abs(k_r,k_c) = -1;                % remove from furhter consideration
    end
    h = h(:,2:end);                         % do not include DC coefficient
end
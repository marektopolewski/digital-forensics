I = imread('halftone_evidence.pgm');

PQ = paddedsize(size(I));
F = fft2(I,PQ(1),PQ(2));

D0 = 60; n = 2;
H1 = notch('btw', PQ(1), PQ(2), D0, 256, 256, n);
H2 = notch('btw', PQ(1), PQ(2), D0, 512, 256, n);
H3 = notch('btw', PQ(1), PQ(2), D0, 768, 256, n);
H4 = notch('btw', PQ(1), PQ(2), D0, 256, 512, n);
H5 = notch('btw', PQ(1), PQ(2), D0, 512, 512, n);
H6 = notch('btw', PQ(1), PQ(2), D0, 768, 512, n);
H7 = notch('btw', PQ(1), PQ(2), D0, 256, 768, n);
H8 = notch('btw', PQ(1), PQ(2), D0, 512, 768, n);
H9 = notch('btw', PQ(1), PQ(2), D0, 768, 768, n);

EH1 = notch('btw', PQ(1), PQ(2), D0, 0, 256, n);
EH2 = notch('btw', PQ(1), PQ(2), D0, 0, 512, n);
EH3 = notch('btw', PQ(1), PQ(2), D0, 0, 768, n);
EH4 = notch('btw', PQ(1), PQ(2), D0, 256, 0, n);
EH5 = notch('btw', PQ(1), PQ(2), D0, 512, 0, n);
EH6 = notch('btw', PQ(1), PQ(2), D0, 768, 0, n);

H_a = H1.*H2.*H3.*H4.*H5.*H6.*H7.*H8.*H9;
H_a = H_a.*EH1.*EH2.*EH3.*EH4.*EH5.*EH6;

g_a = toPixDomain(F.*H_a, size(I));


H_b = H_a; x =10; y = 15;
H_b(1:1+x,       206:818) = 0;
H_b(256-x:256+x, 1:1024)  = 0;
H_b(512-x:514+x, 1:1024 ) = 0;
H_b(768-x:768+x, 1:1024)  = 0;
H_b(1024-x:1024, 206:818) = 0;

H_b(206:818, 1:1+y)       = 0;
H_b(1:1024,  256-y:256+y) = 0;
H_b(1:1024,  512-y:512+y) = 0;
H_b(1:1024,  768-y:768+y) = 0;
H_b(206:818, 1024-y:1024) = 0;

g_b = toPixDomain(F.*H_b, size(I));


figure; 
subplot(2,3,1); imshow(toFreqDomain(I)  ,[],'InitialMagnification','fit'); title('Freq domain (shifted)')
subplot(2,3,2); imshow(toFreqDomain(g_a),[],'InitialMagnification','fit'); title('Freq domain (shifted)')
subplot(2,3,3); imshow(toFreqDomain(g_b),[],'InitialMagnification','fit'); title('Freq domain (shifted)')
subplot(2,3,4); imshow(I,[],'InitialMagnification','fit'); title('Original image')
subplot(2,3,5); imshow(g_a,[],'InitialM                 agnification','fit'); title('Basic noise removal')
subplot(2,3,6); imshow(g_b,[],'InitialMagnification','fit'); title('Advanced noise removal')


figure;
subplot(1,3,1); imshow(  I(200:350,100:300),[],'InitialMagnification','fit'); title('Original image')
subplot(1,3,2); imshow(g_a(200:350,100:300),[],'InitialMagnification','fit'); title('Basic noise removal')
subplot(1,3,3); imshow(g_b(200:350,100:300),[],'InitialMagnification','fit'); title('Advanced noise removal')

% figure; imshow(toFreqDomain(g_b)>10.8);

function [freq] = toFreqDomain(im)
    ps = paddedsize(size(im));
    freq = fft2(im,ps(1),ps(2));
    freq = fftshift(freq);
    freq = log(1+abs(freq));
end

function [pix] = toPixDomain(freq, dims)
    pix = real(ifft2(freq));
    pix = pix(1:dims(1),1 : dims(2));
end
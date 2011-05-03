function PSNR = peakSignalToNoiseRatio(b1, b2)
MSE = mean2((b1 - b2).^2 );
PSNR = 10*log10((255^2) / double(MSE));
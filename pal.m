clc
clear all
close all

RGB = imread('d:/clean/cats.png');
% RGB = imread('d:/clean/female.png');

figure;
image(RGB);
truesize;
title('RGB');

visual = 52e-6;
t = linspace(0, visual, 768);   % horizontal resolution
f = 4.43361875e6;               % color carrier
rgb = double(RGB);

Y = zeros(576, 768);
U = zeros(576, 768);
V = zeros(576, 768);
E = zeros(576, 768);
for y = 1:576
    Y(y, :) = 0.299*rgb(y, :, 1) + 0.587*rgb(y, :, 2) + 0.114*rgb(y, :, 3);
    U(y, :) = 0.493*(rgb(y, :, 3) - Y(y, :));
    V(y, :) = 0.877*(rgb(y, :, 1) - Y(y, :));
    if mod(y, 2)==0 % even lines (0, 2, 4, 6, 8...)
        if mod(y, 4)==2
            E(y, :) = Y(y, :) + U(y, :).*sin(2*pi*f*t) + V(y, :).*cos(2*pi*f*t);
        else
            E(y, :) = Y(y, :) + U(y, :).*sin(2*pi*f*t) - V(y, :).*cos(2*pi*f*t);
        end
    else % odd lines (1, 3, 5, 7...)
        if mod(y+1, 4)==0
            E(y, :) = Y(y, :) + U(y, :).*sin(2*pi*f*t) - V(y, :).*cos(2*pi*f*t);
        else
            E(y, :) = Y(y, :) + U(y, :).*sin(2*pi*f*t) + V(y, :).*cos(2*pi*f*t);
        end
    end
end

g = sin(2*pi*f*t);
h = cos(2*pi*f*t);
Y = E;
N = 1;
M = 1;
N = 16;
M = 24;
c = 232;
U = zeros(1, 768);
V = zeros(1, 768);
for y = 1:576
    if mod(y, 2)==0
        if mod(y, 4)==2
            sig = 1;
        else
            sig = -1;
        end
    else
        if mod(y+1, 4)==0
            sig = -1;
        else
            sig = 1;
        end
    end
    for x = N+1:768-(N+1)
        u = mean(g(x-N:x+N).*E(y, x-N:x+N));
        v = mean(sig*h(x-N:x+N).*E(y, x-N:x+N));
        U(y, 1+x) = 2*u;
        V(y, 1+x) = 2*v;
    end
    % agressive notch
    YY = fft(Y(y, :)); YY(c-M:c+M) = 0; Y(y, :) = ifft(YY, 'symmetric');
    UU = fft(U(y, :)); UU(c-M:c+M) = 0; U(y, :) = ifft(UU, 'symmetric');
    VV = fft(V(y, :)); VV(c-M:c+M) = 0; V(y, :) = ifft(VV, 'symmetric');
    y
end

B = Y + U/0.493;
R = Y + V/0.877;
G = (Y - 0.299*R - 0.114*B)/0.587;

RGBN = zeros(576, 768, 3);
RGBN(:, :, 1) = R;
RGBN(:, :, 2) = G;
RGBN(:, :, 3) = B;

figure;
image(uint8(RGBN));
title('Color PAL signal on a color TV with color carrier notch');
truesize;
% imwrite(uint8(RGBN), 'composite3.png');
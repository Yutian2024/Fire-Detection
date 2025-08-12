clc, clear, close all;

V = VideoReader('C:\Users\86189\Desktop\P2s\fire1.mp4');
n = V.NumberOfFrames;

rgb = read(V, 1);
figure(), imshow(rgb);
[R,G,B] = imsplit(rgb);
figure();
subplot(1,3,1), imshow(R), title('Red Channel');
subplot(1,3,2), imshow(G), title('Green Channel');
subplot(1,3,3), imshow(B), title('Blue Channel');

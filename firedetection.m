clc, clear, close all;

vidObj = VideoReader('C:\Users\86189\Desktop\P2s\fire1.mp4');
numberOfFrames = vidObj.NumberOfFrames;
vidHeight = vidObj.Height;
vidWidth = vidObj.Width;
writerObj = VideoWriter('C:\Users\86189\Desktop\fire1');
open(writerObj);
figure();

for i = 1:NumberOfFrames
    original = read(vidObj, i);
    original_hsv = rgb2hsv(original);

    filter_hsv = (original_hsv(:,:,1))>0.16;
    filter_hsv = filter_hsv.*(original_hsv(:,:,2))>0.5;
    filter_hsv = filter_hsv.*(original_hsv(:,:,2))<0.6;
    filter_hsv = filter_hsv.*(original_hsv(:,:,3))>0.97;

    filter_hsv3(:,:,1) = filter_hsv;
    filter_hsv3(:,:,2) = filter_hsv;
    filter_hsv3(:,:,3) = filter_hsv;

    hsv = double(original).*filter_hsv3;

    hsv = uint8(hsv);

    ratio = 245/180;
    bias = 0.2;

    hsv_gray = rgb2gray(hsv);
    hsv_dilate = im2bw(hsv_gray);

    [B,L] = bwboundaries(hsv_dilate,'noholes');
    max_ = size(B,1);
    filter_hsv_ = filter_hsv;
    Ck_Threshod = 2;
    if max_ ~= 0
            % Handle every single situation independently.
            for iii=1:max_
                boundary = B{iii};
                tempRatio = range(boundary(:,1))/range(boundary(:,2));
                if tempRatio < ratio*(1-bias) || tempRatio > ratio*(1+bias)
                    selected = (L == iii);
                    selected = ~selected;
                    filter_hsv=filter_hsv.*selected;
                else
                    plot(boundary(:,2), boundary(:,1),'g','LineWidth',2);
                end
            end

    end

    hsv_dilate = hsv_dilate.*filter_hsv;
    hsv_dilate = im2bw(hsv_dilate);
    
    [B,L] = bwboundaries(hsv_dilate,'noholes');
    max_ = size(B,1);
    imshow(original);
    hold on;
    if max_ ~= 0
        for iii=1:max_
            boundary = B{iii};
            stats = regionprops('table',B{iii},'Area','Perimeter');
            Ck = 4*pi*sum(stats.Area)/(sum(stats.Perimeter)).^2;
            if Ck > Ck_Threshod
                selected = (L == iii);
                selected = ~selected;
                filter_hsv=filter_hsv.*selected;
            else
                plot(boundary(:,2), boundary(:,1),'g','LineWidth',2);
            end
        end

    end
    writeVideo(writerObj,getframe);
end
close(writerObj);
% Demo to extract frames and get frame means from a movie and save individual frames to separate image files.
% Then rebuilds a new movie by recalling the saved images from disk.
% Also computes the mean gray value of the color channels
% And detects the difference between a frame and the previous frame.

clc;
close all;
imtool close all;
clear;
workspace;
fontSize = 22;

	videoObject = VideoReader('C:\Users\86189\Desktop\P2s\gasstove_infrared.avi');
	numberOfFrames = videoObject.NumberOfFrames;
	vidHeight = videoObject.Height;
	vidWidth = videoObject.Width;
%     writerObj = VideoWriter('C:\Users\86189\Desktop\fire_');
%     open(writerObj);
	
	hFig = figure('Name', 'Video Demo by Image Analyst', 'NumberTitle', 'Off');
	hFig.WindowState = 'maximized'; % Way of maximizing.
	
	meanGrayLevels = zeros(numberOfFrames, 1);
	meanRedLevels = zeros(numberOfFrames, 1);
	meanGreenLevels = zeros(numberOfFrames, 1);
	meanBlueLevels = zeros(numberOfFrames, 1);
	for frame = 1 : 50
		thisFrame = read(videoObject, frame);
		
		% Display
		hImage = subplot(2, 2, 1);
		image(thisFrame);
		caption = sprintf('Frame %4d of %d.', frame, numberOfFrames);
		title(caption, 'FontSize', fontSize);
		axis('on', 'image');
		drawnow; % Force it to refresh the window.
		
		% Calculate the mean gray level.
		grayImage = rgb2gray(thisFrame);
		meanGrayLevels(frame) = mean(grayImage(:));
		
		% Calculate the mean R, G, and B levels.
		meanRedLevels(frame) = mean(mean(thisFrame(:, :, 1)));
		meanGreenLevels(frame) = mean(mean(thisFrame(:, :, 2)));
		meanBlueLevels(frame) = mean(mean(thisFrame(:, :, 3)));
		
		% Plot the mean gray levels.
		hPlot = subplot(2, 2, 2);
		hold off;
		plot(meanGrayLevels, 'k-', 'LineWidth', 3);
		hold on;
		plot(meanRedLevels, 'r-', 'LineWidth', 2);
		plot(meanGreenLevels, 'g-', 'LineWidth', 2);
		plot(meanBlueLevels, 'b-', 'LineWidth', 2);
		grid on;
		title('Mean Intensities In Gray Levels', 'FontSize', fontSize);
		
		if frame == 1
			xlabel('Frame Number');
			ylabel('Gray Level');
			% Get size data later for preallocation if we read the movie back in from disk.
			[rows, columns, numberOfColorChannels] = size(thisFrame);
        end
		
		% Do the differencing.
		alpha = 0.5;
		if frame == 1
			Background = thisFrame;
        else
			Background = (1-alpha)*thisFrame + alpha*Background;
		end
		% Display the changing/adapting background.
		subplot(2, 2, 3);
		imshow(Background);
		title('Adaptive Background', 'FontSize', fontSize);
		axis('on', 'image');
		% Calculate a difference between this frame and the background.
		differenceImage = thisFrame - uint8(Background);
		% Threshold with Otsu method.
		grayImage = rgb2gray(differenceImage); % Convert to gray level.
		thresholdLevel = graythresh(grayImage); % Get threshold.
		binaryImage = im2bw(grayImage, thresholdLevel); % Do the binarization.
		% Plot the binary image.
		subplot(2, 2, 4);
		imshow(binaryImage);hold on
		title('Binarized Difference Image', 'FontSize', fontSize);
		axis('on', 'image'); % Show tick marks and get aspect ratio correct.
        
        % Calculate the connected domains and add boxes.
        for i = 800:1300
            for j = 700:2000
                binImage(i, j) = binaryImage(i, j);
            end
        end
        L = bwlabel(binImage);
        STATS = regionprops(L, 'all');
        for i = 1 : size(STATS, 1)
            boundary = STATS(i).BoundingBox;
            rectangle('Position',boundary,'edgecolor','r' );
        end
        
        % writeVideo(writerObj, uint8(binaryImage));
        
	end
	xlabel(hPlot, 'Frame Number', 'FontSize', fontSize);
	ylabel(hPlot, 'Gray Level', 'FontSize', fontSize);
	legend(hPlot, 'Overall Brightness', 'Red Channel', 'Green Channel', 'Blue Channel', 'Location', 'Northwest');
	
	msgbox('Done with this demo!');
	fprintf('Done with this demo!\n');
	
% close(writerObj);
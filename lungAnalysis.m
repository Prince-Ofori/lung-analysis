function [ ] = lungAnalysis(X)
%lungAnalysis A function that segments and identifies tumorous regions
%within the lungs and counts the number of tumours present within the
%image(Displayed within the command line)

input = imread(X);
im = rgb2gray(input);
%TASK 1: Noise Reduction
%Pad image matrix with zeros
padIm = zeros(size(im)+2);
im2 = zeros(size(im));

%Pass matrix values into padded array
for x = 1 : size(im, 1)
    for y=1 : size(im, 2)
        padIm(x+1,y+1)=im(x,y);
    end
end
%3x3 Median Filter: Iterates through the image with padding using a three by
%three window and stores,sorts and finds the median value of the pixel
%intensities within the viewing window
for i = 1:size(padIm,1) - 2
    for j = 1:size(padIm,2)-2
        window = zeros(9,1);
        ind = 1; 
        for x = 1:3
            for y = 1:3 
                window(ind) = padIm(i+x-1,j+y-1);
                ind = ind + 1; 
            end
        end
        %Sort median values and store in im2 image matrix
        med = sort(window);
        im2(i,j)= med(5);
    end
end
%Convert im2 matrix to uint8 image
im2 = uint8(im2);
imshow(im2), title 'Task 1: Median Filtered Image';

%TASK 2: Image Segmentation
%Store a global grey threshold to be applied to binary conversion
level = graythresh(im2);
bw = im2bw(im2,level);
bwStore = bw; %Variable stored for circle detection(TASK 3)  

%Disk Structured element that removes residual noise and solidifies 
%binary values using the morphological open function
se = strel('disk', 9);
bw2 = imopen(bw,se);
bwOpen = bw2; %Variable stored for circle detection(TASK 3)  

%Iterate through the image removing black from the background through a
%boolean equivilance of a high intensity binary 1 pixel
whiteDetect = 1;
for j = 1:size(bw2,1)
    for i = 1:size(bw2,2)
        if whiteDetect == false
            if bw2(i,j) == 0
                bw2(i,j) = 0.5;
            else
                whiteDetect = true;
            end
        end
    end
    whiteDetect = false; 
end
for j = size(bw2,1): -1:1
    for i = size(bw2,2): -1:1
        if whiteDetect == false
            if bw2(i,j) == 0
                bw2(i,j) = 0.5;
            else
                whiteDetect = true;
            end
        end
    end
    whiteDetect = false; 
end
%Second pass median filter on bw image to remove stray 0 pixel
for i = 1:size(bw2,1) - 2
    for j = 1:size(bw2,2)-2
        window = zeros(3,1);
        ind = 1; 
        for x = 1:3
            for y = 1:3 
                window(ind) = bw2(i+x-1,j+y-1);
                ind = ind + 1; 
            end
        end
        %Sort median values and store in bw2 image matrix
        med = sort(window);
        bw2(i,j)= med(5);
    end
end
bw2 = imcomplement(bw2);%invert binary 1s and 0s creating a black background
figure, imshow(bw2), title 'Task 2: Segmented Image';

%TASK 3 & 4: Tumour Detection and Count 
detect = bwStore - bwOpen;%Detected circle boundary image
se = strel('disk', 1);
detect = imopen(detect,se);

%Using the imtool function coordinates were found that define the point of
%interest (lungs)[2.00000000000006 135 510.5 215]. The for loop below 
%removes the white pixels within the upper band of the image by making all 
%pixel values to zero
[m,n] = size(detect);
for i = 1:165
    for j = 1:n
        detect(i,j) = 0;           
    end
end
%Remove small imfindcircles pixel range warning
warning('off', 'all'); 

%Search for bright(1) circles within the image between 1 - 11 pixel radius
%range and count the number of M(circle centers) within the image to count
%the total number of tumours
[centers, radii] = imfindcircles(detect,[1 11],'ObjectPolarity','bright','Sensitivity', 0.95);
[M,N] = size(centers);
figure, imshow(im2), title 'Task 3 & 4: Tumour Regions';
viscircles(centers, radii,'EdgeColor','g');
output = ['The number of tumours is: ', num2str(M)];
disp(output);
end
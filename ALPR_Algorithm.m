CarPlate_Image = imread('image05.jpg');                 % Import car plate image
CarPlate_Image_GS =rgb2gray(CarPlate_Image);    % Convert the image to gray scale image
[rows,columns]=size(CarPlate_Image_GS);               % Get the size
CarPlate_Image_GS_B= ones(rows,columns);           % Create an image with the same size
%% The following for loop scales the gray scale image to a binary inversed image
for n=1:rows
    for m =1:columns
        if(CarPlate_Image_GS(n,m)>127)
            CarPlate_Image_GS_B(n,m)=0;
        end
    end
end
CarPlate_Image_GS_B_Filtered=medfilt2(CarPlate_Image_GS_B ,[1 1]);  % Apply median filter
Objects=bwconncomp(CarPlate_Image_GS_B_Filtered);                          % Apply connected component analysis
numPixels = cellfun(@numel,Objects.PixelIdxList);                                    % Get the size of each object
CarPlate_Image_GS_B_Filtered_OLD=CarPlate_Image_GS_B_Filtered;
No_Objects=size(numPixels);     % Get number of detected objects
%% The following for loop removes any unnecessary objects from the image
for c=1:No_Objects(2);
    if (numPixels(c)<1.05*columns) % This relation is empirical and based on my trials
        CarPlate_Image_GS_B_Filtered(Objects.PixelIdxList{c}) = 0;
    end
end
CarPlate_Image_GS_B_Filtered=medfilt2(CarPlate_Image_GS_B_Filtered,[7 7]); % Apply median filter
Objects=bwconncomp(CarPlate_Image_GS_B_Filtered);   % Apply connected component analysis
BoundingBox = regionprops(Objects,'BoundingBox'); % Get bounding boxes locations ans sizes
% figure, imshow(CarPlate_Image_GS_B_Filtered);
% hold on
% %% The following for loop draws the bounding boxes on each character
% for n=1:Objects.Connectivity
%      rectangle('Position',BoundingBox(n).BoundingBox,'EdgeColor','r','LineWidth',2 );
% end
% hold off
Result=ocr(CarPlate_Image_GS_B_Filtered); % Apply OCR on the image after processing
Plate_Number=Result.Text; % Get the plate number
%% The following part of the program shows the result obtained in one figure
subplot(2,3,1), imshow(CarPlate_Image)
title('Original Photo');
subplot(2,3,2), imshow(CarPlate_Image_GS)
title('Grayscale Photo');
subplot(2,3,3), imshow(CarPlate_Image_GS_B)
title('Binary Inversed Image');
subplot(2,3,4), imshow(CarPlate_Image_GS_B_Filtered_OLD)
title('After applying the median filter');
subplot(2,3,5), imshow(CarPlate_Image_GS_B_Filtered)
title('After removing unnecessary objects');
subplot(2,3,6), imshow(CarPlate_Image_GS_B_Filtered)
for n=1:Objects.NumObjects
     rectangle('Position',BoundingBox(n).BoundingBox,'EdgeColor','green','LineWidth',1 );
end
title(strcat('Final Image - Plate number is:',{' '},Plate_Number));

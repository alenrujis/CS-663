%% Adaptive Histogram Equalization
   %Input Parameters: Input Image
   %                  Window Size, N
   %Output Parameters: Output Image
%%
function [] = myAHE()

[inputImage, map] =imread('../data/canyon.png');
[row, col, d] = size(inputImage);

window_x = 240;
window_y = 150;

hand = @(x) calcAHEVal(x)

if d==1
   outputImage = nlfilter(inputImage,[window_x window_y],hand);
else
   for k=1:d
      outputImage(:,:,k) = nlfilter(inputImage(:,:,k),[window_x window_y],hand); 
   end
% for i=1:row
%     for j=1:col
%         for k=1:d
%             % // min_x = max(1,i-window_x);
%             % // min_y = max(1,j-window_y);
%             % // max_x = min(row,i+window_x);
%             % // max_y = min(col,j+window_y);
%             % // window_matrix = inputImage(min_x:max_x,min_y:max_y,k);

%             if inputImage(i,j,k) == 0
%                 outputImage(i,j,k) =0;
%             else
%             [histogramEquMatrix, transformationFunction ] = myHE(window_matrix);
%             % disp(transformationFunction);
%             outputImage(i,j,k) = transformationFunction(inputImage(i,j,k));
%             end
%         end
%     end
end

imshow(outputImage);
disp(outputImage(1,1,1));
disp(outputImage(1,2,1));
disp(outputImage(1,3,1));

end

function AHEVal = calcAHEVal(inpMat)
   H=imhist(inpMat);
   [N, M] = size(inpMat);
   H=H/(N*M);
   C = double(zeros(1,255));
   C(1) = H(1)*255;

   for (k=2:256)
       C(k)= C(k-1) + (H(k)*255);
   end
   AHEVal = uint8(C(inpMat(floor((1+N)/2)+1,floor((1+M)/2))+1));
end
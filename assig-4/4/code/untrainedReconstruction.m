function [] = untrainedReconstruction()
% Untrained Face Recognition

directoryPath = uigetdir(); 

tic

noOfTrainingFolder = 35;
noOfTestFolder = 5;
noOfTrainingImages = 5;
noOfTestImages = 10;
width = 112;
breadth = 92;
k=150;
trainedfaces = 1:noOfTrainingFolder;
identities1 = kron(trainedfaces, ones([1 noOfTrainingImages]));

untrainedfaces = noOfTrainingFolder+1:noOfTrainingFolder+noOfTestFolder;
identities2 = kron(untrainedfaces, ones([1 noOfTestImages]));

identities = [identities1 identities2];

X = double(zeros([width*breadth noOfTrainingFolder*noOfTrainingImages]));

for i = 1:noOfTrainingFolder
    for j = 1:noOfTrainingImages
        imgPath = strcat([directoryPath '/s' num2str(i) '/' num2str(j) '.pgm']);
        image = imread(imgPath);
        X(:,noOfTrainingImages*i-noOfTrainingImages+j) = double(image(:));
    end
end

mean = transpose(sum(transpose(X)))/(noOfTrainingFolder*noOfTrainingImages);
X = X - kron(mean, ones([1 noOfTrainingFolder*noOfTrainingImages]));

[W,D] = eig(X'*X);

V = X*W;
norms = sqrt(sum(V.^2));
V = V ./ kron(norms, ones([width*breadth 1]));

D = flipud(D);
Vs = fliplr(V);

Vr = Vs(:, 1:k);
coeffs = transpose(Vr)*X;

XTest1 = double(zeros([width*breadth noOfTrainingFolder*noOfTrainingImages]));

for i = 1:noOfTrainingFolder
    for j = 1:noOfTrainingImages
        imgPath = strcat([directoryPath '/s' num2str(i) '/' num2str(j+5) '.pgm']);
        image = imread(imgPath);
        XTest1(:,noOfTrainingImages*i-noOfTrainingImages+j) = double(image(:))-mean;
    end
end

testCoeffs1 = transpose(transpose(Vr)*XTest1);
% predIdentities1 = transpose(dsearchn(transpose(coeffs), testCoeffs1));
predIdentities1 = transpose((floor((dsearchn(transpose(coeffs), testCoeffs1)-1)/noOfTrainingImages))+1);

% Now get the testing images from the second testing dataset
XTest2 = double(zeros([width*breadth noOfTestFolder*noOfTestImages]));

for i = 1:noOfTestFolder
    for j = 1:noOfTestImages
        imgPath = strcat([directoryPath '/s' num2str(i+35) '/' num2str(j) '.pgm']);
        image = imread(imgPath);
        XTest2(:,noOfTestImages*i-noOfTestImages+j) = double(image(:))-mean;
    end
end

testCoeffs2 = transpose(transpose(Vr)*XTest2);
% predIdentities2 = transpose(dsearchn(transpose(coeffs), testCoeffs2));
predIdentities2 = transpose((floor((dsearchn(transpose(coeffs), testCoeffs2)-1)/noOfTrainingImages))+1);

distances1 = sqrt(sum((transpose(testCoeffs1) - coeffs(:,predIdentities1(:))).^2));

distances2 = sqrt(sum((transpose(testCoeffs2) - coeffs(:,predIdentities2(:))).^2))

thresh = 5200;

falseNegative = 0;
for i = 1:noOfTrainingFolder*noOfTrainingImages
    if(distances1(i)>thresh)
        falseNegative = falseNegative+1;
    end
end

falsePositive = 0;
for i = 1:noOfTestFolder*noOfTestImages
    if(distances2(i)<thresh)
        falsePositive = falsePositive+1;
    end
end

disp('False negatives and positives respectively for k=');
disp(k);
disp('Threshold=');
disp(thresh);
disp([falseNegative falsePositive]);
disp([sum(distances1)/length(distances1) sum(distances2)/length(distances2)]);

toc
end
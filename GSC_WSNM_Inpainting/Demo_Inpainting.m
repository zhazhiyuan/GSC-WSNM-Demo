clc;
clear;
close all;

filename = 'Mickey';

Orgname = [filename '.tif'];

X_RGB = imread(Orgname); 

X_YUV = rgb2ycbcr(X_RGB);

X = double(X_YUV(:,:,1));

X_org = X;

% Initial Input
X_Inpaint_Re = zeros(size(X_YUV));        
X_Inpaint_Re(:,:,2) = X_YUV(:,:,2);     
X_Inpaint_Re(:,:,3) = X_YUV(:,:,3); 

ratio = 0.2; % 80% pixels missing
p= 0.45; % 0.45,0.45,1,1, 0.95 for 80% 70% 60%,50% text inlayed.

MaskType =1;

switch MaskType
    case 1  %random mask;
      rand('seed',0);
      O = double(rand(size(X)) > (1-ratio));
    case 2  %text mask
      O = imread('TextMask256.png');
      O = double(O>128);
end

Y= X.* O;  % Observed Image

% Parameter Setting
par = [];
        
if ~isfield(par,'mu')
    par.mu = 0.0003; 
end
% 0.0003, 0.0003, 0.03, 0.04, 0.95 for 80%, 70%, 60%, 50%, text inlayed, respectively. 

if ~isfield(par,'org')
   par.org = X_org;
end  
        
if ~isfield(par,'IterNums')
   par.IterNums = 800;
end 
        
if ~isfield(par,'Initial')
  par.Initial = Inter_Initial(Y,~O); % Initial
end
        
if ~isfield(par,'patch')
   par.patch = 8; % 8 for random mask, 10 for text mask
end
        
if ~isfield(par,'step')
   par.step = 4;
end       
        
if ~isfield(par,'Similar_patch')
   par.Similar_patch = 60; % Similar patch Numbers
end
         
if ~isfield(par,'Region')
   par.Region = 25;
end        
        
if ~isfield(par,'sigma')
   par.sigma = sqrt(2);
end 
if ~isfield(par,'e')
    par.e = 0.3;
end         
        
[reconstructed_image, PSNR,FSIM] = Inpainting_GSC_WSNM(Y,O,par,p);

X_Inpaint_Re(:,:,1) = uint8(reconstructed_image);

X_Inpainting_Re = ycbcr2rgb(uint8(X_Inpaint_Re));
        
Final_Name= strcat(filename,'_',num2str((1-ratio)*100),'%','_miss_','_PSNR_',num2str(PSNR),'_FSIM_',num2str(FSIM),'.png');

imwrite(uint8(X_Inpainting_Re),strcat('./Inpainting_Results/',Final_Name));
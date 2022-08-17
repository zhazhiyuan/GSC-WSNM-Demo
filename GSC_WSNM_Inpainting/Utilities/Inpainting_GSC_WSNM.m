
function [reconstructed_image, PSN_Result,FSIM_Result] = Inpainting_GSC_WSNM(Y,A,par,p)

Initial = par.Initial;

mu = par.mu;

IterNums = par.IterNums;

X_Org = par.org;

MASK = A;

A = @(x) MASK.*x;

AT = @(x) MASK.*x;

ATy = AT(Y);

X = Initial;
C = zeros(size(Y));
L = zeros(size(Y));
Muinv = 1/mu;
InvAAT = 1./(mu+MASK);

All_PSNR= zeros(1,IterNums);

fprintf('Initial PSNR = %f\n',csnr(X,X_Org,0,1));

for j = 1:IterNums
    
    L = GSR_WSNM_GST(X-C, par,p);
    
    R = ATy +mu*(L+C);
    
    X = Muinv*(R - AT(InvAAT.*A(R)));
    
    C = C + (L - X);
    
    All_PSNR(j) = csnr(X,X_Org,0,1);
    
    fprintf('iter number = %d, PSNR = %f, FSIM = %f\n',j,csnr(X,X_Org,0,1),FeatureSIM(X_Org,X));

    if j>1
        if(All_PSNR(j)-All_PSNR(j-1)<0)
            break;
        end
    end

end

reconstructed_image = X;

PSN_Result  = csnr(reconstructed_image,X_Org,0,1);
FSIM_Result = FeatureSIM(reconstructed_image,X_Org);



end


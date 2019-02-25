% To add into Zernikmoment toolbox from MATLAB file exchange

function [Z, A, phi] = Zernike_Moments( img, single_idx_list )

if size(img,1)~=size(img,2)
    error('Zernike moments: Input image must be square matrix');
end
if any(~ismember(single_idx_list,0:14)) || any(rem(single_idx_list,1)~=0)
    error('Zernike moments: Input indices must be [0 14] integers only');
end

% use OSA/ANSI standard indices (j= [n(n+2)+m] / 2)
std_idx = [0 0;
           1 -1;
           1 1;
           2 -2;
           2 0;
           2 2;
           3 -3;
           3 -1;
           3 1;
           3 3;
           4 -4;
           4 -2;
           4 0;
           4 2;
           4 4 ];
       
       
Z = zeros(1,length(single_idx_list));
A = zeros(size(Z));
phi = zeros(size(Z));
for ii=1:length(single_idx_list)
    [Z(ii),A(ii),phi(ii)] = Zernikmoment( img, std_idx(ii,1), std_idx(ii,2) );
end


end
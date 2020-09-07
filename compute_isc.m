function [ISC,W] = compute_isc(Rpool,Rxy,Ncomp,W)

% Computes the ISC. Uses shrinkage to compute W. If input W, will not
% compute W.


gamma = 0.5;

if gamma >= 0
    % shrinkage
    if nargin == 3
        Rpool_shrink = (1-gamma)*Rpool + gamma*mean(eig(Rpool))*eye(length(Rpool));
        % W matrix, columns are eigenvectors; L eigenvalues
        [W,L] = eig(Rxy, Rpool_shrink);   [d,indx]=sort(diag(real(L)),'descend'); W = W(:,indx);
        W = W(:,1:Ncomp);
    end
    
    %     ISC = diag(corr(x*W, y*W))
    ISC = diag(W'*Rxy*W) ./ (diag(W'*Rpool*W));
else
    % regularization of pooled covariance
    K = 10; % how many PCs to keep
    [V,L] = eig(Rpool); [d,indx]=sort(diag(real(L)),'descend'); V = V(:,indx);
    Rxy=V(:,1:K)*diag(1./d(1:K))*V(:,1:K)'*Rxy;
    [W,L] = eig(Rxy);   [d,indx]=sort(diag(real(L)),'descend'); W = W(:,indx);
    
    W = W(:,1:Ncomp);
    
    %     ISC = diag(corr(x*W, y*W))
    ISC = diag(W'*Rxy*W);
end

end
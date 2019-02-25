%% Turn features into principal components from my trained model and apply classifier
function [gmm_labels] = sample_unpack_model(data, my_model)

feature_matrix = data;
n_conditions = 1;

% gmm_labels = cell(1,n_conditions);

for ii=1:n_conditions
%     % new data projected onto old principal component space
    newdata = bsxfun(@minus, feature_matrix, my_model.pca.mu); % pca used zeroed feature columns
    newdata = bsxfun(@rdivide, newdata, my_model.pca.std); % pca used weighting by variance
    prcomps = newdata * my_model.pca.coeff;
    
     gmm_labels = cluster( my_model.gmm.fit, prcomps );
%     gmm_labels{ii} = cluster( my_model.gmm.fit, prcomps );
end
end
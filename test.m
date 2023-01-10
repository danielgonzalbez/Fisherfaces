% test - Computes the accuracy of the fisherfaces algorithm.
%
%   This MATLAB script predicts the identity of 15 test images a total of 50 times and measures the accuracy of the algorithm.


function test()
    acc = 0;
    for i = 1:50
        [X_train, X_test, y_train, y_rev] = read_images();
        % X_train with shape 80*80 x n
        n = size(X_train,2);
        eigvecs_pca = pca(X_train, n); % 6400 x n_factors    
        eigvecs_lda = lda(X_train, y_train, eigvecs_pca); % n_factors x n_factors_lda
        eigvecs = eigvecs_pca * eigvecs_lda; % 6400 x n_factors_lda (number of fisherfaces);
        weights_train = eigvecs' * X_train; % n_factors_lda x n
        pos = predict(X_test, y_rev, weights_train, eigvecs, 2000);
        fprintf("Iteration %i: %i \n", i, pos/15);
        acc = acc + pos/15; % 15 images in the test set
    end
    fprintf("Final accuracy: %i \n", acc/50);

end

function pos = predict(X_test, y_rev, weights_train, eigvecs,threshold)
    weights_test = eigvecs' * X_test; % n_factors_lda x n_test_images
    n = size(weights_test,2);
    pos = 0; % correct predictions
    for test_idx = 1:n
        [m, idx] = min(sqrt(sum((weights_train-weights_test(:,test_idx)).^2,1)));
        if m < threshold
            pred = y_rev(idx);
        else
            pred = -1;
        end
        if pred == test_idx
            pos = pos + 1;
        end
    end
end


function eigvecs = compute_eigvecs(A)
    [eigvecs, eigvals] = eig(A); % eigenvalues are not sorted
    eigvals = diag(eigvals);
    [eigvals, idx] = sort(eigvals, 'descend');
    eigvecs = eigvecs(:, idx);
    eigvals = eigvals(idx);
    var = 0;
    total_var = sum(eigvals);
    n_factors = 1;
    while var < 0.95 * total_var
        var = var + eigvals(n_factors);
        n_factors = n_factors + 1;
    end
    eigvecs = eigvecs(:, 1:n_factors);
end



function eigvecs_lda = lda(X, y, eigvecs_pca)
    Sb = zeros(80*80, 80*80);
    n_classes = size(y, 1);
    mean_global = mean(X, 2);
    Sw = zeros(80*80, 80*80);
    for i = 1:n_classes
        mean_class = mean(X(:, y{i}), 2);
        Sb = Sb + size(y{i},2) * (mean_class - mean_global) * (mean_class - mean_global)';
        Sw = Sw + (X(:, y{i}) - mean_class) * (X(:, y{i}) - mean_class)';
    end
    Sw = eigvecs_pca' * Sw * eigvecs_pca;
    Sb = eigvecs_pca' * Sb * eigvecs_pca;
    eigvecs_lda = compute_eigvecs(Sb/Sw);   
end


function eigvecs_pca = pca(X, n)
    C = 1/n * (X -mean(X,2)) * (X-mean(X,2))'; % covariance matrix of the centered data
    eigvecs_pca = compute_eigvecs(C);
end



function [images_train, images_test, y, y_rev] = read_images()
    % Read images from archive and store them in two matrices (test and train)
    files = dir('data/subject*');
    L = length(files);
    n_ind = L/11; % number of individuals in the dataset
    images_train = zeros(80*80, L-n_ind); % preallocate: each column is an image
    y = cell(n_ind, 1); % position i contains the indexes of class i
    y_rev = zeros(L-n_ind,1); % position i contains the class of i
    images_test = zeros(80*80, n_ind); % preallocate: each column is an image
    test_idx = randi([1 11], 1, n_ind); % indexes of the test set
    k = 1;
    train_idx = 1;
    for i = 1:n_ind
        idx = test_idx(i); % index j of the test image of the individual i
        for j = 1:11
            matrix = imread(strcat('data/' , files(k).name));
            matrix = imresize(matrix, [80 80]);
            flat_mat = reshape(matrix, 80*80, 1);
            switch j
                case idx
                    images_test(:,i) = flat_mat;
                otherwise
                    images_train(:,train_idx) = flat_mat;
                    y{i} = [y{i}, train_idx];
                    y_rev(train_idx) = i;
                    train_idx = train_idx + 1;
            end
            k = k + 1;
        end
    end
end
    

%%%%%%%%%%%%%%%% Lab 1 / Excercise 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file = 'kimono1_1920x1080_150_10bit_420.raw';
[suspectID,nblocks] = yCbForensics(file);


%% yCbForencsics function definition
function [suspectID,nblocks] = yCbForensics(file)

    % read and display the video frame
    c = 1920; r = 1080; step = 8;
    fid = fopen(file,'r');
    im = fread(fid, c*r*1.5, 'uint16');
    fclose(fid);

    % separate the channels
    dims = c * r;

    Y = im(1 : dims);
    Y = reshape(Y, [r c]);

    Cb = im(dims+1 : dims+(dims/4));
    Cb = reshape(Cb, [r/2 c/2]);

    Cr = im(dims+(dims/4)+1 : dims+(dims/2));
    Cr = reshape(Cr, [r/2 c/2]);

    % display channels
    figure;
    subplot(1,3,1); imshow(Y,[]); title(['Y size=' num2str(c) 'x' num2str(r)])
    subplot(1,3,2); imshow(Cb, []); title(['Cb size=' num2str(c/2) 'x' num2str(r/2)]) 
    subplot(1,3,3); imshow(Cr, []); title(['Cr size=' num2str(c/2) 'x' num2str(r/2)])

    % add zero-padding so that dimensions are mutiples of the step size
    Cb = pad_row(Cb, step);

    max_rc = size(Cb);
    scores = zeros(1,4);

    % subsample and pad the Y channel using 4 possible methods
    A = pad_row(downsample(Y, 2, 1), step);
    B = pad_row(downsample(Y, 2, 2), step);
    C = pad_row(downsample(Y, 2, 3), step);
    D = pad_row(downsample(Y, 2, 4), step);
 
    for x=0:step:max_rc(1)-step
        for y=0:step:max_rc(2)-step
            p_A = A(x+1:x+step, y+1:y+step);
            p_B = B(x+1:x+step, y+1:y+step);
            p_C = C(x+1:x+step, y+1:y+step);
            p_D = D(x+1:x+step, y+1:y+step);
            p_Cb = Cb(x+1:x+step, y+1:y+step);

            sim_A = r_sim(p_A, p_Cb);
            sim_B = r_sim(p_B, p_Cb);
            sim_C = r_sim(p_C, p_Cb);
            sim_D = r_sim(p_D, p_Cb);
            
            [v,k] = max([sim_A,sim_B,sim_C,sim_D]);
            scores(k) = scores(k) + 1;
        end
    end
   
    [nblocks,suspectID] = max(scores);
    ids = ['A','B','C','D'];
    suspectID = ids(suspectID);
end
 

function mat_out = pad_row(mat,step)
% PAD_ROW adds additional rows of zero to make the dimensions of the input
% matrix a multiple of the step value.
    mat_size = size(mat);
    extra = mod(mat_size(1), step);
    mat_out = [mat; zeros(extra, mat_size(2))];
end

function r_score = r_sim(mat1, mat2)
% R_SIM Calculate r similarity between Y and Cb matrices.
    
    m1 = mean2(mat1); m2 = mean2(mat2);

    s_12 = sum(sum( (mat1-m1) .* (mat2-m2) ));
    s_11 = sum(sum( (mat1-m1) .^ 2 )); 
    s_22 = sum(sum( (mat2-m2) .^ 2 )); 
    
    r_score = (s_12 / sqrt(s_11*s_22))^2;
end

function d_mat = downsample(mat, scale, mode)
% DOWNSAMPLE compress a matrix by a given 'scale' factor using 'mode'
% method. For input of size [m n], the output has size [m/scale n/scale].
    it = [1 1]; d_it = [0 0]; 
    max_it = size(mat);
    d_mat = zeros(max_it/scale);
    
    while it(1)-1 < max_it(1)
        d_it(1) = d_it(1) + 1;
        
        while it(2) < max_it(2)
            d_it(2) = d_it(2) + 1;
            
            r = it(1)+scale-1; c = it(2)+scale-1;
            sub_mat = mat(it(1):r, it(2):c);
            sub_mat = reshape(sub_mat,1,[]);
            
            d_mat(d_it(1),d_it(2)) = floor(aggregate(sub_mat, mode));
            it(2) = it(2) + scale;
        end
        it(2) = 1; d_it(2) = 0;
        it(1) = it(1) + scale;
    end
end

function agg = aggregate(mat, mode)
% AGGREGATE convert a matrix of values into a single value using one of the
% four predefined modes (1-4).
    if mode == 1                                    % mean of all
        agg = mean(mat);
    
    elseif mode == 2                                % mean of left-most
        agg = mean(mat(1:length(mat)/2));
     
    elseif mode == 3                                % mean of right-most
        agg = mean(mat(length(mat)/2+1:end));
    
    elseif mode == 4                                % top-left value
        agg = mat(1);
    end
end
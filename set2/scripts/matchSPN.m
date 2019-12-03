%% Q1-Q3 Obtain the similarity thresholds from the training images
cd('THref');
D = dir;
spn_size = [800 800];
REF_SPN = zeros([spn_size length(D)-2]);
REF_MIN = zeros([1 length(D)-2]);
for k = 3:length(D)
    currD = D(k).name;
    cd(currD);
    refSpn = getRefSPN(currD);
    t = getSimThreshold(dir, refSpn);
    
    REF_SPN(:,:,k-2) = refSpn;
    REF_MIN(k-2) = t;
    cd('..');
end
cd('..')

%% Q4-Q7 Match without the sim threshold
cd('TestRand');
D = dir;
RESULTS = zeros([length(D)-2 6]);

% figure; 
for k = 3:length(D)
    imageName = D(k).name;
    IM = imread(imageName);
    SPN = getSPN(IM, spn_size);
    [id,sim] = match(SPN, REF_SPN, REF_MIN, true);
    
    RESULTS(k-2,1) = id;
    RESULTS(k-2,2) = sim;
%     subplot(5,6,k-2); imshow(IM,[]); title(['img= ' imageName ', class=' num2str(id) ', sim=' num2str(sim)])
end
cd('..')

%% Q8 Match without the sim threshold
cd('TestRand');
D = dir;

% figure; 
for k = 3:length(D)
    imageName = D(k).name;
    IM = imread(imageName);
    SPN = getSPN(IM, spn_size);
    [id,sim] = match(SPN, REF_SPN, REF_MIN, false);
    
    RESULTS(k-2,3) = id;
    RESULTS(k-2,4) = sim;
%     subplot(5,6,k-2); imshow(IM,[]); title(['img= ' imageName ', class=' num2str(id) ', sim=' num2str(sim)])
end
cd('..')

%% QX Match with iterative thresholding (next best)
cd('TestRand');
D = dir;

% figure; 
for k = 3:length(D)
    imageName = D(k).name;
    IM = imread(imageName);
    SPN = getSPN(IM, spn_size);
    [id,sim] = matchTest(SPN, REF_SPN, REF_MIN);
    
    RESULTS(k-2,5) = id;
    RESULTS(k-2,6) = sim;
%     subplot(5,6,k-2); imshow(IM,[]); title(['img= ' imageName ', class=' num2str(id) ', sim=' num2str(sim)])
end
cd('..')

%% HELPER METHODS

function [id,sim] = match(SPN, REF_SPN, REF_MIN, min_flag)
    sims = zeros(size(REF_MIN));
    for i=1:length(sims)
        sims(i) = cosineSim(SPN, REF_SPN(:,:,i));
    end
    [sim,id] = max(sims);
    
    if min_flag && sim < REF_MIN(id)    % check if min threshold exceeded
        sim = 0; id = 0;                % if not, assign class 0
    end
end

function [id,sim] = matchTest(SPN, REF_SPN, REF_MIN)
    sims = zeros(size(REF_MIN));
    for i=1:length(sims)
        sim = cosineSim(SPN, REF_SPN(:,:,i));
        if (sim>=REF_MIN(i))
            sims(i) = sim;
        end
    end
    [sim,id] = max(sims);
    
    if sim == 0         % if no model exceeded the threshold
        id = 0;
    end
end

function minSim = getSimThreshold(fList, refSpn)
    sims = zeros([1 length(fList)-2]);
    for i=3:length(fList) 
        I = imread(fList(i).name);
        trainSpn = getSPN(I, size(refSpn));
        sims(i-2) = cosineSim(trainSpn, refSpn);
    end
    minSim = min(sims);
end

function spn = getRefSPN(name)
    name = ['../../SPNs/' name '.mat'];
    load(name);
end

function spn = getSPN(I, spnSize)
    P = double(rgb2gray(I));
    F = wiener2(P, [3 3]);
    N = P - F;
    dims = size(I);
    x = floor((dims(1)-spnSize(1))/2);
    y = floor((dims(2)-spnSize(2))/2);
    spn = N(x:x+spnSize(1)-1, y:y+spnSize(2)-1);
end

function sim = r2(SPN_test, SPN_ref)
    sim = corr2(SPN_test, SPN_ref);
    sim = sim^2;
end

function sim = cosineSim(SPN_test, SPN_ref)
    St = SPN_test - mean(SPN_test(:));
    Sr = SPN_ref - mean(SPN_ref(:));
    
    St = reshape(St, 1, []);
    Sr = reshape(Sr, 1, []);
    
    sim = dot(St,Sr) / (norm(St)*norm(Sr));
    sim = abs(sim);
end
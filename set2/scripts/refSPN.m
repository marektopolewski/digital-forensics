% traverse the reference img directory and compute SPNs for each camera
cd('SKY');
D = dir;
for k = 3:length(D)
    currD = D(k).name;
    if (strcmp(currD,'refSPNs'))
        cd('..');
    else
        cd(currD);
        spn = getSPN(dir);
        cd('..');
        save(['../SPNs/' currD '.mat'], 'spn');
    end
end
cd('..');

%% HELPER METHODS
function spn = getSPN(fList)
    spnSize = [800 800];
    spn = zeros(spnSize);
    for i=3:length(fList) 
        I = imread(fList(i).name);
        P = double(rgb2gray(I));
        F = wiener2(P, [3 3]);
        N = getCentre(P - F, spnSize);
        spn = spn + N;
    end
    spn = spn ./ (length(fList)-2);
end

function I2 = getCentre(I, cetnreSize)
    dims = size(I);
    x = floor((dims(1)-cetnreSize(1))/2);
    y = floor((dims(2)-cetnreSize(2))/2);
    I2 = I(x:x+cetnreSize(1)-1, y:y+cetnreSize(2)-1);
end


function [ballPos]=DBSCAN_MM(X,min_dist,MinPts)

    
    x = X(:,1);
    y = X(:,2);
    x2=[];
    y2=[];
    out = zeros(120);
    out(sub2ind(size(out),x,y)) = 1;
    padded = padarray(out, [min_dist min_dist], 0);
    
    [rr, cc] = meshgrid(1:2*min_dist+1);
    C = sqrt((rr-min_dist-1).^2+(cc-min_dist-1).^2)<=min_dist;
    
    
    for i = 1:size(X, 1)
    	if sum(sum(padded(x(i)-min_dist:x(i)+min_dist,y(i)-min_dist:y(i)+min_dist).*C))>=MinPts
            x2 = [x2; x(i)];
            y2 = [y2; y(i)];
        end
    end
    ballPos = [mean(x2), mean(y2)];

end




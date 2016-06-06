load('recodedBorder.mat')
events = tempEventdataAll;
x = events(:,1);
y = events(:,2);
col = zeros(size(events,1), 3);
col(:,1) = events(:,3);

figure
scatter(x,y,5,col)
axis([0,130,0,130])
hold on;
scatter(mean(x), mean(y), 550, 'blue');

scatter(60, 60, 50, 'green');
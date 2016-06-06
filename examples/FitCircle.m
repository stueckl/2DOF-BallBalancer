function FitCircle()

    load xFrame;
    load yFrame;

    global Xk;
    global Yk;
    Xk = xFrame;
    Yk = yFrame;

    opts = optimset('Algorithm','interior-point');
    FindCirlce = createOptimProblem('fmincon', 'x0', [60;60;50],...
        'objective', @ObjFun,'lb', [10;10;10],'ub', [100;100;63],...
        'options', opts);
    optimtool(FindCirlce);


function MSE = ObjFun(Xin)
    global Xk;
    global Yk;
    
    n = length(Xk);
    D = sqrt( (Xin(1) - Xk).^2 + (Xin(2) - Yk).^2 ) - Xin(3);
    MSE = (1/n)*sum(D.^2);







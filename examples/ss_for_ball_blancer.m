clc
clear all
close all
%%

m = 0.111;
R = 0.015;
g = -9.8;
L = 1.0;
d = 0.03;
J = 9.99e-6;

s = tf('s');
P_ball = -m*g*d/L/(J/R^2+m)/s^2

%% SS parameters for feedback controller

H = -m*g/(J/(R^2)+m);
A = [0 1 ; 0 0];
B = [0 ; H]; 
C = [1 0];
D = [0];
ball_ss = ss(A,B,C,D);

p1 = -3+1i;
p2 = -3-1i;

K = place(A,B,[p1,p2]')


%%
dt = 0.01;
tEnd = 10;
t1 = 0 : dt : tEnd/2; t2 = tEnd/2+dt : dt : tEnd;
t = horzcat(t1, t2);
u = horzcat( ones(1, length(t1)) , -0.5*ones(1, length(t2)));
sys_cl = ss(A-B*K, B, C, D);
[y,t,x] = lsim(sys_cl, u, t);
figure; plot(t,y)



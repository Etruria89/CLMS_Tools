% Optimal control regulator (LQR)
% updated:  24/07/2021
% Author: Federico Danzi
clc; clear; close all;

%%
%--------------------------------------------------------------------------
% Input
%--------------------------------------------------------------------------

% Discrete System parameters
A = 3;
B = 1;
C = 1;
D = 0;

% State vector
syms x0 x1 x2 real
x = [x0 x1 x2];

% Input sequence
syms u0 u1 u2 real
u = [u0 u1 u2];

% Cost fucntional matrices for each step
    % Finite time horizon
P = [1 1 1];
V = [2 2 2 5]; % V has an extra value for V(N)
    % Infinite time horizon
P_inf = 1;
V_inf = 2;

%%
%--------------------------------------------------------------------------
% Core
%--------------------------------------------------------------------------

%%
% Optimal control over a finite time horizon (LQR)
%--------------------------------------------------------------------------

% The problem of the optimal control over a finite time horizon consists in
% minimizing a quadratic cost function wrt the input vector as:
%
% min J 
%  u 
%
% with:
%      k=len(u)-1
% J = sum [h(k, X(k), U(k))] + J0((N)X(N))
%      k=0
%
%  or more specifically 
%      k=len(u)-1
% J = sum [X'(k)V(k)X(k) + U'(k)P(k)U(k)] + X(N)V(N)X(N)
%      k=0
%      
% Hence starting from the end we can get a dynamic programmig algorithm to
% find the optimal action sequence that minimizes J

disp("FINITE TIME HORIZON RESULTS")

disp("Via direct calculation and derivation:")



for i = length(P):-1:1    
    
    
    %Evaluate last term of the cost
    x_iplus1 = A * x(i) + B * u(i);
    if i == length(P)        
        J_zero = x_iplus1' * V(end) * x_iplus1;
    else
        J_zero = subs(J_zero, x(i+1), x_iplus1);
    end
    
    Ji = u(i)' * P(i) * u(i) + x(i)' *  V(i) * x(i) + J_zero;
    dJi_du = diff(Ji, u(i));
    ui_dir = solve([dJi_du == 0], u(i));
    disp(strcat("U", num2str(i), " ="))
    disp(ui_dir)
    
    % Estimate the new J_zero known the value of the control u(i)
    J_zero = subs(Ji, u(i), ui_dir);
    
end


% From the analytical calculation we can also get that the optimal control 
% sequence is:

% Uo(i) = -L(i)X(i) 
% with:

% L(i) = [P(i)+B'T(i+1)B]^-1B'T(i+1)A
% with:

% T(N) = V(N)
% from the discrete (finite difference) Riccati Equation:
% T(i) = V(i) + A'[T(i+1)-T(i-1)B[P(i)+B'T(i+1)B]^-1B'T(i+1)]A

disp("Via analytical calculation:")

% Initilize Ti with T(N) = V(N)
T_iplus1 = V(end);

for i = length(P):-1:1
    
    alpha = P(i) + B' * T_iplus1 * B;
    beta = T_iplus1 - T_iplus1 * B * alpha^-1 * B' * T_iplus1;
    Ti = V(i) + A' * beta * A;
    Li = (P(i) + B' * T_iplus1 * B)^-1 * B' * T_iplus1 * A;
    
    % Optimal control sequence
    uo_fin_ana = - Li * x(i);
    disp(strcat("U", num2str(i), " ="))
    disp(uo_fin_ana)
    
    % Update the T_iplus1 varaible
    T_iplus1 = Ti;   
    
end


%%
% Optimal control over a infinite time horizon (LQR)
%--------------------------------------------------------------------------

% The problem of the optimal control over a INfinite time horizon consists 
% in minimizing a quadratic cost function wrt the input vector as:
%
% min J 
%  u 
%
% with:
%      k=len(u)-1
% J = sum [h(k, X(k), U(k))] 
%      k=0
%
%  or more specifically 
%      k=len(u)-1
% J = sum [X'(k)V(k)X(k) + U'(k)P(k)U(k)] 
%      k=0
% 
% by enforcing V(N) = 0
%
% From the analytical calculations we get that the optimal control 
% sequence over a INfinite time horizon is:
%
% Uo(i) = -LoX(i) 
% with:
%
% Lo = [P+B'ToB]^-1B'ToA
% with:
% from the discrete (finite difference) Riccati Equation we can get the To:
%
% To = V + A'[To-ToB[P+B'To)B]^-1B'To]A

disp("INFINITE TIME HORIZON RESULTS")


syms To 

alpha_inf = [P_inf + B' * To * B ];
beta_inf = To - To * B * alpha_inf^-1 * B' * To;
To_inf = V_inf + A' * beta_inf * A;
To_val = solve([To - To_inf == 0], To);
disp("To = ")
disp(To_val)


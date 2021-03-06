% Discrete transfer function from continuus trnasfer functions
% updated:  25/07/2021
% Author: Federico Danzi
clc; clear; close all;

%--------------------------------------------------------------------------
% Input
%--------------------------------------------------------------------------

% Symbolic variable for transfer function
syms t s z
syms k a

% Numerator and denominator of the transfer function
Ns = k;
Ds = s + a;

%--------------------------------------------------------------------------
% Core
%--------------------------------------------------------------------------

% It is possible to demonstrate that the connection between a discrete and
% acontinuous transfer function can be expressed via the following equation
% 
% T(z) = Y(z)/U(z) = ((z-1)/z)*Z(T(s)/s)
%
% where:  Z = Z trasnfer function
%               whose terms can be obtained evaluting the inverse Laplace
%               trasnform of H(s)/s mapping this function in the time
%               domain and then appling the Z transform

% Evaluate the continuum transfer function
Ts = Ns / Ds;
% Divide the trasnfer function by s
Ts_overs = Ts / s;

% Evaluate its partial fraction expansion, it is helpful to recognise the
% inverse Laplace trnasform of each component
T_pfe = partfrac(Ts_overs, s) 

% Calculate the inverse Laplace transform
Inverse_Laplace = ilaplace(T_pfe)

% replace all the continuous t values with the n*T product
syms n T
Inverse_Discrete_Laplace = subs(Inverse_Laplace, t, n*T)

% Calculate the Z transform of the Inverse Laplace term
Z_trasnf = ztrans(Inverse_Discrete_Laplace)

% Evaluate the full discrete trasnfer function
Tz = simplify(((z-1)/z) * Z_trasnf) % Until here it is ok

% Make the calculation and put the equation in the form Tz = Nz/Dz
[NTz, DTz] = numden(Tz)

% Evaluate the Nz / Dz division to get the output discrete values
% Estimate the degree of numerator and denominator
[C_DTz, T_DTz] = coeffs(DTz, z);
[C_NTz, T_NTz] = coeffs(NTz, z);
if length(T_NTz) == 1
    NTz_deg = 0
else
    NTz_deg = feval(symengine, 'degree', T_NTz(1))
end
if length(T_DTz) == 1
    DTz_deg = 0
else
    DTz_deg = feval(symengine, 'degree', T_DTz(1))
end

if DTz_deg >= NTz_deg
    
    % Devide doth the terms by z at the power of Dz_deg
    Nz_divide = expand(NTz/z^DTz_deg);
    Dz_divide = expand(DTz/z^DTz_deg);
    % Show the colected values
    Nz_show = collect(Nz_divide, z)
    Dz_show = collect(Dz_divide, z)
    
else
    disp("Degree of numerator higher than numerator the system, this is not consistent!")
end

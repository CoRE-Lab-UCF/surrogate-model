

%%% This script fit Surrogate Models and Generate results (River Surface water lavels, SWL) from the simulated boundary conditions

%%   1. read the HEC-RAS simulated data 
%%   2. read the simulated boundary conditions
%%   3. Fit the models and predict the Surface Water Level

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load HEC-RAS simulated data (SWL, Q, and WL) %% This data will be used for model fitting

%%Load MDA selected dischrage and sea water level and HEC-RAS simulated river water level 
load('C:\Potomac_conditions_all_ft.mat');
Inp = [wl_surrogate,Q_surrogate];

%%% HEC-RAS simulations
load('C:\Data\PotomacRiver\Potomac_sim.mat');


cd('C:\Data\PotomacRiver\synthetic_simulations\Simulation data');

FF=dir('*.txt');

%%
for r=1:length(FF);
AA=importdata(strcat(FF(r).folder,'\',FF(r).name));
A=AA.data;

WLs = A(:,6);
Diss = A(:,5);

Inp2 = [WLs,Diss];

%%
for i = 1:length(STAT) 
    disp(strcat('Analysis performing for Simultion'   ,num2str(r),'  XXXXXXXXX', '  Transect No:',   num2str(i)));
    WL = WS_ELEV(i,:);
    Res = WL';
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %  MLRM
    mdl = fitlm(Inp,Res);
    [m] = predict(mdl,Inp2);
    preds_tmp(:,i) = m;
%%	
%%%%%%%%%% Radial Basis Function %%%%%
	ZI = rbfinterp([Inp2(:,1)'; Inp2(:,2)'], rbfcreate([Inp(:,1)'; Inp(:,2)'], Res','RBFFunction', 'linear', 'RBFConstant', 0.01,'RBFSmooth', 10));
    % reshape
    ZI = reshape(ZI, size(Inp2(:,1)));
    preds_RBF_tmp(:,i) = ZI;
	
%%%%%%%%%%%%%RADIAN BASIS FUNCT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%%%%%%%%%%%%%%%%  Scatter Interpolant %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    F = scatteredInterpolant(Inp(:,1),Inp(:,2),Res);
	F.Method = 'natural';% methods
	WSE_I = F(Inp2(:,1),Inp2(:,2));
	preds_SI_tmp(:,i) = WSE_I;
%%%%%%%%%%%%%%%%%  Scatter Interpolant %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end;

preds_MLR(:,:,r)=preds_tmp;
preds_RBF(:,:,r)=preds_RBF_tmp;
preds_SI(:,:,r)=preds_SI_tmp;

Q_simu(:,r)=Inp2(:,2);
SWL_simu(:,r)=Inp2(:,1);

end;

%%%Save the data
cd('C:\Surroate Model_Results');

save('surrogate_model_results_potomacRiver.mat','preds_MLR','preds_RBF','preds_SI','Q_simu','SWL_simu','-v7.3,'-nocompression');


%%%%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX%%%%%%%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
         %%XXXXXXXXXXXXX    END   END XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%%%%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX%%%%%%%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
















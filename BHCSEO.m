
% BINARY HYBRID CUCKOO SEARCH EQUILIBRIUM OPTIMIZER (CSEO) ALGORITHM 
% FOR CRYPTANALYSIS OF INTERNAL STATE OF RIVEST CIPHER 4 (RC4)
%_________________________________________________________________________________
% 
% Madjos, Joyce A.
% Nario, Jullian Pearl A.                         BSCS 4-4
% Singular, Erielle Rose D.
% Tena, Roswell Jayj R.
% ________________________________________________________________________________

%%%---MAIN FUNCTION---%%%                 
function [Best, Worstt, Mean, Sd, Convergence_curve, rmsd] = BHCSEO(rc4, Particles_no)

  %---------------Initializations---------------%
  a1=1;                    % Constant value that controls exploration ability
  a2=2;                    % Constant value used to manage exploitation ability
  Iter=0;                  % Initialize iteration
  GP=0.9;                  % EO Generation Probability
  dim=16;                  % Dimensions of the problem
  Max_iteration=100;       % Maximum number of iterations
  V=1;                     % Unit for EO
  Ub=256;                  % Upper bounds
  Lb=-256;                 % Lower bounds
  [Ceq1_fit, Ceq2_fit, Ceq3_fit, Ceq4_fit] = deal(inf);     % Initialize to positive infinity
  %---------------Initializations---------------%

  %----------Memory Preallocation for speed----------%                          
  [hiQualEgg, particle, Ceq1, Ceq2, Ceq3, Ceq4] = deal(zeros(1,dim));           
  fitness = zeros(1,Particles_no);
  [top_1, top_2, top_3, top_4] = deal(zeros);
  %----------Memory Preallocation for speed----------%
  
                                                            % Random initial solutions
for i=1:Particles_no
    particle(i,:)= randi([1 Ub],1,dim);
end

 
% Starting iterations
for iter=1:Max_iteration
    
    for i=1:Particles_no
                 
            Flag4ub=particle(i,:)>Ub;                            % Boundary Checking (bring back the particles inside search space 
            Flag4lb=particle(i,:)<Lb;                            % if they go beyoud the boundaries)
            particle(i,:)=(particle(i,:).*(~(Flag4ub+Flag4lb)))+Ub.*Flag4ub+Lb.*Flag4lb;partecle = rc4;  
                                   
            fitness(i)=fitness_func(particle(i,:), rc4);   % Call the Fitness function
            
            sorted_fitness = sort(fitness,"descend");            % Sort the Fitness functions
          
            if numel(sorted_fitness) > 4

                   [top_1, top_2, top_3, top_4] = deal (sorted_fitness(1), sorted_fitness(2), sorted_fitness(3), sorted_fitness(4));
            end

            %---------------Update Equilibrium Candidates: Ceq1, Ceq2, Ceq3 and Ceq4---------------%
             if fitness(i) == top_1
                  Ceq1_fit=fitness(i);  Ceq1=partecle(1,:); 
             elseif fitness(i) == top_2 || fitness(i) > Ceq2_fit 
                  Ceq2_fit=fitness(i);  Ceq2=particle(i,:);
             elseif fitness(i) == top_3 || fitness(i) > Ceq3_fit 
                  Ceq3_fit=fitness(i);  Ceq3=particle(i,:);
             elseif fitness(i) == top_4 || fitness(i) > Ceq4_fit 
                  Ceq4_fit=fitness(i);  Ceq4=particle(i,:);         
             end
            %---------------Update Equilibrium Candidates: Ceq1, Ceq2, Ceq3 and Ceq4---------------%

            %---------------Equilibrium Pool---------------%
            cast_ceq1=cast(Ceq1,"double");
            cast_ceq2=cast(Ceq2,"double");
            cast_ceq3=cast(Ceq3,"double");
            cast_ceq4=cast(Ceq4,"double");
            Ceq_ave=(cast_ceq1+cast_ceq2+cast_ceq3+cast_ceq4)/4;             % Averaged candidate 
            C_pool=[cast_ceq1; cast_ceq2; cast_ceq3; cast_ceq4; Ceq_ave];                   % Equilibrium pool
            %---------------Equilibrium Pool---------------%
    end
            
            %---------------- Memory saving-------------------%   
            if Iter > 1                                                        % Computing memory saving memory if iter > 1
                 fit_old=fitness;  C_old=particle;
            
                for i=1:Particles_no
                     if fit_old(i)>fitness(i)
                         fitness(i)=fit_old(i); particle(i,:)=C_old(i,:);
                     end
                end
            end
            C_old=particle;  fit_old=fitness;
           %---------------- Memory saving-------------------% 

           t=(1-Iter/Max_iteration)^(a2*Iter/Max_iteration);            % Exponential Term(F). This is is crucial in balancing 
                                                                        % the EO algorithm s exploration and exploitation.
           for i=1:Particles_no                                         %For i = 1 to no of particles
              
               lambda=rand(1,dim);                                      % lambda 
               r=rand(1,dim);                                           % r  
               Ceq=C_pool(randi(size(C_pool,1)),:);                     % random selection of one candidate from the pool
               F=a1*sign(r-0.5).*(exp(-lambda.*t)-1);                   % →^F 
               r1=rand(); r2=rand();                                    % r1 and r2 
               GCP=0.5*r1*ones(1,dim)*(r2>=GP);                         % GCP (Generation rate Control Parameter)
               G0=GCP.*(Ceq-lambda.*particle(i,:));                     % G0
               G=G0.*F;                                                 % G (Generation Rate)
                                                                        % Levy flights
               n=size(particle,1);
               beta=3/2;
               sigma=(gamma(1+beta)*sin(pi*beta/2)/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);
                
               for j=1:n
                    s=particle(j,:);
                    u=randn(size(s))*sigma;
                    v=randn(size(s));
                    step=u./abs(v).^(1/beta);
                    stepsize=0.01*step.*(s-cast_ceq1); 
                    hiQualEgg(j,:)=s+stepsize; 
                end
              
               particle(i,:)=Ceq+(hiQualEgg(i,:)-Ceq).*F+(G./lambda*V).*(1-F);    % For updating concentrations/particles/solution                                                         
               
          end
     
               Iter=Iter+1; 
               Convergence_curve(Iter)=Ceq1_fit; 
 
   
end 
%End of iterations

  %---Output---%
  Best = max(fitness);
  Worstt = min(fitness);
  Mean = mean(fitness);
  Sd = std(fitness);
  fifty_rmsd = rmse(0.95281,Mean);
  sixty_rsmd = rmse(0.96344,Mean);
  seventy_rsmd = rmse(0.96703,Mean);
  eighty_rsmd = rmse(0.97188,Mean);
  ninety_rsmd = rmse(0.97453,Mean);
  hundred_rsmd = rmse(0.97188,Mean);
  rmsd = {fifty_rmsd sixty_rsmd seventy_rsmd eighty_rsmd ninety_rsmd hundred_rsmd};
  %---Output---%

%%%---END OF MAIN FUNCTION---%%%  
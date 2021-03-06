function [flows] = MSA_exercise(odmatrix,nodes,links)
%Method of successive averages for calculating deterministic user
%equilibrium
%
%SYNTAX
%   [flows] = MSA_exercise(odmatrix,nodes,links)
%
%DESCRIPTION
%   returns the flow on each link in the deterministic user equilibrium as
%   calculated by the method of successive averages
%
%INPUTS
%   odmatrix: static origin/destination matrix
%   nodes: table with all the nodes in the network.
%   links: table with all the links in the network

%setup the output figure
h = figure;
semilogy(0,NaN);
start_time = cputime;

%Maximum number of iterations
maxIt = 20; 

%initilization
totLinks = size(links.capacity,1);
originFlows=zeros(totLinks,size(odmatrix,1));

%Initialize the iteration numbering
it = 0; 

%initialize the travel cost
%note that the total flow on a link is the sum of the origin based flow
%on that link
alpha = 0.15;
beta = 4;
travelCosts = calculateCostBPR(alpha,beta,sum(originFlows,2),links.length,links.freeSpeed,links.capacity);

%initialize the gap function
gap = inf;

%MAIN LOOP: iterate until convergence is reached or maximum number of
%iterations is reached
while it < maxIt && true
    it = it+1;
    
    %Compute new flows via all-or-nothing assignment
    newOriginFlows = allOrNothing(odmatrix, nodes, links, travelCosts);
    
    %calculate the update step
    update = (newOriginFlows - originFlows);
    
    %calculate new flows
    originFlows = originFlows + update;
    
    %update costs
    travelCosts = calculateCostBPR(alpha,beta,sum(originFlows,2),links.length,links.freeSpeed,links.capacity);
    
    %convergence gap
    gap = max(max(abs(update)));
        
    %plot convergence in function of computation time
    figure(h) 
    hold on
    semilogy(cputime-start_time,gap,'r.')
end

%Check for number of iterations until convergence
if it >= maxIt 
    disp(['Maximum Iteration limit reached: ', num2str(maxIt)]);
else
    disp(['Convergence reached in iteration ', num2str(it)]);
end

%Return the total flow for every link (sum over all origines)
flows = sum(originFlows,2);

end
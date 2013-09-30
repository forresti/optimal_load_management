function [Ls1,Lns1,Ls2,Lns2]=load3(N)

% BUS 1
% Sheddable loads

Ls1(1,:)=5000*ones(1,N);
Ls1(2,:)=zeros(1,N); Ls1(2,N/10:end)=1000;
%Ls1(2,:)=zeros(1,N); Ls1(2,N/10:end)=100000; %test
Ls1(3,:)=zeros(1,N); Ls1(3,2*N/10:9*N/10)=1000;
Ls1(4,:)=zeros(1,N); Ls1(4,N/10:9*N/10)=2000;
Ls1(5,:)=zeros(1,N); Ls1(5, 2*N/10:9*N/10 )=1000;
Ls1(6,:)=zeros(1,N); Ls1(6, 3*N/10:9*N/10 )=1000;
Ls1(7,:)=zeros(1,N); Ls1(7, 2*N/10:5*N/10 )=45000; Ls1(7, 7*N/10:9*N/10 )=5000;
Ls1(8,:)=zeros(1,N); Ls1(8, 3*N/10:5*N/10 )=5000; Ls1(8, 8*N/10:9*N/10 )=6000;
Ls1(9,:)=zeros(1,N); Ls1(9, 4*N/10:9*N/10 )=8000; 
Ls1(10,:)=zeros(1,N); Ls1(10, 4*N/10:6*N/10 )=500;

% Non-Sheddable loads
Lns1(1,:)=21000*ones(1,N);   Lns1(2,:)=5000*ones(1,N);     Lns1(3,:)=2000*ones(1,N);
Lns1(4,:)=2000*ones(1,N);    Lns1(5,:)=1000*ones(1,N);     Lns1(6,:)=5000*ones(1,N);
Lns1(7,:)=1000*ones(1,N);    Lns1(8,:)=2000*ones(1,N);     Lns1(9,:)=2000*ones(1,N);
Lns1(10,:)=1000*ones(1,N);


% BUS 2
% Sheddable loads
%Ls2(1,:)=4000*ones(1,N);  % 25000
Ls2(1,:)=4000*ones(1,N);
Ls2(2,:)=zeros(1,N); Ls2(2,N/10:end)=1000;
Ls2(3,:)=zeros(1,N); Ls2(3,1:9*N/10)=1000; 
Ls2(4,:)=zeros(1,N); Ls2(4,1:9*N/10)=2000;
Ls2(5,:)=zeros(1,N); Ls2( 5,2*N/10:9*N/10 )=11000;
Ls2(6,:)=zeros(1,N); Ls2(6, 3*N/10:9*N/10 )=1500;
Ls2(7,:)=zeros(1,N); Ls2(7, N/10:4*N/10)=5000; Ls2(7,5*N/10:7*N/10)=39000; % simulate Lns power spike
Ls2(8,:)=zeros(1,N); Ls2(8,N/10:4*N/10)=4000; Ls2(8,5*N/10:8*N/10)=10000; % pwr spike
%Ls2(7,:)=zeros(1,N); Ls2(7, N/10:4*N/10)=5000; Ls2(7,5*N/10:7*N/10)=5000;
%Ls2(8,:)=zeros(1,N); Ls2(8,N/10:4*N/10)=4000; Ls2(8,5*N/10:8*N/10)=6000;
Ls2(9,:)=zeros(1,N); Ls2(9,1:9*N/10)=500; 
Ls2(10,:)=zeros(1,N); 

% Non-Sheddable loads
Lns2(1,:)=21000*ones(1,N);   Lns2(2,:)=5000*ones(1,N);     Lns2(3,:)=2000*ones(1,N);
%Lns2(1,:)=10000*ones(1,N);   Lns2(2,:)=5000*ones(1,N);     Lns2(3,:)=2000*ones(1,N);
Lns2(4,:)=2000*ones(1,N);    Lns2(5,:)=1000*ones(1,N);     Lns2(6,:)=5000*ones(1,N);
Lns2(7,:)=1000*ones(1,N);    Lns2(8,:)=2000*ones(1,N);     Lns2(9,:)=2000*ones(1,N);
Lns2(10,:)=1000*ones(1,N);
%Lns2(10,:)=100000*ones(1,N); %test


end

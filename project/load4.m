function [Ls1,Lns1,Ls2,Lns2]=load3(N)

%constant workloads.
%60,000 power units in each bus (30,000 sheddable, 30,000 unsheddable)

% BUS 1
% Non-Sheddable loads
Ls1(1,:)=3000*ones(1,N);
Ls1(2,:)=3000*ones(1,N);
Ls1(3,:)=3000*ones(1,N);
Ls1(4,:)=3000*ones(1,N);
Ls1(5,:)=3000*ones(1,N);
Ls1(6,:)=3000*ones(1,N);
Ls1(7,:)=3000*ones(1,N);
Ls1(8,:)=3000*ones(1,N);
Ls1(9,:)=3000*ones(1,N);
Ls1(10,:)=3000*ones(1,N);

% Sheddable loads
Lns1 = Ls1;

% BUS 2
% Non-Sheddable loads
Ls2 = Ls1;

% Sheddable loads
Lns2 = Ls1;

end

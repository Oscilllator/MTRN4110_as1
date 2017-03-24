function PlotOOIs(OOIs)
    if OOIs.N<1, return ; end;
    
    theta = 0:0.1:2*pi;
    
    for i = 1:OOIs.N
        circX = OOIs.Centers.x(i) + OOIs.Sizes(i)*cos(theta);
        circY = OOIs.Centers.y(i) + OOIs.Sizes(i)*sin(theta);
        plot(circX, circY, 'r');
    end
    
return;
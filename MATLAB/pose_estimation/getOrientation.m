clear
point = [1 2 3];
normal = [1 1 2];
noise = 0.5;

p = generateFakePlane(point, normal, noise);
x = p(:, :, 1);
y = p(:, :, 2);
z = p(:, :, 3);

size(p)

%pretty sure this just turns the data from a 2x2 matrix into a vector
[xData, yData, zData] = prepareSurfaceData( x, y, z );
[fitresult, gof] = fit( [xData, yData], zData, 'poly11');

%plane is of the form:
%z = p00 + p10*x + p01*y
%I like the form:
%a*x + b*y + c*z = d
a = fitresult.p10;
b = -fitresult.p01;
c = 1;
d = fitresult.p00;

%now fit the data back, should be more or less the same as
%the previos p and n: (the direction of n, not the magnitude)
nFit = [a b c];

%find a point more or less in the middle of the plane:
[xLen, yLen, ~] = size(p);
pFit = squeeze(p(round(xLen/2), round(yLen/2), :))

pFit(3) = (d - a*pFit(1) - b*pFit(2))/c;





figure(1);clf();
hold on;
for i = 1:length(p(1,:,1))
    plot3(x(:, i), y(:, i), z(:, i), 'b*')
end
plot( fitresult, [xData, yData], zData );
plot3(pFit(1), pFit(2), pFit(3), 'g*');
xlabel('x'); ylabel('y'); zlabel('z');
view( -92.5, 6.0 );
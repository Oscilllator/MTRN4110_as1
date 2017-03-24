figure(1); clf(); 
hold on
grid on
if ~exist('file','var'), file ='Laser__2.mat'; end;

minPoleDia = 5;%cm
maxPoleDia = 0.2;
load(file);
% now, after loading, the data is in a variable named "dataL";

scan = dataL.Scans(:, 3610);%second arg chosen at random, change for different scans
%data is evenly spaces with 0.5deg increments

% We extract range and intensity, here.
%useful masks, for dealing with bits.
mask1FFF = uint16(2^13-1);
maskE000 = bitshift(uint16(7),13);

intensities = bitand(scan,maskE000);
brightPts = find(intensities ~=0);

ranges  = single(bitand(scan,mask1FFF))*0.1; 
% Ranges expressed in meters, and unsing floating point format.

% 2D points, expressed in Cartesian. From the sensor's perpective.
angles = [0:360]'*0.5* pi/180;% associated angle for each range of scan
X = cos(angles).*ranges/10;
Y = sin(angles).*ranges/10;    
clusters = [1 1];%cluster = [index of start of cluster, index of end of cluster]
polePts = false(1, length(ranges));
clusterEndPts = [1];%have to initialise
isPole = false;

%find all clusters of points:
for i = 2:length(ranges) - 1
    
    if pdist([X(i), Y(i); X(i-1), Y(i-1)]) > maxPoleDia
        if pdist([X(i), Y(i); X(i+1), Y(i+1)]) > maxPoleDia
            clusterEndPts = [clusterEndPts, i - 1, i + 1];
            i = i + 1;
        else 
            clusterEndPts = [clusterEndPts, i - 1, i];
        end
            
       
    end
end


lineColor = [0 1 1];
plot(X, Y, 'k.')
for i = 1:2:length(clusterEndPts) - 1
    
    
    if ~any(find(brightPts > clusterEndPts(i) & brightPts < clusterEndPts(i+1)))
        continue
    end
    if pdist([X(clusterEndPts(i)),  Y(clusterEndPts(i)); X(clusterEndPts(i+1)),  Y(clusterEndPts(i+1))]) > maxPoleDia
        continue
    end
    plot(X(clusterEndPts(i):clusterEndPts(i+1)), Y(clusterEndPts(i):clusterEndPts(i+1)), 'Color', hsv2rgb(lineColor), 'Marker', '+')%, 'LineStyle', 'none'
    lineColor(1) = mod(lineColor(1) + pi, 1);
%     pause(0.1)
end
plot(X(brightPts), Y(brightPts), 'r*')

% figure(1) ; clf(); hold on; grid on
% 
% plot(X(~polePts), Y(~polePts), 'b.')
% plot(X(polePts), Y(polePts), 'r.')

% plot(X, Y, '.')
axis([-10,10,0,20]);  








%view the results "dynamically"
% for i = 1:length(X)
%     clf();
%     hold on
%     plot(X(polePts(1:i)), Y(polePts(1:i)), 'r*')
%     plot(X(~polePts(1:i)), Y(~polePts(1:i)), 'b*') 
%     axis([min(X) max(X) min(Y) max(Y)])
%     title(sprintf('current point: %d', i));
%     
%     
%     if get(gcf,'CurrentCharacter') == 'p'
%         disp('paused, press any key to cont');
%         pause
%     end
% end














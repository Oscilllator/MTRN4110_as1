clear

t = tcpip('127.0.0.1',15000);
set(t,'InputBufferSize', (2*76800));
fopen(t);
pause(1)
i = 0;

figure(1);
%Image = imshow(zeros(120,160), []);
Image = imshow(zeros(120,160), 'Colormap',jet(255));

figure(2);
OOI = imshow(zeros(1,160), 'Colormap', jet(255));

while t.BytesAvailable == 0
    pause(1)
end

height = 120;
width = 160;

Timeout = 0;

while ((Timeout < 10000) || (get(t, 'BytesAvailable') > 0)) 
    if(t.BytesAvailable > 0)
        Timeout = 0;
    else
        continue;
    end
    
    DataReceivedXYZ = fread(t,76800, 'int16');%byte size of array
    k = 19280;%number of elements in array
    counter = 1;
    
    for i = 1 : height
        for j = 1: width
          if counter > 160
                 k = k + 160;
                 counter = 1;
          end

          imageArray(i,j) = DataReceivedXYZ(k);
          k = k + 1;
          counter = counter + 1;
          
          if i == height/2
              ooiArray(j) = DataReceivedXYZ(k);
          end
        end
    end

    imageArray(imageArray<0) = 0;
    OOI(OOI<0) = 0;
    set(Image, 'CData', imageArray/31999);
    set(OOI, 'CData', ooiArray);
    
    
    Timeout = Timeout + 1
    pause(0.01);
end

pause(1)

fclose(t);
delete(t);
clear t

function r = ExtractOOIs(ranges,intensities)
    maxPoleDia = 0.2;
    r.N = 0;
    r.Centers.x = [];
    r.Centers.y = [];
    r.Sizes   = [];
    brightPts = find(intensities ~=0);


    % 2D points, expressed in Cartesian. From the sensor's perpective.
    angles = [0:360]'*0.5* pi/180;% associated angle for each range of scan
    X = cos(angles).*ranges;
    Y = sin(angles).*ranges;    
    clusterEndPts = [1];%have to initialise

    %find all clusters of points:
    for i = 2:length(ranges) - 1
        
        %turns out using pdist is literally 9.52 times slower than
        %comparing squares. makes the whole program run about 7 times
        %faster
        if (X(i) - X(i-1))^2 + (Y(i) - Y(i-1))^2 > maxPoleDia^2%pdist([X(i), Y(i); X(i-1), Y(i-1)]) > maxPoleDia
            if (X(i) - X(i+1))^2 + (Y(i) - Y(i+1))^2 > maxPoleDia^2
                clusterEndPts = [clusterEndPts, i - 1, i + 1];
                i = i + 1;
            else 
                clusterEndPts = [clusterEndPts, i - 1, i];
            end


        end
    end


    lineColor = [0 1 1];
    for i = 1:2:length(clusterEndPts) - 1


        if ~any(find(brightPts > clusterEndPts(i) & brightPts < clusterEndPts(i+1)))
            continue
        end
        if pdist([X(clusterEndPts(i)),  Y(clusterEndPts(i)); X(clusterEndPts(i+1)),  Y(clusterEndPts(i+1))]) > maxPoleDia
            continue
        end
        r.N = r.N + 1;
        r.Centers.x = [r.Centers.x mean(X(clusterEndPts(i):clusterEndPts(i+1)))];
        r.Centers.y = [r.Centers.y mean(Y(clusterEndPts(i):clusterEndPts(i+1)))];
        r.Sizes = [r.Sizes pdist( [X(clusterEndPts(i)), Y(clusterEndPts(i));
                           X(clusterEndPts(i+1)), Y(clusterEndPts(i+1))])];
%         plot(X(clusterEndPts(i):clusterEndPts(i+1)), Y(clusterEndPts(i):clusterEndPts(i+1)), 'Color', hsv2rgb(lineColor), 'Marker', '+')%, 'LineStyle', 'none'
%         lineColor(1) = mod(lineColor(1) + pi, 1);
%         axis([-10,10,0,20]);
    %     pause(0.1)
    end
%     plot(X, Y, 'k.')
%     plot(X(brightPts), Y(brightPts), 'r.')
return;
end

function PlotOOIs(OOIs, guiHandle)
    if OOIs.N<1, return ; end;
    
    theta = 0:0.1:2*pi;
    
    for i = 1:OOIs.N
        circX = OOIs.Centers.x(i) + OOIs.Sizes(i)*cos(theta);
        circY = OOIs.Centers.y(i) + OOIs.Sizes(i)*sin(theta);
        set(guiHandle.handle1, 'xdata', circX, 'ydata', circY);
    end
return;
end
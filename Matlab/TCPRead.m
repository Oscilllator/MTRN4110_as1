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
    end
    
    DataReceivedXYZ = fread(t,76800, 'int16');
    k = 19280;
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
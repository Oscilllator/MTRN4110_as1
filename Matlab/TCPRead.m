clear

t = tcpip('127.0.0.1',15000);
set(t,'InputBufferSize', (2*76800));
fopen(t);
pause(1)
i = 0;

figure(1);
figure(2);
%Image = imshow(zeros(120,160), []);
Image = imshow(zeros(120,160), 'Colormap',jet(255));

while t.BytesAvailable == 0
    pause(1)
end

height = 120;
width = 160;

while (get(t, 'BytesAvailable') > 0) 
    t.BytesAvailable
    DataReceivedXYZ = fread(t,76800, 'int16')/31999;
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

    set(Image, 'CData', imageArray);
     
    %imshow(imageArray, [])

    pause(1/2);
end

pause(1)

fclose(t);
delete(t);
clear t
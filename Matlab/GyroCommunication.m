
% Create TCP/IP object 't'. Specify server machine and port number. 
t = tcpip('127.0.0.1', 15000); 

% Set size of receiving buffer, if needed. 
set(t, 'InputBufferSize', 24); 

% Open connection to the server. 
fopen(t); 
yawVS3d = 0;
Yaw = 0;
Xaxis=0;
Yaxis=0;
Zaxis=0;
dt = 0.5; %time between scans
pause(1) 

h = animatedline('Color','r');
g = animatedline('Color','g');
k = animatedline('Color','b');
axis([0,100,-1,257])
tic
% Receive lines of data from server 
while (get(t, 'BytesAvailable') > 0) 
t.BytesAvailable 
DataReceived = fscanf(t)
%the calc bits
dt = cputime-dt;
if yawVS3d ==0
   Value= str2double(DataReceived(13:16))
   Yaw = Yaw+dt*Value/1000; %each ount i 0.01deg/s
   if Yaw > 360
       Yaw = Yaw -360;
   end
   if Yaw < 0 
       Yaw = Yaw +360;
   end
   Yaw = Yaw
   %PLOT THIS 
   dt = toc
   addpoints(h,dt,Yaw);
   drawnow

end
if yawVS3d ==1
   ValueX= str2double(DataReceived(end-8:end-6));
   Xaxis = Xaxis+dt*ValueX/1000; %each ount i 0.01deg/s
   if Xaxis > 360
       Xaxis = Xaxis -360;
   end
   if Xaxis < 0 
       Xaxis = Xaxis +360;
   end
   ValueY= str2double(DataReceived(end-5:end-3));
      Yaxis = Yaxis+dt*ValueY/1000; %each ount i 0.01deg/s
   if Yaxis > 360
       Yaxis = Yaxis -360;
   end
   if Yaxis < 0 
       Yaxis = Yaxis +360;
   end
   ValueZ= str2double(DataReceived(end-2:end));
   Zaxis = Zaxis+dt*ValueZ/1000; %each ount i 0.01deg/s
   if Zaxis > 360
       Zaxis = Zaxis -360;
   end
   if Zaxis < 0 
       Zaxis = Zaxis +360;
   end
   Xaxis
   Yaxis
   Zaxis
   
   addpoints(h,dt,Xaxis);
   addpoints(h,dt,Yaxis);
   addpoints(h,dt,Zaxis);
   drawnow
%PLOT THIS SOME HOW 

end
%end calc bits

pause(1)
end 

% Disconnect and clean up the server connection. 
fclose(t); 
delete(t); 
clear t 
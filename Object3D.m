fclose(instrfind);
delete(instrfind);
close all;
k = 4;
myaxes = axes('xlim', [-k,k], 'ylim', [-k,k], 'zlim', [-k,k]);
view(3);
grid on;
axis equal;
hold on

[rollaxis, pitchaxis, yawaxis] = cylinder([0.1 0.1]);%axis cylinders are defined

h(1) = surface(rollaxis, pitchaxis, yawaxis, 'FaceColor', 'r');
h(2) = surface(rollaxis, -yawaxis, -pitchaxis, 'FaceColor', 'b');
h(3) = surface(yawaxis, rollaxis, pitchaxis, 'FaceColor', 'g');
legend('YAW AXIS', 'PITCH AXIS', 'ROLL AXIS','AutoUpdate','off')

combinedobject = hgtransform('parent', myaxes);
set(h, 'parent', combinedobject);
drawnow;

s = serial('/dev/ttyACM0');
set(s,'Databits',8);
set(s,'Stopbits',1);
set(s,'Baudrate',115200);
set(s,'Parity','none');

check = 0;
fopen(s);
pause(1);%wait for communication to start
while(check == 0)
    initial = fgets(s)
    if(length(initial) == 9)
        if(initial(1:8) == '$GETEU,*')
           check = 1 
        end
    end
    if(check == 0)
        initial = fgets(s);
    end
end
while 1
    flushinput(s);
    data = fgets(s);
    C = strsplit(data, ',');
    if(length(C) == 5)
        D = cell2mat(C(1,5));
        D = D(1);       
        E = cell2mat(C(1,1));
        if length(E) == 1 
            if(E == '$') && (D == '*')
               yaw = str2double(C(1,2));
               pitch = str2double(C(1,3));
               roll = str2double(C(1,4));            
               C

               rotation1 = makehgtform('xrotate', (pi/180)*(roll), 'yrotate', (pi/180)*(pitch), 'zrotate', (pi/180)*(yaw));
               set(combinedobject, 'matrix', rotation1);
               drawnow;

%                rotation2 = makehgtform('yrotate', (pi/180)*(pitch));
%                set(combinedobject, 'matrix', rotation2);
%                drawnow;
% 
%                rotation3 = makehgtform('zrotate', (pi/180)*(yaw));
%                set(combinedobject, 'matrix', rotation3);
%                drawnow;
               %refresh(f);
            end
        end
    end
end

%Creating object 
a=arduino("/dev/tty.SLAB_USBtoUART",'Nano3');

%Setting up the live graph
figure;
h=animatedline;
ax=gca;
ax.YGrid='on';
ax.YLim=[0 100];
%Labeling the Graph
ylabel('Voltage');
xlabel('Time [HH:MM:SS]');
title('Moisture Sensor Measurments vs Time');
stop=0;
startTime=datetime('now');

%Voltage values of when the soil is dry or wet enough
wet=3;
dry=3.5; 

%Creating a While loop which runs until D6 Button is pressed.
while ~stop
    stop=readDigitalPin(a,'D6'); 
    %Reads the D6 button and stops the loop when pressed
    voltage=readVoltage(a,'A1'); 
    %Reads the voltage on the moisture sensor
    
    t=datetime('now')-startTime;
    addpoints(h,datenum(t),convert(voltage));
    datetick('x','keeplimits')
    drawnow

    if (voltage > dry) %if the voltage recorded is more than dry value, the plant is watered
        disp('Dry Soil - Watering Plant')
        disp(voltage);
        writeDigitalPin(a,'D2',1); 
        pause(0.1) ; 
        writeDigitalPin(a,'D2',0);   
        
    elseif (voltage > wet) %if the voltage recorded is more than wet value, the plant is still watered
        disp('Moist Soil - Watering Plant')
        disp(voltage);
        writeDigitalPin(a,'D2',1); 
        pause(0.1) ; 
        writeDigitalPin(a,'D2',0);

    else %If the voltage does not match any conditions, the plant is not watered
        disp('Wet Soil - Not Watering Plant')
        disp(voltage);
        %The pump remains off
        writeDigitalPin(a,'D2',0);
    end
end

function moistureScale=convert(voltage)
minimumVoltage=0.5;
maximumVoltage=5;
m=100/(minimumVoltage-maximumVoltage);
b=100-(m*minVolt);
moistureScale=m*voltage+b;
end
       

% AUTOMATED PLANT WATERING SYSTEM
% Author: Anshdeep Bal
% Course: EECS 1011
% Date: [Insert Date]
%
% Description:
% This MATLAB script automates plant watering using an Arduino Nano and a moisture sensor.
% It continuously monitors soil moisture levels by reading analog voltage from a sensor connected to pin A1.
% If the soil is dry (based on voltage thresholds), a water pump is triggered via digital pin D2.
% A live graph displays the moisture level over time for visual feedback.
% The system runs in a loop until a physical button connected to pin D6 is pressed.
% This project demonstrates real-time data collection, sensor integration, and actuator control.

% Create Arduino object and connect to board (Arduino Nano)
a = arduino("/dev/tty.SLAB_USBtoUART", 'Nano3');

% Set up a real-time graph
figure;
h = animatedline;       % Create animated line for plotting
ax = gca;
ax.YGrid = 'on';        % Enable grid on Y-axis
ax.YLim = [0 100];      % Set Y-axis limits (for moisture scale)

% Label the graph
ylabel('Moisture Level (%)');
xlabel('Time [HH:MM:SS]');
title('Moisture Sensor Measurements vs Time');

% Initialize stop variable and start time
stop = 0;
startTime = datetime('now');

% Define voltage thresholds for soil moisture
wet = 3.0;   % Voltage above this is "moist" soil
dry = 3.5;   % Voltage above this is considered "dry" soil

% Start the monitoring loop; continues until button on D6 is pressed
while ~stop
    stop = readDigitalPin(a, 'D6');         % Read button state from pin D6
    
    voltage = readVoltage(a, 'A1');         % Read moisture sensor voltage from pin A1
    
    % Get current timestamp relative to start
    t = datetime('now') - startTime;
    
    % Add current data point to the graph
    addpoints(h, datenum(t), convert(voltage));
    datetick('x', 'keeplimits');            % Keep X-axis time formatting
    drawnow;                                % Update the figure
    
    % Control logic for watering based on voltage thresholds
    if voltage > dry
        disp('Dry Soil - Watering Plant');
        disp(voltage);
        writeDigitalPin(a, 'D2', 1);        % Turn pump ON
        pause(0.1);
        writeDigitalPin(a, 'D2', 0);        % Turn pump OFF
        
    elseif voltage > wet
        disp('Moist Soil - Watering Plant');
        disp(voltage);
        writeDigitalPin(a, 'D2', 1);        % Turn pump ON
        pause(0.1);
        writeDigitalPin(a, 'D2', 0);        % Turn pump OFF
        
    else
        disp('Wet Soil - Not Watering Plant');
        disp(voltage);
        writeDigitalPin(a, 'D2', 0);        % Keep pump OFF
    end
end

% Helper function to convert voltage to moisture percentage
function moistureScale = convert(voltage)
    minimumVoltage = 0.5;                   % Sensor voltage when fully wet
    maximumVoltage = 5.0;                   % Sensor voltage when fully dry
    m = 100 / (minimumVoltage - maximumVoltage);
    b = 100 - (m * minimumVoltage);
    moistureScale = m * voltage + b;        % Linear conversion to percentage scale
end

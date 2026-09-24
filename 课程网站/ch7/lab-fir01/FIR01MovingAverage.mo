model FIR01MovingAverage "FIR-01: causal four-tap moving average"
  parameter Real fs = 1000;
  parameter Real f1 = 50;
  parameter Real f2 = 250;
  parameter Real a2 = 0.8;
  discrete Real x(start=0, fixed=true) "Sampled input";
  discrete Real y(start=0, fixed=true) "Post-event filter output";
  discrete Real d1(start=0, fixed=true);
  discrete Real d2(start=0, fixed=true);
  discrete Real d3(start=0, fixed=true);
equation
  when sample(0, 1/fs) then
    x = sin(2*Modelica.Constants.pi*f1*time) + a2*sin(2*Modelica.Constants.pi*f2*time);
    y = (x + pre(d1) + pre(d2) + pre(d3))/4;
    d1 = x;
    d2 = pre(d1);
    d3 = pre(d2);
  end when;
  annotation(experiment(StartTime=0, StopTime=2, Interval=0.001, Tolerance=1e-9));
end FIR01MovingAverage;

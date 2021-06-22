function z= hz2bark(f)
%       HZ2BARK         Converts frequencies Hertz (Hz) to Bark
z = 6 * asinh(f/600);

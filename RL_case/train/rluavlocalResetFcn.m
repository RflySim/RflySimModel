function in = rluavlocalResetFcn(in)

% randomize reference signal
blk = sprintf('rluav/Desired X');
x = randn;
while x > 5 || x <= -5
    x = randn;
end
in = setBlockParameter(in,blk,'Value',num2str(x));

end
%calculate the angle of a vector
clear all;
Q = 256;
I = 256;
stepWidth = 16;
anglesVec = zeros(Q/stepWidth, I/stepWidth);

for zQ=stepWidth:stepWidth:Q
    for zI=stepWidth:stepWidth:I
		anglesVec(zQ/stepWidth, zI/stepWidth) = angle(zQ + 1i*zI);
    end
end

import os
bw = [12, 24, 48, 96, 192]
changeTime = 25
for b in bw:
    if b == 12:
        scales = [1, 2]
    elif b == 24:
        scales = [0.5, 2]
    elif b == 48:
        scales = [0.5, 2]
    elif b == 96:
        scales = [0.5, 2]
    else:
        scales = [0.5]
    for scale in scales:
        trace_file = os.path.join("traces", 'wired' + str(b) + '-x' + str(scale) + '-' + str(changeTime))
        with open(trace_file, 'w') as f:
            send_packets1 = b // 12
            if scale == 1:
                for j in range(send_packets1):
                    f.write(str(1)+'\n')
            else:
                for i in range(1, changeTime*1000+1):
                    for j in range(send_packets1):
                        f.write(str(i)+'\n')
                send_packets2 = int(b*scale) // 12
                for i in range(changeTime*1000+1, (changeTime)*2*1000+10*1000):
                    for j in range(send_packets2):
                        f.write(str(i)+'\n')
                    
                
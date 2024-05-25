file = open("../experiments/cellular-traces-name.txt")
links=[]
for line in file.readlines():
    links.append(line.strip())
print(links)
import json

with open("tests/pids.txt", "r") as f:
    lines = f.readlines()

# for line in lines:
#     line = line.split(" - ")
#     print(line[0].split(". ")[1].strip().title(),"-",line[1].strip())

data = []
for line in lines:
    name, pid = line.split(" - ")
    data.append({"name": name, "pid": pid.strip(), "angle": 0})

with open("tests/print.json", "w") as f:
    json.dump(data, f)

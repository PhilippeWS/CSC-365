heightWeightFile = open('Population Details/height_weight_data.csv', 'r')
countryFile = open('Countries.txt', 'r')
reFormatted = open('Reformatted.txt', 'a+')

hWline = heightWeightFile.readline()
reFormatted.write(hWline)

while True:
    hWline = heightWeightFile.readline()
    countryLine = countryFile.readline()
    
    if not hWline:
        break
    lineItems = hWline.split(",")
    lineItems[0] = countryLine.strip()
    
    newLine = "";
    for item in lineItems:
        newLine+=item + ",";
    newLine = newLine[:-1]
    
    reFormatted.write(newLine)

heightWeightFile.close()
countryFile.close()
reFormatted.close()
import xml.etree.ElementTree as ET
import json

# Parse the KML file
tree = ET.parse('tests/places.kml')

# Get the root element
root = tree.getroot()

# Find all Placemark elements
placemarks = root.findall('.//{http://www.opengis.net/kml/2.2}Placemark')

# Loop through the placemarks and print the name and coordinates
data = []

for placemark in placemarks:
    name = placemark.find(
        './/{http://www.opengis.net/kml/2.2}name').text.strip()
    coordinates = placemark.find(
        './/{http://www.opengis.net/kml/2.2}coordinates').text.strip()

    temp = {"name": name, "coordinates": [float(x) for x in coordinates.split(",")[:2]]}
    data.append(temp)

with open("tests/print.json","w") as f: json.dump(data,f)



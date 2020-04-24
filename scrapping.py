

import csv
import requests
import urllib



FILEPATH = ""


def ratingfinder(URL):
	data = urllib.request.urlopen(URL)
	ratings = []
	for line in data:
		line = str(line)
		line = line.replace(".", "")
		line = line.replace(",", "")
		# ~ if "<title>" in line:
			# ~ ratings.append(line)
		try:
			if '<div class="leftAligned">' in line:
				# ~ print(line)
				for pos in range(len(line)):
					if line[pos] == ">":
						for x in (4, 3, 2, 1):
							try:
								num = int(line[pos + 1: pos + 1 + x])
								ratings.append(num)
								raise AssertionError		#Go to next line in HTML
							except ValueError:
								continue
		except AssertionError:
			continue
	total = sum(ratings)
	ratings.append(total)
	# ~ assert len(ratings) == 12
	return ratings




with open(FILEPATH, mode = "r") as csv_file:
	csv_reader = csv.reader(csv_file, delimiter = ',')
	
	with open('ratingsadded.csv', mode='w') as out:
		outfile = csv.writer(out, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)

		urllist = set()
		for row in csv_reader:
			URL = row[3]
			if URL != "" and URL not in urllist:
				urllist.add(URL)
			else:
				print(URL)
				raise AssertionError	#URL DOUBLE FOUND!
			if "www" in URL:
				res = ratingfinder(URL)
				
				output = row + res
				print(output)
				outfile.writerow(output)
				
			else:
				continue



					
					
		

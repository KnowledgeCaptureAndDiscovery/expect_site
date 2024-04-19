# remember to use "gmake" for this file.

files = description.html demo.html people.html publications.html research.html funding.html links.html status.html

all: $(files)


# for all of the files in $(files), the desired html is generated according to the following example (demo.html)
#   demo.html = header.txt + demo.txt + footer.txt
# luckily gmake does this very nicely!

$(files): %.html: %.txt header.txt footer.txt
	cp header.txt $@
	cat $< >> $@
	cat footer.txt >> $@

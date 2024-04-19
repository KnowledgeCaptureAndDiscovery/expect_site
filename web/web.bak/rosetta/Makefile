# this is the Makefile in /home/http/expect/web
#
# Don't use it in that directory! It is symbolically linked to in the subdirs of that directory.
#
# For instance, go to /home/http/expect/web/trellis and type "gmake"
#
#
# remember to use "gmake" and not "make"


files = description.html demo.html people.html publications.html research.html funding.html links.html status.html

all: $(files)


# for all of the files in $(files), the desired html is generated according to the following example (demo.html)
#   demo.html = header.txt + demo.txt + footer.txt
# luckily gmake does this very nicely!

$(files): %.html: %.txt header.txt footer.txt
	cp header.txt $@
	cat $< >> $@
	cat footer.txt >> $@

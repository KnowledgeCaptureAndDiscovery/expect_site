# @(#)GNUmakefile	12/07/99
#
# Makefile for use on Solaris using gnumake. 

SDKHOME = /nfs/v2/jihie/java/sdk

TOOLHOME = /nfs/etg/apps/java/jdk1.2.2

CLIENTS = /nfs/v2/expect/current/clients
XML = /nfs/v2/expect/current/clients/XML

ifeq ($(CSEP),)
CSEP = :
endif

SCLASSPATH =.:classes:$(CLIENTS):$(CLIENTS)/EMeD/classes:$(CLIENTS)/PSMTool/classes:$(XML)/xml4j.jar:$(XML)/xerces.jar:$(XML)/saxon


JAVAC2 = $(TOOLHOME)/bin/javac -deprecation -g -classpath '$(subst :,$(CSEP),$(SCLASSPATH))'
JAVA2 = $(TOOLHOME)/bin/java -classpath '$(subst :,$(CSEP),$(SCLASSPATH))'

FILES = \
	classes/Temple.class

all: classes $(FILES)
	@chmod +x runnit 
	(cd .. ; ./make-expect-jar)

run: $(FILES)
	$(JAVA2) ExpectWindowPanel

clean:
	rm -rf classes 

classes:
	mkdir -p classes

classes/%.class: %.java
	$(JAVAC2) -d classes $?

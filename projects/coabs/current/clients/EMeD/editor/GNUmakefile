# @(#)GNUmakefile	12/07/99
#
# Makefile for use on Solaris using gnumake. 

SDKHOME = /nfs/v2/jihie/java/sdk

ifeq ($(CSEP),)
CSEP = :
endif

# This path is only used when testing the example as part of the Swing build.

SCLASSPATH =.:classes:/nfs/v2/jihie/expect/EMeD/Client2:$(SDKHOME)/lib/dt.jar:$(SDKHOME)/lib/tools.jar:/nfs/v2/jihie/java/XML/xml4j/xml4j.jar:/nfs/v2/jihie/java/XML/saxon

JAVAC2 = $(SDKHOME)/bin/javac -deprecation -g -classpath '$(subst :,$(CSEP),$(SCLASSPATH))'
JAVA2 = $(SDKHOME)/bin/java -classpath '$(subst :,$(CSEP),$(SCLASSPATH))'

FILES = \
	classes/eButton.class		\
	classes/editListCellRenderer.class	\
	classes/methodDescRenderer.class	\
	classes/altPanel.class		\
	classes/MEditor.class

all: classes $(FILES)
	@chmod +x runnit 

run: $(FILES)
	$(JAVA2) MEditor

clean:
	rm -rf classes 

classes:
	mkdir -p classes

classes/%.class: %.java
	$(JAVAC2) -d classes $?

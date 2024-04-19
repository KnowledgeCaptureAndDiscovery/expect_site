# @(#)GNUmakefile	12/07/99
#
# Makefile for use on Solaris using gnumake. 

SDKHOME = /nfs/v2/jihie/java/sdk

XMLHOME = /nfs/v2/jihie/java/XML

TOOLHOME = /nfs/etg/apps/java/jdk1.2.2

CLIENTHOME = /nfs/v2/expect/current/clients

ifeq ($(CSEP),)
CSEP = :
endif

SCLASSPATH =.:classes:$(CLIENTHOME)/EMeD/classes:$(CLIENTHOME)/PSMTool/classes:$(CLIENTHOME):$(SDKHOME)/lib/dt.jar:$(SDKHOME)/lib/tools.jar:$(XMLHOME)/xml4j3/xml4j.jar:$(XMLHOME)/xml4j3/xerces.jar:$(XMLHOME)/saxon


JAVAC2 = $(TOOLHOME)/bin/javac -deprecation -g -classpath '$(subst :,$(CSEP),$(SCLASSPATH))'
JAVA2 = $(TOOLHOME)/bin/java -classpath '$(subst :,$(CSEP),$(SCLASSPATH))'

FILES = \
	classes/RKF.class \

all: classes $(FILES)
	@chmod +x runnit 
	(cd classes ; jar cf ../rkf.jar *.class)

run: $(FILES)
	$(JAVA2) ExpectWindowPanel

clean:
	rm -rf classes 

classes:
	mkdir -p classes

classes/%.class: %.java
	$(JAVAC2) -d classes $?

#!/bin/sh
#
# %% %%

#AF_CLASSES=/nfs/v2/jihie/Active-Catalogs/AF/java/af-1.5.jar
#ALL_CLASSPATH=$(AF_CLASSES):$(CLASSPATH)
ALL_CLASSPATH=$(CLASSPATH)

JAVAC = $(JDKHOME)/bin/javac -g -d . -deprecation -classpath $(ALL_CLASSPATH)

JAVA = $(JDKHOME)/bin/java

FILES = \
	classes/ExpectOutput.class \
	classes/FormManager.class \
	classes/Start.class 


all: classes $(FILES)
	@chmod +x runnit
 
run: $(FILES)
	$(JAVA) Start
 
clean:
	rm -rf classes
 
classes:
	mkdir -p classes
 
classes/%.class: %.java
	$(JAVAC) -d classes $?


# @(#)GNUmakefile	12/07/99
#
# Makefile for use on Solaris using gnumake. 

SDKHOME = /nfs/v2/jihie/java/sdk

TOOLHOME = /nfs/etg/apps/java/jdk1.2.2

ifeq ($(CSEP),)
CSEP = :
endif

SCLASSPATH =.:classes:/nfs/v2/expect/current/clients/EMeD/classes:/nfs/v2/expect/current/clients:$(SDKHOME)/lib/dt.jar:$(SDKHOME)/lib/tools.jar:/nfs/v2/jihie/java/XML/xml4j3/xml4j.jar:/nfs/v2/jihie/java/XML/xml4j3/xerces.jar:/nfs/v2/jihie/java/XML/saxon


JAVAC2 = $(TOOLHOME)/bin/javac -deprecation -g -classpath '$(subst :,$(CSEP),$(SCLASSPATH))'
JAVA2 = $(TOOLHOME)/bin/java -classpath '$(subst :,$(CSEP),$(SCLASSPATH))'

FILES = \
	classes/ActiveText.class \
	classes/MethodEditor.class \
	classes/MethodApplier.class \
	classes/RelationEditor.class \
	classes/InstanceEditor.class \
	classes/KATool.class \
	classes/PSMTool.class \
	classes/CritiqueView.class \
	classes/PlanView.class \
	classes/NameFieldPanel.class \
	classes/CritiqueWizard.class \
	classes/WizardLine.class \
	classes/WizardMenu.class \
	classes/WizardMethodLine.class \
	classes/WizardPanel.class \
	classes/WizardReader.class \
	classes/WizardStep.class \
	classes/KAGrammarTool.class \
	classes/GClass.class \
	classes/ListBuilder.class

all: classes $(FILES)
	@chmod +x runnit 
	(cd classes ; jar cf psmtool.jar *.class)

run: $(FILES)
	$(JAVA2) ExpectWindowPanel

clean:
	rm -rf classes 

classes:
	mkdir -p classes

classes/%.class: %.java
	$(JAVAC2) -d classes $?

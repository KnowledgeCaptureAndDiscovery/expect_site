# @(#)GNUmakefile	12/07/99
#
# Makefile for use on Solaris using gnumake. 

SDKHOME = /nfs/v2/jihie/java/sdk
#SDKHOME = /nfs/etg/apps/java/jdk1.2.2

ifeq ($(CSEP),)
CSEP = :
endif

SCLASSPATH =.:classes:/nfs/v2/expect/current/clients:/nfs/v2/expect/current/clients/PSMTool/classes:$(SDKHOME)/lib/dt.jar:$(SDKHOME)/lib/tools.jar:/nfs/v2/jihie/java/XML/xml4j3/xml4j.jar:/nfs/v2/jihie/java/XML/xml4j3/xerces.jar:/nfs/v2/jihie/java/XML/saxon


JAVAC2 = $(SDKHOME)/bin/javac -deprecation -g -classpath '$(subst :,$(CSEP),$(SCLASSPATH))'
JAVA2 = $(SDKHOME)/bin/java -classpath '$(subst :,$(CSEP),$(SCLASSPATH))'

# classes/Connection/ExpectConnect.class		\
# classes/Connection/FactoryException.class	\

FILES = \
	classes/Connection/ExpectSocketAPI.class	\
	classes/PSTree/GRPanel.class		\
	classes/PSTree/GRRenderer.class		\
	classes/PSTree/GRCellRenderer.class		\
	classes/PSTree/GRSmallCellRenderer.class		\
	classes/HTML/HtmlPanel.class		\
	classes/xml2jtml/testRenderer.class		\
	classes/xml2jtml/renderer.class		\
	classes/xml2jtml/methodDefRenderer.class		\
	classes/Tree/capabilityOrganizer.class		\
	classes/Tree/capOrgRenderer.class		\
	classes/Tree/expandableTreePanel.class		\
	classes/Tree/expandableTreeNode.class		\
	classes/Tree/expandableTree.class		\
	classes/Tree/expandableTreeCellRenderer.class		\
	classes/Tree/messagePanel.class		\
	classes/Tree/messageFrame.class		\
	classes/Tree/messageListCellRenderer.class		\
	classes/Tree/messageListRenderer.class		\
	classes/Tree/renderer.class		\
	classes/Tree/editMethodFrame.class		\
	classes/Tree/editResponseRenderer.class		\
	classes/Tree/methodListPanel.class		\
	classes/Tree/methodListRenderer.class		\
	classes/Tree/highlightedMethodListCellRenderer.class		\
	classes/Tree/methodListCellRenderer.class		\
	classes/Tree/searchMethodsRenderer.class		\
	classes/Tree/searchPanel.class		\
	classes/Tree/undefinedGoalListPanel.class	\
	classes/Tree/undefinedGoalListRenderer.class	\
	classes/Tree/undefinedGoalListCellRenderer.class	\
	classes/Tree/treePanel.class	\
	classes/Tree/treeRenderer.class	\
	classes/Tree/expectTreeCellRenderer.class	\
	classes/Tree/setTopGoalPanel.class	\
	classes/Tree/resultPanel.class	\
	classes/Tree/subTreeFrame.class	\
	classes/PSTree/psTabbedPanel.class	\
	classes/PSTree/PSTreePanel.class	\
	classes/PSTree/PSundefinedGoalsPanel.class	\
	classes/editor/eButton.class		\
	classes/editor/editListCellRenderer.class	\
	classes/editor/methodDescRenderer.class	\
	classes/editor/altPanel.class		\
	classes/editor/MEditor.class		\
	classes/ExpectTabbedPanel.class		\
	classes/SmallTabbedPanel.class		\
	classes/ExpectWindowPanel.class	

all: classes $(FILES)
	(cd classes ; jar cf ../emed.jar *.class */*.class)
	@chmod a+w emed.jar
	@chmod +x runnit 


run: $(FILES)
	$(JAVA2) ExpectWindowPanel

clean:
	rm -rf classes 

classes:
	mkdir -p classes

classes/%.class: %.java
	$(JAVAC2) -d classes $?

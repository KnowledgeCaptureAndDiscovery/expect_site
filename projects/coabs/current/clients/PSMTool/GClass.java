import java.io.*;

public class GClass {

    public GClass subclass[];
    int nClasses = 0, nPartitions = 0;
    public GClass partition[];
    public String gramm[];

    public GClass() {
	gramm = new String[20];
	subclass = new GClass[20];
	partition = new GClass[20];
    }

    public GClass(String passed_gram[]) {
	gramm = new String[passed_gram.length];
	subclass = new GClass[20];
	partition = new GClass[20];
	int i;
	for (i = 0; i < passed_gram.length; i++) {
	    gramm[i] = passed_gram[i];
	}
    }

    public void addClass(GClass newClass) {
	subclass[nClasses++] = newClass;
    }

    public void addPartition(GClass newPart) {
	partition[nPartitions++] = newPart;
    }

    public String toString() {
	return toString(0);
    }

    public String toString(int index) {
	String res = "{";
	int i;
	for (i = 0; i < gramm.length; i++) {
	    res += gramm[i] + " ";
	}
	for (i = 0; i < nPartitions; i++) {
	    res += "\n  [" + partition[i].toString(index + 2) + "]";
	}
	for (i = 0; i < nClasses; i++) {
	    res += "\n  |" + subclass[i].toString(index + 2) + "|";
	}
	return res + "}\n";
    }

    public static void main(String args[]) {
	String topLine[] = {"show me the", "[name]"},
	    critLine[] = {"warn me if the", "[name]", "@1"},
		boundLine[] = {"@1"},
		    upperLine[] = {"is more than", "[bound]"},
			lowerLine[] = {"is less than", "[bound]"};
			GClass top = new GClass(topLine),
			    critique = new GClass(critLine),
			    bound = new GClass(boundLine),
			    upper = new GClass(upperLine),
			    lower = new GClass(lowerLine);
			    
			top.addClass(critique);
			critique.addPartition(bound);
			bound.addPartition(lower);
			bound.addPartition(upper);

			System.out.println(top);
    }
}


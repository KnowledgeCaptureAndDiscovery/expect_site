import java.util.*;
import java.io.*;

import Connection.*;

public class TestList {

    public static void main(String[] args) {

        Vector v;
        LayedData l;
        String[] input = {"",
		      "this",
		      "{this is a list}",
		      "so is this",
		      "This list has a \"string element\"",
		      "{This is {a {nested}} list}",
		      "{this is {a nested} {yes {very {nested}}} list}"};

        for (int i = 0; i < input.length; i++) {
	  System.out.println("Input: " + input[i]);
	  v = LispSocketAPI.readList(input[i]);
	  System.out.println(v);
	  l = LispSocketAPI.readLayedData(input[i]);
	  System.out.println(l);
        }

    }
}

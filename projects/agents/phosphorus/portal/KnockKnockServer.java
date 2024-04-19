import java.net.*;
import java.io.*;

class KnockKnockServer {
    public static void main(String[] args) {
        ServerSocket serverSocket = null;

        try {
            serverSocket = new ServerSocket(4444);
        } catch (IOException e) {
            System.out.println("Could not listen on port: " + 4444 + ", " + e);
            System.exit(1);    
            }
		Socket clientSocket = null;
        try {
            clientSocket = serverSocket.accept();
        } catch (IOException e) {
            System.out.println("Accept failed: " + 4444 + ", " + e);
            System.exit(1);
        }

        try {
            DataInputStream is = new DataInputStream(
                                 new 
BufferedInputStream(clientSocket.getInputStream()));
            PrintStream os = new PrintStream(
                             new 
BufferedOutputStream(clientSocket.getOutputStream(), 1024), false);
            //KKState kks = new KKState();
            String inputLine, outputLine;

            outputLine = " accept  null";
            os.println(outputLine);
            os.flush();

            while ((inputLine = is.readLine()) != null) {
                 outputLine = " accept " + inputLine ;
		 System.out.println ("Accept :" + inputLine);
                 os.println(outputLine);
                 os.flush();
                 //if (inputLine.equals("Bye."))
                 //   break;
            }
            os.close();
            is.close();
            clientSocket.close();
            serverSocket.close();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
     
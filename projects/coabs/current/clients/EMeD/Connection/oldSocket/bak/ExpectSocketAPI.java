// EXPECT Backend

// Author: Hans Chalupsky
// modified by Jihie Kim
package socket;

public abstract class ExpectSocketAPI {

    public static ExpectSocketAPI ExpectSocket;
 
    static boolean isBusy = false;

    public static synchronized ExpectSocketAPI acquire() throws FactoryException {
        if (isBusy)
            throw new FactoryException("ExpectSocketAPI busy");
        if (ExpectSocket == null)
            ExpectSocket = new ExpectLispAPI();
        if (ExpectSocket == null)
            throw new FactoryException("ExpectSocketAPI unavailable");
        isBusy = true;
        return ExpectSocket;
    }

     public static synchronized void release(ExpectSocketAPI pl) {
         if (pl != null)
             isBusy = false;
     }
}

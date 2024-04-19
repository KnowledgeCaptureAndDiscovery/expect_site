// Author: Hans Chalupsky
// modified by Jihie Kim

package Connection;
public class FactoryException extends Exception {

    String type = "generic"; // Use this instead of many different classes

    public FactoryException() {
        super();
    }

    public FactoryException(String type) {
        super(type);
        this.type = type;
    }

    public FactoryException(String type, String message) {
        super(message);
        this.type = type;
    }

    public String getType() {
        return type;
    }
}

// <Access modifier> <class> <class_name> {
//         <Access modifier> <return function> <functionName>
// }

// Classes PascalNamingConvention
// Methods camelNamingConvention

// Main method is always static

import java.util.Date;
import java.awt.*;

public class Main {
    public static void main(String [] args) {
        Point point1 = new Point(x:1, y:1);
        Point point2 = point1;
        point1.x = 2;

        System.out.println(point2);
    }
}


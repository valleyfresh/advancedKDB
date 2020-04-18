import kx.c;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.io.*;
import java.nio.file.*;

public class CsvApi {
    static void headerLines() {
        System.out.println(
                "================================================================================================================");
    }

    static void bodyLines() {
        System.out.println(
                "----------------------------------------------------------------------------------------------------------------");
    }

    static void infoLog(String msg) {
        Logger logger = Logger.getLogger(CsvApi.class.getName());
        logger.log(Level.INFO, msg + "\n");
    }

    static void warningLog(String msg) {
        Logger logger = Logger.getLogger(CsvApi.class.getName());
        logger.log(Level.WARNING, msg + "\n");
    }

    static void fileCheck(String filepath) {
        infoLog("Locating file in path: " + filepath);
        File dir = new File(filepath);
        boolean exists = dir.exists();
        if (exists) {
            // System.out.println("File exists");
            infoLog("File exists");
        } else {
            // System.out.println("File does not exist! Please check and try again...");
            warningLog("File does not exist! Please check and try again...");
            System.exit(1);
        }
    }

    public static void main(String[] args){

        //////////////////////////////////////////////////////////////////////////
        headerLines();
        System.out.println("STARTING JAVA CSV API");
        headerLines();
  
        bodyLines();
        String csvDir = System.getenv("CSV_DIR");
        // System.out.println("CSV Directory is: " + csvDir);
        infoLog("CSV Directory is: " + csvDir);
        System.out.println("Input csv filename: ");
        // Using Console to input data from user
        String name = System.console().readLine();
        bodyLines();
        //////////////////////////////////////////////////////////////////////////
        headerLines();
        System.out.println("TASK 1: CHECKING IF FILE EXISTS");
        headerLines();
        bodyLines();
        String filepath = csvDir + '/' + name;
        fileCheck(filepath);
        bodyLines();
        //////////////////////////////////////////////////////////////////////////
        headerLines();
        System.out.println("TASK 2: CONNECTING TO THE KDB TP PROCESS");
        headerLines();

        bodyLines();
        // Assign TP port environmental variable
        int tpPort = Integer.parseInt(System.getenv("TP_PORT"));
        infoLog("TP Port is :"+ tpPort);

        c c=null;

        try{
            c = new c("localhost",tpPort);
            infoLog("Successfuly connected to the TP process");
            
            //////////////////////////////////////////////////////////////////////////
            headerLines();
            System.out.println("TASK 3: READING AND PUBLISHING CSV FILE CONTENTS");
            headerLines();
    
            bodyLines();
            //csvRead(filepath);
            infoLog("Reading file in path: " + filepath);
            try {
                // Create a reader instance
                BufferedReader br = Files.newBufferedReader(Paths.get(filepath));
    
                // CSV file delimiter
                String delimiter = ",";
    
                // Read all lines in the file
                String line;
                int i = 0;
                while ((line = br.readLine()) != null) {
                    // Additional logic to ignore the header row
                    if (i > 0) {
                        // Split line up using the delimiter and set to a string array
                        String rowValue[] = line.split(delimiter);
                        if (filepath.indexOf("trade.csv") != -1) {               
                            //try{
                                // Convert first value into date format
                                //String timespan = rowValue[0];
                                //System.out.println("Timespan:" + rowValue[0]);
                                //DateFormat dateFormat = new SimpleDateFormat("HH:mm:ss.SSSSSSSSS");
                                //Date d = dateFormat.parse(timespan);
                                //LocalTime t = LocalTime.parse(rowValue[0]);
                                //System.out.println("Converted time value: " + t);
                            //} catch (Exception e) {
                            //    warningLog("Unable to covert timespan value...");
                            //    e.printStackTrace();
                            //    System.exit(1);
                            //}
                            //Extract data row into type array
                            //c.Timespan time = t;
                            String time = rowValue[0];
                            String sym = rowValue[1];
                            double price = Double.parseDouble(rowValue[2]);
                            int size = Integer.parseInt(rowValue[3]);
        
                            Object[] tradeData = new Object[] {time, sym, price, size};
                            // Send row value over to the TP
                            c.ks(".u.upd", "trade", tradeData);
                            infoLog("Successfully sent trade data to the TP");
                        } else if (filepath.indexOf("quote.csv") != -1) {
                            String time = rowValue[0];
                            String sym = rowValue[1];
                            double bid = Double.parseDouble(rowValue[2]);
                            double ask = Double.parseDouble(rowValue[3]);
                            int bsize = Integer.parseInt(rowValue[4]);
                            int asize = Integer.parseInt(rowValue[5]);

                            Object[] quoteData = new Object[] {time, sym, bid, ask, bsize, asize};
                            // Send row value over to the TP
                            c.ks(".u.upd", "quote", quoteData);
                            infoLog("Successfully sent quote data to the TP");
                        } else {
                            warningLog("Invalid file entered...");
                            System.exit(1);
                        }
                    }
                    i += 1;
                }
    
                // Close the reader
                br.close();
    
            } catch (IOException ex) {
                warningLog("Error reading in CSV file...");
                ex.printStackTrace();
            } 
            
            bodyLines();
            //////////////////////////////////////////////////////////////////////////
        } catch (Exception e){
            warningLog("Error connecting to the TP Process...");
            e.printStackTrace();
            System.exit(1);
        } finally {
            try{if(c!=null)c.close();}catch(java.io.IOException e){}
        }
        bodyLines(); 
    }
}
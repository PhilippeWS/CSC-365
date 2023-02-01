import java.sql.*;
import java.sql.Date;
import java.time.DateTimeException;
import java.time.LocalDate;
import java.util.*;

public class FR3 {
    private final Connection conn;
    private static final String noChangeInput = "No Change";
    private StringBuilder query = new StringBuilder("UPDATE pwylezek.lab7_reservations SET ");

    FR3(Connection conn) {
        this.conn = conn;
    }

    public void editReservation() {
        PreparedStatement preparedStatement = null;
        try {
            conn.setAutoCommit(false);
            String[] tableFields = new String[]{"FirstName", "LastName", "Kids", "Adults", "CheckIn", "CheckOut"};
            String[] responses = getPreferences();

            if(responses[0].equalsIgnoreCase("C") || responses[0].equalsIgnoreCase("Cancel")) return;

            //Build Update Query
            for(int index = 1; index < responses.length; index++){
                if(!noChangeInput.equalsIgnoreCase(responses[index])){
                    query.append(tableFields[index - 1]).append(" = ?,");
                }
            }

            query.deleteCharAt(query.length()-1);
            query.append(" WHERE CODE = ?;");

            preparedStatement = conn.prepareStatement(String.valueOf(query));

            int appended = 0;
            for(int index = 1; index < responses.length ; index++){
                if(!noChangeInput.equalsIgnoreCase(responses[index])){
                    if(index == 1 || index == 2){
                        preparedStatement.setString(index, responses[index]);
                    }else if(index == 3 || index == 4) {
                        preparedStatement.setInt(index, Integer.parseInt(responses[index]));
                    }else{
                        preparedStatement.setDate(index, java.sql.Date.valueOf(responses[index]));
                    }
                    appended++;
                }
            }


            if(appended == 0){
                System.out.println("No changes to be made, aborting update.");
                return;
            }

            preparedStatement.setInt(appended+1, Integer.parseInt(responses[0]));

            int rowsModified = preparedStatement.executeUpdate();

            System.out.printf("Updated reservation %s. Modified %d rows\n", responses[0], rowsModified);

            conn.commit();
        } catch (SQLException q) {
            try {
                System.out.println("ERROR | editReservation(): Failed Query, attempting Rollback...");
                conn.rollback();
                System.out.println("ERROR | editReservation(): Rollback Successful");
            } catch (SQLException rb) {
                System.out.println("ERROR | editReservation(): Rollback Failed");
            }
        } finally {
            if (preparedStatement != null) {
                try { preparedStatement.close(); }
                catch (SQLException e) { System.out.println("ERROR | editReservation(): Failed to close Statement Object"); }
            }
            if (this.conn != null) {
                try { conn.close(); }
                catch (SQLException e) { System.out.println("ERROR | editReservation(): Failed to close Connection Object"); }
            }
        }
    }

    private String[] getPreferences() {
        Scanner keyboard = new Scanner(System.in);
        String[] responses = new String[7];
        String resCode;
        do{
            System.out.println("Enter Code of the Reservation you wish to change (\033[3m(C)ancel\033[0m to cancel):");
            resCode = keyboard.nextLine();
        }while(!validateReservationCode(resCode));
        responses[0] = resCode;

        if (responses[0].equalsIgnoreCase("cancel") || responses[0].equalsIgnoreCase("c")) {
            System.out.println("No reservation changed.");
        } else if (validateReservationCode(responses[0])) {
            String[] preferenceFields = new String[]{"First Name", "Last Name", "Number of Children", "Number of Adults", "Begin Date", "End Date"};
            for (int field = 0; field < preferenceFields.length; field++) {
                System.out.printf("Enter new %s (\033[3mNo Change\033[0m to keep):\n", preferenceFields[field]);
                responses[field + 1] = keyboard.nextLine();

                if (preferenceFields[field].contains("Number") && !responses[field + 1].equalsIgnoreCase(noChangeInput)) {
                    if (validateNumericType(responses[field + 1])) field--;
                }

                if (preferenceFields[field].equalsIgnoreCase("Number of Adults")) {
                    if (!validateMaxOccupancy(responses[0], responses[field], responses[field + 1])) field -= 2;
                }

                if (preferenceFields[field].equalsIgnoreCase("End Date")) {
                    if (!validateReservationDate(responses[0], responses[field], responses[field + 1])) field -= 2;
                }
            }
        }
        return responses;
    }

    private boolean validateNumericType(String value){
        try {
            Integer.parseInt(value);
            return true;
        } catch (Exception e) {
            System.out.println("ERROR | editReservation() > getPreferences(): Invalid Numeric Value");
        }
        return false;
    }

    private boolean validateReservationCode(String reservationCode) {
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        try {
            //Search for that reservation
            String query = "SELECT * " +
                    "FROM pwylezek.lab7_reservations " +
                    "WHERE CODE = ?;";

            preparedStatement = conn.prepareStatement(query);
            preparedStatement.setInt(1, Integer.parseInt(reservationCode));
            resultSet = preparedStatement.executeQuery();

            conn.commit();
            //Validate if found
            if (resultSet.next())
                return true;
            else {
                System.out.println("No Reservation found with that code.");
            }
        } catch (SQLException q) {
            try {
                System.out.println("ERROR | editReservation() > getPreferences() > validateReservationCode(): Failed Query, attempting Rollback...");
                conn.rollback();
                System.out.println("ERROR | editReservation() > getPreferences() > validateReservationCode(): Rollback Successful");
            } catch (SQLException rb) {
                System.out.println("ERROR | editReservation() > getPreferences() > validateReservationCode(): Rollback Failed");
            }
        } catch (NumberFormatException nfe) {
            System.out.println("ERROR | editReservation() > getPreferences() > validateReservationCode(): Invalid Reservation Code");
        } finally {
            if (resultSet != null) {
                try {
                    resultSet.close();
                } catch (SQLException e) {
                    System.out.println("ERROR | editReservation() > getPreferences() > validateReservationCode(): Failed to close ResultSet Object");
                }
            }
            if (preparedStatement != null) {
                try {
                    preparedStatement.close();
                } catch (SQLException e) {
                    System.out.println("ERROR | editReservation() > getPreferences() > validateReservationCode(): Failed to close Statement Object");
                }
            }
        }
        return false;
    }

    private boolean validateMaxOccupancy(String reservationCode, String children, String adults){
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        try {
            if(children.equalsIgnoreCase(noChangeInput) && adults.equalsIgnoreCase(noChangeInput)) return true;
            //Search for that reservation
            String query = "SELECT maxOcc, Kids, Adults, Room " +
                    "FROM pwylezek.lab7_rooms " +
                    "JOIN (SELECT Kids, Adults, Room FROM pwylezek.lab7_reservations WHERE CODE = ?) r " +
                    "ON r.Room = RoomCode";


            preparedStatement = conn.prepareStatement(query);
            preparedStatement.setInt(1, Integer.parseInt(reservationCode));
            resultSet = preparedStatement.executeQuery();

            int c = Integer.MAX_VALUE;
            int a = Integer.MAX_VALUE;
            if(resultSet.next()){
                c = children.equalsIgnoreCase(noChangeInput) ? resultSet.getInt("Kids") : Integer.parseInt(children);
                a = adults.equalsIgnoreCase(noChangeInput) ? resultSet.getInt("Adults") : Integer.parseInt(adults);
            }

            conn.commit();
            //Validate if found
            if(a+c <= resultSet.getInt("maxOcc")) return true;
            else throw new InputMismatchException("Too many occupants");
        } catch (SQLException q) {
            try {
                System.out.println("ERROR | editReservation() > getPreferences() > validateMaxOccupancy(): Failed Query, attempting Rollback...");
                conn.rollback();
                System.out.println("ERROR | editReservation() > getPreferences() > validateMaxOccupancy(): Rollback Successful");
            } catch (SQLException rb) {
                System.out.println("ERROR | editReservation() > getPreferences() > validateMaxOccupancy(): Rollback Failed");
            }
        } catch (NumberFormatException nfe) {
            System.out.println("ERROR | editReservation() > getPreferences() > validateMaxOccupancy(): Invalid Reservation Code");
        } catch (InputMismatchException nor){
            System.out.println("ERROR | editReservation() > getPreferences() > validateMaxOccupancy(): Too Many Occupants");
        }
        finally {
            if (resultSet != null) {
                try {
                    resultSet.close();
                } catch (SQLException e) {
                    System.out.println("ERROR | editReservation() > getPreferences() > validateMaxOccupancy(): Failed to close ResultSet Object");
                }
            }
            if (preparedStatement != null) {
                try {
                    preparedStatement.close();
                } catch (SQLException e) {
                    System.out.println("ERROR | editReservation() > getPreferences() > validateMaxOccupancy(): Failed to close Statement Object");
                }
            }
        }
        return false;
    }

    private boolean validateReservationDate(String reservationCode, String checkIn, String checkOut) {
        if(checkIn.equalsIgnoreCase(noChangeInput) && checkOut.equalsIgnoreCase(noChangeInput)){
            return true;
        } else{
            String[] reservationDates = getReservationDatesOnNoChange(reservationCode);
            checkIn = (reservationDates != null && noChangeInput.equalsIgnoreCase(checkIn)) ? reservationDates[0] : checkIn;
            checkOut = (reservationDates != null && noChangeInput.equalsIgnoreCase(checkOut)) ? reservationDates[1] : checkOut;
        }

        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        try {
            if(Date.valueOf(LocalDate.parse(checkIn)).compareTo(Date.valueOf(LocalDate.parse(checkOut))) >= 0){
                throw new DateTimeException("Check In Date on or after Check Out Date");
            }
            //[1]: Reservation Code
            //[2,4,6,7,8,10]: New check in
            //[3,5,8,9,11]: New check out
            String query = "SELECT CheckIn, Checkout FROM pwylezek.lab7_reservations " +
                    "WHERE Room = (SELECT Room FROM pwylezek.lab7_reservations WHERE CODE = ? ) " +
                    "AND ((CheckIn >= ? AND Checkout <= ?) " +
                        "OR (CheckIn < ? AND Checkout > ?) " +
                        "OR (CheckIn < ? AND Checkout > ? AND Checkout <= ?) " +
                        "OR (Checkout > ? AND CheckIn < ? AND CheckIn >= ?));";



            preparedStatement = conn.prepareStatement(query);
            preparedStatement.setInt(1, Integer.parseInt(reservationCode));


            int[] checkInSlots = {2, 4, 6, 7, 10};
            for(int slot : checkInSlots){
                try { preparedStatement.setDate(slot, java.sql.Date.valueOf(LocalDate.parse(checkIn))); }
                catch (Exception e) { System.out.println("ERROR | editReservation() > getPreferences() > validateReservationDate() > checkInSlots.forEach(): Failed to slot value."); }
            }


            int[] checkOutSlots = {3, 5, 8, 9, 11};
            for(int slot : checkOutSlots){
                try { preparedStatement.setDate(slot, java.sql.Date.valueOf(LocalDate.parse(checkOut))); }
                catch (Exception e) { System.out.println("ERROR | editReservation() > getPreferences() > validateReservationDate() > checkInSlots.forEach(): Failed to slot value."); }
            }

            resultSet = preparedStatement.executeQuery();

            conn.commit();

            //Validate if found
            if (!resultSet.next())
                return true;
            else {
                System.out.println("Current selection interferes with the following reserved dates:");
                while (resultSet.next()) {
                    System.out.printf("%s through %s\n",
                            resultSet.getDate("CheckIn"),
                            resultSet.getDate("Checkout"));
                }
            }
        } catch (SQLException q) {
            try {
                System.out.println("ERROR | editReservation() > getPreferences() > validateReservationDate(): Failed Query, attempting Rollback...");
                conn.rollback();
                System.out.println("ERROR | editReservation() > getPreferences() > validateReservationDate(): Rollback Successful");
            } catch (SQLException rb) {
                System.out.println("ERROR | editReservation() > getPreferences() > validateReservationDate(): Rollback Failed");
            }
        } catch (NumberFormatException nfe) {
            System.out.println("ERROR | editReservation() > getPreferences() > validateReservationDate(): Invalid Reservation Code");
        } catch (DateTimeException dte){
            System.out.println("ERROR | editReservation() > getPreferences() > validateReservationDate(): Check In Date on or after Check Out Date");
        }finally{
            if (resultSet != null) {
                try {
                    resultSet.close();
                } catch (SQLException e) {
                    System.out.println("ERROR | editReservation() > getPreferences() > validateReservationDate: Failed to close ResultSet Object");
                }
            }
            if (preparedStatement != null) {
                try {
                    preparedStatement.close();
                } catch (SQLException e) {
                    System.out.println("ERROR | editReservation() > getPreferences() > validateReservationDate(): Failed to close Statement Object");
                }
            }
        }
        return false;
    }

    private String[] getReservationDatesOnNoChange(String reservationCode) {
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        try {
            String checkInQuery = "SELECT CheckIn, Checkout " +
                    "FROM pwylezek.lab7_reservations " +
                    "WHERE CODE = ?";
            preparedStatement = conn.prepareStatement(checkInQuery);
            preparedStatement.setInt(1, Integer.parseInt(reservationCode));
            resultSet = preparedStatement.executeQuery();

            if(resultSet.next()){
                return new String[]{resultSet.getString("CheckIn"), resultSet.getString("Checkout")};
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (resultSet != null) {
                try { resultSet.close(); }
                catch (SQLException e) { System.out.println("ERROR | editReservation() > getPreferences() > getReservationDatesOnNoChange: Failed to close ResultSet Object"); }
            }
            if (preparedStatement != null) {
                try { preparedStatement.close(); }
                catch (SQLException e) { System.out.println("ERROR | editReservation() > getPreferences() > getReservationDatesOnNoChange: Failed to close Statement Object"); }
            }
        }
        return null;
    }
}

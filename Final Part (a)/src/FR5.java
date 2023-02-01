import java.sql.*;
import java.time.LocalDate;
import java.util.Scanner;

public class FR5 {

    private Connection conn;

    FR5(Connection conn) {
        this.conn = conn;
    }

    public void searchReservation() throws SQLException {
        Scanner inReader = new Scanner(System.in);

        System.out.println(
                "Please fill out the fields of what you want to search for, or leave blank for no preference:\n");

        boolean where = false;

        StringBuilder query = new StringBuilder();
        query.append("SELECT distinct * FROM pwylezek.lab7_reservations JOIN pwylezek.lab7_rooms on roomCode = room");

        StringBuilder strToAppend = new StringBuilder();

        System.out.println("First name:");
        String firstName = inReader.nextLine();

        if (!firstName.equalsIgnoreCase("")) {
            where = true;
            strToAppend.append(" FirstName LIKE ? AND");
        }

        System.out.println("Last name:");
        String lastName = inReader.nextLine();

        if (!lastName.equalsIgnoreCase("")) {
            where = true;
            strToAppend.append(" LastName LIKE ? AND");
        }

        System.out.println("CheckIn date (YYYY-MM-DD):");
        String inDate = checkDate();


        System.out.println("CheckOut date (YYYY-MM-DD):");
        String outDate = checkDate();

        System.out.println("Room code:");
        String roomCode = inReader.nextLine();

        if (!roomCode.equalsIgnoreCase("")) {
            where = true;
            strToAppend.append(" Room LIKE ? AND");
        }

        System.out.println("Reservation code:");
        String resCode = inReader.nextLine();

        if (!resCode.equalsIgnoreCase("")) {
            where = true;
            strToAppend.append(" CAST(CODE as CHAR(5)) LIKE '?' AND");
        }

        if (where) {
            query.append(" WHERE" + strToAppend.toString());
            query.delete(query.length() - 3, query.length());
        }

        conn.setAutoCommit(false);

        try (PreparedStatement searchPstmt = conn.prepareStatement(query.toString())) {

            int count = 1;

            if (!firstName.equalsIgnoreCase("")) {
                searchPstmt.setString(count, firstName);
                count++;
            }

            if (!lastName.equalsIgnoreCase("")) {
                searchPstmt.setString(count, lastName);
                count++;
            }

            if (!inDate.equalsIgnoreCase("")) {
                LocalDate newIn = LocalDate.parse(inDate);
                searchPstmt.setDate(count, java.sql.Date.valueOf(newIn));
                count++;
            }

            if (!outDate.equalsIgnoreCase("")) {
                LocalDate newOut = LocalDate.parse(outDate);
                searchPstmt.setDate(count, java.sql.Date.valueOf(newOut));
                count++;
            }

            if (!roomCode.equalsIgnoreCase("")) {
                searchPstmt.setString(count, roomCode);
                count++;
            }

            if (!resCode.equalsIgnoreCase("")) {
                searchPstmt.setInt(count, Integer.parseInt(resCode));
                count++;
            }

            System.out.println("\n");

            ResultSet searchSet = searchPstmt.executeQuery();

            printResults(searchSet);

            conn.commit();
        } catch (SQLException e) {
            conn.rollback();
        }

    }

    private void printResults(ResultSet r) throws SQLException {
        // Header
        System.out.printf("\u001B[1m\033[4m%-20s%-20s%-16s%-16s%-12s%-27s%-15s%-12s%-12s%-12s%-12s\u001B[0m\033[0m\n",
                "First Name",
                "Last Name",
                "Checkin Date",
                "Checkout Date",
                "Room Code",
                "Room Name",
                "Reservation #",
                "Rate",
                "Base Price",
                "Adults",
                "Kids");

        // Print Result Set
        while (r.next()) {
            System.out.printf("\033[2m%-20s%-20s%-16s%-16s%-12s%-27s%-15s%-12s%-12s%-12s%-12s\033[0m\n",
                    r.getString("FirstName"),
                    r.getString("LastName"),
                    r.getDate("CheckIn"),
                    r.getDate("CheckOut"),
                    r.getString("RoomCode"),
                    r.getString("RoomName"),
                    r.getInt("CODE"),
                    r.getInt("Rate"),
                    r.getInt("basePrice"),
                    r.getInt("Adults"),
                    r.getInt("Kids"));

        }
        System.out.println();
    }

    private String checkDate() {
        Scanner inReader = new Scanner(System.in);

        String dateToBeChecked = inReader.nextLine();
        while (true) {
            if (dateToBeChecked.matches("\\d{4}-\\d{2}-\\d{2}")) {
                String[] delimited = dateToBeChecked.split("-");
                if (Integer.parseInt(delimited[1]) > 13 || Integer.parseInt(delimited[1]) <= 0) {
                    System.out.println("Make sure that the months are between 1-12. Please use (YYYY-MM-DD).");
                    System.out.println("New date (YYYY-MM-DD):");
                } else if (Integer.parseInt(delimited[2]) > 32 || Integer.parseInt(delimited[2]) <= 0) {
                    System.out.println("Make sure that the days are between 1-31 Please use (YYYY-MM-DD).");
                    System.out.print("New date (YYYY-MM-DD):");
                } else {
                    return dateToBeChecked;
                }
            }
            else if(dateToBeChecked.equalsIgnoreCase("")){
                return dateToBeChecked;
            }
            else {
                System.out.println("Format incorrect. Please use (YYYY-MM-DD).");
                System.out.println("New date (YYYY-MM-DD):");
            }
            dateToBeChecked = inReader.nextLine();
        }
    }

}

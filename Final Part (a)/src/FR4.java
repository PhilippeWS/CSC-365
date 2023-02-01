import java.sql.*;
import java.util.Scanner;

public class FR4 {

    private final Connection conn;
    private String query = "DELETE FROM pwylezek.lab7_reservations WHERE CODE = ?;";

    FR4(Connection conn) { this.conn = conn; }

    public void cancelReservation(){
        PreparedStatement preparedStatement = null;
        try {
            conn.setAutoCommit(false);
            String response = getPreferences();
            if(response == null) throw new NullPointerException();

            preparedStatement = conn.prepareStatement(query);
            preparedStatement.setInt(1, Integer.parseInt(response));
            int changed = preparedStatement.executeUpdate();

            System.out.format("\n%s Reservation(s) deleted: %d Removed.\n", response, changed);
            conn.commit();

        } catch (SQLException q) {
            try {
                System.out.println("ERROR | cancelReservation: Failed Query, attempting Rollback...");
                conn.rollback();
                System.out.println("ERROR | cancelReservation: Rollback Successful");
            } catch (SQLException rb) {
                System.out.println("ERROR | cancelReservation: Rollback Failed");
            }
        }catch (NullPointerException npe){
            System.out.println("\nReservation deletion canceled.\n");
        }
        finally {
            if (preparedStatement != null) {
                try { preparedStatement.close(); }
                catch (SQLException e) { System.out.println("ERROR | cancelReservation() > validateReservationCode(): Failed to close Statement Object"); }
            }
            if (this.conn != null) {
                try { this.conn.close(); }
                catch (SQLException e) { System.out.println("ERROR | cancelReservation() > validateReservationCode(): Failed to close ResultSet Object"); }
            }
        }

    }

    private String getPreferences(){
        Scanner keyboard = new Scanner(System.in);
        String response;

        System.out.println("Enter Code of the Reservation you'd like to delete (\033[3m(C)ancel\033[0m to cancel):");
        response = keyboard.nextLine();

        if (response.equalsIgnoreCase("cancel") || response.equalsIgnoreCase("c")) {
            System.out.println("No reservation changed.");
        } else if (validateReservationCode(response)) {
            System.out.println("Are you sure you want to delete the reservation for " + response + "?");
            System.out.println("Enter: (Y)ES | (N)O");
            String confirm = keyboard.nextLine();
            if(confirm.equalsIgnoreCase("No") || confirm.equalsIgnoreCase("N")) return null;
        }

        return response;
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
            else{
                System.out.println("ERROR | cancelReservation() > validateReservationCode(): No Reservation Found with that Code");
            }
        } catch (SQLException q) {
            try {
                System.out.println("ERROR | cancelReservation() > validateReservationCode(): Failed Query, attempting Rollback...");
                conn.rollback();
                System.out.println("ERROR | cancelReservation() > validateReservationCode(): Rollback Successful");
            } catch (SQLException rb) {
                System.out.println("ERROR | cancelReservation() > validateReservationCode(): Rollback Failed");
            }
        }catch (NumberFormatException nfe){
            System.out.println("ERROR | cancelReservation() > validateReservationCode(): Invalid Reservation Code");
        } finally {
            if (resultSet != null) {
                try { resultSet.close(); }
                catch (SQLException e) { System.out.println("ERROR | cancelReservation() > validateReservationCode(): Failed to close ResultSet Object"); }
            }
            if (preparedStatement != null) {
                try { preparedStatement.close(); }
                catch (SQLException e) { System.out.println("ERROR | cancelReservation() > validateReservationCode(): Failed to close Statement Object"); }
            }
        }
        return false;
    }

}

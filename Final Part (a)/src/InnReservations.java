import java.sql.*;
import java.util.InputMismatchException;
import java.util.Scanner;

public class InnReservations {
    public static void main(String[] args) throws SQLException {
        int inputNum = -1;
        Scanner keyboard = new Scanner(System.in);
        System.out.flush();

        while (inputNum != 0) {
            System.out.println("----------------------------------------------");
            System.out.println("Select one of the following:");
            System.out.println("0: Quit.");
            System.out.println("1: Rooms and Rates.");
            System.out.println("2: Reservations.");
            System.out.println("3: Reservation Change.");
            System.out.println("4: Reservation Cancellation.");
            System.out.println("5: Detailed Reservation Information.");
            System.out.println("6: Revenue.");
            System.out.println("----------------------------------------------");

            try {
                inputNum = Integer.parseInt(keyboard.nextLine());
                if (inputNum > 6 || inputNum < 0)
                    throw new InputMismatchException();
            } catch (Exception e) {
                System.out.println("Please enter a valid option.");
                inputNum = -1;
            }

            Connection connection = getConnection();
            if (connection != null) {
                switch (inputNum) {
                    case 0:
                        System.out.println("Quit\n");
                        try
                        {
                            connection.close();
                        }catch(SQLException sqle)
                        {
                            System.out.println("");
                        }
                        break;
                    case 1:
                        System.out.println("Rooms and Rates\n");
                        new FR1(connection).popularRooms();
                        break;
                    case 2:
                        System.out.println("Make Reservation\n");
                        new FR2(connection).makeReservation();
                        break;
                    case 3:
                        new FR3(connection).editReservation();
                        break;
                    case 4:
                        System.out.println("Reservation Cancellation\n");
                        new FR4(connection).cancelReservation();
                        break;
                    case 5:
                        System.out.println("Detailed Reservation Information\n");
                        new FR5(connection).searchReservation();
                        break;
                    case 6:
                        System.out.println("Revenue\n");
                        new FR6(connection).getRevenue();
                        break;
                }
            }

        }

    }

    private static Connection getConnection() {
        int attempt = 0;
        while (attempt++ < 5) {
            try {
                return DriverManager.getConnection(System.getenv("HP_JDBC_URL"),
                        System.getenv("HP_JDBC_USER"),
                        System.getenv("HP_JDBC_PW"));
            } catch (SQLException sqlE) {
                System.out.printf("Failed attempt %d, retrying...\n", attempt);
            }
        }
        System.out.println("Failed to connect to database.");
        return null;
    }

}

import java.sql.*;

public class FR1 {

    private final Connection conn;

    private String query = "SELECT ROUND(SUM(DATEDIFF(CheckOut, CheckIn))/180, 2)*100 AS PopularityScore, \n" +
            "DATE_ADD(MAX(CheckOut), INTERVAL 1 DAY) AS NextAvailable,\n" +
            "DATEDIFF(MAX(Checkout), MAX(CheckIn)) AS LastStayLength, \n" +
            "pwylezek.lab7_rooms.*" +
            "FROM pwylezek.lab7_rooms\n" +
            "JOIN pwylezek.lab7_reservations ON RoomCode = Room\n" +
            "WHERE CheckIn BETWEEN DATE_SUB(CURDATE(), INTERVAL 180 DAY) AND CURDATE()\n" +
            "GROUP BY Room\n" +
            "ORDER BY PopularityScore DESC;";

    FR1(Connection conn) {
        this.conn = conn;
    }

    public void popularRooms() {
        Statement statement = null;
        ResultSet resultSet = null;
        try {
            conn.setAutoCommit(false);
            statement = conn.createStatement();
            resultSet = statement.executeQuery(query);
            printResults(resultSet);
            conn.commit();
        } catch (SQLException q) {
            try {
                System.out.println("ERROR | popularRooms(): Failed Query, attempting Rollback...");
                conn.rollback();
                System.out.println("ERROR | popularRooms(): Rollback Successful");
            } catch (SQLException rb) {
                System.out.println("ERROR | popularRooms(): Rollback Failed");
            }
        } finally {
            if (resultSet != null) {
                try { resultSet.close(); }
                catch (SQLException e) { System.out.println("ERROR | popularRooms(): Failed to close ResultSet Object"); }
            }
            if (statement != null) {
                try { statement.close(); }
                catch (SQLException e) { System.out.println("ERROR | popularRooms(): Failed to close Statement Object"); }
            }
            if (this.conn != null) {
                try { conn.close(); }
                catch (SQLException e) { System.out.println("ERROR | popularRooms(): Failed to close Connection Object"); }
            }
        }
    }

    private void printResults(ResultSet r){
        try{
            //Header
            System.out.printf("\u001B[1m\033[4m%-19s%-17s%-19s%-12s%-27s%-7s%-11s%-10s%-13s%-14s\u001B[0m\033[0m\n",
                    "Popularity Score",
                    "Next Available",
                    "Last Stay Length",
                    "Room Code",
                    "Room Name",
                    "Beds",
                    "Bed Type",
                    "Max Occ",
                    "Base Price",
                    "Decor"
            );

            //Print Result Set
            while (r.next()) {
                System.out.printf("\033[2m%-19s%-17s%-19s%-12s%-27s%-7s%-11s%-10s%-13s%-14s\033[0m\n",
                        r.getInt("PopularityScore"),
                        r.getDate("NextAvailable"),
                        r.getInt("LastStayLength"),
                        r.getString("RoomCode"),
                        r.getString("RoomName"),
                        r.getInt("Beds"),
                        r.getString("bedType"),
                        r.getInt("maxOcc"),
                        r.getInt("basePrice"),
                        r.getString("decor"));
            }
            System.out.println();
        }catch (SQLException rse){
            System.out.println("ERROR | popularRooms() > printResults(): Failed to retrieve results.");
        }

    }
    

}

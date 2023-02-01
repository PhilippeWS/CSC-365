import java.sql.*;
import java.util.ArrayList;

public class FR6 {

    private final Connection conn;
    private final String baseQuery =
            "SELECT Room, " +
                    "MONTHNAME(MAX(Checkout)) AS Month, YEAR(MAX(Checkout)) AS Year, " +
                    "ROUND(SUM(DATEDIFF(Checkout,CheckIn)*Rate),2) AS RoomPerMonthRevenue " +
            "FROM pwylezek.lab7_reservations " +
            "GROUP BY Room, MONTH(Checkout), YEAR(Checkout)" +
            "HAVING YEAR(MAX(Checkout)) = YEAR(CURDATE())" +
            "ORDER BY Room, MONTH(Checkout), Year";

    private final String subQueryYearlyRevenue =
            "WITH MRR AS( " + baseQuery + " ) " +
            "SELECT Room, ROUND(SUM(RoomPerMonthRevenue),2) AS YearlyRevenue " +
            "FROM MRR " +
            "GROUP BY Room;";

    private final String subQueryMonthlyTotalRevenue =
            "WITH MRR AS( " + baseQuery + " ) " +
            "SELECT Month, ROUND(SUM(RoomPerMonthRevenue),2) AS TotalPerMonthRevenue " +
            "FROM MRR " +
            "GROUP BY Month;";

    FR6(Connection conn) {
        this.conn = conn;
    }

    public void getRevenue() throws SQLException {

        Statement sqlBaseQuery = null;
        Statement sqlSubQueryYearlyRevenue = null;
        Statement sqlSubQueryMonthlyTotalRevenue = null;

        ResultSet resultSetBaseQuery = null;
        ResultSet resultSetSubQueryYearlyRevenue = null;
        ResultSet resultSetSubQueryMonthlyTotalRevenue = null;

        try{
            conn.setAutoCommit(false);

            sqlBaseQuery = conn.createStatement();
            sqlSubQueryYearlyRevenue = conn.createStatement();
            sqlSubQueryMonthlyTotalRevenue = conn.createStatement();

            resultSetBaseQuery = sqlBaseQuery.executeQuery(baseQuery);
            resultSetSubQueryYearlyRevenue = sqlSubQueryYearlyRevenue.executeQuery(subQueryYearlyRevenue);
            resultSetSubQueryMonthlyTotalRevenue = sqlSubQueryMonthlyTotalRevenue.executeQuery(subQueryMonthlyTotalRevenue);

            if(resultSetBaseQuery.next() && resultSetSubQueryYearlyRevenue.next() && resultSetSubQueryMonthlyTotalRevenue.next()){
                ArrayList<String[]> result = new ArrayList<>();

                int iterator = 1;
                String[] roomResult = new String[14];
                roomResult[0] = resultSetBaseQuery.getString("Room");
                //Add all monthly totals
               do{
                    if(iterator <= 12){
                        roomResult[iterator] = String.valueOf(resultSetBaseQuery.getDouble("RoomPerMonthRevenue"));
                        iterator++;
                    }else{
                        iterator = 2;
                        result.add(roomResult.clone());
                        roomResult = new String[14];
                        roomResult[0] = resultSetBaseQuery.getString("Room");
                        roomResult[1] = String.valueOf(resultSetBaseQuery.getDouble("RoomPerMonthRevenue"));
                        if(roomResult[0].equalsIgnoreCase("SAY")){
                            Double split = (double) Math.round((((double) resultSetBaseQuery.getInt("RoomPerMonthRevenue"))/12)*100)/100;
                            for(int i = 1; i <=12; i++){
                                roomResult[i] = String.valueOf(split);
                            }
                            iterator = 13;
                        }
                    }
                }while(resultSetBaseQuery.next());
                result.add(roomResult); //Add final row.

                //Add All Yearly Revenues
                iterator = 0;
                do{
                    result.get(iterator)[13] = String.valueOf(resultSetSubQueryYearlyRevenue.getDouble("YearlyRevenue"));
                    iterator++;
                }while(resultSetSubQueryYearlyRevenue.next());

                //Add All Monthly Aggregate Revenues
                iterator = 1;
                String[] finalRow = new String[14];
                finalRow[0] = "Monthly Total";
                finalRow[13] = "";
                do{
                    finalRow[iterator] = resultSetSubQueryMonthlyTotalRevenue.getString("TotalPerMonthRevenue");
                    iterator++;
                }while(resultSetSubQueryMonthlyTotalRevenue.next());
                result.add(finalRow);

                printResults(result);
            }

            conn.commit();
        } catch (SQLException e) {
            conn.rollback();
        }finally {
            if (resultSetBaseQuery != null) {
                try { resultSetBaseQuery.close(); }
                catch (SQLException e) { System.out.println("ERROR | popularRooms(): Failed to close ResultSet Object"); }
            }
            if (resultSetSubQueryYearlyRevenue != null) {
                try { resultSetSubQueryYearlyRevenue.close(); }
                catch (SQLException e) { System.out.println("ERROR | popularRooms(): Failed to close ResultSet Object"); }
            }
            if (resultSetSubQueryMonthlyTotalRevenue != null) {
                try { resultSetSubQueryMonthlyTotalRevenue.close(); }
                catch (SQLException e) { System.out.println("ERROR | popularRooms(): Failed to close ResultSet Object"); }
            }
            if (sqlBaseQuery != null) {
                try { sqlBaseQuery.close(); }
                catch (SQLException e) { System.out.println("ERROR | popularRooms(): Failed to close Statement Object"); }
            }
            if (sqlSubQueryYearlyRevenue != null) {
                try { sqlSubQueryYearlyRevenue.close(); }
                catch (SQLException e) { System.out.println("ERROR | popularRooms(): Failed to close Statement Object"); }
            }
            if (sqlSubQueryMonthlyTotalRevenue != null) {
                try { sqlSubQueryMonthlyTotalRevenue.close(); }
                catch (SQLException e) { System.out.println("ERROR | popularRooms(): Failed to close Statement Object"); }
            }
            if (this.conn != null) {
                try { conn.close(); }
                catch (SQLException e) { System.out.println("ERROR | popularRooms(): Failed to close Connection Object"); }
            }
        }
    }

    private void printResults(ArrayList<String[]> resultSet){
        System.out.printf("\u001B[1m\033[4m%-15s%-11s%-11s%-11s%-11s%-11s%-11s%-11s%-11s%-11s%-11s%-11s%-11s%-13s\u001B[0m\033[0m\n",
                "Room",
                "January",
                "February",
                "March",
                "April",
                "May",
                "June",
                "July",
                "August",
                "September",
                "October",
                "November",
                "December",
                "Yearly Total");

        for(int i = 0; i < resultSet.size(); i++){
            System.out.printf("%-15s\033[2m%-11s%-11s%-11s%-11s%-11s%-11s%-11s%-11s%-11s%-11s%-11s%-11s%-13s\033[0m\n",
                    resultSet.get(i)[0],
                    resultSet.get(i)[1],
                    resultSet.get(i)[2],
                    resultSet.get(i)[3],
                    resultSet.get(i)[4],
                    resultSet.get(i)[5],
                    resultSet.get(i)[6],
                    resultSet.get(i)[7],
                    resultSet.get(i)[8],
                    resultSet.get(i)[9],
                    resultSet.get(i)[10],
                    resultSet.get(i)[11],
                    resultSet.get(i)[12],
                    resultSet.get(i)[13]);
        }
    }
}

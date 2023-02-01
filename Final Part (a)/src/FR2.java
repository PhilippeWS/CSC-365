import java.sql.*;
import java.sql.Date;
import java.time.DateTimeException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.concurrent.TimeUnit;

public class FR2 {
    private final Connection conn;
    private static final String anyResponseValue = "Any";
    private ArrayList<String> queryAvailability = generateAvailabilityQueryTemplate();
    private ArrayList<String> querySuggestions = generateSuggestionQueryTemplate();
    private static final String[] preferenceFields = new String[]{"First Name", "Last Name", "Room Code", "Bed Type", "Number of Children", "Number of Adults", "Begin Date", "End Date"};

    FR2(Connection conn){
        this.conn = conn;
    }

    public void makeReservation() {
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        try {
            conn.setAutoCommit(false);
            Map<String,String> responses = getPreferences();

            if(responses == null) throw new NullPointerException();

            String realizedQuery = buildAvailabilityQuery(queryAvailability, responses);

            // Query to check for any available
            preparedStatement = conn.prepareStatement(realizedQuery);
            buildAvailabilityStatement(preparedStatement, responses);
            resultSet = preparedStatement.executeQuery();

            if(resultSet.next()){
                String[] choice = getAvailabilityReservation(resultSet, responses);
                if(choice != null){
                    insertReservation(choice, responses, true);
                }else{
                    throw new NullPointerException();
                }
            }else{
                System.out.println("No exact matches found, getting suggestions...");
                resultSet =  executeSuggestionQuery(responses);
                String[] choice = getSuggestionReservation(resultSet, responses);
                if(choice != null){
                    insertReservation(choice, responses, false);
                }else {
                    throw new NullPointerException();
                }
            }
            conn.commit();
        } catch (SQLException q) {
            try {
                System.out.println("ERROR | makeReservation(): Failed Query, attempting Rollback...");
                conn.rollback();
                System.out.println("ERROR | makeReservation(): Rollback Successful");
            } catch (SQLException rb) {
                System.out.println("ERROR | makeReservation(): Rollback Failed");
            }
        } catch (NullPointerException npe){
            System.out.println("Reservation creation canceled.");
        } finally {
            if (resultSet != null) {
                try { resultSet.close(); }
                catch (SQLException e) { System.out.println("ERROR | makeReservation(): Failed to close ResultSet Object"); }
            }
            if (preparedStatement != null) {
                try { preparedStatement.close(); }
                catch (SQLException e) { System.out.println("ERROR | makeReservation(): Failed to close Statement Object"); }
            }
            if (this.conn != null) {
                try { conn.close(); }
                catch (SQLException e) { System.out.println("ERROR | makeReservation(): Failed to close Connection Object"); }
            }
        }
    }


    //Helper Functions
    private static long dateDiff(Date d1, Date d2){
        long diffInMillies = Math.abs(d2.getTime() - d1.getTime());
        return TimeUnit.DAYS.convert(diffInMillies, TimeUnit.MILLISECONDS);
    }

    private int generateNewReservationCode(){
        int newReservationCode = -1;
        while(newReservationCode == -1){
            newReservationCode = (int) ((Math.random() * (999999 - 100000)) + 100000); //Range 100,000 - 999,999
            if(!validateReservationCode(String.valueOf(newReservationCode), true)) newReservationCode = -1;
        }
        return newReservationCode;
    }

    private Map<String, String> getPreferences() {
        Scanner keyboard = new Scanner(System.in);
        Map<String,String> responses = new HashMap<>();

        System.out.println("Booking a new Room (\033[3m(C)ancel\033[0m to cancel at anytime):");

        for (int field = 0; field < preferenceFields.length; field++) {
            String currentField = preferenceFields[field];
            if (currentField.contains("Name")) {
                System.out.printf("Enter %s:\n", currentField);
            } else if (currentField.equalsIgnoreCase("Room Code") || currentField.equalsIgnoreCase("Bed Type")) {
                System.out.printf("Enter desired %s (or \033[3mAny\033[0m):\n", currentField);
            } else {
                System.out.printf("Enter desired %s\n", currentField);
            }
            responses.put(currentField, keyboard.nextLine());

            if(responses.get(currentField).equalsIgnoreCase("Cancel") || responses.get(currentField).equalsIgnoreCase("C")) return null;

            if (currentField.contains("Number")) {
                if (!validateNumericType(responses.get(currentField))) field--;
            }

            if(currentField.equalsIgnoreCase("Room Code") && !responses.get(currentField).equalsIgnoreCase(anyResponseValue)){
                if(!validateRoomCode(responses.get(currentField))) field--;
            }

            if (currentField.equalsIgnoreCase("Bed Type") && !responses.get(currentField).equalsIgnoreCase(anyResponseValue)) {
                if (!validateBedType(responses.get(currentField))) field--;
            }

            if (currentField.equalsIgnoreCase("Number of Adults")) {
                if (!validateMaxOccupancy(responses.get(preferenceFields[field-1]), responses.get(currentField))) field -= 2;
            }

            if (currentField.equalsIgnoreCase("End Date")) {
                if (!validateReservationDate(responses.get(preferenceFields[field-1]), responses.get(currentField))) field -= 2;
            }
        }

        return responses;
    }


    //Availability Sequence
    private static ArrayList<String> generateAvailabilityQueryTemplate(){
        ArrayList<String> querySegments = new ArrayList<>();
        querySegments.add("WITH BR AS ( SELECT RoomCode FROM pwylezek.lab7_reservations JOIN pwylezek.lab7_rooms ON RoomCode = Room ");
        querySegments.add("WHERE maxOcc >= ? "); //1
        querySegments.add("AND RoomCode = ? "); //2
        querySegments.add("AND bedType = ? "); //3
        querySegments.add("AND ((CheckIn >= ? AND Checkout <= ?) " +
                "OR (CheckIn < ? AND Checkout > ?) " +
                "OR (CheckIn < ? AND Checkout > ? AND Checkout <= ?) " +
                "OR (Checkout > ? AND CheckIn < ? AND CheckIn >= ?))) "); //4 - 13
        querySegments.add("SELECT RoomCode, RoomName, Beds, bedType, basePrice, decor  FROM lab7_rooms r " +
                            "WHERE NOT EXISTS( " +
                            "SELECT * FROM BR " +
                            "WHERE BR.RoomCode = r.RoomCode) ");
        querySegments.add("AND maxOcc >= ? "); //14
        querySegments.add("AND RoomCode = ? "); //15
        querySegments.add("AND bedType = ?;"); //16
        return querySegments;
    }

    private String buildAvailabilityQuery(ArrayList<String> queryAvailability, Map<String, String> responses){
        int removed = 0;
        if(responses.get("Bed Type").equalsIgnoreCase(anyResponseValue)){
            queryAvailability.remove(8);
            queryAvailability.remove(3);
            removed = 1;
        }

        if(responses.get("Room Code").equalsIgnoreCase(anyResponseValue)){
            queryAvailability.remove(7-removed);
            queryAvailability.remove(2);
        }

        StringBuilder query = new StringBuilder();
        queryAvailability.forEach(query::append);

        return query.toString();
    }

    private void buildAvailabilityStatement(PreparedStatement preparedStatement, Map<String, String> responses) throws SQLException {
        int offset = 0;
        if(responses.get(preferenceFields[2]).equalsIgnoreCase(anyResponseValue) && responses.get(preferenceFields[3]).equalsIgnoreCase(anyResponseValue)){
            offset = 2;
        }else if(responses.get(preferenceFields[2]).equalsIgnoreCase(anyResponseValue) || responses.get(preferenceFields[3]).equalsIgnoreCase(anyResponseValue)){
            offset = 1;
        }

        if(offset == 0){
            preparedStatement.setString(2,responses.get(preferenceFields[2]));
            preparedStatement.setString(15,responses.get(preferenceFields[2]));
            preparedStatement.setString(3,responses.get(preferenceFields[3]));
            preparedStatement.setString(16,responses.get(preferenceFields[3]));
        }else if(offset == 1){
            String specifiedField = responses.get(preferenceFields[2]).equalsIgnoreCase(anyResponseValue) ?
                    responses.get(preferenceFields[3]) : responses.get(preferenceFields[2]);
            preparedStatement.setString(2,specifiedField);
            preparedStatement.setString(15-offset,specifiedField);
        }

        int maxOcc = Integer.parseInt(responses.get(preferenceFields[4])) + Integer.parseInt(responses.get(preferenceFields[5]));
        try {
            preparedStatement.setInt(1, maxOcc);
            preparedStatement.setInt(14-offset, maxOcc);
        } catch (Exception e) { System.out.println("ERROR | makeReservation() > setMaxOcc(): Failed to slot value."); }

        int[] checkInSlots = {4-offset, 6-offset, 8-offset, 9-offset, 12-offset};
        for(int slot : checkInSlots){
            try { preparedStatement.setDate(slot, java.sql.Date.valueOf(LocalDate.parse(responses.get(preferenceFields[6])))); }
            catch (Exception e) { System.out.println("ERROR | makeReservation() > checkInSlots.forEach(): Failed to slot value."); }
        }


        int[] checkOutSlots = {5-offset, 7-offset, 10-offset, 11-offset, 13-offset};
        for(int slot : checkOutSlots){
            try { preparedStatement.setDate(slot, java.sql.Date.valueOf(LocalDate.parse(responses.get(preferenceFields[7])))); }
            catch (Exception e) { System.out.println("ERROR | makeReservation() > checkInSlots.forEach(): Failed to slot value."); }
        }
    }

    private static ArrayList<String[]> printAvailabilityResults(ResultSet resultSet) throws SQLException {
        int rowNo = 1;
        //RoomCode, RoomName, Beds, bedType, basePrice, decor
        System.out.printf("  %-10s%-27s%-10s%-10s%-15s%-10s\n", "RoomCode", "RoomName", "Beds", "Bed Type", "Base Price", "Decor");
        ArrayList<String[]> rooms = new ArrayList<>();
        do{
            String[] row = new String[]{
                    resultSet.getString("RoomCode"),
                    resultSet.getString("RoomName"),
                    resultSet.getString("Beds"),
                    resultSet.getString("bedType"),
                    resultSet.getString("basePrice"),
                    resultSet.getString("decor")};
            System.out.printf("%d %-10s%-27s%-10s%-10s%-15s%-10s\n", rowNo++, row[0], row[1], row[2], row[3], row[4], row[5]);
            rooms.add(row);
        }while(resultSet.next());
        return rooms;
    }

    private String[] getAvailabilityReservation(ResultSet resultSet, Map<String, String> responses) throws SQLException {
        System.out.println("Please select one of the following options (\033[3m(C)ancel\033[0m to cancel):");
        ArrayList<String[]> rooms = printAvailabilityResults(resultSet);

        Scanner keyboard = new Scanner(System.in);
        String select;
        do {
            select = keyboard.nextLine();
            if (select.equalsIgnoreCase("Cancel") || select.equalsIgnoreCase("C")) {
                return null;
            }else if(!validateNumericType(select) && (Integer.parseInt(select) >= rooms.size() || Integer.parseInt(select) < 1)){
                System.out.println("Please Enter a Valid Option.");
            }else break;
        } while(true);

        //Select can be 1 to rooms.size()
        System.out.println("Confirm following Reservation ((Y)es to Confirm or \033[3m(C)ancel\033[0m to Cancel):");
        String[] option = rooms.get(Integer.parseInt(select)-1); //RoomCode, RoomName, Beds, Bed Type, Base Price, Decor
        System.out.printf("  %-10s%-27s%-10s%-19s%-17s%-11s%-9s\n", "RoomCode", "RoomName", "Bed Type", preferenceFields[4],
                preferenceFields[5], preferenceFields[6], preferenceFields[7]);
        System.out.printf("%s %-10s%-27s%-10s%-19s%-17s%-11s%-9s\n", select, option[0], option[1], option[3], responses.get(preferenceFields[4]),
                responses.get(preferenceFields[5]), responses.get(preferenceFields[6]), responses.get(preferenceFields[7]));

        do{
            select = keyboard.nextLine();
            if (select.equalsIgnoreCase("Cancel") || select.equalsIgnoreCase("C")) {
                return null;
            }else if(select.equalsIgnoreCase("Yes") || select.equalsIgnoreCase("Y")){
                String[] fullInformation = new String[option.length+1];
                fullInformation[0] = String.valueOf(generateNewReservationCode());
                for(int i = 1; i < option.length; i++) fullInformation[i] = option[i-1];
                return fullInformation; //New Reservation Code , Option[]...
            }else {
                System.out.println("Please Enter a Valid Option.");
            }
        }while (true);
    }


    //Suggestion Sequence
    private static ArrayList<String> generateSuggestionQueryTemplate(){
        ArrayList<String> querySegments = new ArrayList<>();

        querySegments.add("WITH GR AS (SELECT r.Room, RoomName, r.Checkout AS eOR1, r2.CheckIn AS sOR2, Beds, bedType, basePrice, decor " +
                "FROM pwylezek.lab7_reservations r " +
                    "JOIN pwylezek.lab7_reservations r2 ON r2.Code != r.Code AND r2.Room = r.Room AND r2.CheckIn > r.CheckOut " +
                    "JOIN pwylezek.lab7_rooms ON r.Room = RoomCode " +
                "WHERE maxOcc >= ? "); //1
        querySegments.add("AND RoomCode = ? "); //2
        querySegments.add("AND bedType = ? "); //3
        querySegments.add("AND r.Checkout >= ? " + //4
                            "AND DATEDIFF(r2.CheckIn, r.CheckOut) " +
                            "BETWEEN (DATEDIFF(?,?)+?) AND (DATEDIFF(?,?)+?) " + //Date Shift to be smaller // 5,6,7  8,9
                "ORDER BY r.Checkout) SELECT * FROM GR WHERE NOT EXISTS( " +
                        "SELECT eOR1, sOR2 FROM GR gr " +
                        "JOIN lab7_reservations r ON r.Room = gr.Room AND " +
                                "((CheckIn >= eOR1 AND Checkout <= sOR2) " +
                            "OR (CheckIn < eOR1 AND Checkout > sOR2) " +
                            "OR (CheckIn < eOR1 AND Checkout > eOR1 AND Checkout <= sOR2) " +
                            "OR (Checkout > sOR2 AND CheckIn < eOR1 AND CheckIn >= eOR1)) " +
                "WHERE gr.Room = GR.Room AND gr.eOR1 = GR.eOR1 AND gr.sOR2 = GR.sOR2) LIMIT 5;");
        return querySegments;
    }

    private String buildSuggestionQuery(ArrayList<String> querySuggestion, Map<String,String> responses){
        int removed = 0;
        if(responses.get(preferenceFields[2]).equalsIgnoreCase(anyResponseValue)){
            querySuggestion.remove(1);
            removed = 1;
        }

        if(responses.get(preferenceFields[3]).equalsIgnoreCase(anyResponseValue)){
            querySuggestion.remove(2-removed);
        }

        StringBuilder query = new StringBuilder();
        querySuggestion.forEach(query::append);

        return query.toString();
    }

    private void buildSuggestionStatement(PreparedStatement preparedStatement, Map<String, String> responses, int dateShift) throws SQLException {
        int maxOcc = Integer.parseInt(responses.get(preferenceFields[4])) + Integer.parseInt(responses.get(preferenceFields[5]));
        try {
            preparedStatement.setInt(1, maxOcc);
        } catch (Exception e) { System.out.println("ERROR | makeReservation() > buildSuggestionsStatement() > setMaxOcc(): Failed to slot value."); }

        int offset = 0;
        if(responses.get(preferenceFields[2]).equalsIgnoreCase("Any")) offset++; //Room Code
        else { preparedStatement.setString(2, responses.get(preferenceFields[2])); }

        if(responses.get(preferenceFields[3]).equalsIgnoreCase("Any")) offset++; //Bed Type
        else{ preparedStatement.setString(3-offset, responses.get(preferenceFields[3]));}

        int[] checkInSlots = {4-offset, 6-offset, 9-offset};
        for(int slot : checkInSlots){
            try { preparedStatement.setDate(slot, java.sql.Date.valueOf(LocalDate.parse(responses.get(preferenceFields[6])))); }
            catch (Exception e) { System.out.println("ERROR | makeReservation() > buildSuggestionQuery() > checkInSlots.forEach(): Failed to slot value."); }
        }

        int[] checkOutSlots = {5-offset, 8-offset};
        for(int slot : checkOutSlots){
            try { preparedStatement.setDate(slot, java.sql.Date.valueOf(LocalDate.parse(responses.get(preferenceFields[7])))); }
            catch (Exception e) { System.out.println("ERROR | makeReservation() > buildSuggestionQuery() > checkInSlots.forEach(): Failed to slot value."); }
        }

        try {
            preparedStatement.setInt(7-offset, dateShift);
            preparedStatement.setInt(10-offset, dateShift*-1);}
        catch (Exception e) { System.out.println("ERROR | makeReservation() > buildSuggestionQuery() > dateShift(): Failed to slot value."); }
    }

    private ResultSet executeSuggestionQuery(Map<String, String> responses){
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        try {
            int attempt = 0, dateShift = 0, resultSize = 0;
            do{
                System.out.println("Broadening search parameters...");
                if(attempt == 1){
                    if(!responses.get(preferenceFields[2]).equalsIgnoreCase(anyResponseValue))
                        responses.put(preferenceFields[2], anyResponseValue);
                }else if(attempt == 2){
                    if(!responses.get(preferenceFields[3]).equalsIgnoreCase(anyResponseValue))
                        responses.put(preferenceFields[3], anyResponseValue);
                }else if(attempt >= 3){
                    dateShift--;
                }
                String realizeQuery = buildSuggestionQuery(generateSuggestionQueryTemplate(), responses);

                preparedStatement = conn.prepareStatement(realizeQuery);
                buildSuggestionStatement(preparedStatement, responses, dateShift);
                resultSet = preparedStatement.executeQuery();
                if (resultSet != null) {
                    resultSet.last();
                    resultSize = resultSet.getRow();
                }
                attempt++;
            }while(resultSize < 5 && attempt != 10);
            resultSet.first();
            return resultSet;
        } catch (SQLException q) {
            try {
                System.out.println("ERROR | makeReservation(): Failed Query, attempting Rollback...");
                conn.rollback();
                System.out.println("ERROR | makeReservation(): Rollback Successful");
            } catch (SQLException rb) {
                System.out.println("ERROR | makeReservation(): Rollback Failed");
            }
        }
        return null;
    }

    private static ArrayList<String[]> printSuggestionResults(ResultSet resultSet) throws SQLException {
        int rowNo = 1;
        //r.Room, RoomName, r.Checkout AS eOR1, r2.CheckIn AS sOR2, Beds, bedType, basePrice, decor
        System.out.printf("  %-10s%-27s%-23s%-21s%-11s%-15s%-8s%-10s\n", "RoomCode", "RoomName", "Availability Starting", "Availability Ending", "Base Price", "Decor", "Beds", "Bed Type");
        ArrayList<String[]> rooms = new ArrayList<>();
        do{
            String[] row = new String[]{
                    resultSet.getString("Room"),
                    resultSet.getString("RoomName"),
                    resultSet.getString("eOR1"),
                    resultSet.getString("sOR2"),
                    resultSet.getString("basePrice"),
                    resultSet.getString("decor"),
                    resultSet.getString("Beds"),
                    resultSet.getString("bedType")};
            System.out.printf("%d %-10s%-27s%-23s%-21s%-11s%-15s%-8s%-10s\n", rowNo++, row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7]);
            rooms.add(row);
        }while(resultSet.next());
        try{
            if(resultSet != null){
                resultSet.close();
            }
        }catch (SQLException sqle){
            System.out.println("ERROR | PrintSuggestionResults(): Failed to close result set");
        }
        return rooms;
    }

    private String[] getSuggestionReservation(ResultSet resultSet, Map<String, String> responses) throws SQLException {
        System.out.println("Please select one of the following options (\033[3m(C)ancel\033[0m to cancel):");
        ArrayList<String[]> rooms = printSuggestionResults(resultSet);

        Scanner keyboard = new Scanner(System.in);
        String select;
        do {
            select = keyboard.nextLine();
            if (select.equalsIgnoreCase("Cancel") || select.equalsIgnoreCase("C")) {
                return null;
            }else if(!validateNumericType(select) && (Integer.parseInt(select) >= rooms.size() || Integer.parseInt(select) < 1)){
                System.out.println("Please Enter a Valid Option.");
            }else break;
        } while(true);

        String[] option = rooms.get(Integer.parseInt(select)-1); //RoomCode, RoomName, Beds, Bed Type, Base Price, Decor

        long selectedDiff = dateDiff(Date.valueOf(LocalDate.parse(option[3])), Date.valueOf(LocalDate.parse(option[2])));
        long responseDiff = dateDiff(Date.valueOf(LocalDate.parse(responses.get(preferenceFields[7]))), Date.valueOf(LocalDate.parse(responses.get(preferenceFields[6]))));
        if(selectedDiff > responseDiff){
            System.out.println("Select desired date Range:");
            int i = 1;
            for(; i <= selectedDiff; i++){
                System.out.printf("%d %s through %s\n", i, LocalDate.parse(option[2]).plusDays(i-1), LocalDate.parse(option[3]).minusDays(selectedDiff - responseDiff).plusDays(i-1));
            }

            do{
                select = keyboard.nextLine();
                if (select.equalsIgnoreCase("Cancel") || select.equalsIgnoreCase("C")) {
                    return null;
                }else if(!validateNumericType(select) || Integer.parseInt(select) > i-1){
                    System.out.println("Please Enter a Valid Option.");
                }else break;
            }while(true);
            option[2] = LocalDate.parse(option[2]).plusDays(Integer.parseInt(select)-1).toString();
            option[3] = LocalDate.parse(option[3]).minusDays(selectedDiff - responseDiff).plusDays(Integer.parseInt(select) -1).toString();
        }


        //Select can be 1 to rooms.size()
        System.out.println("Confirm following Reservation ((Y)es to Confirm or \033[3m(C)ancel\033[0m to Cancel):");
        System.out.printf("  %-10s%-27s%-23s%-21s%-11s%-15s%-8s%-10s\n", "RoomCode", "RoomName", "Availability Starting", "Availability Ending", "Base Price", "Decor", "Beds", "Bed Type");
        System.out.printf("%s %-10s%-27s%-23s%-21s%-11s%-15s%-8s%-10s\n", select, option[0], option[1], option[2], option[3], option[4], option[5], option[6], option[7]);

        do{
            select = keyboard.nextLine();
            if (select.equalsIgnoreCase("Cancel") || select.equalsIgnoreCase("C")) {
                return null;
            }else if(select.equalsIgnoreCase("Yes") || select.equalsIgnoreCase("Y")){
                String[] fullInformation = new String[option.length+1];
                fullInformation[0] = String.valueOf(generateNewReservationCode());
                for(int i = 1; i < option.length; i++) fullInformation[i] = option[i-1];
                return fullInformation; //New Reservation Code , Option[]...
            }else {
                System.out.println("Please Enter a Valid Option.");
            }
        }while (true);
    }

    //Insert New Reservation
    private void insertReservation(String[] choices, Map<String, String> responses, boolean exactMatchInsert){
        PreparedStatement preparedStatement = null;
        try {
            String insertStatement = "INSERT INTO pwylezek.lab7_reservations (CODE, Room, CheckIn, Checkout, Rate, LastName, FirstName, Adults, Kids) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)";
            preparedStatement = conn.prepareStatement(insertStatement);
            if(exactMatchInsert){
                preparedStatement.setInt(1, Integer.parseInt(choices[0]));
                preparedStatement.setString(2, choices[1]);
                preparedStatement.setDate(3, Date.valueOf(LocalDate.parse( responses.get(preferenceFields[6]))));
                preparedStatement.setDate(4, Date.valueOf(LocalDate.parse( responses.get(preferenceFields[7]))));
                preparedStatement.setFloat(5, Float.parseFloat(choices[5]));
                preparedStatement.setString(6,  responses.get(preferenceFields[1]));
                preparedStatement.setString(7,responses.get(preferenceFields[0]));
                preparedStatement.setInt(8,Integer.parseInt(responses.get(preferenceFields[5])));
                preparedStatement.setInt(9,Integer.parseInt(responses.get(preferenceFields[4])));
            }else{
                preparedStatement.setInt(1, Integer.parseInt(choices[0]));
                preparedStatement.setString(2,  choices[1]);
                preparedStatement.setDate(3, Date.valueOf(LocalDate.parse(choices[3])));
                preparedStatement.setDate(4, Date.valueOf(LocalDate.parse(choices[4])));
                preparedStatement.setFloat(5, Float.parseFloat(choices[5]));
                preparedStatement.setString(6, responses.get(preferenceFields[1]));
                preparedStatement.setString(7,responses.get(preferenceFields[0]));
                preparedStatement.setInt(8,Integer.parseInt(responses.get(preferenceFields[5])));
                preparedStatement.setInt(9,Integer.parseInt(responses.get(preferenceFields[4])));
            }

            int changed = preparedStatement.executeUpdate();

            System.out.format("Scheduled %d Following Reservation(s)\n", changed);
            conn.commit();
        } catch (SQLException q) {
            try {
                System.out.println("ERROR | insertReservation(): Failed Query, attempting Rollback...");
                conn.rollback();
                System.out.println("ERROR | insertReservation(): Rollback Successful");
            } catch (SQLException rb) {
                System.out.println("ERROR | insertReservation(): Rollback Failed");
            }
        } finally {
            if (preparedStatement != null) {
                try { preparedStatement.close(); }
                catch (SQLException e) { System.out.println("ERROR | insertReservation(): Failed to close Statement Object"); }
            }
        }
    }


    //Validation Methods
    private boolean validateReservationCode(String reservationCode, boolean validatingNew) {
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

            boolean foundReservation = resultSet.next();
            //Validate if found
            if(validatingNew && !foundReservation){
                return true;
            }else if(foundReservation)
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

    private boolean validateRoomCode(String roomCode){
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        try {
            String query = "SELECT * FROM pwylezek.lab7_rooms WHERE RoomCode = ?;";

            preparedStatement = conn.prepareStatement(query);
            preparedStatement.setString(1, roomCode);
            resultSet = preparedStatement.executeQuery();

            conn.commit();
            if(resultSet.next()){
                return true;
            }else{
                throw new InputMismatchException();
            }
        } catch (SQLException q) {
            try {
                System.out.println("ERROR | makeReservation() > getPreferences() > validateRoomCode(): Failed Query, attempting Rollback...");
                conn.rollback();
                System.out.println("ERROR | makeReservation() > getPreferences() > validateRoomCode(): Rollback Successful");
            } catch (SQLException rb) {
                System.out.println("ERROR | makeReservation() > getPreferences() > validateRoomCode(): Rollback Failed");
            }
        } catch (InputMismatchException ime){
            System.out.println("ERROR | makeReservation() > getPreferences() > validateRoomCode(): No Room Code Matches Desired Type");
        }
        finally {
            if (resultSet != null) {
                try {
                    resultSet.close();
                } catch (SQLException e) {
                    System.out.println("ERROR | makeReservation() > getPreferences() > validateRoomCode(): Failed to close ResultSet Object");
                }
            }
            if (preparedStatement != null) {
                try {
                    preparedStatement.close();
                } catch (SQLException e) {
                    System.out.println("ERROR | makeReservation() > getPreferences() > validateRoomCode(): Failed to close Statement Object");
                }
            }
        }
        return false;

    }

    private boolean validateNumericType(String value){
        try {
            Integer.parseInt(value);
            return true;
        } catch (Exception e) {
            System.out.println("ERROR | makeReservation() > getPreferences() >  getNumericType(): Invalid Numeric Value");
        }
        return false;
    }

    private boolean validateBedType(String bedType){
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        try {
            String query = "SELECT * FROM pwylezek.lab7_rooms WHERE bedType = ?;";

            preparedStatement = conn.prepareStatement(query);
            preparedStatement.setString(1, bedType);
            resultSet = preparedStatement.executeQuery();

            conn.commit();
            if (resultSet.next()){
                return true;
            }else{
                throw new InputMismatchException();
            }
        } catch (SQLException q) {
            try {
                System.out.println("ERROR | makeReservation() > getPreferences() > validateBedType(): Failed Query, attempting Rollback...");
                conn.rollback();
                System.out.println("ERROR | makeReservation() > getPreferences() > validateBedType(): Rollback Successful");
            } catch (SQLException rb) {
                System.out.println("ERROR | makeReservation() > getPreferences() > validateBedType(): Rollback Failed");
            }
        } catch (InputMismatchException ime){
            System.out.println("ERROR | makeReservation() > getPreferences() > validateBedType(): No bed type matches desired type");
        }
        finally {
            if (resultSet != null) {
                try {
                    resultSet.close();
                } catch (SQLException e) {
                    System.out.println("ERROR | makeReservation() > getPreferences() > validateBedType(): Failed to close ResultSet Object");
                }
            }
            if (preparedStatement != null) {
                try {
                    preparedStatement.close();
                } catch (SQLException e) {
                    System.out.println("ERROR | makeReservation() > getPreferences() > validateBedType(): Failed to close Statement Object");
                }
            }
        }
        return false;
    }

    private boolean validateMaxOccupancy(String children, String adults){
        Statement statement = null;
        ResultSet resultSet = null;
        try {
            String query = "SELECT MAX(maxOcc) AS maxMO FROM pwylezek.lab7_rooms;";

            statement = conn.createStatement();
            resultSet = statement.executeQuery(query);

            if(resultSet.next()){
                int totalPeople = Integer.parseInt(children) + Integer.parseInt(adults);
                if(totalPeople > resultSet.getInt("maxMO")){
                    throw new InputMismatchException("Too many occupants for any room");
                }else return true;
            }

            conn.commit();
        } catch (SQLException q) {
            try {
                System.out.println("ERROR | makeReservation() > getPreferences() > validateMaxOccupancy(): Failed Query, attempting Rollback...");
                conn.rollback();
                System.out.println("ERROR | makeReservation() > getPreferences() > validateMaxOccupancy(): Rollback Successful");
            } catch (SQLException rb) {
                System.out.println("ERROR | makeReservation() > getPreferences() > validateMaxOccupancy(): Rollback Failed");
            }
        } catch (NumberFormatException nfe) {
            System.out.println("ERROR | makeReservation() > getPreferences() > validateMaxOccupancy(): Invalid Reservation Code");
        } catch (InputMismatchException nor){
            System.out.println("ERROR | makeReservation() > getPreferences() > validateMaxOccupancy(): Too many occupants for any room, Use multiple bookings");
        }
        finally {
            if (resultSet != null) {
                try {
                    resultSet.close();
                } catch (SQLException e) {
                    System.out.println("ERROR | makeReservation() > getPreferences() > validateMaxOccupancy(): Failed to close ResultSet Object");
                }
            }
            if (statement != null) {
                try {
                    statement.close();
                } catch (SQLException e) {
                    System.out.println("ERROR | makeReservation() > getPreferences() > validateMaxOccupancy(): Failed to close Statement Object");
                }
            }
        }
        return false;
    }

    private boolean validateReservationDate(String checkIn, String checkOut) {
        try {
            Date ci = Date.valueOf(LocalDate.parse(checkIn));
            Date co = Date.valueOf(LocalDate.parse(checkOut));
            if(ci.compareTo(co) >= 0){
                throw new DateTimeException("Check In Date on or after Check Out Date");
            }else return true;
        } catch (DateTimeParseException dtpe){
            System.out.println("ERROR | makeReservation() > getPreferences() > validateReservationDate(): Invalid Date Format(s)");
        } catch (DateTimeException dte){
            System.out.println("ERROR | makeReservation() > getPreferences() > validateReservationDate(): Check In Date on or after Check Out Date");
        }
        return false;
    }
}

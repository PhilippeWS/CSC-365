import java.io.File;
import java.io.FileNotFoundException;
import java.util.*;
import java.util.stream.Collectors;

public class SchoolSearch {
    public static void main(String[] args) throws FileNotFoundException {
        List<Student> allStudents = readInStudents("./students.txt");
        beginPrompt(allStudents);
    }

    private static void beginPrompt(List<Student> allStudents){
        Scanner keyboard = new Scanner(System.in);
        boolean cont = true;
        while(cont){
            System.out.println("Enter a query: ");
            cont = analyzeQuery(keyboard.nextLine().split(" "), allStudents);
        }
    }

    private static boolean analyzeQuery(String[] query, List<Student> allStudents){
        try{
            if(query.length > 0 && query.length < 4) {
                if (query[0].equalsIgnoreCase("S:") || query[0].equalsIgnoreCase("Student:")) {
                    student(allStudents, query[1],query.length == 3 ? query[2] : null);
                } else if (query[0].equalsIgnoreCase("T:") || query[0].equalsIgnoreCase("Teacher:")) {
                    teacher(allStudents, query[1]);
                } else if (query[0].equalsIgnoreCase("B:") || query[0].equalsIgnoreCase("Bus:")) {
                    bus(allStudents, query[1]);
                } else if (query[0].equalsIgnoreCase("G:") || query[0].equalsIgnoreCase("Grade:")) {
                    grade(allStudents, Integer.parseInt(query[1]), query.length==3 ? query[2] : null);
                } else if (query[0].equalsIgnoreCase("A:") || query[0].equalsIgnoreCase("Average:")) {
                    average(allStudents, Integer.parseInt(query[1]));
                } else if (query[0].equalsIgnoreCase("I") || query[0].equalsIgnoreCase("Info")) {
                    info(allStudents);
                } else if (query[0].equalsIgnoreCase("Q") || query[0].equalsIgnoreCase("Quit")) {
                    System.out.println("Exiting...");
                    return false;
                } else System.out.println("Invalid Query, Please Re-Enter.");
            }else System.out.println("Invalid Query, Please Re-Enter.");
        }catch (Exception e){ System.out.println("Invalid Query, Please Re-Enter."); }

        return true;
    }


    private static void student(List<Student> allStudents, String lastname, String bus){
        if (bus != null){
            if((bus.equalsIgnoreCase("B") || bus.equalsIgnoreCase("Bus"))){
                allStudents.stream().filter(student -> student.getStLastName().equalsIgnoreCase(lastname)).
                        forEach(student -> System.out.println(student.getStLastName()
                                + " " + student.getStFirstName() + " " + student.getBus()));
            }else throw new IllegalArgumentException();
        } else {
            allStudents.stream().filter(student -> student.getStLastName().equalsIgnoreCase(lastname)).
                    forEach(student -> System.out.println(student.getStLastName()
                            + " " + student.getStFirstName() + " " + student.getGrade() + " " + student.getClassroom()
                            + " " + student.gettLastName() + " " + student.gettFirstName()));
        }
    }

    private static void teacher(List<Student> allStudents, String teacherLastname){
        allStudents.stream().filter(student -> student.gettLastName().equalsIgnoreCase(teacherLastname)).
                forEach(student -> System.out.println(student.getStLastName() + " " + student.getStFirstName()));
    }

    private static void bus(List<Student> allStudents, String bus){
        allStudents.stream().filter(student -> student.getBus() == Integer.parseInt(bus)).
                forEach(student -> System.out.println(student.getStLastName() + " " + student.getStFirstName() + " "
                        + student.getGrade() + " " + student.getClassroom()));
    }

    private static void grade(List<Student> allStudents, int grade, String specifier){
        if(grade < 0) throw new IllegalArgumentException();
        List<Student> gradeTargets = allStudents.stream().filter(student -> student.getGrade() == grade).collect(Collectors.toList());
        if (specifier == null) {
            gradeTargets.forEach(student -> System.out.println(student.getStLastName() + " " + student.getStFirstName()));
        } else {
            Student target;
            if(specifier.equalsIgnoreCase("H") || specifier.equalsIgnoreCase("High")){
                target = Collections.max(gradeTargets, Comparator.comparing(Student::getGpa));
            }else if(specifier.equalsIgnoreCase("L") || specifier.equalsIgnoreCase("Low")){
                target = Collections.min(gradeTargets, Comparator.comparing(Student::getGpa));
            }else throw new IllegalArgumentException();

            if(target != null) System.out.println(target.getStLastName() + " " + target.getStFirstName() + " " + target.getGpa() + " "
                    + target.gettLastName() + " " + target.gettFirstName() + " " + target.getBus());
        }
    }

    private static void average(List<Student> allStudents, int gradeTarget){
        OptionalDouble average = (allStudents.stream().filter(student -> student.getGrade() == gradeTarget).mapToDouble(Student::getGpa).average());
        System.out.printf(gradeTarget + " %.3f\n", average.isPresent()  ? average.getAsDouble() : 0.0);

    }

    private static void info(List<Student> allStudents){
        int[] counts = new int[7];
        allStudents.forEach(student -> counts[student.getGrade()]++);
        for(int i = 0; i<counts.length; i++) System.out.println(i + ": " + counts[i]);
    }

    private static List<Student> readInStudents(String fileName) throws FileNotFoundException {
        List<Student> allStudents = new ArrayList<>();
        Scanner fileReader = new Scanner(new File(fileName));

        while(fileReader.hasNext()){
            String[] fields = fileReader.nextLine().split(",");
            allStudents.add(new Student(fields[0], fields[1], Integer.parseInt(fields[2]),
                    Integer.parseInt(fields[3]), Integer.parseInt(fields[4]), Float.parseFloat(fields[5]), fields[6], fields[7]));
        }

        return allStudents;
    }
}






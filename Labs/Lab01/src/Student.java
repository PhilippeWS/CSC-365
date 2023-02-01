public class Student{
    private String stLastName;
    private String stFirstName;
    private int grade;
    private int classroom;
    private int bus;
    private float gpa;
    private String tLastName;
    private String tFirstName;

    public String getStLastName() {
        return stLastName;
    }

    public String getStFirstName() {
        return stFirstName;
    }

    public int getGrade() {
        return grade;
    }

    public int getClassroom() {
        return classroom;
    }

    public int getBus() {
        return bus;
    }

    public float getGpa() {
        return gpa;
    }

    public String gettLastName() {
        return tLastName;
    }

    public String gettFirstName() {
        return tFirstName;
    }

    public Student(String stLastName, String stFirstName , int Grade, int Classroom, int Bus,
                   float GPA, String TLastName, String TFirstName) {
        this.stLastName = stLastName;
        this.stFirstName = stFirstName;
        this.grade = Grade;
        this.classroom = Classroom;
        this.bus = Bus;
        this.gpa = GPA;
        this.tLastName = TLastName;
        this.tFirstName = TFirstName;
    }

    @Override
    public String toString(){
        return "Lastname: " + this.stLastName + ", Firstname: " + this.stFirstName  + ", Grade: " + this.grade
                + ", Classroom: " + this.classroom + ", Bus: " + this.bus + ", GPA: " + this.gpa +
                ", tLastName: " + this.tLastName + ", tFirstName: " + this.tFirstName;
    }
}
# Lab07
CSC365 Fall 2022\
FINAL PROJECT

The database UserName is under: **Philippe Wylezek-Serrano**\
    &nbsp;&nbsp;&nbsp;&nbsp;-pwylezek.lab7_reservations\
    &nbsp;&nbsp;&nbsp;&nbsp;-pwylezek.lab7_rooms

Project Breakdown:\
&nbsp;&nbsp;&nbsp;&nbsp;**InnReservation:** Taylor\
&nbsp;&nbsp;&nbsp;&nbsp;**FR1:** Taylor\
&nbsp;&nbsp;&nbsp;&nbsp;**FR2:** Philippe\
&nbsp;&nbsp;&nbsp;&nbsp;**FR3:** Philippe\
&nbsp;&nbsp;&nbsp;&nbsp;**FR4:** Taylor\
&nbsp;&nbsp;&nbsp;&nbsp;**FR5:** Taylor\
&nbsp;&nbsp;&nbsp;&nbsp;**FR6:** Taylor | Philippe \
&nbsp;&nbsp;&nbsp;&nbsp;**Initial project setup:** Philippe\
&nbsp;&nbsp;&nbsp;&nbsp;**Refactoring:** Philippe\
&nbsp;&nbsp;&nbsp;&nbsp;**Styling:** Taylor\
&nbsp;&nbsp;&nbsp;&nbsp;**ReadMe:** Taylor\
\
There will be a gitlog.txt file provided that will show the Git Log --Stats






## Authors

- [@Taylor Morgan](https://www.github.com/Taylor1818)
- [@Philippe Wylezek-Serrano](https://www.github.com/PhilippeWS)



## Environment Variables

To run this project, you will need to add the following environment variables to your .env file

`export HP_JDBC_URL=jdbc:mysql://db.labthreesixfive.com/<USERNAME>?autoReconnect=true\&useSSL=false\`\
`export HP_JDBC_USER=<USERNAME>`\
`export HP_JDBC_PW=<PASSWORD>`

**Add in own USERNAME and PASSWORD**

## Run Locally
Go to the project directory

```bash
cd Lab7/src
```

Run Commands
```bash
source .env 
javac *.java 
java -cp {PATH_TO_JAR}:. InnReservations
```
**Copy local path to the mysql-connector-java-8.0.16.jar into the {PATH_TO_JAR}**


## Bugs
The program assumes that the person that is reserving wants a date that is after the checkin date becuase of this it may not always return 5 results.\
Cost of the Total stay is not provided.
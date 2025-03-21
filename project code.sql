create database Project;
create table accident(
AccidentID int primary key,
DateTime datetime,
LocationID int,
WeatherConditionID int,
RoadConditionID int,
Severity varchar(25),
TotalVehiclesInvolved int,
TotalCasualties int,
foreign key (LocationID) references location(LocationID),
foreign key(WeatherConditionID) references weather(WeatherConditionID),
foreign key(RoadConditionID) references roadcondition(RoadConditionID));
 
create table hospital(
HospitalID int primary key,
HospitalName varchar(50),
LocationID int,
EmergencyResponseTime int,
Capacity int,
foreign key (LocationID) references location(LocationID));

create table location(
LocationID int primary key,
Street varchar(50),
City varchar(50),
District varchar(50),
State varchar(50),
Latitude float,
Longitude float,
AccidentHotspot bool);

create table lawenforcement(
PoliceReportID int primary key,
AccidentID int,
OfficerName varchar(25),
BadgeNumber varchar(25),
ActionTaken varchar(25),
ReportFiled bool,
foreign key (AccidentID) references accident(AccidentID));

create table casualty(
CasualtyID int primary key,
AccidentID int,
PersonType varchar(25),
Age int,
Gender varchar(25),
InjurySeverity varchar(25),
HospitalID int,
TreatmentGiven varchar(50),
foreign key(AccidentID) references accident(AccidentID),
foreign key(HospitalID) references hospital(HospitalID)) ;

create table roadcondition(
RoadConditionID int primary key,
SurfaceType varchar(25),
RoadWidth float,
SpeedLimit int,
LightingCondition varchar(25),
TrafficSignalWorking bool);

create table vehicle(
VehicleID int primary key,
AccidentID int,
VehicleType varchar(25),
VehicleMake varchar(25),
VehicleModel varchar(25),
VehicleYear int,
OwnerID int,
DriverAge int,
DriverGender varchar(25),
LicenseStatus varchar(25),
InsuranceStatus varchar(25),
foreign key (AccidentID) references accident(AccidentID),
foreign key (OwnerID) references owner(OwnerID));

create table owner(
OwnerID int primary key,
FullName varchar(25),
PhoneNumber int,
LicenseNumber varchar(25),
InsuranceCompany varchar(50),
Address varchar(100));

 create table weather(
WeatherConditionID int primary key,
WeatherCondition varchar(25),
Temperature float,
Visibility int,
WindSpeed float,
Humidity int);

create view severitypercentage as
select severity,
count(*)*100.0/(select count(*) from accident)as percentage
from accident
group by severity;
select * from severitypercentage ;

create view list_of_casualities as
SELECT C.CasualtyID, C.PersonType, C.Age, C.Gender, C.InjurySeverity, H.HospitalName
FROM casualty C
LEFT JOIN hospital H ON C.HospitalID = H.HospitalID;

select*from list_of_casualities;


create view common_road_surface as
SELECT R.SurfaceType, COUNT(A.AccidentID) AS TotalAccidents
FROM accident A
JOIN roadcondition R ON A.RoadConditionID = R.RoadConditionID
GROUP BY R.SurfaceType
ORDER BY TotalAccidents DESC
LIMIT 1;

select*from common_road_surface;


create view signal_failure_accidents as
SELECT COUNT(*) AS NoSignalAccidents
FROM accident A
JOIN roadcondition R ON A.RoadConditionID = R.RoadConditionID
WHERE R.TrafficSignalWorking = 0;

select*from signal_failure_accidents;

create view accidentlog as
SELECT A.AccidentID, A.DateTime, L.City, L.State, A.Severity
FROM accident A
JOIN location L ON A.LocationID = L.LocationID
WHERE L.City = 'New York' 
AND A.DateTime BETWEEN '2024-01-01' AND '2024-12-31';

select * from accidentlog;


DELIMITER //
CREATE PROCEDURE AllAccidentsWithLocation()
BEGIN
    SELECT A.AccidentID, A.DateTime, L.Street, L.City, L.State, A.Severity
    FROM accident A
    JOIN location L ON A.LocationID = L.LocationID;
END //
DELIMITER ;
CALL AllAccidentsWithLocation();



DELIMITER //
CREATE PROCEDURE AccidentCountBySeverity(IN severity_level VARCHAR(50))
BEGIN
    SELECT COUNT(*) AS TotalAccidents
    FROM accident
    WHERE Severity = severity_level;
END //
DELIMITER ;
CALL AccidentCountBySeverity('high'); 



DELIMITER //
CREATE PROCEDURE MostCommonWeatherCondition()
BEGIN
    SELECT W.WeatherCondition, COUNT(A.AccidentID) AS AccidentCount
    FROM accident A
    JOIN weather W ON A.WeatherConditionID = W.WeatherConditionID
    GROUP BY W.WeatherCondition
    ORDER BY AccidentCount DESC
    LIMIT 1;
END //
DELIMITER ;
CALL MostCommonWeatherCondition();



DELIMITER //
CREATE PROCEDURE AccidentsWithMoreThanXVehicles(IN min_vehicles INT)
BEGIN
    SELECT AccidentID, DateTime, TotalVehiclesInvolved, Severity
    FROM accident
    WHERE TotalVehiclesInvolved > min_vehicles;
END //
DELIMITER ;
CALL AccidentsWithMoreThanXVehicles(2); 



DELIMITER //
CREATE PROCEDURE HospitalWithHighestCapacity()
BEGIN
    SELECT HospitalName, Capacity
    FROM hospital
    ORDER BY Capacity DESC
    LIMIT 1;
END //
DELIMITER ;
CALL HospitalWithHighestCapacity();



DELIMITER //
CREATE PROCEDURE NightAccidentsCount()
BEGIN
    SELECT COUNT(*) AS NightAccidents
    FROM accident A
    JOIN roadcondition R ON A.RoadConditionID = R.RoadConditionID
    WHERE R.LightingCondition = 'No Lights' OR R.LightingCondition = 'Night';
END //
DELIMITER ;
CALL NightAccidentsCount();



DELIMITER //
CREATE PROCEDURE AccidentHotspotsByCity(IN city_name VARCHAR(100))
BEGIN
    SELECT L.Street, COUNT(A.AccidentID) AS AccidentCount
    FROM accident A
    JOIN location L ON A.LocationID = L.LocationID
    WHERE L.City = city_name
    GROUP BY L.Street
    ORDER BY AccidentCount DESC
    LIMIT 5;
END //
DELIMITER ;
CALL AccidentHotspotsByCity('New York'); 



DELIMITER //
CREATE PROCEDURE Top5OfficersByReports()
BEGIN
    SELECT OfficerName, COUNT(PoliceReportID) AS ReportsFiled
    FROM lawenforcement
    GROUP BY OfficerName
    ORDER BY ReportsFiled DESC
    LIMIT 5;
END //
DELIMITER ;
CALL Top5OfficersByReports();


DELIMITER //
CREATE PROCEDURE AverageResponseTimeByState(IN state_name VARCHAR(50))
BEGIN
    SELECT AVG(H.EmergencyResponseTime) AS AvgResponseTime
    FROM hospital H
    JOIN location L ON H.LocationID = L.LocationID  -- Assuming hospitals are linked to locations
    WHERE L.State = state_name;
END //
DELIMITER ;
CALL AverageResponseTimeByState('California') ;



DELIMITER //
CREATE PROCEDURE VehiclesByAccidentID(IN accident_id INT)
BEGIN
    SELECT V.VehicleID, V.VehicleType, V.VehicleMake, V.VehicleModel, V.VehicleYear
    FROM vehicle V
    WHERE V.AccidentID = accident_id;
END //
	DELIMITER ;
CALL VehiclesByAccidentID(10); 



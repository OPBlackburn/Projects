-- How many encounters did we have in 2019
SELECT * FROM healthcare.encounters
Where Start >= '2019-01-01'
And Start < '2020-01-01';

-- count of encounters from 2019
SELECT Count(*) FROM healthcare.encounters
Where Start >= '2019-01-01'
And Start < '2020-01-01';

-- distinct count of patients from 2019
SELECT Count(Distinct Patient) 
FROM healthcare.encounters
Where Start >= '2019-01-01'
And Start < '2020-01-01';

-- total patients ever registered, living or dead
SELECT Count(Distinct Patient) 
FROM healthcare.encounters;

-- using patients table to confirm accuracy of above results
SELECT count(*) FROM healthcare.patients;

-- what are the different encounterclasses?
SELECT distinct encounterclass FROM healthcare.encounters;

-- How many inpatient encounters did we have in 2019?
SELECT * FROM healthcare.encounters
Where Start >= '2019-01-01'
And Start < '2020-01-01'
And Encounterclass = 'inpatient';

SELECT count(*) FROM healthcare.encounters
Where Start >= '2019-01-01'
And Start < '2020-01-01'
And Encounterclass = 'inpatient';

-- How many ambulatory encounters did we have in 2019?
SELECT * FROM healthcare.encounters
Where Start >= '2019-01-01'
And Start < '2020-01-01'
And Encounterclass = 'ambulatory';

SELECT count(*) FROM healthcare.encounters
Where Start >= '2019-01-01'
And Start < '2020-01-01'
And Encounterclass = 'ambulatory';

-- reveiwing encounter classes (requirement is for every patient encountered in 2019 that was not an inpatient or admitted)
SELECT count(*) FROM healthcare.encounters
Where Start >= '2019-01-01'
And Start < '2020-01-01'
And Encounterclass IN ('ambulatory', 'wellness', 'outpatient', 'urgentcare');

--- How many encounters did we have before the year 2020?
-- confirm all records available before 2020
SELECT * FROM healthcare.encounters
Where Start < '2020-01-01';

SELECT Count(*) FROM healthcare.encounters
Where Start < '2020-01-01';

-- How many distinct patients did we treat before the year 2020?
SELECT Count(Distinct Patient) FROM healthcare.encounters
Where Start < '2020-01-01';

SELECT distinct patient
FROM healthcare.encounters
Where Start < '2020-01-01';

-- How many distinct encounter classes are documented in the HEALTHCARE.ENCOUNTERS table?
SELECT Count(distinct encounterclass) FROM healthcare.encounters;

-- How many inpatient and ambulatory encounters did we have before 2020?
SELECT count(*) FROM healthcare.encounters
Where Start < '2020-01-01'
And Encounterclass IN ('ambulatory', 'inpatient'); 

SELECT * FROM healthcare.encounters
Where Start < '2020-01-01'
And Encounterclass IN ('ambulatory', 'inpatient'); 

-- what is our patient mix by gender, race, and ethnicity?
SELECT Gender, Count(*) 
FROM healthcare.patients
group by Gender;

SELECT Race, Count(*) 
FROM healthcare.patients
group by Race;

SELECT Ethnicity, Count(*) 
FROM healthcare.patients
group by Ethnicity;

SELECT Gender, Race, Ethnicity, Count(*) 
FROM healthcare.patients
group by Gender, Race, Ethnicity
Order by 2;

-- what about age? patient doesnt actually have an 'age' column, but a birthdate column
SELECT ID, Birthdate, Floor(datediff(curdate(), Birthdate)/365.25) AS AGE
FROM healthcare.patients; 

-- how many states and zipcodes do we treat patients from?
SELECT distinct State FROM healthcare.patients;

-- Looks like we have alot of null zip codes
SELECT distinct ZIP, Count(*) FROM healthcare.patients
Group by ZIP;

-- lets see if we have an accurate data for county
SELECT distinct County, Count(*) FROM healthcare.patients
Group by County; -- yes we do

-- For inpatient encounter in 2019, what is the patient mix?
SELECT Gender, Race, Ethnicity, Count(*) as VOLUMES FROM healthcare.encounters Enc
Join healthcare.patients Pat On Enc.patient=Pat.ID
Where Start >= '2019-01-01'
And Start < '2020-01-01'
And Encounterclass = 'inpatient'
Group By Gender, Race, Ethnicity;

-- Given what is documented in this data set, how many different combinations of gender, race, and ethnicity exist in our patient population? Hint: Use the Group By.
SELECT Gender, Race, Ethnicity, Count(*) 
FROM healthcare.patients
group by Gender, Race, Ethnicity;

-- Which county had the highest number of patients?
SELECT distinct County, Count(*) FROM healthcare.patients
Group by County
Order by 2 desc;

-- How many inpatient encounters did we have in the entire dataset where the patient was at least 21 years old at the time of the encounter start?
SELECT 
COUNT(*) AS VOLUMES
FROM HEALTHCARE.ENCOUNTERS ENC
JOIN HEALTHCARE.patients PAT ON ENC.PATIENT=PAT.ID
WHERE FLOOR(DATEDIFF(START,BIRTHDATE)/365.25) >=21
AND ENCOUNTERCLASS='inpatient';

-- what about the list of patients who were 21 years old at the time of their first encounter?
SELECT 
Birthdate, Pat.Id, start
FROM HEALTHCARE.ENCOUNTERS ENC
JOIN HEALTHCARE.patients PAT ON ENC.PATIENT=PAT.ID
WHERE FLOOR(DATEDIFF(START,BIRTHDATE)/365.25) =21
AND ENCOUNTERCLASS='inpatient';
-- How many ER encounters did we have in 2019?
SELECT * FROM healthcare.encounters
WHERE Start >= '2019-01-01'
AND Start < '2020-01-01'
AND Encounterclass = 'emergency';

SELECT Count(*) AS ER_Volumes
FROM healthcare.encounters
WHERE Start >= '2019-01-01'
AND Start < '2020-01-01'
AND Encounterclass = 'emergency';

-- What conditioner were treated in those encounters?
SELECT *
FROM healthcare.encounters ENC
JOIN healthcare.conditions CON
ON ENC.Id = CON.encounter
WHERE ENC.Start >= '2019-01-01'
AND ENC.Start < '2020-01-01'
AND ENC.Encounterclass = 'emergency';

-- How many of each diagnosis?
SELECT CON.Description, Count(*)
FROM healthcare.encounters ENC
LEFT JOIN healthcare.conditions CON
ON ENC.Id = CON.encounter
WHERE ENC.Start >= '2019-01-01'
AND ENC.Start < '2020-01-01'
AND ENC.Encounterclass = 'emergency'
Group by CON.Description;

SELECT *
FROM healthcare.encounters ENC
LEFT JOIN healthcare.conditions CON
ON ENC.Id = CON.encounter
WHERE ENC.Start >= '2019-01-01'
AND ENC.Start < '2020-01-01'
AND ENC.Encounterclass = 'emergency';

-- What was the emergency throughput(difference between start and stop times) and how did that vary by condition treated?
SELECT *, timestampdiff(Minute, Start, Stop) Throughput_In_Min
FROM healthcare.encounters
WHERE Start >= '2019-01-01'
AND Start < '2020-01-01'
AND Encounterclass = 'emergency';

SELECT ID, Throughput_In_Min
From(
SELECT *, timestampdiff(Minute, Start, Stop) Throughput_In_Min
FROM healthcare.encounters
WHERE Start >= '2019-01-01'
AND Start < '2020-01-01'
AND Encounterclass = 'emergency'
)Throughput;

-- Average throughput for emergency encounters
SELECT AVG(Throughput_In_Min) AS AVG_Throughput
From(
	SELECT *, timestampdiff(Minute, Start, Stop) Throughput_In_Min
	FROM healthcare.encounters
	WHERE Start >= '2019-01-01'
	AND Start < '2020-01-01'
	AND Encounterclass = 'emergency'
	)Throughput;

SELECT Throughput.Description,
AVG(Throughput_In_Min) AS AVG_Throughput
From(
	SELECT ENC.ID, CON.Description,
    timestampdiff(Minute, ENC.Start, ENC.Stop) Throughput_In_Min
	FROM healthcare.encounters ENC
    Left JOIN healthcare.conditions CON
    ON ENC.ID = CON.Encounter
	WHERE ENC.Start >= '2019-01-01'
	AND ENC.Start < '2020-01-01'
	AND ENC.Encounterclass = 'emergency'
	)Throughput
    Group By Throughput.Description;

-- How many emergency encounters did we have before 2020?
SELECT * FROM healthcare.encounters
Where Start < '2020-01-01'
AND ENCOUNTERCLASS = 'emergency';

SELECT Count(*) FROM healthcare.encounters
Where Start < '2020-01-01'
AND ENCOUNTERCLASS = 'emergency';

-- Other than nulls (where no condition was documented), which condition was most documented for emergency encounters before 2020?
SELECT CON.DESCRIPTION
,COUNT(*) AS CONDITION_VOLUMES
FROM HEALTHCARE.ENCOUNTERS ENC
LEFT JOIN HEALTHCARE.CONDITIONS CON ON ENC.ID=CON.ENCOUNTER
WHERE ENC.START<'2020-01-01'
AND ENC.ENCOUNTERCLASS='emergency'
GROUP BY CON.DESCRIPTION
Order by 2 desc;

-- How many conditions for emergency encounters before 2020 had average ER throughputs above 100 minutes? Don't count nulls if they appear in your solution.
SELECT Throughput.Description,
AVG(Throughput_In_Min) AS AVG_Throughput
From(
	SELECT ENC.ID, CON.Description,
    timestampdiff(Minute, ENC.Start, ENC.Stop) Throughput_In_Min
	FROM healthcare.encounters ENC
    Left JOIN healthcare.conditions CON
    ON ENC.ID = CON.Encounter
	WHERE ENC.Start < '2020-01-01'
	AND ENC.Encounterclass = 'emergency'
	)Throughput
    Group By Throughput.Description
    Having AVG_Throughput>100;
    
    -- what is the total and average claim cost 2019?
SELECT SUM(TOTAL_CLAIM_COST) AS Total2019ClaimCost, 
AVG(TOTAL_CLAIM_COST) as Avg2019ClaimCost 
FROM healthcare.encounters
WHERE START>='2019-01-01'
AND START<'2020-01-01';

-- what is total payer coverage in 2019?
SELECT SUM(TOTAL_CLAIM_COST) AS Total2019ClaimCost, 
AVG(TOTAL_CLAIM_COST) as Avg2019ClaimCost,
SUM(PAYER_COVERAGE) AS Total2019PayerCoverage, 
AVG(PAYER_COVERAGE) AS Avg2019PayerCoverage
FROM healthcare.encounters
WHERE START>='2019-01-01'
AND START<'2020-01-01';

-- which encounter types had the highest cost?
SELECT encounterclass, 
SUM(TOTAL_CLAIM_COST) - SUM(PAYER_COVERAGE) AS Differ_Claim_to_Payer_Cov_TOT,
AVG(TOTAL_CLAIM_COST) - AVG(PAYER_COVERAGE) AS Differ_Claim_to_Payer_Cov_AVG
FROM healthcare.encounters
WHERE START>='2019-01-01'
AND START<'2020-01-01'
Group By  encounterclass
Order by 2 desc;

-- Which encounter class had the highest cost covered by payers?
SELECT Payer, encounterclass, SUM(TOTAL_CLAIM_COST) AS Total2019ClaimCost, 
AVG(TOTAL_CLAIM_COST) as Avg2019ClaimCost,
SUM(PAYER_COVERAGE) AS Total2019PayerCoverage, 
AVG(PAYER_COVERAGE) AS Avg2019PayerCoverage
FROM healthcare.encounters
WHERE START>='2019-01-01'
AND START<'2020-01-01'
Group By Payer, encounterclass
Order by 5 desc;

SELECT Payer, Name, encounterclass, 
SUM(TOTAL_CLAIM_COST) - SUM(PAYER_COVERAGE) AS Differ_Claim_to_Payer_Cov_TOT,
AVG(TOTAL_CLAIM_COST) - AVG(PAYER_COVERAGE) AS Differ_Claim_to_Payer_Cov_AVG
FROM healthcare.encounters ENC
JOIN healthcare.Payers PAY 
ON ENC.payer=Pay.Id
WHERE START>='2019-01-01'
AND START<'2020-01-01'
Group By Payer, Name, encounterclass
Order by 3;

-- What was the total claim cost for encounters before 2020? Return answer in whole dollars (round up to nearest dollar).
SELECT SUM(TOTAL_CLAIM_COST) AS TotalClaimCostBfor2020 
FROM healthcare.encounters
WHERE START<'2020-01-01';

-- What was the total payer coverage for encounters before 2020? Return answer in whole dollars (round up to nearest dollar).
SELECT SUM(PAYER_COVERAGE) AS TotalPayerCovBfor2020
FROM healthcare.encounters
WHERE START<'2020-01-01';

-- Which payer (per this training dataset) had the highest claim coverage percentage (total payer coverage/ total claim cost) for encounters before 2020?
SELECT Payer, Name,
100*(SUM(PAYER_COVERAGE)/SUM(TOTAL_CLAIM_COST)) AS Payer_Cov_Perc
FROM healthcare.encounters ENC
JOIN healthcare.Payers PAY 
ON ENC.payer=Pay.Id
WHERE START<'2020-01-01'
Group By Payer, Name
Order by 3 desc;

-- Which payer (per this training dataset) had the highest claim coverage percentage (total payer coverage / total claim cost) for ambulatory encounters before 2020?
SELECT Payer, Name,
100*(SUM(PAYER_COVERAGE)/SUM(TOTAL_CLAIM_COST)) AS Payer_Cov_Perc_Ambulatory
FROM healthcare.encounters ENC
JOIN healthcare.Payers PAY 
ON ENC.payer=Pay.Id
WHERE START<'2020-01-01'
AND ENC.ENCOUNTERCLASS='ambulatory'
GROUP BY PAYER, NAME
Order by 3 desc;

-- How many different types of procedures did we perform in 2019?
Select * From
		(SELECT DESCRIPTION, Count(*) As Total_Procedure
		FROM healthcare.procedures
		Where Date>='2019-01-01'
		And Date<'2020-01-01'
		Group By DESCRIPTION
        ) Procs
		Order by 2 desc;
        
-- How many procedures were performed accross each care setting?
SELECT Enc.ENCOUNTERCLASS, Count(*) as Total_Procs_Class
FROM healthcare.procedures Procs
Join healthcare.encounters Enc ON Procs.encounter=Enc.Id
Where Date>='2019-01-01'
And Date<'2020-01-01'
Group By Enc.ENCOUNTERCLASS
Order by 2 desc;

-- How many procedures were performed accross each care setting (inpatient/ambulatory)?
SELECT Enc.ENCOUNTERCLASS, Count(*) as Total_Procs_Class
FROM healthcare.procedures Procs
Join healthcare.encounters Enc ON Procs.encounter=Enc.Id
Where Date>='2019-01-01'
And Date<'2020-01-01'
And ENCOUNTERCLASS in ("inpatient", "ambulatory")
Group By Enc.ENCOUNTERCLASS;

-- Which organization performed the most inpatient procedures in 2019?
SELECT Org.Name, Enc.organization, Count(*) as Total_Procs2019
FROM healthcare.procedures Procs
Join healthcare.encounters Enc ON Procs.encounter=Enc.Id
Join healthcare.organizations Org ON Org.Id=Enc.organization
Where Date>='2019-01-01'
And Date<'2020-01-01'
And Enc.ENCOUNTERCLASS = "Inpatient"
Group By  Org.Name, Enc.organization;

-- How many Colonoscopy procedures were performed before 2020?
SELECT DESCRIPTION, Count(*) As Total_ProcsB42020
FROM healthcare.procedures
Where Date<'2020-01-01'
And DESCRIPTION = "Colonoscopy";

-- Compare our total number of procedures in 2018 to 2019. Did we perform more procedures in 2019 or less?
Select distinct(count(DESCRIPTION)) as Total_Procs2018
From healthcare.procedures
Where Date>='2018-01-01'
And Date<'2019-01-01';

Select distinct(count(DESCRIPTION)) as Total_Procs2019
From healthcare.procedures
Where Date>='2019-01-01'
And Date<'2020-01-01';

-- Which organizations (Using Organization ID) performed the most Auscultation of the fetal heart procedures before 2020? 
SELECT Enc.organization, Count(*) as Total_ProcsB42020
FROM healthcare.procedures Procs
Join healthcare.encounters Enc ON Procs.encounter=Enc.Id
Join healthcare.organizations Org ON Org.Id=Enc.organization
Where Date<'2020-01-01'
And Procs.DESCRIPTION Like "Auscu%"
Group By Enc.organization
Order by 2 desc;

-- Which race (in this training dataset) had the highest number of procedures done in 2019?
SELECT Pat.Race, Count(*) Total_Procs2019
FROM healthcare.patients Pat
Join healthcare.encounters Enc
On Pat.ID=Enc.PATIENT
Where Start >='2019-01-01'
And Start<'2020-01-01'
Group By Pat.Race;

-- Which race (in this training dataset) had the highest number of Colonoscopy procedures performed before 2020?
SELECT Pat.Race, Count(*) Total_Colon_ProcsB42020
FROM healthcare.patients Pat
Join healthcare.procedures Pro
On Pat.ID=Pro.PATIENT
Where Date <'2020-01-01'
And Pro.DESCRIPTION like "Colo%"
Group By Pat.Race

-- What observations were recorded and which has been the highest?
Select distinct description, count(*) As volumes
from Healthcare.observations
Group By description
Order by 2 desc;

-- How many patients had documented uncontrolled hypertension (140/90) at any time in 2018 & 2019?
SELECT Count(DISTINCT PATIENT)
FROM Healthcare.observations
WHERE (
(description = "Diastolic Blood Pressure" AND VALUE> 90)
OR (description = "Systolic Blood Pressure" AND VALUE> 140)
)
AND Date>='2018-01-01' 
AND Date<'2020-01-01';

-- Which providers treated patients with uncontrolled hypertension (140/90) in 2018 and 2019?
SELECT DISTINCT BP.PATIENT, PRO.Name AS ProviderName
FROM Healthcare.observations BP
LEFT JOIN Healthcare.Encounters ENC ON BP.PATIENT=ENC.PATIENT
									AND ENC.START>=BP.DATE
JOIN Healthcare.Providers PRO ON ENC.Provider=PRO.ID
WHERE (
(BP.description = "Diastolic Blood Pressure" AND BP.VALUE> 90)
OR (BP.description = "Systolic Blood Pressure" AND BP.VALUE> 140)
)
AND BP.Date>='2018-01-01' 
AND BP.Date<'2020-01-01';

--  What medications were given to patients with uncontrolled hypertension (140/90) before of after the diagnosis?
SELECT DISTINCT BP.PATIENT, MED.Description AS Medication
FROM Healthcare.observations BP
JOIN Healthcare.medications MED ON BP.Patient=MED.Patient
								AND MED.Start>=BP.Date
WHERE (
(BP.description = "Diastolic Blood Pressure" AND BP.VALUE> 90)
OR (BP.description = "Systolic Blood Pressure" AND BP.VALUE> 140)
)
AND BP.Date>='2018-01-01' 
AND BP.Date<'2020-01-01';

-- Volumes of medication given to above patients within same category
SELECT DISTINCT BP.PATIENT,  MED.Description, Count(MED.Description) AS MedicationVolume
FROM Healthcare.observations BP
JOIN Healthcare.medications MED ON BP.Patient=MED.Patient
								AND MED.Start>=BP.Date
WHERE (
(BP.description = "Diastolic Blood Pressure" AND BP.VALUE> 90)
OR (BP.description = "Systolic Blood Pressure" AND BP.VALUE> 140)
)
AND BP.Date>='2018-01-01' 
AND BP.Date<'2020-01-01'
Group By  MED.Description, BP.PATIENT;

-- If we used a lower cut off of 135/85 for hypertension than the 140/90, how many patients would have been documented hypertension at any time across 2018 or 2019?
SELECT Count(DISTINCT PATIENT)
FROM Healthcare.observations
WHERE (
(description = "Diastolic Blood Pressure" AND VALUE> 85)
OR (description = "Systolic Blood Pressure" AND VALUE> 135)
)
AND Date>='2018-01-01' 
AND Date<'2020-01-01';

-- What was the most commonly prescribed medication to the patients with hypertension (as identified as having a BP over 140/90 at any point in 2018 or 2019)?
SELECT DISTINCT MED.Description AS Medication, Count(MED.Description) AS MedicationVolume
FROM Healthcare.observations BP
JOIN Healthcare.medications MED ON BP.Patient=MED.Patient
								-- AND MED.Start>=BP.Date
WHERE (
(BP.description = "Diastolic Blood Pressure" AND BP.VALUE> 90)
OR (BP.description = "Systolic Blood Pressure" AND BP.VALUE> 140)
)
AND BP.Date>='2018-01-01' 
AND BP.Date<'2020-01-01'
Group By MED.Description
Order by 2 desc;

-- Which race (in this data set) had the highest total number of patients with a BP of 140/90 before 2020?
SELECT Pat.Race, Count(DISTINCT PAT.ID) as DISTINCT_PATIENTS
FROM Healthcare.observations BP
Join Healthcare.Patients PAT ON PAT.ID=BP.Patient
WHERE (
(description = "Diastolic Blood Pressure" AND VALUE> 90)
OR (description = "Systolic Blood Pressure" AND VALUE> 140)
) 
AND Date<'2020-01-01'
Group By Pat.Race;

-- Which race (in this training data set) had the highest percentage of blood pressure readings that were above 140/90 and taken before 2020?
SELECT TOTAL_BPS.RACE
,TOTAL_BPS.TOTAL_BP_READINGS
,POSITIVE_BPS.TOTAL_HIGH_BP_READINGS
,100*(POSITIVE_BPS.TOTAL_HIGH_BP_READINGS/TOTAL_BP_READINGS) AS PERCENT_HIGH_BPS
FROM
	(
-- determine total number of BP readings done by race
		SELECT PAT.RACE
		,COUNT(*) / 2 AS TOTAL_BP_READINGS -- we divide by two because otherwise we'd be counting readings double (due to us getting one row per diastolic and one row per systolic
		FROM HEALTHCARE.OBSERVATIONS  BP
		JOIN HEALTHCARE.PATIENTS PAT ON BP.PATIENT=PAT.ID
		WHERE 
			(									
				(DESCRIPTION = 'Diastolic Blood Pressure' )
			OR (DESCRIPTION = 'Systolic Blood Pressure' )
            )
			AND  DATE<'2020-01-01'
			GROUP BY PAT.RACE
			) TOTAL_BPS

LEFT JOIN (
-- determine number of BP readings where we have high blood pressure documented
	SELECT PAT.RACE
	,COUNT(*)/2 AS TOTAL_HIGH_BP_READINGS
	FROM HEALTHCARE.OBSERVATIONS  BP
	JOIN HEALTHCARE.PATIENTS PAT ON BP.PATIENT=PAT.ID
	WHERE 
		(
			(DESCRIPTION = 'Diastolic Blood Pressure' AND VALUE>90)
			OR (DESCRIPTION = 'Systolic Blood Pressure' AND VALUE>140)
		)
			AND  DATE<'2020-01-01'
			GROUP BY PAT.RACE
							) POSITIVE_BPS ON TOTAL_BPS.RACE=POSITIVE_BPS.RACE
		;

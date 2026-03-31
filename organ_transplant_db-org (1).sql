-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 15, 2026 at 05:58 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `organ_transplant_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `Match_Organ` (IN `donor_id` INT)   BEGIN
    DECLARE d_blood VARCHAR(5);
    DECLARE d_organ VARCHAR(50);

    -- Get donor info (force single row)
    SELECT Blood_Group, Organ_Type
    INTO d_blood, d_organ
    FROM Donor
    WHERE Donor_ID = donor_id
    LIMIT 1;

    -- Return best matching recipient
    SELECT *
    FROM Recipient
    WHERE Blood_Group = d_blood
      AND Organ_Required = d_organ
      AND Status = 'Waiting'
    ORDER BY Urgency_Level DESC, Registration_Date ASC
    LIMIT 1;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `donor`
--

CREATE TABLE `donor` (
  `Donor_ID` int(11) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Age` int(11) DEFAULT NULL CHECK (`Age` >= 18),
  `Blood_Group` varchar(5) NOT NULL,
  `Organ_Type` varchar(50) NOT NULL,
  `Hospital_ID` int(11) DEFAULT NULL,
  `Donation_Date` date DEFAULT NULL,
  `Status` varchar(20) DEFAULT 'Available'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `donor`
--

INSERT INTO `donor` (`Donor_ID`, `Name`, `Age`, `Blood_Group`, `Organ_Type`, `Hospital_ID`, `Donation_Date`, `Status`) VALUES
(1, 'Rahul Shetty', 25, 'O+', 'Kidney', 1, '2026-02-10', 'Available'),
(2, 'Arjun Nair', 32, 'A+', 'Liver', 2, '2026-02-15', 'Used'),
(3, 'Vikram Rao', 28, 'B+', 'Heart', 3, '2026-02-18', 'Used'),
(4, 'Aditya Sharma', 35, 'AB+', 'Kidney', 4, '2026-02-20', 'Used'),
(5, 'Kiran Bhat', 30, 'O-', 'Liver', 1, '2026-02-22', 'Used'),
(6, 'Rohan Kumar', 27, 'A-', 'Kidney', 2, '2026-02-23', 'Used'),
(7, 'Manish Gupta', 29, 'B-', 'Heart', 3, '2026-02-24', 'Used'),
(8, 'Sandeep Reddy', 24, 'O+', 'Kidney', 1, '2026-02-01', 'Available'),
(9, 'Akash Verma', 30, 'A+', 'Liver', 2, '2026-02-02', 'Used'),
(10, 'Nikhil Joshi', 28, 'B+', 'Heart', 3, '2026-02-03', 'Available'),
(11, 'Pranav Desai', 35, 'AB+', 'Kidney', 4, '2026-02-04', 'Available'),
(12, 'Harsh Patil', 29, 'O-', 'Liver', 1, '2026-02-05', 'Available'),
(13, 'Rohit Singh', 31, 'A-', 'Kidney', 2, '2026-02-06', 'Used'),
(14, 'Siddharth Mehta', 27, 'B-', 'Heart', 3, '2026-02-07', 'Used'),
(15, 'Abhishek Kulkarni', 33, 'O+', 'Kidney', 4, '2026-02-08', 'Used'),
(16, 'Varun Malhotra', 26, 'A+', 'Liver', 1, '2026-02-09', 'Available'),
(17, 'Aniket Pai', 34, 'B+', 'Heart', 2, '2026-02-10', 'Available'),
(18, 'Yash Thakur', 25, 'AB+', 'Kidney', 3, '2026-02-11', 'Available'),
(19, 'Deepak Mishra', 32, 'O-', 'Liver', 4, '2026-02-12', 'Used'),
(20, 'Suraj Menon', 29, 'A-', 'Kidney', 1, '2026-02-13', 'Used'),
(21, 'Neha Sharma', 36, 'B-', 'Heart', 2, '2026-02-14', 'Used'),
(22, 'Ananya Rao', 28, 'O+', 'Kidney', 3, '2026-02-15', 'Available'),
(23, 'Priya Nair', 30, 'A+', 'Liver', 4, '2026-02-16', 'Available'),
(24, 'Sneha Shetty', 27, 'B+', 'Heart', 1, '2026-02-17', 'Used'),
(25, 'Kavya Reddy', 33, 'AB+', 'Kidney', 2, '2026-02-18', 'Used'),
(26, 'Aishwarya Bhat', 26, 'O-', 'Liver', 3, '2026-02-19', 'Available'),
(27, 'Divya Menon', 35, 'A-', 'Kidney', 4, '2026-02-20', 'Available'),
(28, 'Pooja Verma', 24, 'B-', 'Heart', 1, '2026-02-21', 'Available'),
(29, 'Riya Patel', 31, 'O+', 'Kidney', 2, '2026-02-22', 'Available'),
(30, 'Meera Iyer', 29, 'A+', 'Liver', 3, '2026-02-23', 'Available'),
(31, 'Shruti Kulkarni', 34, 'B+', 'Heart', 4, '2026-02-24', 'Used'),
(32, 'Tanvi Deshpande', 27, 'AB+', 'Kidney', 1, '2026-02-25', 'Available'),
(33, 'Nisha Gupta', 32, 'O-', 'Liver', 2, '2026-02-26', 'Used'),
(34, 'Isha Joshi', 28, 'A-', 'Kidney', 3, '2026-02-27', 'Available'),
(35, 'Aditi Singh', 36, 'B-', 'Heart', 4, '2026-02-28', 'Available'),
(36, 'Simran Kaur', 25, 'O+', 'Kidney', 1, '2026-03-01', 'Used'),
(37, 'Anjali Mishra', 30, 'A+', 'Liver', 2, '2026-03-02', 'Available'),
(38, 'Swathi Pai', 29, 'B+', 'Heart', 3, '2026-03-03', 'Used'),
(39, 'Lakshmi Narayan', 33, 'AB+', 'Kidney', 4, '2026-03-04', 'Used'),
(40, 'Sanjay Kumar', 26, 'O-', 'Liver', 1, '2026-03-05', 'Used'),
(41, 'Gaurav Jain', 34, 'A-', 'Kidney', 2, '2026-03-06', 'Available'),
(42, 'Kartik Rao', 28, 'B-', 'Heart', 3, '2026-03-07', 'Available'),
(43, 'Mohit Agarwal', 31, 'O+', 'Kidney', 4, '2026-03-08', 'Used'),
(44, 'Tanishq Kapoor', 27, 'A+', 'Liver', 1, '2026-03-09', 'Available'),
(45, 'Vivek Chandra', 35, 'B+', 'Heart', 2, '2026-03-10', 'Available'),
(46, 'Preeti Nambiar', 29, 'AB+', 'Kidney', 3, '2026-03-11', 'Available'),
(47, 'Ritu Sharma', 32, 'O-', 'Liver', 4, '2026-03-12', 'Used'),
(48, 'Pooja Shetty', 24, 'A-', 'Kidney', 1, '2026-03-13', 'Used'),
(49, 'Shreya Nair', 30, 'B-', 'Heart', 2, '2026-03-14', 'Available'),
(50, 'Monika Reddy', 28, 'O+', 'Kidney', 3, '2026-03-15', 'Used'),
(51, 'Ashwin Bhat', 34, 'A+', 'Liver', 4, '2026-03-16', 'Available'),
(52, 'Tejas Naik', 26, 'B+', 'Heart', 1, '2026-03-17', 'Used'),
(53, 'Prakash Hegde', 33, 'AB+', 'Kidney', 2, '2026-03-18', 'Used'),
(54, 'Nitin Rao', 29, 'O-', 'Liver', 3, '2026-03-19', 'Available'),
(55, 'Bhavana Iyer', 31, 'A-', 'Kidney', 4, '2026-03-20', 'Used'),
(56, 'Deepika Sharma', 27, 'B-', 'Heart', 1, '2026-03-21', 'Available'),
(57, 'Keerthi Shetty', 35, 'O+', 'Kidney', 2, '2026-03-22', 'Used'),
(58, 'Madhu Gowda', 28, 'A+', 'Kidney', 3, '2026-03-23', 'Available'),
(59, 'Chirag Patel', 34, 'O-', 'Heart', NULL, '2026-03-24', 'Used'),
(60, 'Rakesh Naidu', 30, 'B+', 'Liver', 5, '2026-03-25', 'Available');

-- --------------------------------------------------------

--
-- Table structure for table `hospital`
--

CREATE TABLE `hospital` (
  `Hospital_ID` int(11) NOT NULL,
  `Hospital_Name` varchar(100) NOT NULL,
  `Location` varchar(100) DEFAULT NULL,
  `Contact_Number` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `hospital`
--

INSERT INTO `hospital` (`Hospital_ID`, `Hospital_Name`, `Location`, `Contact_Number`) VALUES
(1, 'KMC Attavar', 'Mangalore', '9876500001'),
(2, 'Manipal Kasturba Hospital', 'Manipal', '9876500002'),
(3, 'AJ Medical Institute', 'Mangalore', '9876500003'),
(4, 'Narayana Hrudayalaya', 'Bangalore', '9876500004'),
(5, 'Apollo Main Centre', 'Chennai', '9876500005'),
(6, 'Fortis Memorial', 'Mumbai', '9876500006'),
(8, 'Global Multispeciality', 'Chennai', '9876500008'),
(9, 'Columbia Asia Whitefield', 'Bangalore', '9876500009'),
(10, 'Aster RV Hospital', 'Bangalore', '9876500010'),
(11, 'LifeCare Advanced Center', 'Mysore', '9876500011'),
(12, 'Unity Health Plus', 'Udupi', '9876500012'),
(13, 'Apex Organ Institute', 'Manipal', '9876500013'),
(14, 'Green Cross Medical', 'Hubli', '9876500014'),
(15, 'Sunrise Multicare', 'Mysore', '9876500015'),
(16, 'Hope Transplant Center', 'Hubli', '9876500016'),
(17, 'Sparsh Hospital', 'Bangalore', '9876500017'),
(18, 'Medanta Regional', 'Delhi', '9876500018'),
(19, 'AIIMS Extension', 'Delhi', '9876500019'),
(20, 'Ruby Hall Clinic', 'Pune', '9876500020');

-- --------------------------------------------------------

--
-- Table structure for table `recipient`
--

CREATE TABLE `recipient` (
  `Recipient_ID` int(11) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Age` int(11) DEFAULT NULL,
  `Blood_Group` varchar(5) NOT NULL,
  `Organ_Required` varchar(50) NOT NULL,
  `Urgency_Level` int(11) DEFAULT NULL CHECK (`Urgency_Level` between 1 and 5),
  `Registration_Date` date DEFAULT NULL,
  `Hospital_ID` int(11) DEFAULT NULL,
  `Status` varchar(20) DEFAULT 'Waiting'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `recipient`
--

INSERT INTO `recipient` (`Recipient_ID`, `Name`, `Age`, `Blood_Group`, `Organ_Required`, `Urgency_Level`, `Registration_Date`, `Hospital_ID`) VALUES
(1, 'Megha Nair', 40, 'O+', 'Kidney', 5, '2026-01-01', 1),
(2, 'Priya Sharma', 50, 'A+', 'Liver', 4, '2026-01-05', 2),
(3, 'Karan Verma', 45, 'B+', 'Heart', 5, '2026-01-10', 3),
(4, 'Sneha Iyer', 38, 'AB+', 'Kidney', 3, '2026-01-15', 4),
(5, 'Anita Reddy', 55, 'O-', 'Liver', 5, '2026-01-02', 1),
(6, 'Ritesh Patil', 48, 'A-', 'Kidney', 4, '2026-01-08', 2),
(7, 'Farhan Ali', 60, 'B-', 'Heart', 5, '2026-01-12', 3),
(8, 'Divya Bhat', 42, 'O+', 'Kidney', 2, '2026-01-20', 1),
(9, 'Rahul Shetty', 36, 'A+', 'Kidney', 4, '2026-01-22', 2),
(10, 'Ananya Rao', 29, 'O+', 'Liver', 5, '2026-01-23', 3),
(11, 'Vikram Jain', 48, 'B+', 'Heart', 5, '2026-01-24', 4),
(12, 'Pooja Kulkarni', 34, 'AB+', 'Kidney', 3, '2026-01-25', 5),
(13, 'Suresh Naik', 55, 'O-', 'Liver', 5, '2026-01-26', 1),
(14, 'Neha Verma', 31, 'A-', 'Kidney', 4, '2026-01-27', 2),
(15, 'Arjun Patel', 42, 'B+', 'Heart', 5, '2026-01-28', 3),
(16, 'Kavya Nair', 26, 'O+', 'Kidney', 2, '2026-01-29', 4),
(17, 'Manoj Kumar', 50, 'A+', 'Liver', 5, '2026-01-30', 5),
(18, 'Ritika Shah', 38, 'AB-', 'Kidney', 4, '2026-01-31', 1),
(19, 'Deepak Mishra', 47, 'O+', 'Heart', 5, '2026-02-01', 2),
(20, 'Sneha Patil', 33, 'A+', 'Kidney', 3, '2026-02-02', 3),
(21, 'Amit Joshi', 41, 'B-', 'Liver', 4, '2026-02-03', 4),
(22, 'Isha Mehta', 28, 'AB+', 'Kidney', 2, '2026-02-04', 5),
(23, 'Ramesh Gowda', 58, 'O-', 'Heart', 5, '2026-02-05', 1),
(24, 'Tanvi Deshpande', 35, 'A-', 'Kidney', 3, '2026-02-06', 2),
(25, 'Nikhil Bansal', 44, 'B+', 'Liver', 4, '2026-02-07', 3),
(26, 'Divya Menon', 30, 'O+', 'Kidney', 2, '2026-02-08', 4),
(27, 'Sunil Reddy', 52, 'A+', 'Heart', 5, '2026-02-09', 5),
(28, 'Pallavi Joshi', 39, 'AB-', 'Kidney', 3, '2026-02-10', 1),
(29, 'Harish Rao', 46, 'B-', 'Liver', 4, '2026-02-11', 2),
(30, 'Aishwarya Pillai', 27, 'O+', 'Kidney', 2, '2026-02-12', 3),
(31, 'Sanjay Malhotra', 54, 'A-', 'Heart', 5, '2026-02-13', 4),
(32, 'Riya Arora', 32, 'AB+', 'Kidney', 3, '2026-02-14', 5),
(33, 'Mahesh Iyer', 49, 'O+', 'Liver', 4, '2026-02-15', 1),
(34, 'Kiran Kulkarni', 37, 'A+', 'Kidney', 3, '2026-02-16', 2),
(35, 'Rohit Khanna', 45, 'B+', 'Heart', 5, '2026-02-17', 3),
(36, 'Megha Joshi', 34, 'O-', 'Kidney', 4, '2026-02-18', 4),
(37, 'Vivek Singh', 51, 'A-', 'Liver', 5, '2026-02-19', 5),
(38, 'Nandini Roy', 29, 'AB-', 'Kidney', 2, '2026-02-20', 1),
(39, 'Prakash Shetty', 56, 'O+', 'Heart', 5, '2026-02-21', 2),
(40, 'Shruti Naidu', 31, 'A+', 'Kidney', 3, '2026-02-22', 3),
(41, 'Alok Verma', 43, 'B-', 'Liver', 4, '2026-02-23', 4),
(42, 'Irfan Khan', 48, 'O-', 'Heart', 5, '2026-02-24', 5),
(43, 'Pooja Arvind', 36, 'AB+', 'Kidney', 3, '2026-02-25', 1),
(44, 'Naveen Chandra', 52, 'A+', 'Liver', 5, '2026-02-26', 2),
(45, 'Sonal Gupta', 28, 'O+', 'Kidney', 2, '2026-02-27', 3),
(46, 'Rajat Kapoor', 47, 'B+', 'Heart', 5, '2026-02-28', 4),
(47, 'Lakshmi Narayan', 60, 'A-', 'Kidney', 5, '2026-03-01', 5),
(48, 'Sameer Khan', 40, 'O+', 'Liver', 4, '2026-03-02', 1),
(49, 'Ankit Agarwal', 35, 'AB-', 'Kidney', 3, '2026-03-03', 2),
(50, 'Bhavya Shah', 33, 'A+', 'Kidney', 2, '2026-03-04', 3),
(51, 'Chirag Mehta', 46, 'B+', 'Heart', 5, '2026-03-05', 4),
(52, 'Dinesh Kumar', 55, 'O-', 'Liver', 5, '2026-03-06', 5),
(53, 'Esha Malhotra', 29, 'AB+', 'Kidney', 2, '2026-03-07', 1),
(54, 'Farhan Ali', 42, 'A-', 'Heart', 5, '2026-03-08', 2),
(55, 'Gaurav Pandey', 48, 'O+', 'Liver', 4, '2026-03-09', 3),
(56, 'Heena Qureshi', 34, 'B-', 'Kidney', 3, '2026-03-10', 4),
(57, 'Imran Sheikh', 50, 'A+', 'Heart', 5, '2026-03-11', 5),
(58, 'Jyoti Desai', 31, 'O+', 'Kidney', 2, '2026-03-12', 1),
(59, 'Karthik R', 45, 'B+', 'Liver', 4, '2026-03-13', 2),
(60, 'Leena Fernandes', 38, 'AB-', 'Kidney', 3, '2026-03-14', 3);

-- --------------------------------------------------------

--
-- Table structure for table `transplant_record`
--

CREATE TABLE `transplant_record` (
  `Transplant_ID` int(11) NOT NULL,
  `Donor_ID` int(11) DEFAULT NULL,
  `Recipient_ID` int(11) DEFAULT NULL,
  `Transplant_Date` date DEFAULT NULL,
  `Hospital_ID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transplant_record`
--

INSERT INTO `transplant_record` (`Transplant_ID`, `Donor_ID`, `Recipient_ID`, `Transplant_Date`, `Hospital_ID`) VALUES
(1, 1, 1, '2026-02-25', 1),
(2, 2, 2, '2026-02-26', 2),
(3, 3, 3, '2026-02-27', 3),
(4, 4, 4, '2026-02-28', 4),
(5, 5, 5, '2026-03-01', 5),
(6, 6, 6, '2026-03-02', 1),
(7, 7, 7, '2026-03-03', 2),
(8, 8, 8, '2026-03-04', 3),
(9, 9, 9, '2026-03-05', 4),
(10, 10, 10, '2026-03-06', 5),
(11, 11, 11, '2026-03-07', 1),
(12, 12, 12, '2026-03-08', 2),
(13, 13, 13, '2026-03-09', 3),
(14, 14, 14, '2026-03-10', 4),
(15, 15, 15, '2026-03-11', 5),
(16, 16, 16, '2026-03-12', 1),
(17, 17, 17, '2026-03-13', 2),
(18, 18, 18, '2026-03-14', 3),
(19, 19, 19, '2026-03-15', 4),
(20, 20, 20, '2026-03-16', 5),
(21, 21, 21, '2026-03-17', 1),
(22, 22, 22, '2026-03-18', 2),
(23, 23, 23, '2026-03-19', 3),
(24, 24, 24, '2026-03-20', 4),
(25, 25, 25, '2026-03-21', 5),
(26, 26, 26, '2026-03-22', 1),
(27, 27, 27, '2026-03-23', 2),
(28, 28, 28, '2026-03-24', 3),
(30, 30, 30, '2026-03-26', 5),
(31, 59, 3, '2026-02-25', 8),
(32, 60, 5, '2026-02-27', 8);

--
-- Triggers `transplant_record`
--
DELIMITER $$
CREATE TRIGGER `check_donor_status` BEFORE INSERT ON `transplant_record` FOR EACH ROW BEGIN
    DECLARE donor_status VARCHAR(20);

    SELECT Status INTO donor_status
    FROM Donor
    WHERE Donor_ID = NEW.Donor_ID;

    IF donor_status = 'Used' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Donor already used!';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_donor_status` AFTER INSERT ON `transplant_record` FOR EACH ROW BEGIN
    UPDATE Donor
    SET Status = 'Used'
    WHERE Donor_ID = NEW.Donor_ID;

    UPDATE Recipient
    SET Status = 'Received'
    WHERE Recipient_ID = NEW.Recipient_ID;
END
$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `revert_status_on_delete` AFTER DELETE ON `transplant_record` FOR EACH ROW BEGIN
    UPDATE Donor
    SET Status = 'Available'
    WHERE Donor_ID = OLD.Donor_ID;

    UPDATE Recipient
    SET Status = 'Waiting'
    WHERE Recipient_ID = OLD.Recipient_ID;
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `donor`
--
ALTER TABLE `donor`
  ADD PRIMARY KEY (`Donor_ID`),
  ADD KEY `Hospital_ID` (`Hospital_ID`),
  ADD KEY `idx_donor_blood` (`Blood_Group`);

--
-- Indexes for table `hospital`
--
ALTER TABLE `hospital`
  ADD PRIMARY KEY (`Hospital_ID`);

--
-- Indexes for table `recipient`
--
ALTER TABLE `recipient`
  ADD PRIMARY KEY (`Recipient_ID`),
  ADD KEY `Hospital_ID` (`Hospital_ID`),
  ADD KEY `idx_recipient_blood` (`Blood_Group`),
  ADD KEY `idx_recipient_urgency` (`Urgency_Level`);

--
-- Indexes for table `transplant_record`
--
ALTER TABLE `transplant_record`
  ADD PRIMARY KEY (`Transplant_ID`),
  ADD KEY `Donor_ID` (`Donor_ID`),
  ADD KEY `Recipient_ID` (`Recipient_ID`),
  ADD KEY `Hospital_ID` (`Hospital_ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `donor`
--
ALTER TABLE `donor`
  MODIFY `Donor_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=62;

--
-- AUTO_INCREMENT for table `hospital`
--
ALTER TABLE `hospital`
  MODIFY `Hospital_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `recipient`
--
ALTER TABLE `recipient`
  MODIFY `Recipient_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT for table `transplant_record`
--
ALTER TABLE `transplant_record`
  MODIFY `Transplant_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `donor`
--
ALTER TABLE `donor`
  ADD CONSTRAINT `donor_ibfk_1` FOREIGN KEY (`Hospital_ID`) REFERENCES `hospital` (`Hospital_ID`) ON DELETE SET NULL;

--
-- Constraints for table `recipient`
--
ALTER TABLE `recipient`
  ADD CONSTRAINT `recipient_ibfk_1` FOREIGN KEY (`Hospital_ID`) REFERENCES `hospital` (`Hospital_ID`) ON DELETE SET NULL;

--
-- Constraints for table `transplant_record`
--
ALTER TABLE `transplant_record`
  ADD CONSTRAINT `transplant_record_ibfk_1` FOREIGN KEY (`Donor_ID`) REFERENCES `donor` (`Donor_ID`),
  ADD CONSTRAINT `transplant_record_ibfk_2` FOREIGN KEY (`Recipient_ID`) REFERENCES `recipient` (`Recipient_ID`),
  ADD CONSTRAINT `transplant_record_ibfk_3` FOREIGN KEY (`Hospital_ID`) REFERENCES `hospital` (`Hospital_ID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

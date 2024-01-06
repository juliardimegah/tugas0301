-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 06, 2024 at 03:12 PM
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
-- Database: `ulbi2024db`
--

-- --------------------------------------------------------

--
-- Table structure for table `mstdosen`
--

CREATE TABLE `mstdosen` (
  `nik` int(11) NOT NULL,
  `nama_lengkap` varchar(255) NOT NULL,
  `alamat` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `mstdosen`
--

INSERT INTO `mstdosen` (`nik`, `nama_lengkap`, `alamat`) VALUES
(1213131, 'ada', 'bandung');

-- --------------------------------------------------------

--
-- Table structure for table `mstmahasiswa`
--

CREATE TABLE `mstmahasiswa` (
  `npm` char(10) NOT NULL,
  `nama_lengkap` varchar(100) NOT NULL,
  `alamat` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `mstmahasiswa`
--

INSERT INTO `mstmahasiswa` (`npm`, `nama_lengkap`, `alamat`) VALUES
('1214066', 'Megah Juliardi', 'Bandung');

-- --------------------------------------------------------

--
-- Table structure for table `mstmmatkul`
--

CREATE TABLE `mstmmatkul` (
  `kode_matkul` int(11) NOT NULL,
  `nama_matkul` varchar(255) NOT NULL,
  `dosen` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `mstmmatkul`
--

INSERT INTO `mstmmatkul` (`kode_matkul`, `nama_matkul`, `dosen`) VALUES
(0, 'Pemrograman 3', 'Roni Andarsyah'),
(0, 'pemrograman 3', 'roni andrasyah');

-- --------------------------------------------------------

--
-- Table structure for table `mstruangan`
--

CREATE TABLE `mstruangan` (
  `noruang` int(11) NOT NULL,
  `gedung` varchar(255) NOT NULL,
  `lantai` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `mstruangan`
--

INSERT INTO `mstruangan` (`noruang`, `gedung`, `lantai`) VALUES
(113, 'Pendidikan Vokasi', '1 (Satu)');
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

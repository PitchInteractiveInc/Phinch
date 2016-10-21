-- phpMyAdmin SQL Dump
-- version 3.5.2
-- http://www.phpmyadmin.net
--
-- Host: internal-db.s179208.gridserver.com
-- Generation Time: May 21, 2014 at 04:56 PM
-- Server version: 5.1.72-rel14.10
-- PHP Version: 5.3.27

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `db179208_phinch`
--

-- --------------------------------------------------------

--
-- Table structure for table `Layer`
--

CREATE TABLE IF NOT EXISTS `Layer` (
  `layer_id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(60) NOT NULL,
  PRIMARY KEY (`layer_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8 ;

--
-- Dumping data for table `Layer`
--

INSERT INTO `Layer` (`layer_id`, `name`) VALUES
(1, 'kingdom'),
(2, 'phylum'),
(3, 'class'),
(4, 'order'),
(5, 'family'),
(6, 'genus'),
(7, 'species');

-- --------------------------------------------------------

--
-- Table structure for table `SharedData`
--

CREATE TABLE IF NOT EXISTS `SharedData` (
  `SharedData_id` int(10) NOT NULL AUTO_INCREMENT,
  `biom_filename` varchar(255) NOT NULL,
  `biom_file_hash` varchar(32) NOT NULL,
  `ip_address` varchar(15) NOT NULL,
  `from_email` varchar(255) NOT NULL,
  `from_name` varchar(255) NOT NULL,
  `to_email` varchar(255) NOT NULL,
  `to_name` varchar(255) NOT NULL,
  `notes` text NOT NULL,
  `url_hash` varchar(32) NOT NULL,
  `visualization_id` int(10) NOT NULL,
  `layer_id` int(10) NOT NULL,
  `visualization_options` text NOT NULL,
  `date_uploaded` datetime NOT NULL,
  `countView` int(10) NOT NULL,
  `filter_options_json` text NOT NULL,
  PRIMARY KEY (`SharedData_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `Visualization`
--

CREATE TABLE IF NOT EXISTS `Visualization` (
  `visualization_id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(60) NOT NULL,
  PRIMARY KEY (`visualization_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=6 ;

--
-- Dumping data for table `Visualization`
--

INSERT INTO `Visualization` (`visualization_id`, `name`) VALUES
(1, 'taxonomyBarChart'),
(2, 'bubbleChart'),
(3, 'sankeyDiagram'),
(4, 'donutPartition'),
(5, 'attributesColumn');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

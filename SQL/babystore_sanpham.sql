-- MySQL dump 10.13  Distrib 8.0.32, for Win64 (x86_64)
--
-- Host: localhost    Database: babystore
-- ------------------------------------------------------
-- Server version	8.0.32

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `sanpham`
--

DROP TABLE IF EXISTS `sanpham`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sanpham` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ten` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `gia` decimal(12,0) NOT NULL,
  `anh` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mota` text COLLATE utf8mb4_unicode_ci,
  `danhmuc` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT 'do_so_sinh',
  `soluong` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sanpham`
--

LOCK TABLES `sanpham` WRITE;
/*!40000 ALTER TABLE `sanpham` DISABLE KEYS */;
INSERT INTO `sanpham` VALUES (1,'Bình sữa cao cấp',120000,'an01.jpg','Bình sữa an toàn cho bé','Ăn uống',50),(2,'Yếm ăn cho bé',50000,'an02.jpg','Yếm chống thấm tiện lợi','Ăn uống',38),(3,'Bình sữa chống sặc',150000,'an04.jpg','Chống sặc hiệu quả','Ăn uống',29),(4,'Bộ muỗng ăn dặm',70000,'an05.jpg','Muỗng mềm cho bé','Ăn uống',25),(5,'Máy hâm sữa',300000,'an06.jpg','Giữ ấm sữa nhanh chóng','Ăn uống',15),(6,'Áo sơ sinh',90000,'ao01.jpg','Áo cotton mềm mại','Quần áo',60),(7,'Áo khoác bé',150000,'ao03.jpg','Giữ ấm cho bé','Quần áo',35),(8,'Set đồ xanh',130000,'ao04.jpg','Bộ đồ dễ thương','Quần áo',20),(9,'Quần yếm',110000,'ao05.jpg','Phong cách năng động','Quần áo',25),(10,'Váy bé gái',120000,'ao06.jpg','Dễ thương cho bé gái','Quần áo',30),(11,'Sữa tắm em bé',180000,'canhan02.jpg','Dịu nhẹ cho da bé','Đồ dùng',40),(12,'Khăn giấy ướt',60000,'canhan03.png','Tiện lợi khi ra ngoài','Đồ dùng',49),(13,'Dầu gội Johnson',170000,'canhan04.jpg','Không cay mắt','Đồ dùng',35),(14,'Kem chống hăm',90000,'canhan05.jpg','Bảo vệ da bé','Đồ dùng',20),(15,'Đồ chơi treo nôi',150000,'choi01.jpg','Kích thích phát triển','Đồ chơi',20),(16,'Gấu bông nhỏ',80000,'choi02.jpg','Mềm mại dễ thương','Đồ chơi',30),(17,'Đồ chơi phát nhạc',220000,'choi03.jpg','Phát nhạc vui nhộn','Đồ chơi',15),(18,'Xếp hình cho bé',140000,'choi04.jpg','Rèn luyện tư duy','Đồ chơi',25),(19,'Nôi em bé',1200000,'noi01.jpg','An toàn cho bé ngủ','Nôi-cũi',10),(20,'Ghế ăn dặm',900000,'noi02.png','Tiện lợi cho bé','Nôi-cũi',8),(21,'Cũi trẻ em',1500000,'noi03.jpg','Chắc chắn và an toàn','Nôi-cũi',5),(22,'Sữa bột',350000,'sua.jpg','Dinh dưỡng cho bé','Ăn uống',40),(23,'Tã em bé',280000,'ta.jpg','Thấm hút tốt','Đồ dùng',50),(24,'Tô ăn dặm có nắp',100000,'an07.jpg','Chât liệu: Nhựa PP không BPA      Dung tích: 200ml       Màu: Hồng  Chống đổ, có nắp       Xuất xứ: Nhật Bản','Ăn uống',35),(25,'Nôi cũi đa năng có màn che',2200000,'noi04.jpg','','Nôi-cũi',5),(26,'Bóng nhựa phát sáng',20000,'choi06.jpg','','Đồ chơi',10),(27,'Máy tiệt trùng bình sữa Philips',1000000,'canhan06.png','','Đồ dùng',5);
/*!40000 ALTER TABLE `sanpham` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-26 14:57:01

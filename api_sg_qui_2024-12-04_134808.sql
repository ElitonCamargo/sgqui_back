-- MySQL dump 10.13  Distrib 8.0.33, for Win64 (x86_64)
--
-- Host: 100.26.59.163    Database: api_sg_qui
-- ------------------------------------------------------
-- Server version	8.0.40-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `configuracao`
--

DROP TABLE IF EXISTS `configuracao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `configuracao` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `value` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `elemento`
--

DROP TABLE IF EXISTS `elemento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `elemento` (
  `id` tinyint unsigned NOT NULL AUTO_INCREMENT,
  `simbolo` char(3) NOT NULL,
  `nome` varchar(50) DEFAULT NULL,
  `numero_atomico` int DEFAULT NULL,
  `massa_atomica` decimal(10,6) DEFAULT NULL,
  `grupo` int unsigned DEFAULT NULL,
  `periodo` int unsigned DEFAULT NULL,
  `ponto_de_fusao` decimal(10,6) DEFAULT NULL,
  `ponto_de_ebulicao` decimal(10,6) DEFAULT NULL,
  `densidade` decimal(10,8) DEFAULT NULL,
  `estado_padrao` varchar(20) DEFAULT NULL,
  `configuracao_eletronica` varchar(50) DEFAULT NULL,
  `propriedades` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `simbolo` (`simbolo`),
  UNIQUE KEY `nome` (`nome`)
) ENGINE=InnoDB AUTO_INCREMENT=119 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `etapa`
--

DROP TABLE IF EXISTS `etapa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `etapa` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `projeto` int unsigned DEFAULT NULL,
  `nome` varchar(255) DEFAULT NULL,
  `descricao` varchar(255) DEFAULT NULL,
  `ordem` tinyint DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `projeto` (`projeto`),
  CONSTRAINT `etapa_ibfk_1` FOREIGN KEY (`projeto`) REFERENCES `projeto` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `etapa_mp`
--

DROP TABLE IF EXISTS `etapa_mp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `etapa_mp` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `etapa` int unsigned DEFAULT NULL,
  `mp` int unsigned DEFAULT NULL,
  `percentual` double DEFAULT NULL,
  `tempo_agitacao` varchar(10) DEFAULT NULL,
  `observacao` varchar(1000) DEFAULT NULL,
  `ordem` tinyint DEFAULT NULL,
  `lote` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `etapa` (`etapa`,`mp`),
  KEY `mp` (`mp`),
  KEY `etapa_2` (`etapa`),
  CONSTRAINT `etapa_mp_ibfk_2` FOREIGN KEY (`mp`) REFERENCES `materia_prima` (`id`),
  CONSTRAINT `etapa_mp_ibfk_3` FOREIGN KEY (`etapa`) REFERENCES `etapa` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `garantia`
--

DROP TABLE IF EXISTS `garantia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `garantia` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `materia_prima` int unsigned NOT NULL,
  `nutriente` int unsigned NOT NULL,
  `percentual` double unsigned DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nutriente` (`nutriente`,`materia_prima`),
  KEY `materia_prima` (`materia_prima`),
  CONSTRAINT `garantia_ibfk_1` FOREIGN KEY (`nutriente`) REFERENCES `nutriente` (`id`),
  CONSTRAINT `garantia_ibfk_2` FOREIGN KEY (`materia_prima`) REFERENCES `materia_prima` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `materia_prima`
--

DROP TABLE IF EXISTS `materia_prima`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `materia_prima` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(50) DEFAULT NULL,
  `nome` varchar(100) DEFAULT NULL,
  `formula` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `cas_number` varchar(50) DEFAULT NULL,
  `densidade` double unsigned DEFAULT NULL,
  `descricao` varchar(1000) DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `codigo` (`codigo`),
  UNIQUE KEY `nome` (`nome`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nutriente`
--

DROP TABLE IF EXISTS `nutriente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nutriente` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) DEFAULT NULL,
  `formula` varchar(100) DEFAULT NULL,
  `visivel` tinyint unsigned DEFAULT '1',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nome` (`nome`),
  UNIQUE KEY `formula` (`formula`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `percentual_nutriente_projeto`
--

DROP TABLE IF EXISTS `percentual_nutriente_projeto`;
/*!50001 DROP VIEW IF EXISTS `percentual_nutriente_projeto`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `percentual_nutriente_projeto` AS SELECT 
 1 AS `projeto_id`,
 1 AS `projeto_nome`,
 1 AS `nutriente_id`,
 1 AS `nutriente_nome`,
 1 AS `percentual_nutriente`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `projeto`
--

DROP TABLE IF EXISTS `projeto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `projeto` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(20) DEFAULT NULL,
  `nome` varchar(255) DEFAULT NULL,
  `cliente` varchar(255) DEFAULT NULL,
  `descricao` text,
  `data_inicio` date DEFAULT NULL,
  `data_termino` date DEFAULT NULL,
  `densidade` double unsigned DEFAULT NULL,
  `ph` varchar(255) DEFAULT NULL,
  `tipo` varchar(255) DEFAULT NULL,
  `aplicacao` json DEFAULT NULL,
  `natureza_fisica` varchar(255) DEFAULT NULL,
  `status` json DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `projeto_detalhado`
--

DROP TABLE IF EXISTS `projeto_detalhado`;
/*!50001 DROP VIEW IF EXISTS `projeto_detalhado`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `projeto_detalhado` AS SELECT 
 1 AS `projeto_id`,
 1 AS `projeto_codigo`,
 1 AS `projeto_nome`,
 1 AS `projeto_cliente`,
 1 AS `projeto_descricao`,
 1 AS `projeto_data_inicio`,
 1 AS `projeto_data_termino`,
 1 AS `projeto_densidade`,
 1 AS `projeto_ph`,
 1 AS `projeto_tipo`,
 1 AS `projeto_aplicacao`,
 1 AS `projeto_natureza_fisica`,
 1 AS `projeto_status`,
 1 AS `projeto_createdAt`,
 1 AS `projeto_updatedAt`,
 1 AS `etapa_id`,
 1 AS `etapa_nome`,
 1 AS `etapa_descricao`,
 1 AS `etapa_ordem`,
 1 AS `etapa_mp_id`,
 1 AS `etapa_mp_percentual`,
 1 AS `etapa_mp_tempo_agitacao`,
 1 AS `etapa_mp_observacao`,
 1 AS `etapa_mp_lote`,
 1 AS `etapa_mp_ordem`,
 1 AS `materia_prima_id`,
 1 AS `materia_prima_codigo`,
 1 AS `materia_prima_nome`,
 1 AS `materia_prima_formula`,
 1 AS `materia_prima_cas_number`,
 1 AS `materia_prima_densidade`,
 1 AS `materia_prima_descricao`,
 1 AS `garantia_id`,
 1 AS `garantia_percentual`,
 1 AS `nutriente_id`,
 1 AS `nutriente_nome`,
 1 AS `nutriente_formula`,
 1 AS `nutriente_visivel`,
 1 AS `percentual_origem`,
 1 AS `parcial_densidade`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `token`
--

DROP TABLE IF EXISTS `token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `token` (
  `usuario` int unsigned NOT NULL,
  `chave_token` varchar(255) DEFAULT NULL,
  `validade` datetime DEFAULT NULL,
  PRIMARY KEY (`usuario`),
  CONSTRAINT `token_ibfk_1` FOREIGN KEY (`usuario`) REFERENCES `usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `senha` varchar(255) DEFAULT NULL,
  `permissao` tinyint DEFAULT NULL,
  `avatar` varchar(100) DEFAULT NULL,
  `status` tinyint DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'api_sg_qui'
--
/*!50003 DROP FUNCTION IF EXISTS `nutriente_percentualComposicao` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`admin_api`@`%.%.%.%` FUNCTION `nutriente_percentualComposicao`(`mp_id` INT, `mp_percentual` DOUBLE) RETURNS json
    DETERMINISTIC
BEGIN
    RETURN (
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'nutriente', nutriente.nome,
                'percentual', mp_percentual/100*garantia.percentual
            )
        )
        FROM nutriente
        JOIN garantia ON nutriente.id = garantia.nutriente
        JOIN materia_prima ON garantia.materia_prima = materia_prima.id
        WHERE materia_prima.id = mp_id
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `duplicar_projeto` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`admin_api`@`%.%.%.%` PROCEDURE `duplicar_projeto`(IN `projeto_base_id` INT)
BEGIN
    DECLARE novo_projeto_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        
        ROLLBACK;        
    END;
    
	START TRANSACTION;    
    
    
    INSERT INTO projeto (nome, descricao, data_inicio, data_termino, densidade, ph, tipo, aplicacao, natureza_fisica, status)
    SELECT CONCAT(nome, ' (Copy)'), descricao, data_inicio, data_termino, densidade, ph, tipo, aplicacao, natureza_fisica, status
    FROM projeto
    WHERE id = projeto_base_id;
    
    SET novo_projeto_id = LAST_INSERT_ID();
    
    
    INSERT INTO etapa (projeto, nome, descricao, ordem)
    SELECT novo_projeto_id, nome, descricao, ordem
    FROM etapa
    WHERE projeto = projeto_base_id;
    
    
    CREATE TEMPORARY TABLE etapa_mapeamento AS
    SELECT e_base.id AS base_etapa_id, e_new.id AS new_etapa_id
    FROM 
	etapa e_base
    JOIN 
	etapa e_new ON e_base.ordem = e_new.ordem AND e_base.projeto = projeto_base_id AND e_new.projeto = novo_projeto_id;
    
    
    INSERT INTO etapa_mp (etapa, mp, percentual, tempo_agitacao, observacao, ordem)
    SELECT emap.new_etapa_id, em.mp, em.percentual, em.tempo_agitacao, em.observacao, em.ordem
    FROM 
	etapa_mp em
    JOIN 
	etapa_mapeamento emap ON em.etapa = emap.base_etapa_id;

    DROP TEMPORARY TABLE etapa_mapeamento;

    SELECT * FROM projeto WHERE projeto.id = novo_projeto_id;
    
COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `etapa_alterarOrdem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`admin_api`@`%.%.%.%` PROCEDURE `etapa_alterarOrdem`(IN `ordemEtapa` JSON)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total INT DEFAULT JSON_LENGTH(ordemEtapa);
    DECLARE etapaId INT;
    DECLARE etapaOrdem INT;

    
    START TRANSACTION;

    
    WHILE i < total DO
        
        SET etapaId = JSON_UNQUOTE(JSON_EXTRACT(ordemEtapa, CONCAT('$[', i, '].id')));
        SET etapaOrdem = JSON_UNQUOTE(JSON_EXTRACT(ordemEtapa, CONCAT('$[', i, '].ordem')));
        
        
        UPDATE etapa SET ordem = etapaOrdem WHERE id = etapaId;
        
        
        SET i = i + 1;
    END WHILE;

    
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `etapa_mp_alterarOrdemMateriasPrimas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`admin_api`@`%.%.%.%` PROCEDURE `etapa_mp_alterarOrdemMateriasPrimas`(IN `ordemMateriasPrimas` JSON)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total INT DEFAULT JSON_LENGTH(ordemMateriasPrimas);
    DECLARE _id INT;
    DECLARE etapaId INT;
    DECLARE materiaPrimaOrdem INT;

    
    START TRANSACTION;

    
    WHILE i < total DO
        
        SET _id = JSON_UNQUOTE(JSON_EXTRACT(ordemMateriasPrimas, CONCAT('$[', i, '].id')));
        SET etapaId = JSON_UNQUOTE(JSON_EXTRACT(ordemMateriasPrimas, CONCAT('$[', i, '].etapa')));
        SET materiaPrimaOrdem = JSON_UNQUOTE(JSON_EXTRACT(ordemMateriasPrimas, CONCAT('$[', i, '].ordem')));
        
        
        UPDATE etapa_mp SET etapa = etapaId,  ordem = materiaPrimaOrdem WHERE id = _id;
        
        
        SET i = i + 1;
    END WHILE;

    
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mp_precentual_nutriente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`admin_api`@`%.%.%.%` PROCEDURE `mp_precentual_nutriente`(IN `_nutriente` INT, IN `_percentual` DOUBLE)
SELECT
	materia_prima.id 					as mp_id,
	materia_prima.nome 					as mp_nome,
	materia_prima.formula 				as mp_formula,
	(_percentual * 100) / garantia.percentual 	as percentual,
    nutriente_percentualComposicao(materia_prima.id, ((_percentual * 100) / garantia.percentual)) as composicao
FROM
	nutriente
	JOIN
	garantia ON nutriente.id = garantia.nutriente
	JOIN
	materia_prima ON garantia.materia_prima = materia_prima.id
WHERE
	nutriente.id = _nutriente AND ((_percentual * 100) / garantia.percentual) < 100
    ORDER BY percentual ASC ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `projeto_marcarVisualizacao` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`admin_api`@`%.%.%.%` PROCEDURE `projeto_marcarVisualizacao`(IN `id` INT)
BEGIN
    UPDATE projeto SET updatedAt = CURRENT_TIMESTAMP WHERE projeto.id = id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `token_consultar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`admin_api`@`%.%.%.%` PROCEDURE `token_consultar`(IN `_chave_token` VARCHAR(255))
BEGIN
	SET @usuario = SUBSTRING_INDEX(_chave_token, '.', 1);
	SELECT * FROM token WHERE token.usuario = @usuario AND token.chave_token LIKE _chave_token;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `token_criar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`admin_api`@`%.%.%.%` PROCEDURE `token_criar`(IN `_usuario` INT, IN `_validade` INT, IN `_chave_token` VARCHAR(255))
BEGIN
    SET @token = CONCAT(_usuario, '.', _chave_token);
    SET @vaidade = DATE_ADD(CURRENT_TIMESTAMP, INTERVAL _validade HOUR);
    INSERT INTO token(usuario, chave_token, validade) VALUES(_usuario, @token, @vaidade) ON DUPLICATE KEY UPDATE chave_token = VALUES(chave_token), validade = VALUES(validade);
    SELECT * FROM token WHERE token.usuario = _usuario;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `token_extender` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`admin_api`@`%.%.%.%` PROCEDURE `token_extender`(IN `_usuario` INT, IN `_horas` INT)
    NO SQL
UPDATE token
SET 
	validade = DATE_ADD(validade, INTERVAL _horas HOUR)
WHERE 
	token.usuario = _usuario ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `percentual_nutriente_projeto`
--

/*!50001 DROP VIEW IF EXISTS `percentual_nutriente_projeto`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`admin_api`@`%.%.%.%` SQL SECURITY DEFINER */
/*!50001 VIEW `percentual_nutriente_projeto` AS select `projeto_detalhado`.`projeto_id` AS `projeto_id`,`projeto_detalhado`.`projeto_nome` AS `projeto_nome`,`projeto_detalhado`.`nutriente_id` AS `nutriente_id`,`projeto_detalhado`.`nutriente_nome` AS `nutriente_nome`,sum(`projeto_detalhado`.`percentual_origem`) AS `percentual_nutriente` from `projeto_detalhado` group by `projeto_detalhado`.`projeto_id`,`projeto_detalhado`.`nutriente_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `projeto_detalhado`
--

/*!50001 DROP VIEW IF EXISTS `projeto_detalhado`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`admin_api`@`%.%.%.%` SQL SECURITY DEFINER */
/*!50001 VIEW `projeto_detalhado` AS select `projeto`.`id` AS `projeto_id`,`projeto`.`codigo` AS `projeto_codigo`,`projeto`.`nome` AS `projeto_nome`,`projeto`.`cliente` AS `projeto_cliente`,`projeto`.`descricao` AS `projeto_descricao`,`projeto`.`data_inicio` AS `projeto_data_inicio`,`projeto`.`data_termino` AS `projeto_data_termino`,`projeto`.`densidade` AS `projeto_densidade`,`projeto`.`ph` AS `projeto_ph`,`projeto`.`tipo` AS `projeto_tipo`,`projeto`.`aplicacao` AS `projeto_aplicacao`,`projeto`.`natureza_fisica` AS `projeto_natureza_fisica`,`projeto`.`status` AS `projeto_status`,`projeto`.`createdAt` AS `projeto_createdAt`,`projeto`.`updatedAt` AS `projeto_updatedAt`,`etapa`.`id` AS `etapa_id`,`etapa`.`nome` AS `etapa_nome`,`etapa`.`descricao` AS `etapa_descricao`,`etapa`.`ordem` AS `etapa_ordem`,`etapa_mp`.`id` AS `etapa_mp_id`,`etapa_mp`.`percentual` AS `etapa_mp_percentual`,`etapa_mp`.`tempo_agitacao` AS `etapa_mp_tempo_agitacao`,`etapa_mp`.`observacao` AS `etapa_mp_observacao`,`etapa_mp`.`lote` AS `etapa_mp_lote`,`etapa_mp`.`ordem` AS `etapa_mp_ordem`,`materia_prima`.`id` AS `materia_prima_id`,`materia_prima`.`codigo` AS `materia_prima_codigo`,`materia_prima`.`nome` AS `materia_prima_nome`,`materia_prima`.`formula` AS `materia_prima_formula`,`materia_prima`.`cas_number` AS `materia_prima_cas_number`,`materia_prima`.`densidade` AS `materia_prima_densidade`,`materia_prima`.`descricao` AS `materia_prima_descricao`,`garantia`.`id` AS `garantia_id`,`garantia`.`percentual` AS `garantia_percentual`,`nutriente`.`id` AS `nutriente_id`,`nutriente`.`nome` AS `nutriente_nome`,`nutriente`.`formula` AS `nutriente_formula`,`nutriente`.`visivel` AS `nutriente_visivel`,((`garantia`.`percentual` * `etapa_mp`.`percentual`) / 100) AS `percentual_origem`,((`etapa_mp`.`percentual` / 100) * `materia_prima`.`densidade`) AS `parcial_densidade` from (((((`projeto` left join `etapa` on((`projeto`.`id` = `etapa`.`projeto`))) left join `etapa_mp` on((`etapa`.`id` = `etapa_mp`.`etapa`))) left join `materia_prima` on((`etapa_mp`.`mp` = `materia_prima`.`id`))) left join `garantia` on((`materia_prima`.`id` = `garantia`.`materia_prima`))) left join `nutriente` on((`garantia`.`nutriente` = `nutriente`.`id`))) order by `projeto`.`id`,`etapa`.`ordem`,`etapa_mp`.`ordem`,`etapa_mp`.`id` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-12-04 13:49:07

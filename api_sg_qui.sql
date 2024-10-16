-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Tempo de geração: 16/10/2024 às 16:04
-- Versão do servidor: 8.0.30
-- Versão do PHP: 8.3.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `api_sg_qui`
--

DELIMITER $$
--
-- Procedimentos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `duplicar_projeto` (IN `projeto_base_id` INT)   BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `etapa_alterarOrdem` (IN `ordemEtapa` JSON)   BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `etapa_mp_alterarOrdemMateriasPrimas` (IN `ordemMateriasPrimas` JSON)   BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `mp_precentual_nutriente` (IN `_nutriente` INT, IN `_percentual` DOUBLE)   SELECT
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
    ORDER BY percentual ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `projeto_marcarVisualizacao` (IN `id` INT)   BEGIN
    UPDATE projeto SET updatedAt = CURRENT_TIMESTAMP WHERE projeto.id = id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `token_consultar` (IN `_chave_token` VARCHAR(255))   BEGIN
	SET @usuario = SUBSTRING_INDEX(_chave_token, '.', 1);
	SELECT * FROM token WHERE token.usuario = @usuario AND token.chave_token LIKE _chave_token;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `token_criar` (IN `_usuario` INT, IN `_validade` INT, IN `_chave_token` VARCHAR(255))   BEGIN
    SET @token = CONCAT(_usuario, '.', _chave_token);
    SET @vaidade = DATE_ADD(CURRENT_TIMESTAMP, INTERVAL _validade HOUR);
    INSERT INTO token(usuario, chave_token, validade) VALUES(_usuario, @token, @vaidade) ON DUPLICATE KEY UPDATE chave_token = VALUES(chave_token), validade = VALUES(validade);
    SELECT * FROM token WHERE token.usuario = _usuario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `token_extender` (IN `_usuario` INT, IN `_horas` INT)  NO SQL UPDATE token
SET 
	validade = DATE_ADD(validade, INTERVAL _horas HOUR)
WHERE 
	token.usuario = _usuario$$

--
-- Funções
--
CREATE DEFINER=`root`@`localhost` FUNCTION `nutriente_percentualComposicao` (`mp_id` INT, `mp_percentual` DOUBLE) RETURNS JSON DETERMINISTIC BEGIN
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
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `configuracao`
--

CREATE TABLE `configuracao` (
  `id` int UNSIGNED NOT NULL,
  `key` varchar(25) DEFAULT NULL,
  `value` json DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Despejando dados para a tabela `configuracao`
--

INSERT INTO `configuracao` (`id`, `key`, `value`) VALUES
(1, 'textoImpressaoRodape', '\"valor\"'),
(2, 'print-produzido-por', '\"David Carvalho\"'),
(3, 'print-resultado-final', '\"Aprovado\"'),
(4, 'exemplo2', '[{\"id\": 0, \"nome\": \"A\"}, {\"id\": 1, \"nome\": \"B\"}, {\"id\": 2, \"nome\": \"C\"}]'),
(5, 'print-anexo', '\"ANEXO PQ03 A01 - VIGÊNCIA: 05/03/2024 - REVISÃO:01\"'),
(6, 'print-responsavel-area', '\"Fábio Scudeler\"'),
(7, 'print-procedimento', '\"Acrescentar as matérias primas em ordem de adição, seguindo os tempos de agitação\"');

-- --------------------------------------------------------

--
-- Estrutura para tabela `elemento`
--

CREATE TABLE `elemento` (
  `id` tinyint UNSIGNED NOT NULL,
  `simbolo` char(3) NOT NULL,
  `nome` varchar(50) DEFAULT NULL,
  `numero_atomico` int DEFAULT NULL,
  `massa_atomica` decimal(10,6) DEFAULT NULL,
  `grupo` int UNSIGNED DEFAULT NULL,
  `periodo` int UNSIGNED DEFAULT NULL,
  `ponto_de_fusao` decimal(10,6) DEFAULT NULL,
  `ponto_de_ebulicao` decimal(10,6) DEFAULT NULL,
  `densidade` decimal(10,8) DEFAULT NULL,
  `estado_padrao` varchar(20) DEFAULT NULL,
  `configuracao_eletronica` varchar(50) DEFAULT NULL,
  `propriedades` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Despejando dados para a tabela `elemento`
--

INSERT INTO `elemento` (`id`, `simbolo`, `nome`, `numero_atomico`, `massa_atomica`, `grupo`, `periodo`, `ponto_de_fusao`, `ponto_de_ebulicao`, `densidade`, `estado_padrao`, `configuracao_eletronica`, `propriedades`) VALUES
(1, 'H', 'Hidrogênio', 1, 1.008000, 1, 1, -259.140000, -252.870000, 0.08990000, 'Gasoso', '1s¹', 'Não metal'),
(2, 'He', 'Hélio', 2, 4.002600, 18, 1, -272.200000, -268.930000, 0.17860000, 'Gasoso', '1s²', 'Gás nobre'),
(3, 'Li', 'Lítio', 3, 6.940000, 1, 2, 180.540000, 1342.000000, 0.53000000, 'Sólido', '[He] 2s¹', 'Metal alcalino'),
(4, 'Be', 'Berílio', 4, 9.012200, 2, 2, 1278.000000, 2970.000000, 1.85000000, 'Sólido', '[He] 2s²', 'Metal alcalino-terroso'),
(5, 'B', 'Boro', 5, 10.810000, 13, 2, 2076.000000, 3927.000000, 2.34000000, 'Sólido', '[He] 2s² 2p¹', 'Semimetal'),
(6, 'C', 'Carbono', 6, 12.011000, 14, 2, 3550.000000, 4827.000000, 2.26700000, 'Sólido', '[He] 2s² 2p²', 'Não metal'),
(7, 'N', 'Nitrogênio', 7, 14.007000, 15, 2, -209.860000, -195.790000, 0.00125000, 'Gasoso', '[He] 2s² 2p³', 'Não metal'),
(8, 'O', 'Oxigênio', 8, 15.999000, 16, 2, -218.790000, -182.960000, 0.00143000, 'Gasoso', '[He] 2s² 2p⁴', 'Não metal'),
(9, 'F', 'Flúor', 9, 18.998000, 17, 2, -219.670000, -188.120000, 0.00170000, 'Gasoso', '[He] 2s² 2p⁵', 'Halogênio'),
(10, 'Ne', 'Neônio', 10, 20.180000, 18, 2, -248.590000, -246.080000, 0.00090000, 'Gasoso', '[He] 2s² 2p⁶', 'Gás nobre'),
(11, 'Na', 'Sódio', 11, 22.990000, 1, 3, 97.720000, 883.000000, 0.97000000, 'Sólido', '[Ne] 3s¹', 'Metal alcalino'),
(12, 'Mg', 'Magnésio', 12, 24.305000, 2, 3, 650.000000, 1090.000000, 1.74000000, 'Sólido', '[Ne] 3s²', 'Metal alcalino-terroso'),
(13, 'Al', 'Alumínio', 13, 26.982000, 13, 3, 660.320000, 2519.000000, 2.70000000, 'Sólido', '[Ne] 3s² 3p¹', 'Metal'),
(14, 'Si', 'Silício', 14, 28.085000, 14, 3, 1414.000000, 3265.000000, 2.33000000, 'Sólido', '[Ne] 3s² 3p²', 'Semimetal'),
(15, 'P', 'Fósforo', 15, 30.974000, 15, 3, 44.150000, 280.500000, 1.82300000, 'Sólido', '[Ne] 3s² 3p³', 'Não metal'),
(16, 'S', 'Enxofre', 16, 32.060000, 16, 3, 115.210000, 444.720000, 2.06700000, 'Sólido', '[Ne] 3s² 3p⁴', 'Não metal'),
(17, 'Cl', 'Cloro', 17, 35.450000, 17, 3, -100.980000, -34.600000, 0.00320000, 'Gasoso', '[Ne] 3s² 3p⁵', 'Halogênio'),
(18, 'Ar', 'Argônio', 18, 39.948000, 18, 3, -189.360000, -185.860000, 0.00170000, 'Gasoso', '[Ne] 3s² 3p⁶', 'Gás nobre'),
(19, 'K', 'Potássio', 19, 39.098000, 1, 4, 63.380000, 759.900000, 0.89000000, 'Sólido', '[Ar] 4s¹', 'Metal alcalino'),
(20, 'Ca', 'Cálcio', 20, 40.078000, 2, 4, 839.000000, 1484.000000, 1.55000000, 'Sólido', '[Ar] 4s²', 'Metal alcalino-terroso'),
(21, 'Sc', 'Escândio', 21, 44.956000, 3, 4, 1539.000000, 2832.000000, 2.99000000, 'Sólido', '[Ar] 3d¹ 4s²', 'Metal de transição'),
(22, 'Ti', 'Titânio', 22, 47.867000, 4, 4, 1668.000000, 3287.000000, 4.50700000, 'Sólido', '[Ar] 3d² 4s²', 'Metal de transição'),
(23, 'V', 'Vanádio', 23, 50.942000, 5, 4, 1910.000000, 3407.000000, 6.11000000, 'Sólido', '[Ar] 3d³ 4s²', 'Metal de transição'),
(24, 'Cr', 'Cromo', 24, 51.996000, 6, 4, 1907.000000, 2672.000000, 7.15000000, 'Sólido', '[Ar] 3d⁵ 4s¹', 'Metal de transição'),
(25, 'Mn', 'Manganês', 25, 54.938000, 7, 4, 1246.000000, 2061.000000, 7.44000000, 'Sólido', '[Ar] 3d⁵ 4s²', 'Metal de transição'),
(26, 'Fe', 'Ferro', 26, 55.845000, 8, 4, 1538.000000, 2862.000000, 7.87000000, 'Sólido', '[Ar] 3d⁶ 4s²', 'Metal de transição'),
(27, 'Co', 'Cobalto', 27, 58.933000, 9, 4, 1495.000000, 2927.000000, 8.90000000, 'Sólido', '[Ar] 3d⁷ 4s²', 'Metal de transição'),
(28, 'Ni', 'Níquel', 28, 58.693000, 10, 4, 1455.000000, 2913.000000, 8.90000000, 'Sólido', '[Ar] 3d⁸ 4s²', 'Metal de transição'),
(29, 'Cu', 'Cobre', 29, 63.546000, 11, 4, 1084.620000, 2562.000000, 8.96000000, 'Sólido', '[Ar] 3d¹⁰ 4s¹', 'Metal de transição'),
(30, 'Zn', 'Zinco', 30, 65.380000, 12, 4, 419.530000, 907.000000, 7.14000000, 'Sólido', '[Ar] 3d¹⁰ 4s²', 'Metal de transição'),
(31, 'Ga', 'Gálio', 31, 69.723000, 13, 4, 29.760000, 2204.000000, 5.91000000, 'Sólido', '[Ar] 3d¹⁰ 4s² 4p¹', 'Metal'),
(32, 'Ge', 'Germanio', 32, 72.630000, 14, 4, 938.250000, 2830.000000, 5.32000000, 'Sólido', '[Ar] 3d¹⁰ 4s² 4p²', 'Semimetal'),
(33, 'As', 'Arsênio', 33, 74.922000, 15, 4, 817.000000, 613.000000, 5.73000000, 'Sólido', '[Ar] 3d¹⁰ 4s² 4p³', 'Semimetal'),
(34, 'Se', 'Selênio', 34, 78.971000, 16, 4, 221.000000, 685.000000, 4.81000000, 'Sólido', '[Ar] 3d¹⁰ 4s² 4p⁴', 'Não metal'),
(35, 'Br', 'Bromo', 35, 79.904000, 17, 4, -7.200000, 58.780000, 3.12000000, 'Líquido', '[Ar] 3d¹⁰ 4s² 4p⁵', 'Halogênio'),
(36, 'Kr', 'Criptônio', 36, 83.798000, 18, 4, -157.370000, -153.220000, 0.00375000, 'Gasoso', '[Ar] 3d¹⁰ 4s² 4p⁶', 'Gás nobre'),
(37, 'Rb', 'Rubídio', 37, 85.468000, 1, 5, 38.890000, 688.000000, 1.53200000, 'Sólido', '[Kr] 5s¹', 'Metal alcalino'),
(38, 'Sr', 'Estrôncio', 38, 87.620000, 2, 5, 769.000000, 1384.000000, 2.64000000, 'Sólido', '[Kr] 5s²', 'Metal alcalino-terroso'),
(39, 'Y', 'Ítrio', 39, 88.906000, 3, 5, 1522.000000, 3345.000000, 4.47000000, 'Sólido', '[Kr] 4d¹ 5s²', 'Metal de transição'),
(40, 'Zr', 'Zircônio', 40, 91.224000, 4, 5, 1852.000000, 4377.000000, 6.52000000, 'Sólido', '[Kr] 4d² 5s²', 'Metal de transição'),
(41, 'Nb', 'Nióbio', 41, 92.906000, 5, 5, 2477.000000, 4744.000000, 8.57000000, 'Sólido', '[Kr] 4d⁴ 5s¹', 'Metal de transição'),
(42, 'Mo', 'Molibdênio', 42, 95.950000, 6, 5, 2623.000000, 4639.000000, 10.22000000, 'Sólido', '[Kr] 4d⁵ 5s¹', 'Metal de transição'),
(43, 'Tc', 'Tecnécio', 43, 98.000000, 7, 5, 2157.000000, 4265.000000, 11.00000000, 'Sólido', '[Kr] 4d⁵ 5s²', 'Metal de transição'),
(44, 'Ru', 'Rutênio', 44, 101.070000, 8, 5, 2334.000000, 4150.000000, 12.41000000, 'Sólido', '[Kr] 4d⁷ 5s¹', 'Metal de transição'),
(45, 'Rh', 'Ródio', 45, 102.910000, 9, 5, 1964.000000, 3695.000000, 12.41000000, 'Sólido', '[Kr] 4d⁸ 5s¹', 'Metal de transição'),
(46, 'Pd', 'Paládio', 46, 106.420000, 10, 5, 1552.000000, 2927.000000, 12.02000000, 'Sólido', '[Kr] 4d¹⁰', 'Metal de transição'),
(47, 'Ag', 'Prata', 47, 107.870000, 11, 5, 961.780000, 2162.000000, 10.49000000, 'Sólido', '[Kr] 4d¹⁰ 5s¹', 'Metal de transição'),
(48, 'Cd', 'Cádmio', 48, 112.410000, 12, 5, 321.070000, 767.000000, 8.65000000, 'Sólido', '[Kr] 4d¹⁰ 5s²', 'Metal de transição'),
(49, 'In', 'Índio', 49, 114.820000, 13, 5, 156.600000, 2072.000000, 7.31000000, 'Sólido', '[Kr] 4d¹⁰ 5s² 5p¹', 'Metal'),
(50, 'Sn', 'Estanho', 50, 118.710000, 14, 5, 231.930000, 2602.000000, 7.31000000, 'Sólido', '[Kr] 4d¹⁰ 5s² 5p²', 'Metal'),
(51, 'Sb', 'Antimônio', 51, 121.760000, 15, 5, 630.630000, 1587.000000, 6.68000000, 'Sólido', '[Kr] 4d¹⁰ 5s² 5p³', 'Semimetal'),
(52, 'Te', 'Telúrio', 52, 127.600000, 16, 5, 449.510000, 988.000000, 6.24000000, 'Sólido', '[Kr] 4d¹⁰ 5s² 5p⁴', 'Semimetal'),
(53, 'I', 'Iodo', 53, 126.900000, 17, 5, 113.700000, 184.400000, 4.93000000, 'Sólido', '[Kr] 4d¹⁰ 5s² 5p⁵', 'Halogênio'),
(54, 'Xe', 'Xenônio', 54, 131.290000, 18, 5, -111.790000, -108.120000, 0.00590000, 'Gasoso', '[Kr] 4d¹⁰ 5s² 5p⁶', 'Gás nobre'),
(55, 'Cs', 'Césio', 55, 132.910000, 1, 6, 28.440000, 671.000000, 1.87300000, 'Sólido', '[Xe] 6s¹', 'Metal alcalino'),
(56, 'Ba', 'Bário', 56, 137.330000, 2, 6, 727.000000, 1870.000000, 3.51000000, 'Sólido', '[Xe] 6s²', 'Metal alcalino-terroso'),
(57, 'Ce', 'Cério', 58, 140.120000, 3, 6, 795.000000, 3443.000000, 6.77000000, 'Sólido', '[Xe] 4f¹ 5d¹ 6s²', 'Lantanídeo'),
(58, 'La', 'Lantânio', 57, 138.910000, 3, 6, 920.000000, 3464.000000, 6.15000000, 'Sólido', '[Xe] 5d¹ 6s²', 'Lantanídeo'),
(59, 'Pm', 'Promécio', 61, 145.000000, 3, 6, 1042.000000, 3000.000000, 7.26000000, 'Sólido', '[Xe] 4f⁵ 6s²', 'Lantanídeo'),
(60, 'Hf', 'Háfnio', 72, 178.490000, 4, 6, 2233.000000, 4603.000000, 13.31000000, 'Sólido', '[Xe] 4f¹⁴ 5d² 6s²', 'Metal de transição'),
(61, 'Pr', 'Praseodímio', 59, 140.910000, 3, 6, 931.000000, 3290.000000, 6.77000000, 'Sólido', '[Xe] 4f³ 6s²', 'Lantanídeo'),
(62, 'Nd', 'Neodímio', 60, 144.240000, 3, 6, 1021.000000, 3068.000000, 7.01000000, 'Sólido', '[Xe] 4f⁴ 6s²', 'Lantanídeo'),
(63, 'Ta', 'Tântalo', 73, 180.950000, 5, 6, 3017.000000, 5458.000000, 16.65000000, 'Sólido', '[Xe] 4f¹⁴ 5d³ 6s²', 'Metal de transição'),
(64, 'W', 'Tungstênio', 74, 183.840000, 6, 6, 3422.000000, 5555.000000, 19.25000000, 'Sólido', '[Xe] 4f¹⁴ 5d⁴ 6s²', 'Metal de transição'),
(65, 'Re', 'Rênio', 75, 186.210000, 7, 6, 3186.000000, 5627.000000, 21.02000000, 'Sólido', '[Xe] 4f¹⁴ 5d⁵ 6s²', 'Metal de transição'),
(66, 'Sm', 'Samário', 62, 150.360000, 3, 6, 1072.000000, 1794.000000, 7.52000000, 'Sólido', '[Xe] 4f⁶ 6s²', 'Lantanídeo'),
(67, 'Eu', 'Európio', 63, 151.960000, 3, 6, 822.000000, 1597.000000, 5.24000000, 'Sólido', '[Xe] 4f⁷ 6s²', 'Lantanídeo'),
(68, 'Os', 'Ósmio', 76, 190.230000, 8, 6, 3033.000000, 5012.000000, 22.59000000, 'Sólido', '[Xe] 4f¹⁴ 5d⁶ 6s²', 'Metal de transição'),
(69, 'Gd', 'Gadolínio', 64, 157.250000, 3, 6, 1311.000000, 3233.000000, 7.90000000, 'Sólido', '[Xe] 4f⁷ 5d¹ 6s²', 'Lantanídeo'),
(70, 'Ir', 'Irídio', 77, 192.220000, 9, 6, 2739.000000, 4701.000000, 22.65000000, 'Sólido', '[Xe] 4f¹⁴ 5d⁷ 6s²', 'Metal de transição'),
(71, 'Pt', 'Platina', 78, 195.080000, 10, 6, 2041.400000, 4098.000000, 21.45000000, 'Sólido', '[Xe] 4f¹⁴ 5d⁹ 6s¹', 'Metal de transição'),
(72, 'Tb', 'Térbio', 65, 158.930000, 3, 6, 1356.000000, 3123.000000, 8.23000000, 'Sólido', '[Xe] 4f⁹ 6s²', 'Lantanídeo'),
(73, 'Au', 'Ouro', 79, 196.970000, 11, 6, 1064.180000, 2856.000000, 19.32000000, 'Sólido', '[Xe] 4f¹⁴ 5d¹⁰ 6s¹', 'Metal de transição'),
(74, 'Dy', 'Disprósio', 66, 162.500000, 3, 6, 1412.000000, 2567.000000, 8.55000000, 'Sólido', '[Xe] 4f¹⁰ 6s²', 'Lantanídeo'),
(75, 'Hg', 'Mercúrio', 80, 200.590000, 12, 6, -38.830000, 356.730000, 13.53000000, 'Líquido', '[Xe] 4f¹⁴ 5d¹⁰ 6s²', 'Metal de transição'),
(76, 'Ho', 'Hólmio', 67, 164.930000, 3, 6, 1474.000000, 2720.000000, 8.79000000, 'Sólido', '[Xe] 4f¹¹ 6s²', 'Lantanídeo'),
(77, 'Er', 'Érbio', 68, 167.260000, 3, 6, 1522.000000, 2510.000000, 9.07000000, 'Sólido', '[Xe] 4f¹² 6s²', 'Lantanídeo'),
(78, 'Tl', 'Tálio', 81, 204.380000, 13, 6, 304.000000, 1473.000000, 11.85000000, 'Sólido', '[Xe] 4f¹⁴ 5d¹⁰ 6s² 6p¹', 'Metal'),
(79, 'Pb', 'Chumbo', 82, 207.200000, 14, 6, 327.500000, 1749.000000, 11.34000000, 'Sólido', '[Xe] 4f¹⁴ 5d¹⁰ 6s² 6p²', 'Metal'),
(80, 'Tm', 'Túlio', 69, 168.930000, 3, 6, 1545.000000, 1727.000000, 9.32000000, 'Sólido', '[Xe] 4f¹³ 6s²', 'Lantanídeo'),
(81, 'Bi', 'Bismuto', 83, 208.980000, 15, 6, 271.300000, 1564.000000, 9.78000000, 'Sólido', '[Xe] 4f¹⁴ 5d¹⁰ 6s² 6p³', 'Metal'),
(82, 'Yb', 'Itérbio', 70, 173.050000, 3, 6, 819.000000, 1196.000000, 6.90000000, 'Sólido', '[Xe] 4f¹⁴ 6s²', 'Lantanídeo'),
(83, 'Lu', 'Lutécio', 71, 174.970000, 3, 6, 1663.000000, 3402.000000, 9.84000000, 'Sólido', '[Xe] 4f¹⁴ 5d¹ 6s²', 'Lantanídeo'),
(84, 'Po', 'Polônio', 84, 209.000000, 16, 6, 254.000000, 962.000000, 9.20000000, 'Sólido', '[Xe] 4f¹⁴ 5d¹⁰ 6s² 6p⁴', 'Semimetal'),
(85, 'At', 'Ástato', 85, 210.000000, 17, 6, 302.000000, 337.000000, 7.00000000, 'Sólido', '[Xe] 4f¹⁴ 5d¹⁰ 6s² 6p⁵', 'Halogênio'),
(86, 'Rn', 'Radônio', 86, 222.000000, 18, 6, -71.000000, -61.700000, 0.00973000, 'Gasoso', '[Xe] 4f¹⁴ 5d¹⁰ 6s² 6p⁶', 'Gás nobre'),
(87, 'Fr', 'Frâncio', 87, 223.000000, 1, 7, 27.000000, 677.000000, 1.87000000, 'Sólido', '[Rn] 7s¹', 'Metal alcalino'),
(88, 'Ra', 'Rádio', 88, 226.000000, 2, 7, 700.000000, 1737.000000, 5.00000000, 'Sólido', '[Rn] 7s²', 'Metal alcalino-terroso'),
(89, 'Ac', 'Actínio', 89, 227.000000, 3, 7, 1050.000000, 3200.000000, 10.07000000, 'Sólido', '[Rn] 6d¹ 7s²', 'Actinídeo'),
(90, 'Am', 'Amerício', 95, 243.000000, 13, 7, 1176.000000, 2011.000000, 13.67000000, 'Sólido', '[Rn] 5f⁷ 7s²', 'Actinídeo'),
(91, 'Bk', 'Berquélio', 97, 247.000000, NULL, 7, 1323.000000, 2627.000000, 14.78000000, 'Sólido', '[Rn] 5f⁹ 7s²', 'Actinídeo'),
(92, 'Cf', 'Califórnio', 98, 251.000000, NULL, 7, 1173.000000, NULL, 15.10000000, 'Sólido', '[Rn] 5f¹⁰ 7s²', 'Actinídeo'),
(93, 'Cm', 'Cúrio', 96, 247.000000, NULL, 7, 1345.000000, NULL, 13.51000000, 'Sólido', '[Rn] 5f⁸ 7s²', 'Actinídeo'),
(94, 'Es', 'Einstênio', 99, 252.000000, NULL, 7, 883.000000, NULL, 8.84000000, 'Sólido', '[Rn] 5f¹¹ 7s²', 'Actinídeo'),
(95, 'Fm', 'Férmio', 100, 257.000000, NULL, 7, 1527.000000, NULL, NULL, 'Sólido', '[Rn] 5f¹² 7s²', 'Actinídeo'),
(96, 'Lr', 'Laurêncio', 103, 266.000000, NULL, 7, 1627.000000, NULL, NULL, 'Sólido', '[Rn] 5f¹⁴ 7s²', 'Actinídeo'),
(97, 'Md', 'Mendelévio', 101, 258.000000, NULL, 7, 1100.000000, NULL, NULL, 'Sólido', '[Rn] 5f¹³ 7s²', 'Actinídeo'),
(98, 'No', 'Nobélio', 102, 259.000000, NULL, 7, 827.000000, NULL, NULL, 'Sólido', '[Rn] 5f¹⁴ 7s² 7p¹', 'Actinídeo'),
(99, 'Np', 'Neptúnio', 93, 237.000000, NULL, 7, 640.000000, 3900.000000, 20.45000000, 'Sólido', '[Rn] 5f⁴ 6d¹ 7s²', 'Actinídeo'),
(100, 'Pa', 'Protactínio', 91, 231.036000, NULL, 7, 1841.000000, 4300.000000, 15.37000000, 'Sólido', '[Rn] 5f² 6d¹ 7s²', 'Actinídeo'),
(101, 'Pu', 'Plutônio', 94, 244.000000, NULL, 7, 640.000000, 3235.000000, 19.86000000, 'Sólido', '[Rn] 5f⁶ 7s²', 'Actinídeo'),
(102, 'Th', 'Tório', 90, 232.038000, NULL, 7, 1750.000000, 4820.000000, 11.72000000, 'Sólido', '[Rn] 6d² 7s²', 'Actinídeo'),
(103, 'U', 'Urânio', 92, 238.029000, NULL, 7, 1132.200000, 4131.000000, 19.05000000, 'Sólido', '[Rn] 5f³ 6d¹ 7s²', 'Actinídeo'),
(104, 'Rf', 'Rutherfórdio', 104, 267.000000, 4, 7, 2100.000000, NULL, NULL, 'Sólido', '[Rn] 5f¹⁴ 6d² 7s²', 'Metal de transição'),
(105, 'Db', 'Dúbnio', 105, 268.000000, 5, 7, NULL, NULL, NULL, 'Sólido', '[Rn] 5f¹⁴ 6d³ 7s²', 'Metal de transição'),
(106, 'Sg', 'Seabórgio', 106, 269.000000, 6, 7, NULL, NULL, NULL, 'Sólido', '[Rn] 5f¹⁴ 6d⁴ 7s²', 'Metal de transição'),
(107, 'Bh', 'Bório', 107, 270.000000, 7, 7, NULL, NULL, NULL, 'Sólido', '[Rn] 5f¹⁴ 6d⁵ 7s²', 'Metal de transição'),
(108, 'Hs', 'Hássio', 108, 277.000000, 8, 7, NULL, NULL, NULL, 'Sólido', '[Rn] 5f¹⁴ 6d⁶ 7s²', 'Metal de transição'),
(109, 'Mt', 'Meitnério', 109, 278.000000, 9, 7, NULL, NULL, NULL, 'Sólido', '[Rn] 5f¹⁴ 6d⁷ 7s²', 'Metal de transição'),
(110, 'Ds', 'Darmstádio', 110, 281.000000, 10, 7, NULL, NULL, NULL, 'Sólido', '[Rn] 5f¹⁴ 6d⁹ 7s²', 'Metal de transição'),
(111, 'Rg', 'Roentgênio', 111, 282.000000, 11, 7, NULL, NULL, NULL, 'Sólido', '[Rn] 5f¹⁴ 6d¹⁰ 7s²', 'Metal de transição'),
(112, 'Cn', 'Copernício', 112, 285.000000, 12, 7, NULL, NULL, NULL, 'Sólido', '[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p¹', 'Metal de transição'),
(113, 'Nh', 'Nihônio', 113, 286.000000, 13, 7, NULL, NULL, NULL, 'Sólido', '[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p²', 'Metal de transição'),
(114, 'Fl', 'Fleróvio', 114, 289.000000, 14, 7, NULL, NULL, NULL, 'Sólido', '[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p³', 'Metal de transição'),
(115, 'Mc', 'Moscóvio', 115, 290.000000, 15, 7, NULL, NULL, NULL, 'Sólido', '[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p⁴', 'Metal de transição'),
(116, 'Lv', 'Livermório', 116, 293.000000, 16, 7, NULL, NULL, NULL, 'Sólido', '[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p⁵', 'Metal de transição'),
(117, 'Ts', 'Tenessino', 117, 294.000000, 17, 7, NULL, NULL, NULL, 'Sólido', '[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p⁶', 'Metal de transição'),
(118, 'Og', 'Oganessônio', 118, 294.000000, 18, 7, NULL, NULL, NULL, 'Sólido', '[Rn] 5f¹⁴ 6d¹⁰ 7s² 7p⁶', 'Desconhecido');

-- --------------------------------------------------------

--
-- Estrutura para tabela `etapa`
--

CREATE TABLE `etapa` (
  `id` int UNSIGNED NOT NULL,
  `projeto` int UNSIGNED DEFAULT NULL,
  `nome` varchar(255) DEFAULT NULL,
  `descricao` varchar(255) DEFAULT NULL,
  `ordem` tinyint DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Despejando dados para a tabela `etapa`
--

INSERT INTO `etapa` (`id`, `projeto`, `nome`, `descricao`, `ordem`, `createdAt`, `updatedAt`) VALUES
(130, 46, 'Mistura de Sais', 'Fazer a mistura de sais', 0, '2024-09-04 18:25:24', '2024-09-04 18:25:24'),
(132, 47, 'Tancagem', 'mistura', 0, '2024-09-05 02:55:45', '2024-09-05 02:55:45'),
(133, 48, 'teste', 'teste', 0, '2024-09-14 08:58:42', '2024-09-14 08:58:42'),
(135, 50, 'teste1509ETP', 'teste1509ETPS', 0, '2024-09-15 09:21:32', '2024-09-15 09:21:43'),
(136, 52, 'Tancagem', 'Mistura', 0, '2024-09-17 19:07:17', '2024-09-17 19:07:17'),
(137, 49, 'teste2', 'teste2', 0, '2024-09-21 10:51:51', '2024-09-21 10:51:51'),
(138, 54, '1', '1', 0, '2024-10-15 13:09:01', '2024-10-15 13:09:01');

-- --------------------------------------------------------

--
-- Estrutura para tabela `etapa_mp`
--

CREATE TABLE `etapa_mp` (
  `id` int UNSIGNED NOT NULL,
  `etapa` int UNSIGNED DEFAULT NULL,
  `mp` int UNSIGNED DEFAULT NULL,
  `percentual` double DEFAULT NULL,
  `tempo_agitacao` varchar(10) DEFAULT NULL,
  `observacao` varchar(1000) DEFAULT NULL,
  `ordem` tinyint DEFAULT NULL,
  `lote` varchar(20) DEFAULT '',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Despejando dados para a tabela `etapa_mp`
--

INSERT INTO `etapa_mp` (`id`, `etapa`, `mp`, `percentual`, `tempo_agitacao`, `observacao`, `ordem`, `lote`, `createdAt`, `updatedAt`) VALUES
(456, 130, 142, 5.12, '0', '', 8, '', '2024-09-04 18:26:47', '2024-09-17 18:35:30'),
(460, 130, 139, 28.57, '0', '', 1, '', '2024-09-04 18:32:05', '2024-09-17 18:35:35'),
(461, 130, 143, 4.285714285714286, '0', '', 2, '', '2024-09-04 18:32:20', '2024-09-17 18:35:35'),
(462, 130, 133, 31.612903225806456, '0', '', 3, '', '2024-09-04 18:32:41', '2024-09-17 18:35:30'),
(469, 130, 145, 2, '0', '', 4, '', '2024-09-04 18:50:07', '2024-09-17 18:35:30'),
(470, 130, 144, 4, '0', '', 5, '', '2024-09-04 18:50:25', '2024-09-17 18:35:30'),
(471, 130, 146, 1.2, '0', '', 6, '', '2024-09-04 18:50:37', '2024-09-17 18:35:30'),
(481, 130, 134, 23.2, '0', '', 7, '', '2024-09-05 02:50:40', '2024-09-17 18:35:30'),
(485, 132, 134, 50, '0', '', 0, '', '2024-09-05 02:55:59', '2024-09-05 02:55:59'),
(486, 132, 144, 25, '0', '', 0, '', '2024-09-05 02:56:20', '2024-09-05 02:56:20'),
(487, 132, 145, 25, '0', '', 0, '', '2024-09-05 02:56:28', '2024-09-05 02:56:28'),
(488, 133, 143, 42.85714285714285, '0', '', 0, '', '2024-09-14 09:03:01', '2024-09-14 09:03:01'),
(490, 133, 145, 15, '0', '', 0, '', '2024-09-14 10:12:48', '2024-09-14 10:12:48'),
(500, 133, 134, 15, '0', 'asdf', 0, '', '2024-09-14 14:13:00', '2024-09-14 14:15:52'),
(507, 137, 144, 5, '1', '', 2, 'DRS5544', '2024-09-14 16:30:46', '2024-09-23 11:18:11'),
(511, 135, 134, 10, '0', '', 0, '', '2024-09-15 09:23:33', '2024-09-15 09:23:33'),
(512, 135, 146, 66.66666666666667, '0', '', 0, '', '2024-09-15 09:23:35', '2024-09-15 09:23:35'),
(513, 135, 145, 20, '0', '', 0, '', '2024-09-15 09:38:57', '2024-09-15 09:38:57'),
(514, 136, 155, 11.11111111111111, '0', '', 0, '', '2024-09-17 19:09:28', '2024-09-17 19:09:28'),
(515, 136, 154, 15.625, '0', '', 0, '', '2024-09-17 19:09:33', '2024-09-17 19:09:33'),
(516, 136, 141, 52.63157894736842, '0', '', 0, '', '2024-09-17 19:11:01', '2024-09-17 19:11:01'),
(517, 136, 146, 3.533333333333333, '0', '', 0, '', '2024-09-17 19:12:07', '2024-09-17 19:12:07'),
(518, 136, 134, 17.1, '0', '', 0, '', '2024-09-17 19:13:08', '2024-09-17 19:13:08'),
(520, 137, 145, 3, '0', '', 1, '', '2024-09-22 08:13:35', '2024-09-23 11:18:11'),
(521, 137, 141, 1, '0', '', 3, 'DRS4444', '2024-09-22 08:14:09', '2024-09-23 11:18:11'),
(522, 137, 155, 39, '0', '', 6, 'DRS5544', '2024-09-22 08:42:15', '2024-09-23 11:18:11'),
(523, 137, 133, 0.4, '0', '', 5, '', '2024-09-22 08:43:40', '2024-09-23 11:18:11'),
(524, 137, 140, 6.6, '0', '', 6, '', '2024-09-22 08:44:59', '2024-09-23 11:18:11'),
(526, 137, 134, 45, '0', '', 0, '', '2024-09-23 11:18:53', '2024-09-23 11:18:53'),
(527, 138, 156, 36.36363636363637, '0', '', 0, '', '2024-10-15 13:10:25', '2024-10-15 13:10:25'),
(528, 138, 143, 8.571428571428571, '0', '', 0, '', '2024-10-15 13:10:38', '2024-10-15 13:10:38');

-- --------------------------------------------------------

--
-- Estrutura para tabela `garantia`
--

CREATE TABLE `garantia` (
  `id` int UNSIGNED NOT NULL,
  `materia_prima` int UNSIGNED NOT NULL,
  `nutriente` int UNSIGNED NOT NULL,
  `percentual` double UNSIGNED DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Despejando dados para a tabela `garantia`
--

INSERT INTO `garantia` (`id`, `materia_prima`, `nutriente`, `percentual`, `createdAt`, `updatedAt`) VALUES
(350, 133, 50, 31, '2024-08-21 18:26:29', '2024-08-21 18:26:29'),
(359, 134, 23, 100, '2024-08-21 19:02:30', '2024-08-21 19:02:30'),
(361, 139, 52, 35, '2024-09-04 16:26:00', '2024-09-04 16:26:00'),
(363, 139, 51, 17, '2024-09-04 16:26:21', '2024-09-04 16:26:21'),
(364, 140, 53, 17, '2024-09-04 16:29:29', '2024-09-04 16:29:29'),
(365, 141, 53, 19, '2024-09-04 16:32:02', '2024-09-04 16:32:02'),
(367, 142, 55, 39, '2024-09-04 18:04:15', '2024-09-04 18:04:15'),
(368, 143, 56, 35, '2024-09-04 18:06:27', '2024-09-04 18:06:27'),
(370, 143, 51, 17, '2024-09-04 18:07:13', '2024-09-04 18:07:13'),
(371, 144, 57, 100, '2024-09-04 18:13:34', '2024-09-04 18:13:34'),
(372, 145, 58, 100, '2024-09-04 18:20:06', '2024-09-04 18:20:06'),
(375, 141, 54, 18, '2024-09-04 18:40:54', '2024-09-04 18:40:54'),
(376, 133, 51, 18, '2024-09-04 18:53:21', '2024-09-04 18:53:21'),
(398, 146, 54, 15, '2024-09-08 13:13:05', '2024-09-08 13:13:05'),
(399, 146, 23, 15, '2024-09-08 13:13:09', '2024-09-08 13:13:09'),
(400, 146, 59, 15, '2024-09-08 13:13:19', '2024-09-08 13:13:19'),
(401, 146, 57, 15, '2024-09-08 13:13:25', '2024-09-08 13:13:25'),
(402, 151, 23, 10, '2024-09-15 09:05:29', '2024-09-15 09:05:29'),
(403, 151, 57, 10, '2024-09-15 09:05:41', '2024-09-15 09:05:41'),
(405, 151, 54, 10, '2024-09-15 09:06:18', '2024-09-15 09:06:18'),
(407, 151, 50, 10, '2024-09-15 09:33:37', '2024-09-15 09:33:37'),
(408, 152, 67, 100, '2024-09-17 19:02:02', '2024-09-17 19:02:02'),
(409, 154, 64, 32, '2024-09-17 19:04:17', '2024-09-17 19:04:17'),
(410, 155, 64, 45, '2024-09-17 19:05:38', '2024-09-17 19:05:38'),
(411, 156, 82, 55, '2024-10-15 12:54:39', '2024-10-15 12:54:39'),
(413, 156, 84, 22, '2024-10-15 12:55:38', '2024-10-15 12:55:38'),
(415, 156, 85, 2, '2024-10-15 13:02:08', '2024-10-15 13:02:08');

-- --------------------------------------------------------

--
-- Estrutura para tabela `materia_prima`
--

CREATE TABLE `materia_prima` (
  `id` int UNSIGNED NOT NULL,
  `codigo` varchar(50) DEFAULT NULL,
  `nome` varchar(100) DEFAULT NULL,
  `formula` varchar(50) DEFAULT NULL,
  `cas_number` varchar(50) DEFAULT NULL,
  `densidade` double UNSIGNED DEFAULT NULL,
  `descricao` varchar(1000) DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Despejando dados para a tabela `materia_prima`
--

INSERT INTO `materia_prima` (`id`, `codigo`, `nome`, `formula`, `cas_number`, `densidade`, `descricao`, `createdAt`, `updatedAt`) VALUES
(133, '135', 'Sulfato de Manganês Mono', 'MnSO4.H2O', '10034-96-5', 1, 'Sal Inorgânico. ', '2024-08-21 18:10:58', '2024-09-04 16:23:15'),
(134, '173', 'Água', 'H2O', '7732-18-5', 1, 'Solvente', '2024-08-21 18:11:39', '2024-08-21 18:11:39'),
(139, '142', 'Sulfato de Zinco Mono', 'ZnSO4.H2O', '7446-19-7', 1, 'Sal Inorgânico', '2024-09-04 16:25:32', '2024-09-04 16:25:32'),
(140, '124', 'Ácido Bórico', 'H3BO3', '10043-35-3', 1, 'Acidificante', '2024-09-04 16:29:13', '2024-09-04 16:29:13'),
(141, '00', 'Octaborato de Potássio', 'K2HPO4', '7758-11-4', 1, 'Sal Inorgânico', '2024-09-04 16:31:41', '2024-09-04 16:31:41'),
(142, '133', 'Molibdato de Sódio', 'Na2MoO4', '10102-40-6', 1, 'Sal Inorgânico ', '2024-09-04 18:03:35', '2024-09-04 18:03:35'),
(143, '568', 'Sulfato de Cobre Mono', 'CuSO4.H2O', '7758-99-8', 1, 'Sal Inorgânico ', '2024-09-04 18:06:08', '2024-09-04 18:06:08'),
(144, '146', 'Ácido Cítrico', 'C6H8O7', '77-92-9 ', 1, 'Acidificante', '2024-09-04 18:12:45', '2024-09-04 18:12:45'),
(145, '2919', 'L-Glicina', 'C6H8O7', '56-40-6', 1, 'aminoácido', '2024-09-04 18:19:43', '2024-09-04 18:19:43'),
(146, '462', 'EDTA Dissódico', 'C10H14N2Na2O8 · 2H2O', '6381-92-6', 1, 'Agente Quelante', '2024-09-04 18:22:00', '2024-09-04 18:22:00'),
(151, '3245', 'teste1509mp', 'teste1509mp', 'teste1509mp', 1.22, 'teste1509mp', '2024-09-15 08:59:55', '2024-09-15 08:59:55'),
(152, '145', 'Ácido sulfurico', 'H2SO4', '123131', 1.22, 'Produto Ácidificante', '2024-09-17 19:01:33', '2024-09-17 19:01:33'),
(154, '1678', 'Uran', 'csas', '1234', 1, 'iyuohjkd', '2024-09-17 19:02:50', '2024-09-17 19:02:50'),
(155, '134', 'Ureia', 'as', '144', 1.22, 'asas', '2024-09-17 19:05:14', '2024-09-17 19:05:14'),
(156, '123456', 'xxyy', 'xxyy', '123456', 1.2, 'xxyy33', '2024-10-15 12:53:52', '2024-10-15 12:53:52');

-- --------------------------------------------------------

--
-- Estrutura para tabela `nutriente`
--

CREATE TABLE `nutriente` (
  `id` int UNSIGNED NOT NULL,
  `nome` varchar(100) DEFAULT NULL,
  `formula` varchar(100) DEFAULT NULL,
  `visivel` tinyint UNSIGNED DEFAULT '1',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Despejando dados para a tabela `nutriente`
--

INSERT INTO `nutriente` (`id`, `nome`, `formula`, `visivel`, `createdAt`, `updatedAt`) VALUES
(23, 'Água', 'H2O', 1, '2024-08-21 17:44:22', '2024-09-21 13:06:35'),
(50, 'Manganês', 'Mn', 1, '2024-08-21 18:16:01', '2024-09-04 16:21:45'),
(51, 'Enxofre', 'S', 1, '2024-09-04 16:20:37', '2024-09-04 16:20:37'),
(52, 'Zinco', 'Zn', 1, '2024-09-04 16:24:17', '2024-09-04 16:24:17'),
(53, 'Boro', 'B', 1, '2024-09-04 16:28:16', '2024-09-04 16:28:16'),
(54, 'Potássio', 'K2O', 1, '2024-09-04 16:30:07', '2024-09-04 16:30:07'),
(55, 'Molibdênio ', 'Mo', 1, '2024-09-04 18:00:49', '2024-09-04 18:00:49'),
(56, 'Cobre', 'Cu', 1, '2024-09-04 18:04:45', '2024-09-04 18:04:45'),
(57, 'Ácido Cítrico', 'C6H8O7', 0, '2024-09-04 18:11:31', '2024-10-06 09:50:00'),
(58, 'aminoácido', 'C2H5NO2', 1, '2024-09-04 18:17:45', '2024-09-04 18:17:45'),
(59, 'Quelante', 'C10H14N2Na2O8 · 2H2O', 1, '2024-09-04 18:21:01', '2024-09-04 18:21:01'),
(64, 'Nitrogenio', 'N', 1, '2024-09-17 18:57:22', '2024-09-17 18:57:22'),
(67, 'Ácidificante', 'H2SO4', 0, '2024-09-17 19:00:34', '2024-09-21 00:55:06'),
(82, 'xxx', 'x3', 1, '2024-10-15 12:50:09', '2024-10-15 12:50:09'),
(84, 'yyy', 'y3', 1, '2024-10-15 12:50:52', '2024-10-15 12:50:52'),
(85, 'eee', 'e3', 1, '2024-10-15 13:01:47', '2024-10-15 13:01:47');

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `percentual_nutriente_projeto`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `percentual_nutriente_projeto` (
`projeto_id` int unsigned
,`projeto_nome` varchar(255)
,`nutriente_id` int unsigned
,`nutriente_nome` varchar(100)
,`percentual_nutriente` double
);

-- --------------------------------------------------------

--
-- Estrutura para tabela `projeto`
--

CREATE TABLE `projeto` (
  `id` int UNSIGNED NOT NULL,
  `codigo` varchar(20) DEFAULT NULL,
  `nome` varchar(255) DEFAULT NULL,
  `cliente` varchar(255) DEFAULT NULL,
  `descricao` text,
  `data_inicio` date DEFAULT NULL,
  `data_termino` date DEFAULT NULL,
  `densidade` double UNSIGNED DEFAULT NULL,
  `ph` varchar(255) DEFAULT NULL,
  `tipo` varchar(255) DEFAULT NULL,
  `aplicacao` json DEFAULT NULL,
  `natureza_fisica` varchar(255) DEFAULT NULL,
  `status` json DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Despejando dados para a tabela `projeto`
--

INSERT INTO `projeto` (`id`, `codigo`, `nome`, `cliente`, `descricao`, `data_inicio`, `data_termino`, `densidade`, `ph`, `tipo`, `aplicacao`, `natureza_fisica`, `status`, `createdAt`, `updatedAt`) VALUES
(46, '222222', 'MS Cana', NULL, '', '2024-09-03', '2024-09-03', 1, '4,00 - 5,00', 'Mineral Misto/Simples', '[\"Foliar\", \"Solo\"]', 'Sólido', '[{\"status\": \"Inicializando\", \"data_alteracao\": \"2024-09-05 02:28:01.000000\", \"id_responsavel\": \"2\"}, {\"status\": \"Inicializando\", \"data_alteracao\": \"2024-09-04 18:24:25.000000\", \"id_responsavel\": \"1\"}]', '2024-09-04 18:24:25', '2024-09-30 11:17:52'),
(47, 'D0717', 'TS AAAA', NULL, 'ferti', '2024-09-03', '2024-09-03', 1, '6,00 - 7,00', 'Mineral Misto/Simples', '[\"Foliar\", \"Fertirrigação\", \"Solo\", \"Hidroponia\"]', 'Fluido (Solução)', '[{\"status\": \"Em Andamento\", \"data_alteracao\": \"2024-09-09 13:30:22.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Em Andamento\", \"data_alteracao\": \"2024-09-05 02:52:32.000000\", \"id_responsavel\": \"1\"}]', '2024-09-05 02:52:32', '2024-09-30 11:48:26'),
(48, 'PROJ105', 'TESTE ANDERSON', 'ANDERSOON', 'TESTE ANDERSON DESCRIÇÃO', '2024-09-03', '2024-09-07', 1.22, '10', 'Organomineral', '[\"Foliar\", \"Pulverização\"]', 'Fluido (Solução)', '[{\"status\": \"Finalizado\", \"data_alteracao\": \"2024-09-14 14:19:07.000000\", \"id_responsavel\": \"2\"}, {\"status\": \"Reiniciado\", \"data_alteracao\": \"2024-09-14 14:18:38.000000\", \"id_responsavel\": \"2\"}, {\"status\": \"Reiniciado\", \"data_alteracao\": \"2024-09-14 14:17:49.000000\", \"id_responsavel\": \"2\"}, {\"status\": \"Finalizados\", \"data_alteracao\": \"2024-09-14 13:27:35.000000\", \"id_responsavel\": \"2\"}, {\"status\": \"Não Iniciado\", \"data_alteracao\": \"2024-09-14 08:13:45.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Não Iniciado\", \"data_alteracao\": \"2024-09-14 08:11:39.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Não Iniciado\", \"data_alteracao\": \"2024-09-14 07:53:39.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Não Iniciado\", \"data_alteracao\": \"2024-09-14 07:53:07.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Não Iniciado\", \"data_alteracao\": \"2024-09-14 07:52:56.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Não Iniciado\", \"data_alteracao\": \"2024-09-14 07:52:48.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Não Iniciado\", \"data_alteracao\": \"2024-09-09 13:31:21.000000\", \"id_responsavel\": \"1\"}]', '2024-09-09 13:31:21', '2024-09-14 14:19:49'),
(49, 'PRO-489', 'Teste de consulta detalhada', 'Wpa', 'Teste de consulta detalhada', '2024-07-25', '2024-08-25', 1.4, '10', 'Organomineral', '[\"Foliar\", \"Fertirrigação\", \"Solo\"]', 'Fluido (Solução)', '[{\"status\": \"Inicializando\", \"data_alteracao\": \"2024-09-22 08:49:05.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Inicializando\", \"data_alteracao\": \"2024-09-21 11:47:29.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Inicializando\", \"data_alteracao\": \"2024-09-21 11:39:41.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Inicializando\", \"data_alteracao\": \"2024-09-21 10:52:36.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Inicializando\", \"data_alteracao\": \"2024-09-15 08:20:41.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Inicializando\", \"data_alteracao\": \"2024-09-15 08:20:34.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Inicializando\", \"data_alteracao\": \"2024-09-15 08:20:25.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Inicializando\", \"data_alteracao\": \"2024-09-15 08:17:13.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Inicializando\", \"data_alteracao\": \"2024-09-15 08:14:45.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Inicializando\", \"data_alteracao\": \"2024-09-14 14:31:40.000000\", \"id_responsavel\": \"2\"}]', '2024-09-14 14:31:40', '2024-09-27 19:21:58'),
(50, 'dicMqn', 'ffFAeb', 'bbFbKY', 'fGVXeE', '2024-09-12', '2024-09-18', 1.22, '10', 'Organomineral', '[\"Foliar\"]', 'Fluido (Suspensão)', '[{\"status\": \"Inicializando\", \"data_alteracao\": \"2024-09-15 09:15:27.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Inicializando\", \"data_alteracao\": \"2024-09-15 09:15:14.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Inicializando\", \"data_alteracao\": \"2024-09-15 09:15:07.000000\", \"id_responsavel\": \"1\"}, {\"status\": \"Inicializando\", \"data_alteracao\": \"2024-09-15 09:14:02.000000\", \"id_responsavel\": \"1\"}]', '2024-09-15 09:14:02', '2024-09-27 19:32:34'),
(52, '18523-192', 'Testeggg', 'B2B', '', '2024-09-17', '2024-09-17', 1.24, '7,00 - 8,00', 'Mineral Misto/Simples', '[\"Foliar\", \"Fertirrigação\"]', 'Fluido (Solução)', '[{\"status\": \"Inicializando\", \"data_alteracao\": \"2024-09-17 19:06:49.000000\", \"id_responsavel\": \"1\"}]', '2024-09-17 19:06:49', '2024-10-04 12:50:43'),
(54, 'xxx', 'xxx', 'xxx', 'xxxx', '2024-10-08', '2024-11-09', 1.2, '5-6', 'Mineral Misto/Simples', '[\"Foliar\", \"Solo\"]', 'Fluido (Solução)', '[{\"status\": \"Não Iniciado\", \"data_alteracao\": \"2024-10-15 13:08:11.000000\", \"id_responsavel\": \"1\"}]', '2024-10-15 13:08:11', '2024-10-15 13:45:51');

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `projeto_detalhado`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `projeto_detalhado` (
`projeto_id` int unsigned
,`projeto_codigo` varchar(20)
,`projeto_nome` varchar(255)
,`projeto_cliente` varchar(255)
,`projeto_descricao` text
,`projeto_data_inicio` date
,`projeto_data_termino` date
,`projeto_densidade` double unsigned
,`projeto_ph` varchar(255)
,`projeto_tipo` varchar(255)
,`projeto_aplicacao` json
,`projeto_natureza_fisica` varchar(255)
,`projeto_status` json
,`projeto_createdAt` datetime
,`projeto_updatedAt` datetime
,`etapa_id` int unsigned
,`etapa_nome` varchar(255)
,`etapa_descricao` varchar(255)
,`etapa_ordem` tinyint
,`etapa_mp_id` int unsigned
,`etapa_mp_percentual` double
,`etapa_mp_tempo_agitacao` varchar(10)
,`etapa_mp_observacao` varchar(1000)
,`etapa_mp_lote` varchar(20)
,`etapa_mp_ordem` tinyint
,`materia_prima_id` int unsigned
,`materia_prima_codigo` varchar(50)
,`materia_prima_nome` varchar(100)
,`materia_prima_formula` varchar(50)
,`materia_prima_cas_number` varchar(50)
,`materia_prima_densidade` double unsigned
,`materia_prima_descricao` varchar(1000)
,`garantia_id` int unsigned
,`garantia_percentual` double unsigned
,`nutriente_id` int unsigned
,`nutriente_nome` varchar(100)
,`nutriente_formula` varchar(100)
,`nutriente_visivel` tinyint unsigned
,`percentual_origem` double
,`parcial_densidade` double
);

-- --------------------------------------------------------

--
-- Estrutura para tabela `token`
--

CREATE TABLE `token` (
  `usuario` int UNSIGNED NOT NULL,
  `chave_token` varchar(255) DEFAULT NULL,
  `validade` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `usuario`
--

CREATE TABLE `usuario` (
  `id` int UNSIGNED NOT NULL,
  `nome` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `senha` varchar(255) DEFAULT NULL,
  `permissao` tinyint DEFAULT NULL,
  `avatar` varchar(100) DEFAULT NULL,
  `status` tinyint DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Despejando dados para a tabela `usuario`
--

INSERT INTO `usuario` (`id`, `nome`, `email`, `senha`, `permissao`, `avatar`, `status`, `createdAt`, `updatedAt`) VALUES
(1, 'Administrador', 'admin@sgqui.com', '$2a$10$LkIQ1SVYcFOS5NZyA2OPDewXmBLMMblMuAiGmagK/0s1Mc3gGZr2y', 0, NULL, 1, '2024-06-05 09:56:50', '2024-07-09 12:18:23'),
(2, 'Eliton Camargo', 'camargoliveira@gmail.com', '$2a$10$6g1S5cvl1NOSFg7xrhxagORPzmhwiqdVnJsTZKIVpNE9fqGqrq3W6', 0, NULL, 1, '2024-06-05 09:56:50', '2024-06-05 09:56:50');

-- --------------------------------------------------------

--
-- Estrutura para view `percentual_nutriente_projeto`
--
DROP TABLE IF EXISTS `percentual_nutriente_projeto`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `percentual_nutriente_projeto`  AS SELECT `projeto_detalhado`.`projeto_id` AS `projeto_id`, `projeto_detalhado`.`projeto_nome` AS `projeto_nome`, `projeto_detalhado`.`nutriente_id` AS `nutriente_id`, `projeto_detalhado`.`nutriente_nome` AS `nutriente_nome`, sum(`projeto_detalhado`.`percentual_origem`) AS `percentual_nutriente` FROM `projeto_detalhado` GROUP BY `projeto_detalhado`.`projeto_id`, `projeto_detalhado`.`nutriente_id` ;

-- --------------------------------------------------------

--
-- Estrutura para view `projeto_detalhado`
--
DROP TABLE IF EXISTS `projeto_detalhado`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `projeto_detalhado`  AS SELECT `projeto`.`id` AS `projeto_id`, `projeto`.`codigo` AS `projeto_codigo`, `projeto`.`nome` AS `projeto_nome`, `projeto`.`cliente` AS `projeto_cliente`, `projeto`.`descricao` AS `projeto_descricao`, `projeto`.`data_inicio` AS `projeto_data_inicio`, `projeto`.`data_termino` AS `projeto_data_termino`, `projeto`.`densidade` AS `projeto_densidade`, `projeto`.`ph` AS `projeto_ph`, `projeto`.`tipo` AS `projeto_tipo`, `projeto`.`aplicacao` AS `projeto_aplicacao`, `projeto`.`natureza_fisica` AS `projeto_natureza_fisica`, `projeto`.`status` AS `projeto_status`, `projeto`.`createdAt` AS `projeto_createdAt`, `projeto`.`updatedAt` AS `projeto_updatedAt`, `etapa`.`id` AS `etapa_id`, `etapa`.`nome` AS `etapa_nome`, `etapa`.`descricao` AS `etapa_descricao`, `etapa`.`ordem` AS `etapa_ordem`, `etapa_mp`.`id` AS `etapa_mp_id`, `etapa_mp`.`percentual` AS `etapa_mp_percentual`, `etapa_mp`.`tempo_agitacao` AS `etapa_mp_tempo_agitacao`, `etapa_mp`.`observacao` AS `etapa_mp_observacao`, `etapa_mp`.`lote` AS `etapa_mp_lote`, `etapa_mp`.`ordem` AS `etapa_mp_ordem`, `materia_prima`.`id` AS `materia_prima_id`, `materia_prima`.`codigo` AS `materia_prima_codigo`, `materia_prima`.`nome` AS `materia_prima_nome`, `materia_prima`.`formula` AS `materia_prima_formula`, `materia_prima`.`cas_number` AS `materia_prima_cas_number`, `materia_prima`.`densidade` AS `materia_prima_densidade`, `materia_prima`.`descricao` AS `materia_prima_descricao`, `garantia`.`id` AS `garantia_id`, `garantia`.`percentual` AS `garantia_percentual`, `nutriente`.`id` AS `nutriente_id`, `nutriente`.`nome` AS `nutriente_nome`, `nutriente`.`formula` AS `nutriente_formula`, `nutriente`.`visivel` AS `nutriente_visivel`, ((`garantia`.`percentual` * `etapa_mp`.`percentual`) / 100) AS `percentual_origem`, ((`etapa_mp`.`percentual` / 100) * `materia_prima`.`densidade`) AS `parcial_densidade` FROM (((((`projeto` left join `etapa` on((`projeto`.`id` = `etapa`.`projeto`))) left join `etapa_mp` on((`etapa`.`id` = `etapa_mp`.`etapa`))) left join `materia_prima` on((`etapa_mp`.`mp` = `materia_prima`.`id`))) left join `garantia` on((`materia_prima`.`id` = `garantia`.`materia_prima`))) left join `nutriente` on((`garantia`.`nutriente` = `nutriente`.`id`))) ORDER BY `projeto`.`id` ASC, `etapa`.`ordem` ASC, `etapa_mp`.`ordem` ASC, `etapa_mp`.`id` DESC ;

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `configuracao`
--
ALTER TABLE `configuracao`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `key` (`key`);

--
-- Índices de tabela `elemento`
--
ALTER TABLE `elemento`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `simbolo` (`simbolo`),
  ADD UNIQUE KEY `nome` (`nome`);

--
-- Índices de tabela `etapa`
--
ALTER TABLE `etapa`
  ADD PRIMARY KEY (`id`),
  ADD KEY `projeto` (`projeto`);

--
-- Índices de tabela `etapa_mp`
--
ALTER TABLE `etapa_mp`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `etapa` (`etapa`,`mp`),
  ADD KEY `mp` (`mp`),
  ADD KEY `etapa_2` (`etapa`);

--
-- Índices de tabela `garantia`
--
ALTER TABLE `garantia`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nutriente` (`nutriente`,`materia_prima`),
  ADD KEY `materia_prima` (`materia_prima`);

--
-- Índices de tabela `materia_prima`
--
ALTER TABLE `materia_prima`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo` (`codigo`),
  ADD UNIQUE KEY `nome` (`nome`);

--
-- Índices de tabela `nutriente`
--
ALTER TABLE `nutriente`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nome` (`nome`),
  ADD UNIQUE KEY `formula` (`formula`);

--
-- Índices de tabela `projeto`
--
ALTER TABLE `projeto`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `codigo` (`codigo`);

--
-- Índices de tabela `token`
--
ALTER TABLE `token`
  ADD PRIMARY KEY (`usuario`);

--
-- Índices de tabela `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `configuracao`
--
ALTER TABLE `configuracao`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de tabela `elemento`
--
ALTER TABLE `elemento`
  MODIFY `id` tinyint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=119;

--
-- AUTO_INCREMENT de tabela `etapa`
--
ALTER TABLE `etapa`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=139;

--
-- AUTO_INCREMENT de tabela `etapa_mp`
--
ALTER TABLE `etapa_mp`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=529;

--
-- AUTO_INCREMENT de tabela `garantia`
--
ALTER TABLE `garantia`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=417;

--
-- AUTO_INCREMENT de tabela `materia_prima`
--
ALTER TABLE `materia_prima`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=157;

--
-- AUTO_INCREMENT de tabela `nutriente`
--
ALTER TABLE `nutriente`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86;

--
-- AUTO_INCREMENT de tabela `projeto`
--
ALTER TABLE `projeto`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT de tabela `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `etapa`
--
ALTER TABLE `etapa`
  ADD CONSTRAINT `etapa_ibfk_1` FOREIGN KEY (`projeto`) REFERENCES `projeto` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Restrições para tabelas `etapa_mp`
--
ALTER TABLE `etapa_mp`
  ADD CONSTRAINT `etapa_mp_ibfk_2` FOREIGN KEY (`mp`) REFERENCES `materia_prima` (`id`),
  ADD CONSTRAINT `etapa_mp_ibfk_3` FOREIGN KEY (`etapa`) REFERENCES `etapa` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Restrições para tabelas `garantia`
--
ALTER TABLE `garantia`
  ADD CONSTRAINT `garantia_ibfk_1` FOREIGN KEY (`nutriente`) REFERENCES `nutriente` (`id`),
  ADD CONSTRAINT `garantia_ibfk_2` FOREIGN KEY (`materia_prima`) REFERENCES `materia_prima` (`id`);

--
-- Restrições para tabelas `token`
--
ALTER TABLE `token`
  ADD CONSTRAINT `token_ibfk_1` FOREIGN KEY (`usuario`) REFERENCES `usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

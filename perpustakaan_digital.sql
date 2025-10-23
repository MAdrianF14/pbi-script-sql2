-- FILE: perpustakaan_digital.sql
-- Database Sistem Informasi Perpustakaan Digital
-- M Adrian F - Web Developer


CREATE DATABASE IF NOT EXISTS perpustakaan_digital;

USE perpustakaan_digital;

DROP VIEW IF EXISTS ViewPeminjamanAktif;
DROP FUNCTION IF EXISTS HitungTotalPinjamanAnggota;
DROP PROCEDURE IF EXISTS GetBukuDipinjam;
DROP TRIGGER IF EXISTS AfterInsertPeminjaman;

DROP TABLE IF EXISTS LogPeminjaman;
DROP TABLE IF EXISTS Peminjaman;
DROP TABLE IF EXISTS Anggota;
DROP TABLE IF EXISTS Buku;
DROP TABLE IF EXISTS TabelCadangan;

DROP USER IF EXISTS 'web_perpus'@'localhost'; 


USE perpustakaan_digital; 

CREATE TABLE Anggota (
    id_anggota INT AUTO_INCREMENT,
    nama VARCHAR(100) NOT NULL,
    alamat TEXT,
    nomor_telepon VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    PRIMARY KEY (id_anggota)
);

CREATE TABLE Buku (
    isbn VARCHAR(20), 
    judul VARCHAR(255) NOT NULL,
    penulis VARCHAR(150),
    penerbit VARCHAR(150),
    tahun_terbit YEAR,
    stok INT DEFAULT 0,
    PRIMARY KEY (isbn)
);

CREATE TABLE Peminjaman (
    id_peminjaman INT AUTO_INCREMENT,
    id_anggota INT NOT NULL,
    isbn VARCHAR(20) NOT NULL,
    tanggal_pinjam DATE NOT NULL,
    tanggal_kembali DATE,
    status ENUM('Dipinjam', 'Selesai') DEFAULT 'Dipinjam',
    PRIMARY KEY (id_peminjaman), 
    
    FOREIGN KEY (id_anggota) REFERENCES Anggota(id_anggota) ON DELETE CASCADE,
    FOREIGN KEY (isbn) REFERENCES Buku(isbn) ON DELETE CASCADE
);

CREATE TABLE LogPeminjaman (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    aksi VARCHAR(50) NOT NULL,
    id_peminjaman_baru INT,
    waktu_aksi DATETIME DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE Anggota
ADD COLUMN tanggal_daftar DATE DEFAULT (CURRENT_DATE());

CREATE TABLE TabelUjiCoba (
    id INT PRIMARY KEY,
    data VARCHAR(50)
);
INSERT INTO TabelUjiCoba (id, data) VALUES (1, 'Data Uji Coba');
RENAME TABLE TabelUjiCoba TO TabelCadangan;


INSERT INTO Anggota (nama, alamat, nomor_telepon, email) VALUES
('Budi Santoso', 'Jl. Merdeka No. 10', '081234567890', 'budi.santoso@email.com'),
('Siti Aisyah', 'Perumahan Indah Blok C', '085098765432', 'siti.aisyah@email.com'),
('Joko Susilo', 'Kp. Durian Runtuh', '089911223344', 'joko.susilo@email.com');

INSERT INTO Buku (isbn, judul, penulis, penerbit, tahun_terbit, stok) VALUES
('978-6020332959', 'Filosofi Teras', 'Henry Manampiring', 'Kompas Gramedia', 2017, 5),
('978-9794336025', 'Laskar Pelangi', 'Andrea Hirata', 'Bentang Pustaka', 2005, 3),
('978-6237895000', 'Bumi Manusia', 'Pramoedya Ananta Toer', 'Hasta Mitra', 1980, 2);

INSERT INTO Peminjaman (id_anggota, isbn, tanggal_pinjam, tanggal_kembali, status) VALUES
(1, '978-6020332959', '2025-10-01', '2025-10-08', 'Selesai'),
(2, '978-9794336025', '2025-10-15', NULL, 'Dipinjam'),
(1, '978-6237895000', '2025-10-20', NULL, 'Dipinjam');

UPDATE Buku
SET stok = 4
WHERE isbn = '978-9794336025';

CREATE USER 'web_perpus'@'localhost' IDENTIFIED BY 'password_kuat';

GRANT SELECT, INSERT, UPDATE, DELETE ON perpustakaan_digital.* TO 'web_perpus'@'localhost';

FLUSH PRIVILEGES;

CREATE VIEW ViewPeminjamanAktif AS
SELECT
    P.id_peminjaman,
    A.nama AS Nama_Anggota,
    B.judul AS Judul_Buku,
    P.tanggal_pinjam
FROM Peminjaman P
JOIN Anggota A ON P.id_anggota = A.id_anggota
JOIN Buku B ON P.isbn = B.isbn
WHERE P.status = 'Dipinjam';

DELIMITER //

CREATE PROCEDURE GetBukuDipinjam()
BEGIN
    SELECT 
        A.nama AS Nama_Peminjam, 
        B.judul AS Judul_Buku, 
        P.tanggal_pinjam
    FROM Peminjaman P
    JOIN Anggota A ON P.id_anggota = A.id_anggota
    JOIN Buku B ON P.isbn = B.isbn
    WHERE P.status = 'Dipinjam'
    ORDER BY P.tanggal_pinjam DESC;
END //

DELIMITER ;

DELIMITER //

CREATE FUNCTION HitungTotalPinjamanAnggota(id_anggota_param INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_pinjaman INT;
    SELECT COUNT(*) INTO total_pinjaman
    FROM Peminjaman
    WHERE id_anggota = id_anggota_param;
    RETURN total_pinjaman;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER AfterInsertPeminjaman
AFTER INSERT ON Peminjaman
FOR EACH ROW
BEGIN
    INSERT INTO LogPeminjaman (aksi, id_peminjaman_baru)
    VALUES (CONCAT('INSERT Peminjaman ID: ', NEW.id_peminjaman), NEW.id_peminjaman);
END //

DELIMITER ;



SELECT * FROM Anggota;


SELECT * FROM ViewPeminjamanAktif;


CALL GetBukuDipinjam();

SELECT HitungTotalPinjamanAnggota(1) AS Total_Pinjaman_Budi;
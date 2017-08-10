CREATE DATABASE uvicorderofpi;
CREATE USER 'OrderAdmin'@'localhost' IDENTIFIED BY 'OrderAdmin';
GRANT ALL ON uvicorderofpi.* TO 'OrderAdmin'@'localhost';

BEGIN;
-- Create and use Database
CREATE DATABASE IF NOT EXISTS clark CHARACTER SET utf8;
USE clark;

-- Create Tables
CREATE TABLE IF NOT EXISTS user (
    id VARCHAR(36) PRIMARY KEY GENERATED ALWAYS AS UUID(),
    name VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    is_admin BIT DEFAULT 0,
    last_login DATETIME,
    created_at DATETIME DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS log (
    id VARCHAR(36) PRIMARY KEY GENERATED ALWAYS AS UUID(),
    service_name VARCHAR NOT NULL,
    severity ENUM('info', 'trace', 'warn', 'error', 'fatal') NOT NULL,
    message VARCHAR NOT NULL,
    created_at DATETIME DEFAULT NOW()
);
COMMIT;
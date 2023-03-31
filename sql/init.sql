-- This database should never be available over the internet

BEGIN;
-- Create and use Database
CREATE DATABASE IF NOT EXISTS clark CHARACTER SET utf8;
USE clark;

-- Create Tables
CREATE TABLE IF NOT EXISTS user (
    id VARCHAR(36) DEFAULT (UUID()) PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    is_admin BIT DEFAULT 0,
    last_login DATETIME,
    created_at DATETIME DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS log (
    id VARCHAR(36) DEFAULT (UUID()) PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    severity VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    created_at DATETIME DEFAULT (NOW())
);

COMMIT;
-- This database should never be available over the internet

BEGIN;
-- Create and use Database
CREATE DATABASE IF NOT EXISTS clark CHARACTER SET utf8;
USE clark;

-- Create Tables
CREATE TABLE IF NOT EXISTS user (
    id VARCHAR(36) DEFAULT (UUID()) PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    password TEXT NOT NULL,
    is_admin TINYINT(1) DEFAULT 0,
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

CREATE TABLE IF NOT EXISTS api_key (
    id VARCHAR(36) DEFAULT (UUID()) PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    matcher VARCHAR(100) NOT NULL,
    created_by VARCHAR(36) NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    inactive_since DATETIME,
    CONSTRAINT created_by_fk FOREIGN KEY (created_by) REFERENCES user(id)
);

COMMIT;
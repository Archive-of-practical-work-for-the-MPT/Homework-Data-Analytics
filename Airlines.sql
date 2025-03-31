CREATE DATABASE Aviasales;
GO

USE Aviasales;
GO

-- 1. создание и заполнение таблиц
CREATE TABLE Traveler(
 ID_Traveler INT PRIMARY KEY IDENTITY(1, 1),
 TravelertSurname VARCHAR(50) NOT NULL,
 TravelerName VARCHAR(50) NOT NULL,
 TravelerMiddleName VARCHAR(50) NOT NULL,
 Email VARCHAR(100) NOT NULL UNIQUE
);
GO

INSERT INTO Traveler(TravelertSurname, TravelerName, TravelerMiddleName, Email)
VALUES
 ('Парамонова', 'Елизавета', 'Михайловна', 'prepod_paramonova@mpt.ru'),
 ('Мысев', 'Дмитрий', 'Владимирович', 'prepod_musev@mpt.ru'),
 ('Себежко', 'Александр', 'Андреевич', 'sebezhko@gmail.ru'),
 ('Кирсанкина', 'Алина', 'Павловна', 'prepod_kirsankina@mpt.ru');
GO

CREATE TABLE Airlines(
 ID_Airline INT PRIMARY KEY IDENTITY(1, 1),
 NameAirline VARCHAR(50),
 price_mile DECIMAL(10, 2) NOT NULL
);
GO

INSERT INTO Airlines(NameAirline, price_mile)
VALUES
 ('S7', 35.62),
 ('Аэрофлот', 46.99),
 ('ПОБЕДА', 28.67);
GO

CREATE TABLE Categories(
 ID_Category INT PRIMARY KEY IDENTITY(1, 1),
 Name_Category VARCHAR(20) NOT NULL
);
GO

INSERT INTO Categories(Name_Category)
VALUES
 ('Внутренний'),
 ('Международный');
GO

CREATE TABLE Cities(
 ID_City INT PRIMARY KEY IDENTITY(1, 1),
 Name_City VARCHAR(100) NOT NULL
);
GO

INSERT INTO Cities(Name_City)
VALUES
 ('Москва'),
 ('Санкт-Петербург'),
 ('Новосибирск'),
 ('Мурманск'),
 ('Владивосток'),
 ('Великий Новгород'),
 ('Стамбул'),
 ('Дубай');
GO

CREATE TABLE Tickets(
 ID_Ticket INT PRIMARY KEY IDENTITY(1, 1),
 Airline_ID INT NOT NULL FOREIGN KEY REFERENCES Airlines(ID_Airline),
 From_City_ID INT NOT NULL FOREIGN KEY REFERENCES Cities(ID_City),
 Where_City_ID INT NOT NULL FOREIGN KEY REFERENCES Cities(ID_City),
 Category_ID INT NOT NULL FOREIGN KEY REFERENCES Categories(ID_Category),
 Count_mile DECIMAL(10, 2) NOT NULL
);
GO

INSERT INTO Tickets(Airline_ID, From_City_ID, Where_City_ID, Category_ID, Count_mile)
VALUES
 (1, 1, 2, 1, 435),
 (1, 3, 4, 1, 1806),
 (2, 1, 2, 1, 435),
 (2, 1, 5, 1, 3990),
 (3, 6, 7, 2, 1583),
 (3, 2, 8, 2, 2674);
GO

CREATE TABLE TicketsTravelers (
    ID_TicketsTravelers INT PRIMARY KEY IDENTITY(1, 1),
    Traveler_ID INT NOT NULL,
    Ticket_ID INT NOT NULL UNIQUE,
    FOREIGN KEY (Traveler_ID) REFERENCES Traveler(ID_Traveler),
    FOREIGN KEY (Ticket_ID) REFERENCES Tickets(ID_Ticket)
);
GO

INSERT INTO TicketsTravelers(Traveler_ID, Ticket_ID)
VALUES
 (1, 1),
 (2, 3),
 (3, 2),
 (4, 4),
 (1, 6);
GO

-- 2. select запросы
SELECT -- количество билетов и общая стоимость каждой компании
    NameAirline,
    Name_Category,
    COUNT(ID_Ticket) AS TicketCount,
    SUM(Count_mile * price_mile) AS TotalRevenue
FROM Tickets
JOIN Airlines ON Airline_ID = ID_Airline
JOIN Categories ON Category_ID = ID_Category
GROUP BY
    NameAirline,
    Name_Category
HAVING COUNT(ID_Ticket) > 1;

SELECT -- кто летит в определенный город
    TravelertSurname,
    TravelerName,
    TravelerMiddleName,
    Email,
    Name_City AS DestinationCity
FROM Traveler 
JOIN TicketsTravelers ON ID_Traveler = Traveler_ID
JOIN Tickets ON Ticket_ID = ID_Ticket
JOIN Cities ON Where_City_ID = ID_City
WHERE Name_City = 'Санкт-Петербург';

SELECT -- стоимость купленных внутренних билетов, отсортированные по возрастанию
    TravelertSurname,
    TravelerName,
    Count_mile,
    price_mile,
    Count_mile * price_mile AS TotalPrice
FROM Traveler
JOIN TicketsTravelers ON ID_Traveler = Traveler_ID
JOIN Tickets ON Ticket_ID = ID_Ticket
JOIN Airlines ON Airline_ID = ID_Airline
JOIN Categories ON Category_ID = ID_Category
WHERE Name_Category = 'Внутренний'
ORDER BY TotalPrice ASC;

-- 3. агрегатные функции
SELECT
    COUNT(Ticket_ID) AS TotalTicketsSold, -- количество проданных билетов
    SUM(Count_mile * price_mile) AS TotalRevenue, -- выручка
    MAX(Count_mile * price_mile) AS MaxTicketPrice, -- самый дорогой билет
    MIN(Count_mile * price_mile) AS MinTicketPrice, -- самый дешевый билет
    AVG(Count_mile * price_mile) AS AverageTicketPrice -- среднняя цена за билет
FROM TicketsTravelers
JOIN Tickets ON Ticket_ID = ID_Ticket
JOIN Airlines ON Airline_ID = ID_Airline;

-- 4. оконная функция
SELECT 
    NameAirline AS AirlineName,
    c1.Name_City AS FromCity,
    c2.Name_City AS ToCity,
    Name_Category AS Category,
    Count_mile AS Mileage,
    price_mile * Count_mile AS TotalCost,
    MIN(price_mile * Count_mile) OVER (PARTITION BY Airline_ID) AS MinTotalCostByAirline -- оконная функция
FROM TicketsTravelers
JOIN Tickets ON Ticket_ID = ID_Ticket
JOIN Airlines ON Airline_ID = ID_Airline
JOIN Cities c1 ON From_City_ID = c1.ID_City
JOIN Cities c2 ON Where_City_ID = c2.ID_City
JOIN Categories ON Category_ID = ID_Category


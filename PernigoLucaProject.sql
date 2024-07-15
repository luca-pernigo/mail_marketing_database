drop schema MAIL_MARKETING;
-- Create the database MARKETING
create schema MAIL_MARKETING;

-- use it
use MAIL_MARKETING;

-- Create the tables


CREATE TABLE PEOPLE_NAMES(
	Pemail varchar(30),
    PFirstName varchar(10) not null,
    PLastName varchar(10) not null,
    PRIMARY KEY (Pemail)
    );
    
CREATE TABLE PEOPLE_BIRTHDATE(
	Pemail varchar(30),
    Birthdate date DEFAULT NULL,
    PRIMARY KEY (Pemail)
    );


CREATE TABLE USER(
	Uemail varchar(30),
    -- each user can register with the desired Username only if
    -- no other User has already registered with that Username, hence the UNIQUE constraint
    Username varchar(20) NOT NULL UNIQUE,
    Password_ varchar(20) NOT NULL,
    City char(20) NOT NULL,
    Zip varchar(10) NOT NULL,
    Country char(20),
    -- since Website url is not mandatory
    -- this attribute does not have the NOT NULL constraint
    BusinessName varchar(30) NOT NULL,
    Website_url varchar(100),
    UFirstName varchar(10) NOT NULL,
    ULastName varchar(10) NOT NULL,
    PRIMARY KEY(Uemail),
    CONSTRAINT chk_password CHECK(length(Password_)>=8 and 
    Password_ REGEXP '[0-9]' and
    Password_ REGEXP '[A-Z]' and
    Password_ REGEXP '[!@#$%^&*()-_+=.,;:~]')
);
    

CREATE TABLE MAIL_MARKETING_CAMPAIGN(
	#assume each campaign_id consists of 6 alphanumeric characters
    Campaign_ID char(6),
    Uemail varchar(30),
    DateCreationCampaign DATETIME NOT NULL,
    Title TINYTEXT NOT NULL,
    Subject TINYTEXT NOT NULL,
    PRIMARY KEY(Campaign_ID),
    FOREIGN KEY (Uemail) REFERENCES USER(Uemail)
    
    -- the mail marketing tool provider wants to keep information
	-- concerning also the MARKETING_CAMPAIGNs that reference USERs
    -- that have been unregistered from the mail marketing tool
    ON DELETE RESTRICT
    
    -- if a USER changes the email address of its account
    -- the mail marketing provider wants that the previous MARKETING_CAMPAIGNs
    -- created by this USER reference the new USER email
    ON UPDATE CASCADE
	);
    
CREATE TABLE MAIL_MARKETING_CAMPAIGN_SCOPE_OPENED(
	#assume each campaign_id consists of 6 alphanumeric characters
    Campaign_ID char(6),
    Scope TINYTEXT,
    -- NumberPeopleOpened ranges from 0 to N
    -- and it cannot be NULL
    NumberPeopleOpened INT NOT NULL,
    PRIMARY KEY(Campaign_ID)
	);
    
    
    
CREATE TABLE MAILING_LIST(
	#assume each list consists of 4 alphanumeric characters
	List_ID varchar(10),
    Uemail varchar(30),
    DateCreationList DATETIME NOT NULL,
    List_name TINYTEXT,
    PRIMARY KEY(List_ID),
    FOREIGN KEY(Uemail) REFERENCES USER(Uemail)
     -- the mail marketing tool provider wants to keep information
	-- concerning also the MARKETING_LISTs that reference USERs
    -- that have been unregistered from the mail marketing tool
    ON DELETE RESTRICT
    
    -- if a USER changes the email address of its account
    -- the mail marketing provider wants that the previously MARKETING_LISTs
    -- created by this USER reference the new USER email
    ON UPDATE CASCADE
    
    );
    
    
CREATE TABLE MAILING_LIST_PARTICIPANTS(
	#assume each list consists of 4 alphanumeric characters
	List_ID varchar(10),
     -- NumberParticipants ranges from 0 to N
    -- and it cannot be NULL
    NumberParticipants INT NOT NULL,
    PRIMARY KEY(List_ID)
    );
    


CREATE TABLE TEXT_MESSAGE(
	Message_ID varchar(10),
    Campaign_ID char(6),
    -- Length message ranges from 1 to N
    -- hence it cannot be NULL
    Lenght_message INT NOT NULL,
    Font_type TINYTEXT,
    Font_size INT,
    PRIMARY KEY(Message_ID),
    FOREIGN KEY (Campaign_ID) REFERENCES MAIL_MARKETING_CAMPAIGN(Campaign_ID)
    
    -- if the mail marketing tool provider deletes
    -- a MAIL_MARKETING_CAMPAIGN from this database, it makes more sense
    -- to delete also the text messages that reference
    -- this MAIL_MARKETING_CAMPAIGN
    ON DELETE CASCADE
    
    -- once a MAIL_MARKETING_CAMPAIGN is created
    -- it is assigned an unique ID
    -- and from then on it cannot be modified anymore
    ON UPDATE RESTRICT
    );






CREATE TABLE CATEGORY(
	Category_ID varchar(10),
	CategoryName TINYTEXT NOT NULL,
    PRIMARY KEY (Category_ID)
    );
    

CREATE TABLE PRODUCT(
    Product_ID varchar(10),
    Product_Name TEXT NOT NULL,
    Category_ID varchar(10),
    PRIMARY KEY (Product_ID),
    
    FOREIGN KEY (Category_ID) REFERENCES CATEGORY(Category_ID)
    
    --  if we try to delete a Category_ID in the table CATEGORY
    -- the database has to reject the operation if one PRODUCT
    -- at least links on this CATEGORY
    ON DELETE RESTRICT
    
    -- if the Category_ID of a certain PRODUCT changes
    -- then its new Category_ID is updated accordingly
    ON UPDATE CASCADE
    );



CREATE TABLE TARGET(
	Campaign_ID char(6),
    List_ID varchar(10),
    PRIMARY KEY(Campaign_ID, List_ID),
    
    FOREIGN KEY(Campaign_ID) REFERENCES MAIL_MARKETING_CAMPAIGN(Campaign_ID)
    
    -- if mail marketing tool provider wants to delete
    -- a CAMPAIGN from its database, it makes sense to remove
    -- also the tuple of the TARGET relation to which it participate
    ON DELETE CASCADE
    
    -- once a MAIL_MARKETING_CAMPAIGN is created
    -- it is assigned an unique ID
    -- and from then on it cannot be modified anymore
    ON UPDATE RESTRICT,
    
    
    FOREIGN KEY (List_ID) REFERENCES MAILING_LIST(List_ID)
    
     -- if mail marketing tool provider wants to delete
    -- a LIST from its database, it makes sense to remove
    -- also the tuple of the TARGET relation to which it participate
    
    ON DELETE CASCADE
    
     -- once a MAILING_LIST is created
    -- it is assigned an unique ID
    -- and from then on it cannot be modified anymore
    ON UPDATE RESTRICT
    );
    
    
CREATE TABLE TREAT(
	List_ID varchar(10),
    Category_ID  varchar(10),
    PRIMARY KEY(List_ID, Category_ID),
    FOREIGN KEY(List_ID) REFERENCES MAILING_LIST(List_ID)
     -- if mail marketing tool provider wants to delete
    -- a LIST from its database, it makes sense to remove
    -- also the tuple of the TARGET relation to which it participate
    ON DELETE CASCADE
    
	-- once a MAILING_LIST is created
    -- it is assigned an unique ID
    -- and from then on it cannot be modified anymore
    ON UPDATE RESTRICT,
    
    
    FOREIGN KEY(Category_ID) REFERENCES CATEGORY(Category_ID)
    
     --  if we try to delete a Category_ID in the table CATEGORY
    -- the database has to reject the operation if there exists
    -- at least one TREAT tuple referencing that particular CATEGORY
    
    ON DELETE RESTRICT
    
    
     -- if the Category_ID of a certain PRODUCT changes
    -- then its new Category_ID is updated accordingly
    ON UPDATE CASCADE
    );
    
    
    
CREATE TABLE SUBSCRIBED(
	Pemail varchar(30),
    List_ID varchar(10),
    PRIMARY KEY(Pemail, List_ID),
    FOREIGN KEY(Pemail) REFERENCES PEOPLE_NAMES(Pemail)
    
    -- if a PEOPLE unsubscribes from a MAILING_LIST
    -- the tuple made of this PEOPLE mail and the Mailing_list_ID
    -- will be deleted
    ON DELETE CASCADE
    
	-- if a PEOPLE updates the mail he used to register to 
    -- a particular MAILING_LIST, we would like to update this
    -- mail also in the SUBSCRIBED relation
    ON UPDATE CASCADE,
    
    
    FOREIGN KEY(List_ID) REFERENCES MAILING_LIST(List_ID)
     -- if a MAILING LIST is deleted
    -- the tuples made of its the Mailing_list_ID and the PEOPLE mails
    -- will be deleted
    
    ON DELETE CASCADE
    
     -- once a MAILING_LIST is created
    -- it is assigned an unique ID
    -- and from then on it cannot be modified anymore
    ON UPDATE RESTRICT
    );
    
    
CREATE TABLE PHONES(
	Uemail varchar(30),
    Phone varchar(16),
    PRIMARY KEY(Uemail, Phone),
    FOREIGN KEY(Uemail) REFERENCES USER(Uemail)
    
	-- the mail marketing tool provider may want to keep information
	-- concerning the USERs
    -- even though they have been unregistered from the mail marketing tool
    ON DELETE RESTRICT
    
    -- if a USER changes the email address of its account
    -- the mail marketing provider wants that the new mail
    -- still matches the PHONE of the USER
    ON UPDATE CASCADE
    );


CREATE TABLE ADVERTISE(
	Campaign_ID varchar(6),
    Product_ID varchar(10),
    PRIMARY KEY(Campaign_ID, Product_ID),
    
    
    FOREIGN KEY(Campaign_ID) REFERENCES MAIL_MARKETING_CAMPAIGN(Campaign_ID)
    
     -- if mail marketing tool provider wants to delete
    -- a CAMPAIGN from its database, it makes sense to remove
    -- also the tuple of the ADVERTISE relation to which it participate
    ON DELETE CASCADE
    
    -- once a MAIL_MARKETING_CAMPAIGN is created
    -- it is assigned an unique ID
    -- and from then on it cannot be modified anymore
    ON UPDATE RESTRICT,
    
    
    FOREIGN KEY(Product_ID) REFERENCES PRODUCT(Product_ID)
      --  if we try to delete a PRODUCT
    -- the database has to reject the operation if there exists
    -- at least one ADVERTISE tuple referencing the Product_ID of this PRODUCT
    ON DELETE RESTRICT
    
      -- once a PRODUCT is registered in the database
    -- it is assigned an unique ID
    -- and from then on it cannot be modified anymore
    ON UPDATE RESTRICT
    );
    
    
#Insert Data

insert into PEOPLE_NAMES values ('sherma.gran@gmail.com','Sherman','Grand'),
('er.he@outlook.com', 'Erick','Heldt'),
('bay.klosterm@yahoo.com', 'Bay','Klosterman'),
('micheline-huns@gmail.com', 'Micheline','Hunsucker'),
('rohit_baumg@hotmail.com', 'Rohit','Baumgarten'),
('ubu-senior@gmail.com', 'Ubul','Senior'),
('penric.am@outlook.com', 'Penrice','Amerson'),
('careyne@yahoo.com', 'Carey','Neill'),
('cornelianmalla@gmail.com', 'Cornelian','Mallard'),
('wyn.loes@yahoo.com', 'Wynford','Loesch'),
('elgar_luken@aol.com', 'Elgar','Lukens'),
('jutenniso@gmail.com', 'Juan','Tennison'),
('la_enoch@gmail.com','Lang','Enoch'),
('rohitbor@yahoo.com', 'Rohit','Borgen'),
('chance-tap@aol.com', 'Chance','Tapp'),
('raborg@yahoo.com','Ramsden','Borgen'),
('trudiberli@gmail.com', 'Trudie','Berlin'),
('caitr_abs@gmail.com','Caitrin','Absher'),
('adihickers@gmail.com', 'Adin','Hickerson'),
('sirish-theo@gmail.com','Sirisha','Theodore'),
('john.doe@gmail.com', 'John', 'Doe'),
('jane.smith@yahoo.com', 'Jane', 'Smith'),
('jim.brown@hotmail.com', 'Jim', 'Brown'),
('sarah.jackson@gmail.com', 'Sarah', 'Jackson'),
('mark.johnson@outlook.com', 'Mark', 'Johnson')
;


INSERT INTO PEOPLE_BIRTHDATE VALUES
('ubu-senior@gmail.com', NULL),
('cornelianmalla@gmail.com', NULL),
('wyn.loes@yahoo.com', NULL),
('elgar_luken@aol.com', NULL),
('jutenniso@gmail.com', NULL),
('la_enoch@gmail.com', NULL),
('chance-tap@aol.com', NULL),
('raborg@yahoo.com', NULL),
('adihickers@gmail.com', NULL),
('sirish-theo@gmail.com', NULL),
('jane.smith@yahoo.com', NULL),
('jim.brown@hotmail.com', NULL),
('john.doe@gmail.com', '1990-02-15'),
('sarah.jackson@gmail.com', '1992-08-10'),
('er.he@outlook.com', '1992-05-20'),
('bay.klosterm@yahoo.com', '1975-12-01'),
('micheline-huns@gmail.com', '1988-06-05'),
('penric.am@outlook.com', '1978-09-15'),
('careyne@yahoo.com', '1985-08-09'),
('trudiberli@gmail.com', '1986-01-10'),
('caitr_abs@gmail.com','1982-03-09'),
('rohitbor@yahoo.com', '1963-02-17'),
('rohit_baumg@hotmail.com', '1980-02-17'),
('sherma.gran@gmail.com', '1959-12-14'),
('mark.johnson@outlook.com', '1971-06-30');



INSERT INTO USER (Uemail, Username, Password_, City, Zip, Country, BusinessName, Website_url, UFirstName, ULastName) 
VALUES 
('hannah.miller@gmail.com', 'hannahmiller', 'H@nnaH123', 'New York', '10001', 'USA', 'PlusStyle', NULL, 'Hannah', 'Miller'),
('alex.wang@yahoo.com', 'alexwang', 'Alex123!', 'Los Angeles', '90001', 'USA', 'AWF', NULL, 'Alex', 'Wang'),
('juan.flores@hotmail.com', 'juanitaflores', 'Jf!_2023', 'Mexico City', '01000', 'Mexico', 'FinServ', NULL, 'Juanita', 'Flores'),
('marc.garcia@gmail.com', 'marcgarcia', 'M@rc2023', 'Barcelona', '08001', 'Spain', 'Marc Garcia Inc.', 'http://marcgarcia.com', 'Marc', 'Garcia'),
('oliver.yen@gmail.com', 'olivernguyen', 'Oliver@123', 'Toronto', 'M5J 0A3', 'Canada', 'Nguyen Tech', 'http://nguyentech.com', 'Oliver', 'Nguyen');


INSERT INTO MAIL_MARKETING_CAMPAIGN 
    (Campaign_ID, Uemail, DateCreationCampaign, Title, Subject) 
VALUES 
    ('CAM562', 'hannah.miller@gmail.com', '2023-01-21 10:10:01', 'Summer Fashion Sale', 'Get ready for the hottest season in style!'),
    ('MKD024', 'alex.wang@yahoo.com', '2023-03-31 11:33:05', 'Healthy Living Tips', 'Stay healthy and happy with our expert advice!'),
    ('PVW302', 'oliver.yen@gmail.com', '2023-02-03 12:16:24', 'DIY Home Improvement', 'Transform your home with our easy DIY projects!'),
    ('VQP202', 'marc.garcia@gmail.com', '2023-04-23 14:03:41', 'Pet Care Essentials', 'Keep your furry friends happy and healthy with our top tips!'),
    ('VAM231', 'juan.flores@hotmail.com', '2023-03-12 15:43:22', 'Travel Deals', 'Explore the world without breaking the bank!'),
    ('VAP24O', 'marc.garcia@gmail.com', '2023-04-24 16:32:42', 'Gourmet Cooking Made Easy', 'Impress your guests with our delicious recipes!'),
    ('VMO302', 'alex.wang@yahoo.com', '2023-05-19 17:15:05', 'Fitness Challenge', 'Get fit and feel great with our 30-day challenge!'),
    ('PEI021', 'juan.flores@hotmail.com', '2023-04-23 18:06:03', 'Finance Tips for Millennials', 'Take control of your finances and plan for the future!'),
    ('MVE942', 'oliver.yen@gmail.com', '2023-02-28 19:32:04', 'Green Living Guide', 'Protect the planet and live sustainably with our tips and tricks!'),
    ('EKC174', 'oliver.yen@gmail.com', '2023-02-18 20:19:31', 'Parenting Hacks', 'Simplify your life and be a super parent with our expert advice!') ;
    
    
INSERT INTO MAIL_MARKETING_CAMPAIGN_SCOPE_OPENED 
    (Campaign_ID, Scope, NumberPeopleOpened)
VALUES 
    ('CAM562', 'Fashion Enthusiasts', 10),
    ('MKD024', 'Health and Fitness Enthusiasts', 4),
    ('PVW302', 'DIY Home Improvement Enthusiasts', 11),
    ('VQP202', 'Pet Lovers', 3),
    ('VAM231', 'Travel Enthusiasts', 13),
    ('VAP24O', NULL, 8),
    ('VMO302', 'Fitness Enthusiasts', 9),
    ('PEI021', 'Millennials', 8),
    ('MVE942', 'Eco-friendly Consumers', 10),
    ('EKC174', 'Parents', 4);

 
INSERT INTO MAILING_LIST 
    (List_ID, Uemail, DateCreationList, List_name) 
VALUES 
    ('LST1', 'hannah.miller@gmail.com', '2022-12-01 09:45:23', 'VIP Customers'),
    ('LST2', 'alex.wang@yahoo.com', '2023-01-02 10:23:16', 'Happy Subscribers'),
    ('LST3', 'oliver.yen@gmail.com', '2023-02-03 11:17:09', 'Homeowners'),
    ('LST4', 'marc.garcia@gmail.com', '2023-03-04 12:05:55', 'Pet Owners'),
    ('LST5', 'juan.flores@hotmail.com', '2023-02-05 13:02:01', 'Travel Enthusiasts'),
    ('LST6', 'hannah.miller@gmail.com', '2023-03-06 14:03:23', 'Fashionistas'),
    ('LST7', 'alex.wang@yahoo.com', '2023-02-07 15:00:12', 'Healthy Living'),
    ('LST8', 'oliver.yen@gmail.com', '2023-03-08 16:10:19', 'DIY Home Improvement'),
    ('LST9', 'marc.garcia@gmail.com', '2023-01-09 17:05:34', 'Foodies'),
    ('LST10', 'juan.flores@hotmail.com', '2023-02-10 18:12:45', 'Financial Planning'), 
    ('LST11', 'oliver.yen@gmail.com', '2023-01-08 09:21:01', 'Weekend Getaways'),
    ('LST12', 'oliver.yen@gmail.com', '2023-01-04 19:22:12', 'Home Decor Ideas'),
    ('LST13', 'alex.wang@yahoo.com', '2023-03-21 08:08:08', 'Healthy Eating Tips'),
    ('LST14', 'oliver.yen@gmail.com', '2023-02-018 17:30:05', 'DIY Projects'),
    ('LST15', 'hannah.miller@gmail.com', '2023-03-24 14:21:21', 'Fashion Trends'),
    ('LST16', 'juan.flores@hotmail.com', '2023-04-01 00:00:00', 'Saving for the Future'),
    ('LST17', 'oliver.yen@gmail.com', '2023-01-01 21:02:12', 'We Parents'),
    ('LST18', 'oliver.yen@gmail.com', '2023-02-11 22:01:14', 'E-Planet')
    ;



INSERT INTO MAILING_LIST_PARTICIPANTS 
    (List_ID, NumberParticipants) 
VALUES 
    ('LST1', 14),
    ('LST2', 3),
    ('LST3', 5),
    ('LST4', 8),
    ('LST5', 5),
    ('LST6', 4),
    ('LST7', 9),
    ('LST8', 12),
    ('LST9', 4),
    ('LST10', 15),
    ('LST11', 13),
    ('LST12', 14),
    ('LST13', 3),
    ('LST14', 4),
    ('LST15', 8),
    ('LST16', 9),
    ('LST17', 6),
    ('LST18', 8)
    ;
    
    
INSERT INTO TEXT_MESSAGE (Message_ID, Campaign_ID, Lenght_message, Font_type, Font_size)
VALUES 
    ('CAM562-1', 'CAM562', 90, 'Arial', 12),
    ('MKD024-1', 'MKD024', 75, 'Calibri', 10),
    ('PVW302-1', 'PVW302', 120, 'Times New Roman', 14),
    ('VQP202-1', 'VQP202', 110, 'Verdana', 11),
    ('VAM231-1', 'VAM231', 100, 'Arial', 13),
    ('VAP24O-1', 'VAP24O', 95, 'Calibri', 12),
    ('VMO302-1', 'VMO302', 80, 'Times New Roman', 10),
    ('PEI021-1', 'PEI021', 105, 'Verdana', 11),
    ('MVE942-1', 'MVE942', 115, 'Arial', 14),
    ('EKC174-1', 'EKC174', 85, 'Calibri', 12),
    ('CAM562-2', 'CAM562', 80, 'Times New Roman', 11),
    ('MKD024-2', 'MKD024', 70, 'Verdana', 10),
    ('VQP202-2', 'VQP202', 100, 'Calibri', 11),
    ('VAM231-2', 'VAM231', 95, 'Times New Roman', 13),
    ('PEI021-2', 'PEI021', 100, 'Calibri', 11),
    ('EKC174-2', 'EKC174', 90, 'Verdana', 12),
    ('MKD024-3', 'MKD024', 70, 'Verdana', 10),
    ('PEI021-3', 'PEI021', 100, 'Calibri', 11),
    ('EKC174-3', 'EKC174', 90, 'Verdana', 12)
    ;
    
    
    

    
   INSERT INTO CATEGORY(Category_ID, CategoryName)
VALUES
('CAT001', 'Footwear'),
('CAT002', 'Fitness'),
('CAT003', 'Tools'),
('CAT004', 'Pet Supplies'),
('CAT005', 'Travel'),
('CAT006', 'Yoga'),
('CAT007', 'Personal Finance'),
('CAT008', 'Eco-Friendly'),
('CAT009', 'Parenting'),
('CAT010', 'Accessories'),
('CAT011', 'Food')

; 
    
INSERT INTO PRODUCT(Product_ID, Product_Name, Category_ID)
VALUES 
	('PROD01', 'Pet Bed', 'CAT004'),
    ('PROD002', 'High Heels', 'CAT001'),
    ('PROD003', 'Fitness Tracker', 'CAT002'),
    ('PROD004', 'Gym Membership', 'CAT002'),
    ('PROD005', 'Power Drill', 'CAT003'),
    ('PROD006', 'Hammer', 'CAT003'),
    ('PROD007', 'Dog Food', 'CAT004'),
    ('PROD008', 'Cat Toy', 'CAT004'),
    ('PROD009', 'Travel Guide Book', 'CAT005'),
    ('PROD010', 'Luggage', 'CAT005'),
    ('PROD011', 'Yoga Mat', 'CAT006'),
    ('PROD012', 'Running Shoes', 'CAT002'),
    ('PROD013', 'Budgeting App', 'CAT007'),
    ('PROD014', 'Investment Book', 'CAT007'),
    ('PROD015', 'Reusable Water Bottle', 'CAT008'),
    ('PROD017', 'Baby Food', 'CAT009'),
    ('PROD018', 'Eco-friendly Cleaning Supplies', 'CAT008'),
    ('PROD019', 'Solar-powered Charger', 'CAT008'),
    ('PROD020', 'Leather Shoes', 'CAT001'),
	('PROD021', 'Sunglasses', 'CAT010'),
	('PROD022', 'Fitness Tracker', 'CAT002'),
	('PROD023', 'Dumbbell Set', 'CAT002'),
	('PROD024', 'Smart Watch', 'CAT002'),
	('PROD025', 'Air Purifier', 'CAT008'),
	('PROD026', 'Reusable Water Bottle', 'CAT011'),
	('PROD027', 'Recycled Paper Notebook', 'CAT008'),
	('PROD028', 'Baby Stroller', 'CAT009'),
    ('PROD029', 'Pizza Recipe', 'CAT009')
    ;    
    
       
insert into TARGET values
	('CAM562','LST1' ),
    ('CAM562','LST6' ),
    ('CAM562','LST15' ),
    ('MKD024','LST2' ),
    ('VMO302','LST2' ),
	('VMO302','LST7' ),
    ('VMO302','LST13' ),
	('PVW302','LST3' ),
    ('PVW302','LST8' ),
    ('PVW302','LST12' ),
    ('PVW302','LST11' ),
    ('PVW302','LST14' ),
    ('VQP202','LST4' ),
    ('VAP24O','LST9' ),
    ('VAM231','LST5' ),
    ('PEI021','LST10'),
    ('PEI021','LST16'),
    ('MVE942', 'LST18'),
    ('EKC174','LST17'),
    ('EKC174','LST11')
    ;
    

insert into TREAT values
	('LST1', 'CAT001'),
    ('LST1', 'CAT010'),
    ('LST2', 'CAT006'),
    ('LST3', 'CAT003'),
	('LST4', 'CAT004'),
    ('LST5', 'CAT005'),
    ('LST6', 'CAT010'),
    ('LST7', 'CAT002'),
    ('LST8', 'CAT003'),
    ('LST8', 'CAT009'),
    ('LST9', 'CAT011'),
    ('LST10', 'CAT007'),
    ('LST11', 'CAT009'),
    ('LST11', 'CAT003'),
    ('LST12', 'CAT003'),
    ('LST13', 'CAT002'),
    ('LST14', 'CAT003'),
    ('LST15', 'CAT010'),
    ('LST16', 'CAT007'),
    ('LST17', 'CAT009'),
    ('LST18', 'CAT008')
    ;


insert into SUBSCRIBED values
('sherma.gran@gmail.com', 'LST1'),
('elgar_luken@aol.com', 'LST1'),
('bay.klosterm@yahoo.com', 'LST1'),
('ubu-senior@gmail.com', 'LST1'),
('jutenniso@gmail.com', 'LST1'),
('la_enoch@gmail.com', 'LST1'),
('rohitbor@yahoo.com', 'LST1'),
('trudiberli@gmail.com', 'LST1'),
('caitr_abs@gmail.com', 'LST1'),
('john.doe@gmail.com', 'LST1'),
('jane.smith@yahoo.com', 'LST1'),
('jim.brown@hotmail.com', 'LST1'),
('sarah.jackson@gmail.com', 'LST1'),
('mark.johnson@outlook.com', 'LST1'),

('elgar_luken@aol.com', 'LST2'),
('sarah.jackson@gmail.com', 'LST2'),
('adihickers@gmail.com', 'LST2'),



('elgar_luken@aol.com', 'LST3'),
('sarah.jackson@gmail.com', 'LST3'),
('adihickers@gmail.com', 'LST3'),
('penric.am@outlook.com', 'LST3'),
('chance-tap@aol.com', 'LST3'),


('jutenniso@gmail.com', 'LST4'),
('caitr_abs@gmail.com', 'LST4'),
('jane.smith@yahoo.com', 'LST4'),
('jim.brown@hotmail.com', 'LST4'),
('chance-tap@aol.com', 'LST4'),
('elgar_luken@aol.com', 'LST4'),
('sarah.jackson@gmail.com', 'LST4'),
('adihickers@gmail.com', 'LST4'),

('penric.am@outlook.com', 'LST5'),
('chance-tap@aol.com', 'LST5'),
('trudiberli@gmail.com', 'LST5'),
('caitr_abs@gmail.com', 'LST5'),
('sarah.jackson@gmail.com', 'LST5'),



('sherma.gran@gmail.com', 'LST6'),
('er.he@outlook.com', 'LST6'),
('bay.klosterm@yahoo.com', 'LST6'),
('ubu-senior@gmail.com', 'LST6'),


('penric.am@outlook.com', 'LST7'),
('careyne@yahoo.com', 'LST7'),
('cornelianmalla@gmail.com', 'LST7'),
('wyn.loes@yahoo.com', 'LST7'),
('elgar_luken@aol.com', 'LST7'),
('jutenniso@gmail.com', 'LST7'),
('la_enoch@gmail.com', 'LST7'),
('rohitbor@yahoo.com', 'LST7'),
('chance-tap@aol.com', 'LST7'),


('raborg@yahoo.com', 'LST8'),
('trudiberli@gmail.com', 'LST8'),
('caitr_abs@gmail.com', 'LST8'),
('adihickers@gmail.com', 'LST8'),
('sirish-theo@gmail.com', 'LST8'),
('john.doe@gmail.com', 'LST8'),
('jane.smith@yahoo.com', 'LST8'),
('jim.brown@hotmail.com', 'LST8'),
('sarah.jackson@gmail.com', 'LST8'),
('mark.johnson@outlook.com', 'LST8'),
('sherma.gran@gmail.com', 'LST8'),
('er.he@outlook.com', 'LST8'),

('bay.klosterm@yahoo.com', 'LST9'),
('ubu-senior@gmail.com', 'LST9'),
('penric.am@outlook.com', 'LST9'),
('careyne@yahoo.com', 'LST9'),



('cornelianmalla@gmail.com', 'LST10'),
('wyn.loes@yahoo.com', 'LST10'),
('elgar_luken@aol.com', 'LST10'),
('jutenniso@gmail.com', 'LST10'),
('la_enoch@gmail.com', 'LST10'),
('rohitbor@yahoo.com', 'LST10'),
('chance-tap@aol.com', 'LST10'),
('raborg@yahoo.com', 'LST10'),
('trudiberli@gmail.com', 'LST10'),
('caitr_abs@gmail.com', 'LST10'),
('adihickers@gmail.com', 'LST10'),
('sirish-theo@gmail.com', 'LST10'),
('john.doe@gmail.com', 'LST10'),
('jane.smith@yahoo.com', 'LST10'),
('jim.brown@hotmail.com', 'LST10'),




('sarah.jackson@gmail.com', 'LST11'),
('mark.johnson@outlook.com', 'LST11'),
('sherma.gran@gmail.com', 'LST11'),
('er.he@outlook.com', 'LST11'),
('bay.klosterm@yahoo.com', 'LST11'),
('ubu-senior@gmail.com', 'LST11'),
('penric.am@outlook.com', 'LST11'),
('careyne@yahoo.com', 'LST11'),
('cornelianmalla@gmail.com', 'LST11'),
('wyn.loes@yahoo.com', 'LST11'),
('elgar_luken@aol.com', 'LST11'),
('jutenniso@gmail.com', 'LST11'),
('la_enoch@gmail.com', 'LST11'),



('rohitbor@yahoo.com', 'LST12'),
('chance-tap@aol.com', 'LST12'),
('raborg@yahoo.com', 'LST12'),
('trudiberli@gmail.com', 'LST12'),
('caitr_abs@gmail.com', 'LST12'),
('adihickers@gmail.com', 'LST12'),
('sirish-theo@gmail.com', 'LST12'),
('john.doe@gmail.com', 'LST12'),
('jane.smith@yahoo.com', 'LST12'),
('jim.brown@hotmail.com', 'LST12'),
('sarah.jackson@gmail.com', 'LST12'),
('mark.johnson@outlook.com', 'LST12'),
('sherma.gran@gmail.com', 'LST12'),
('er.he@outlook.com', 'LST12'),


('trudiberli@gmail.com', 'LST13'),
('caitr_abs@gmail.com', 'LST13'),
('sarah.jackson@gmail.com', 'LST13'),

('raborg@yahoo.com', 'LST14'),
('trudiberli@gmail.com', 'LST14'),
('caitr_abs@gmail.com', 'LST14'),
('adihickers@gmail.com', 'LST14'),

('sarah.jackson@gmail.com', 'LST15'),
('mark.johnson@outlook.com', 'LST15'),
('sherma.gran@gmail.com', 'LST15'),
('er.he@outlook.com', 'LST15'),
('bay.klosterm@yahoo.com', 'LST15'),
('ubu-senior@gmail.com', 'LST15'),
('penric.am@outlook.com', 'LST15'),
('careyne@yahoo.com', 'LST15'),


('adihickers@gmail.com', 'LST16'),
('sirish-theo@gmail.com', 'LST16'),
('john.doe@gmail.com', 'LST16'),
('jane.smith@yahoo.com', 'LST16'),
('jim.brown@hotmail.com', 'LST16'),
('sarah.jackson@gmail.com', 'LST16'),
('mark.johnson@outlook.com', 'LST16'),
('sherma.gran@gmail.com', 'LST16'),
('er.he@outlook.com', 'LST16'),

('caitr_abs@gmail.com', 'LST17'),
('john.doe@gmail.com', 'LST17'),
('jane.smith@yahoo.com', 'LST17'),
('jim.brown@hotmail.com', 'LST17'),
('sarah.jackson@gmail.com', 'LST17'),
('mark.johnson@outlook.com', 'LST17'),



('rohitbor@yahoo.com', 'LST18'),
('chance-tap@aol.com', 'LST18'),
('raborg@yahoo.com', 'LST18'),
('trudiberli@gmail.com', 'LST18'),
('caitr_abs@gmail.com', 'LST18'),
('adihickers@gmail.com', 'LST18'),
('sirish-theo@gmail.com', 'LST18'),
('john.doe@gmail.com', 'LST18')
;


INSERT INTO PHONES (Uemail, Phone)
VALUES
('hannah.miller@gmail.com', '+1-123-456-7890'),
('hannah.miller@gmail.com', '+1-234-567-8901'),
('alex.wang@yahoo.com', '+1-345-678-9012'),
('juan.flores@hotmail.com', '+52-55-1234-5678'),
('juan.flores@hotmail.com', '+52-55-2345-6789'),
('marc.garcia@gmail.com', '+34-93-123-4567'),
('oliver.yen@gmail.com', '+1-416-123-4567'),
('oliver.yen@gmail.com', '+1-647-234-5678');


insert into ADVERTISE values
('CAM562','PROD002'),
('CAM562','PROD020'),
('CAM562','PROD021'),

('MKD024','PROD003'),
('MKD024','PROD011'),
('MKD024','PROD024'),

('VMO302','PROD003'),
('VMO302','PROD004'),
('VMO302','PROD012'),
('VMO302','PROD022'),
('VMO302','PROD023'),
('VMO302','PROD024'),



('VQP202','PROD01'),
('VQP202','PROD007'),
('VQP202','PROD008'),


('VAM231','PROD009'),
('VAM231','PROD010'),


('VAP24O','PROD029'),


('PEI021','PROD013'),
('PEI021','PROD014'),

('MVE942','PROD015'),
('MVE942','PROD018'),
('MVE942','PROD019'),
('MVE942','PROD025'),
('MVE942','PROD026'),
('MVE942','PROD027'),

('EKC174','PROD017'),
('EKC174','PROD028'),

('PVW302','PROD005'),
('PVW302','PROD006')
;


    


#QUERIES

#1 See how many users we have in our database
SELECT count(*) Number_of_Users FROM USER;


#2 See categories of product in the database
SELECT DISTINCT CategoryName FROM CATEGORY;


#3 See which user has more than one phone
SELECT USER.Uemail, UFirstName, ULastName, count(Phone)
FROM USER JOIN PHONES ON USER.Uemail=PHONES.Uemail
GROUP BY Uemail
HAVING count(Phone)>1
;

#4 Find the first campaign created
SELECT Title, Campaign_ID, DateCreationCampaign, Uemail FROM MAIL_MARKETING_CAMPAIGN
WHERE DateCreationCampaign=(SELECT MIN(DateCreationCampaign)  FROM MAIL_MARKETING_CAMPAIGN)
;




#5 find out how many subscribers each newsletter has
SELECT List_name, Subscribed
FROM (
SELECT List_name, count(Pemail) Subscribed 
FROM SUBSCRIBED e JOIN  MAILING_LIST l ON e.List_ID=l.List_ID
GROUP BY List_name) as totsubs
ORDER BY Subscribed DESC
;

#6 prompt newsletter with most subscribers
SELECT List_name, Subscribed
FROM (
SELECT List_name, count(Pemail) Subscribed 
FROM SUBSCRIBED e JOIN  MAILING_LIST l ON e.List_ID=l.List_ID
GROUP BY List_name) as totsubs
WHERE Subscribed=(SELECT MAX(Subscribed)
FROM (SELECT List_name, count(Pemail) Subscribed 
FROM SUBSCRIBED e JOIN  MAILING_LIST l ON e.List_ID=l.List_ID
GROUP BY List_name) as totsubs)
;


#7 find most common email domains in the database

SELECT 
SUBSTRING(Pemail,
POSITION('@' IN Pemail)) as domains,
count(SUBSTRING(Pemail,
POSITION('@' IN Pemail))) as count
FROM PEOPLE_NAMES
GROUP BY SUBSTRING(Pemail,POSITION('@' IN Pemail))
;


#8 find user that created the most marketing campaigns
SELECT *
FROM
(SELECT Username, count(USER.Uemail) CountCampaigns, UFirstName, ULastName
FROM USER JOIN MAIL_MARKETING_CAMPAIGN ON USER.Uemail=MAIL_MARKETING_CAMPAIGN.Uemail
GROUP BY USER.Uemail) as countmail
WHERE CountCampaigns=(SELECT max(CountCampaigns)
FROM
(SELECT Username, count(USER.Uemail) CountCampaigns, UFirstName, ULastName
FROM USER JOIN MAIL_MARKETING_CAMPAIGN ON USER.Uemail=MAIL_MARKETING_CAMPAIGN.Uemail
GROUP BY USER.Uemail) as countmail2)
;

#9 Find shortest text message

SELECT * FROM TEXT_MESSAGE
WHERE Lenght_message=(SELECT min(Lenght_message) FROM TEXT_MESSAGE)
;




#10 search average length of text message for campaign and order them by average
#length in ascending order
SELECT Title, AVG(Lenght_message) FROM MAIL_MARKETING_CAMPAIGN
JOIN TEXT_MESSAGE
  ON  MAIL_MARKETING_CAMPAIGN.Campaign_ID=TEXT_MESSAGE.Campaign_ID
GROUP BY Title
ORDER by AVG(Lenght_message);


#11 Inspect all products belonging to the category Fitness
SELECT Product_Name
FROM PRODUCT JOIN CATEGORY on PRODUCT.Category_ID=CATEGORY.CATEGORY_ID
WHERE CategoryName='Fitness';




#12 Select the most targeted mailing list
#that is Countlist corresponds to the numer of
#MAIL_MARKETING_CAMPAIGNs that target a LIST
SELECT List_ID,List_name, Countlist
FROM
(SELECT MAILING_LIST.List_ID,List_name, count(MAILING_LIST.List_ID) Countlist FROM TARGET
JOIN MAILING_LIST ON TARGET.List_ID=MAILING_LIST.List_ID
GROUP BY List_ID) as countlist
WHERE Countlist=(SELECT max(Countlist)
FROM
(SELECT List_ID, count(List_ID) Countlist FROM TARGET
GROUP BY List_ID) as countlist)
;


# 13 See the mailing campaigns that target Weekend Gateways
SELECT MAIL_MARKETING_CAMPAIGN.Campaign_ID, Title, Subject, MAILING_LIST.List_ID, List_name FROM TARGET
JOIN MAIL_MARKETING_CAMPAIGN ON TARGET.Campaign_ID=MAIL_MARKETING_CAMPAIGN.Campaign_ID
JOIN MAILING_LIST ON  TARGET.List_ID=MAILING_List.List_ID
WHERE List_name='Weekend Getaways'
;

# 14 See who is subscribed to Weekend Gateways
SELECT Pemail
FROM SUBSCRIBED JOIN MAILING_LIST ON SUBSCRIBED.List_ID=MAILING_LIST.List_ID
WHERE List_name='Weekend Getaways'
;

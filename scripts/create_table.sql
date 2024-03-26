DROP TABLE IF EXISTS population CASCADE;
DROP TABLE IF EXISTS client_ids;



CREATE TABLE client_ids (
    id SERIAL PRIMARY KEY,
    client_id BIGINT NOT NULL UNIQUE
);


CREATE TABLE population (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    birthday DATE NOT NULL,
    client_id BIGINT NOT NULL,
    FOREIGN KEY (client_id) REFERENCES client_ids(client_id),
    gender VARCHAR(10) NOT NULL,
    is_retired BOOLEAN NOT NULL DEFAULT false,
    is_underage BOOLEAN NOT NULL DEFAULT true
);


CREATE OR REPLACE VIEW v_population AS
SELECT 
    id,
    first_name,
    last_name,
    email,
    address,
    city,
    country,
    phone,
    birthday,
    gender,
    client_id,
    EXTRACT(YEAR FROM age(CURRENT_DATE, birthday)) < 18 AS is_underage,
    EXTRACT(YEAR FROM age(CURRENT_DATE, birthday)) >= 65 AS is_retired
FROM 
    population;


CREATE OR REPLACE FUNCTION generate_client_id()
RETURNS TRIGGER AS $$
DECLARE
    ascii_sum INT := 0;
    new_client_id BIGINT;
    i INT;
BEGIN
    FOR i IN 1..LENGTH(NEW.email) LOOP
        ascii_sum := ascii_sum + ASCII(SUBSTRING(NEW.email FROM i FOR 1));
    END LOOP;

    IF ascii_sum = 0 THEN
        ascii_sum := 1;
    END IF;

    new_client_id := ROUND(((EXTRACT(DAY FROM NEW.birthday) * EXTRACT(MONTH FROM NEW.birthday) * EXTRACT(YEAR FROM NEW.birthday))::NUMERIC / ascii_sum / 1000000000000) * 1000000000000)::BIGINT;

    -- Insert the new client_id into the client_ids table
    INSERT INTO client_ids (client_id)
    VALUES (new_client_id)
    ON CONFLICT (client_id) DO NOTHING;

    NEW.client_id := new_client_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER set_client_id
BEFORE INSERT ON population
FOR EACH ROW
EXECUTE FUNCTION generate_client_id();


-- INSERT INTO population (first_name, last_name, email, address, city, country, phone, birthday, gender)
-- VALUES
-- ('Alex', 'River', 'alex.river@example.com', '101 Blossom Rd', 'Paris', 'France', '+33-1-3030-1010', '2014-03-20', 'Other'),
-- ('Bailey', 'Skye', 'bailey.skye@example.com', '202 Azure Ln', 'Berlin', 'Germany', '+49-30-2020-2020', '2012-03-20', 'Male'),
-- ('Casey', 'Brook', 'casey.brook@example.com', '303 Cedar Blvd', 'Tokyo', 'Japan', '+81-3-3030-3030', '2009-03-20', 'Female'),
-- ('Devon', 'Cloud', 'devon.cloud@example.com', '404 Pine St', 'Sydney', 'Australia', '+61-2-4040-4040', '2010-03-20', 'Other'),
-- ('Emery', 'Stone', 'emery.stone@example.com', '505 Maple Ave', 'Toronto', 'Canada', '+1-416-5050-5050', '2008-03-20', 'Male'),
-- ('Finley', 'Dale', 'finley.dale@example.com', '606 Oak Grove', 'Cape Town', 'South Africa', '+27-21-6060-6060', '2011-03-20', 'Female'),
-- ('Gale', 'Hill', 'gale.hill@example.com', '707 River Rd', 'São Paulo', 'Brazil', '+55-11-7070-7070', '2007-03-20', 'Other'),
-- ('Harley', 'Wren', 'harley.wren@example.com', '808 Elm St', 'Moscow', 'Russia', '+7-495-8080-8080', '2013-03-20', 'Male'),
-- ('Ira', 'Meadow', 'ira.meadow@example.com', '909 Lavender Ln', 'Madrid', 'Spain', '+34-91-9090-9090', '1959-03-20', 'Female'),
-- ('Jordan', 'Sage', 'jordan.sage@example.com', '1010 Spruce Rd', 'Rome', 'Italy', '+39-06-1010-1010', '1954-03-20', 'Male'),
-- ('Kai', 'Fern', 'kai.fern@example.com', '1111 Willow Way', 'New Delhi', 'India', '+91-11-1111-1111', '1949-03-20', 'Other'),
-- ('Leslie', 'Grove', 'leslie.grove@example.com', '1212 Hawthorn Ln', 'Amsterdam', 'Netherlands', '+31-20-1212-1212', '1956-03-20', 'Female'),
-- ('Morgan', 'Vale', 'morgan.vale@example.com', '1313 Birch Blvd', 'Beijing', 'China', '+86-10-1313-1313', '1958-03-20', 'Male'),
-- ('Nico', 'Heath', 'nico.heath@example.com', '1414 Aspen Sq', 'Cairo', 'Egypt', '+20-2-1414-1414', '1944-03-20', 'Other'),
-- ('Oakley', 'Ford', 'oakley.ford@example.com', '1515 Juniper Jct', 'Lagos', 'Nigeria', '+234-1-1515-1515', '1939-03-20', 'Female'),
-- ('Parker', 'Shade', 'parker.shade@example.com', '1616 Pinecone Pl', 'Istanbul', 'Turkey', '+90-212-1616-1616', '1934-03-20', 'Male'),
-- ('Quinn', 'Glade', 'quinn.glade@example.com', '1717 Alder Alley', 'Bangkok', 'Thailand', '+66-2-1717-1717', '1952-03-20', 'Female'),
-- ('Riley', 'Thorn', 'riley.thorn@example.com', '1818 Cedar Path', 'Buenos Aires', 'Argentina', '+54-11-1818-1818', '1947-03-20', 'Male'),
-- ('Sydney', 'Briar', 'sydney.briar@example.com', '1919 Oak Lane', 'Seoul', 'South Korea', '+82-2-1919-1919', '1942-03-20', 'Other'),
-- ('Taylor', 'Cove', 'taylor.cove@example.com', '2020 Pine Ridge', 'Helsinki', 'Finland', '+358-9-2020-2020', '1937-03-20', 'Female'),
-- ('Daniel', 'Gonzalez', 'daniel.gonzalez@example.com', '852 Oak St', 'Barcelona', 'Spain', '+34-930-8520', '1989-10-25', 'Male'),
-- ('Olivia', 'Lee', 'olivia.lee@example.com', '123 Elm St', 'Seoul', 'South Korea', '+82-2-1230-4567', '1993-05-15', 'Female'),
-- ('Emma', 'Wong', 'emma.wong@example.com', '789 Maple St', 'Toronto', 'Canada', '+1-416-7890-1234', '1995-08-25', 'Female'),
-- ('Charlotte', 'Martinez', 'charlotte.martinez@example.com', '852 Maple St', 'Vienna', 'Austria', '+43-1-8520-4789', '1986-06-20', 'Female'),
-- ('David', 'Brown', 'david.brown@example.com', '987 Cedar St', 'Dublin', 'Ireland', '+353-1-9870-6543', '1977-12-05', 'Male'),
-- ('Ryan', 'Garcia', 'ryan.garcia@example.com', '159 Cedar St', 'Wellington', 'New Zealand', '+64-4-1590-7834', '1986-02-15', 'Male'),
-- ('Liam', 'Garcia', 'liam.garcia@example.com', '321 Pine St', 'Buenos Aires', 'Argentina', '+54-11-3210-5678', '1987-03-10', 'Male'),
-- ('Ava', 'Rodriguez', 'ava.rodriguez@example.com', '987 Cedar St', 'Lima', 'Peru', '+51-1-9870-4321', '1980-12-05', 'Female'),
-- ('Michael', 'Johnson', 'michael.johnson@example.com', '789 Oak St', 'Cape Town', 'South Africa', '+27-21-7890-1234', '1982-08-25', 'Male'),
-- ('Amelia', 'Brown', 'amelia.brown@example.com', '147 Cherry St', 'Athens', 'Greece', '+30-21-1470-5678', '1992-04-30', 'Female'),
-- ('Michael', 'Ng', 'michael.ng@example.com', '258 Spruce St', 'Singapore', 'Singapore', '+65-2580-1234', '1994-07-25', 'Male'),
-- ('Emily', 'Williams', 'emily.williams@example.com', '321 Pine St', 'Istanbul', 'Turkey', '+90-212-3210-6543', '1987-03-10', 'Female'),
-- ('Christopher', 'Miller', 'christopher.miller@example.com', '852 Maple St', 'Oslo', 'Norway', '+47-852-2345', '1994-06-20', 'Male'),
-- ('Maximilian', 'Fischer', 'maximilian.fischer@gmail.com', 'Elm Linden Birch Beech 189 Avenue', 'Dortmund', 'Germany', '+495606988163', '2008-04-20', 'Male'),
-- ('Sofia', 'Johansen', 'sofia.johansen@fastmail.com', 'Hazel Ash Holly Elm 1184 Drive', 'Sarpsborg', 'Norway', '+475379142282', '2016-05-21', 'Male'),
-- ('Luis', 'Garca', 'luis.garca@tutanota.com', 'Willow Elm 1185 Avenue', 'Tijuana', 'Mexico', '+522357518390', '2010-12-01', 'Male'),
-- ('Amelia', 'Kelly', 'amelia.kelly@mail.com', 'Maple Cherry 207 Avenue', 'Cork', 'Ireland', '+3538976940259', '2017-11-24', 'Other'),
-- ('Yuto', 'Suzuki', 'yuto.suzuki@msn.com', 'Beech Hazel Cedar Birch 950 Avenue', 'Sapporo', 'Japan', '+816001771028', '2023-06-17', 'Male'),
-- ('Maja', 'Nilsson', 'maja.nilsson@gmail.com', 'Cedar Oak 996 Drive', 'Jönköping', 'Sweden', '+463155301728', '2010-09-28', 'Female'),
-- ('Victor', 'Pedersen', 'victor.pedersen@yandex.com', 'Willow Hazel Elm 128 Street', 'Kolding', 'Denmark', '+457070143209', '2007-05-06', 'Male'),
-- ('Lucas', 'Fernndez', 'lucas.fernndez@tutanota.com', 'Ivy Hazel Elm Birch 292 Street', 'Tacuarembó', 'Uruguay', '+5984680538767', '2020-09-21', 'Male'),
-- ('Chen', 'Zhang', 'chen.zhang@yahoo.com', 'Linden Maple 389 Street', 'Guangzhou', 'China', '+865787876523', '2009-04-13', 'Male'),
-- ('Antero', 'Mkel', 'antero.mkel@icloud.com', 'Beech Birch Cedar 463 Road', 'Vantaa', 'Finland', '+3586581942117', '2013-03-20', 'Female'),
-- ('Aarav', 'Kumar', 'aarav.kumar@live.com', 'Hazel Ash Holly Elm 1184 Drive', 'Jaipur', 'India', '+918555381267', '2023-11-29', 'Female'),
-- ('Feng', 'Li', 'feng.li@outlook.com', 'Ash Ivy 437 Avenue', 'Tianjin', 'China', '+864037748435', '2010-01-19', 'Other'),
-- ('Oscar', 'Andersen', 'oscar.andersen@protonmail.com', 'Willow Linden 764 Avenue', 'Kolding', 'Denmark', '+452697394740', '2020-12-06', 'Other'),
-- ('Sofia', 'Kuznetsov', 'sofia.kuznetsov@fastmail.com', 'Elm Cherry Ash Linden 796 Avenue', 'Omsk', 'Russia', '+71159986721', '2018-02-01', 'Female'),
-- ('Sophia', 'Rodrigues', 'sophia.rodrigues@me.com', 'Pine Willow 270 Avenue', 'Belo Horizonte', 'Brazil', '+557886384222', '2007-09-23', 'Other'),
-- ('Jesse', 'VandenBerg', 'jesse.vandenberg@hotmail.com', 'Willow Elm Hazel 549 Drive', 'Breda', 'Netherlands', '+312558387813', '2013-04-08', 'Female'),
-- ('Haruka', 'Watanabe', 'haruka.watanabe@outlook.com', 'Linden Maple Cherry Elm 216 Road', 'Osaka', 'Japan', '+817835964981', '1991-05-30', 'Male'),
-- ('Agustn', 'Prez', 'agustn.prez@protonmail.com', 'Cherry Beech 604 Road', 'Temuco', 'Chile', '+566769257067', '1989-07-11', 'Female'),
-- ('Patricia', 'Lpez', 'patricia.lpez@zoho.com', 'Willow Spruce Linden 824 Drive', 'Puebla', 'Mexico', '+529677514574', '1992-12-14', 'Female'),
-- ('Mara', 'Garca', 'mara.garca@fastmail.com', 'Maple Cherry 282 Avenue', 'Mexico City', 'Mexico', '+527588441009', '1994-01-06', 'Other'),
-- ('Aditya', 'Patel', 'aditya.patel@mail.com', 'Ash Spruce Maple 32 Street', 'Delhi', 'India', '+914481063679', '2000-07-18', 'Female'),
-- ('Alice', 'Souza', 'alice.souza@outlook.com', 'Beech Hazel Cedar Birch 950 Avenue', 'Curitiba', 'Brazil', '+553993473942', '2001-03-06', 'Other'),
-- ('Carmen', 'Lpez', 'carmen.lpez@yandex.com', 'Linden Maple Beech Ash 539 Avenue', 'Mexico City', 'Mexico', '+521055659889', '1995-02-06', 'Female'),
-- ('Miguel', 'Oliveira', 'miguel.oliveira@proton.me', 'Maple Spruce 442 Road', 'Manaus', 'Brazil', '+553643873377', '1997-01-19', 'Female'),
-- ('Charlotte', 'Roy', 'charlotte.roy@fastmail.com', 'Beech Oak Ivy 216 Drive', 'Toronto', 'Canada', '+17072687046', '1993-09-16', 'Other'),
-- ('Alessandro', 'Esposito', 'alessandro.esposito@mail.com', 'Ash Ivy Willow 423 Avenue', 'Bari', 'Italy', '+391674139630', '1998-06-08', 'Male'),
-- ('Luca', 'Fernndez', 'luca.fernndez@icloud.com', 'Birch Cherry Pine 17 Street', 'Bilbao', 'Spain', '+346366071916', '1989-08-07', 'Male'),
-- ('Valentina', 'Rodrigues', 'valentina.rodrigues@zoho.com', 'Willow Elm Hazel Ash 1014 Drive', 'Brasília', 'Brazil', '+558375972159', '2004-04-21', 'Female'),
-- ('Mateo', 'Prez', 'mateo.prez@protonmail.com', 'Beech Hazel Cedar Birch 950 Avenue', 'Chillán', 'Chile', '+562155458951', '2005-12-14', 'Female'),
-- ('Arjun', 'Patel', 'arjun.patel@hotmail.com', 'Maple Spruce 442 Road', 'Kolkata', 'India', '+915578089436', '2000-03-12', 'Male'),
-- ('Harry', 'Taylor', 'harry.taylor@mail.com', 'Linden Hazel 945 Street', 'London', 'UK', '+442084609371', '2005-07-09', 'Male'),
-- ('Aurora', 'Rossi', 'aurora.rossi@yahoo.com', 'Birch Cherry Pine 17 Street', 'Rome', 'Italy', '+397499188666', '2000-07-26', 'Other'),
-- ('Seoyeon', 'Lee', 'seoyeon.lee@fastmail.com', 'Linden Oak Ash 923 Drive', 'Daejeon', 'South Korea', '+822930735727', '1991-09-29', 'Female'),
-- ('Rodrigo', 'Lpez', 'rodrigo.lpez@gmail.com', 'Elm Hazel Cedar Ash 252 Drive', 'Maldonado', 'Uruguay', '+5986520076159', '1997-04-17', 'Male'),
-- ('Huan', 'Chen', 'huan.chen@outlook.com', 'Ash Ivy Willow 423 Avenue', 'Beijing', 'China', '+867975317402', '1996-03-31', 'Other'),
-- ('Mateo', 'Rodrguez', 'mateo.rodrguez@aol.com', 'Linden Oak Ash 923 Drive', 'Mercedes', 'Uruguay', '+5982923262367', '2000-03-17', 'Male'),
-- ('James', 'Smith', 'james.smith@zoho.com', 'Ash Ivy 437 Avenue', 'Philadelphia', 'USA', '+15327636578', '2002-12-25', 'Other'),
-- ('Juhani', 'Mkel', 'juhani.mkel@me.com', 'Ash Beech Linden 302 Drive', 'Turku', 'Finland', '+3588203633562', '1994-06-10', 'Other'),
-- ('William', 'Larsson', 'william.larsson@protonmail.com', 'Linden Cherry Maple 499 Street', 'Uppsala', 'Sweden', '+461138699519', '1990-08-24', 'Male'),
-- ('William', 'Nielsen', 'william.nielsen@hushmail.com', 'Holly Hazel Oak 891 Avenue', 'Aarhus', 'Denmark', '+459425192693', '1999-02-13', 'Female'),
-- ('Arthur', 'Rodrigues', 'arthur.rodrigues@gmx.com', 'Birch Cherry Pine 17 Street', 'Manaus', 'Brazil', '+555956255794', '2000-01-03', 'Other'),
-- ('Harry', 'Brown', 'harry.brown@gmail.com', 'Cherry Birch Maple Ivy 573 Avenue', 'Birmingham', 'UK', '+444045261922', '1990-03-10', 'Male'),
-- ('Maria', 'Virtanen', 'maria.virtanen@yahoo.com', 'Ivy Oak Cherry 345 Avenue', 'Oulu', 'Finland', '+3584360068116', '2003-07-20', 'Male'),
-- ('Oliver', 'Taylor', 'oliver.taylor@hushmail.com', 'Cherry Beech 604 Road', 'Glasgow', 'UK', '+444184837850', '1996-01-30', 'Other'),
-- ('Hina', 'Takahashi', 'hina.takahashi@msn.com', 'Maple Spruce 442 Road', 'Osaka', 'Japan', '+813898064596', '1994-07-11', 'Other'),
-- ('Michael', 'Brown', 'michael.brown@msn.com', 'Holly Spruce Elm Birch 1110 Avenue', 'Los Angeles', 'USA', '+17366317207', '1989-12-07', 'Male'),
-- ('Ida', 'Jensen', 'ida.jensen@icloud.com', 'Ivy Hazel Elm Birch 292 Street', 'Aarhus', 'Denmark', '+454955203818', '1992-06-22', 'Other'),
-- ('Paula', 'Fernndez', 'paula.fernndez@tutanota.com', 'Beech Oak Cherry Willow 69 Avenue', 'Palma', 'Spain', '+349272220517', '1972-01-10', 'Female'),
-- ('Juana', 'Gonzlez', 'juana.gonzlez@hushmail.com', 'Hazel Ivy Birch 841 Avenue', 'Monterrey', 'Mexico', '+524640454671', '1987-09-02', 'Other'),
-- ('Sophia', 'Oliveira', 'sophia.oliveira@yandex.com', 'Birch Elm 843 Street', 'Porto Alegre', 'Brazil', '+556828590116', '1977-11-26', 'Other'),
-- ('Ava', 'Roy', 'ava.roy@protonmail.com', 'Elm Linden Birch Beech 189 Avenue', 'Calgary', 'Canada', '+12277667988', '1979-02-04', 'Male'),
-- ('Antero', 'Korhonen', 'antero.korhonen@gmx.com', 'Cedar Beech 1067 Drive', 'Oulu', 'Finland', '+3581711084153', '1974-03-15', 'Other'),
-- ('Sophia', 'Brown', 'sophia.brown@fastmail.com', 'Cedar Maple 714 Street', 'Mississauga', 'Canada', '+11379191984', '1972-03-22', 'Male'),
-- ('Aurora', 'Russo', 'aurora.russo@fastmail.com', 'Holly Spruce 431 Drive', 'Turin', 'Italy', '+396156803134', '1969-05-26', 'Other'),
-- ('Oskar', 'Hansen', 'oskar.hansen@gmx.com', 'Elm Ivy 1029 Road', 'Sarpsborg', 'Norway', '+471252588013', '1973-01-08', 'Female'),
-- ('Lucas', 'Rodrguez', 'lucas.rodrguez@outlook.com', 'Elm Birch Ash 259 Road', 'Bilbao', 'Spain', '+347845293362', '1976-03-25', 'Female'),
-- ('Jennifer', 'Jones', 'jennifer.jones@aol.com', 'Elm Spruce Willow Birch 251 Drive', 'Philadelphia', 'USA', '+11389175356', '1979-06-21', 'Female'),
-- ('Sophia', 'Mller', 'sophia.mller@hotmail.com', 'Beech Oak Cherry Willow 69 Avenue', 'Cologne', 'Germany', '+496621973536', '1976-07-22', 'Other'),
-- ('Noah', 'Brown', 'noah.brown@gmail.com', 'Birch Oak 1126 Drive', 'Vancouver', 'Canada', '+15361050418', '1969-09-29', 'Female'),
-- ('Vikram', 'Singh', 'vikram.singh@mail.com', 'Hazel Ash Holly Elm 1184 Drive', 'Chennai', 'India', '+914521566726', '1981-12-27', 'Other'),
-- ('Noah', 'Smith', 'noah.smith@zoho.com', 'Cedar Willow Ivy 1193 Drive', 'Edinburgh', 'UK', '+449759808197', '1976-05-31', 'Other'),
-- ('Gabriel', 'Silva', 'gabriel.silva@aol.com', 'Willow Linden 764 Avenue', 'São Paulo', 'Brazil', '+553469476757', '1982-11-07', 'Other'),
-- ('Siwoo', 'Kim', 'siwoo.kim@mail.com', 'Ivy Ash Beech Holly 550 Avenue', 'Daegu', 'South Korea', '+829915806212', '1963-06-21', 'Female'),
-- ('Helena', 'Souza', 'helena.souza@proton.me', 'Beech Maple Ash 96 Avenue', 'Recife', 'Brazil', '+554650113478', '1968-07-17', 'Male'),
-- ('Siwoo', 'Choi', 'siwoo.choi@zoho.com', 'Pine Elm 135 Drive', 'Seongnam', 'South Korea', '+821018911425', '1967-04-28', 'Male'),
-- ('Mary', 'Brown', 'mary.brown@aol.com', 'Hazel Ash Holly Elm 1184 Drive', 'New York', 'USA', '+15888187947', '1987-02-04', 'Female'),
-- ('William', 'Andersen', 'william.andersen@gmail.com', 'Beech Hazel Cherry 1005 Drive', 'Horsens', 'Denmark', '+454571866101', '1963-09-09', 'Female'),
-- ('Santiago', 'Gonzlez', 'santiago.gonzlez@zoho.com', 'Holly Ivy Beech 1100 Avenue', 'Mar del Plata', 'Argentina', '+549927969441', '1962-05-21', 'Other'),
-- ('George', 'Taylor', 'george.taylor@me.com', 'Cedar Beech 1067 Drive', 'Manchester', 'UK', '+446798065497', '1982-07-25', 'Other'),
-- ('Ananya', 'Singh', 'ananya.singh@yahoo.com', 'Oak Linden Ivy 1194 Road', 'Kolkata', 'India', '+916946764835', '1970-08-03', 'Other'),
-- ('Filip', 'Johansen', 'filip.johansen@tutanota.com', 'Elm Ivy 1029 Road', 'Oslo', 'Norway', '+472937555644', '1960-05-28', 'Female'),
-- ('Michael', 'Williams', 'michael.williams@me.com', 'Cedar Holly Maple 521 Avenue', 'San Diego', 'USA', '+12186283788', '1971-02-18', 'Female'),
-- ('Emily', 'Walsh', 'emily.walsh@yahoo.com', 'Hazel Maple Cedar Ash 924 Avenue', 'Galway', 'Ireland', '+3533492043005', '1980-11-27', 'Male'),
-- ('Ananya', 'Patel', 'ananya.patel@hushmail.com', 'Beech Ash Cherry 548 Avenue', 'Kolkata', 'India', '+918728343652', '1983-11-12', 'Female'),
-- ('Aadhya', 'Singh', 'aadhya.singh@gmail.com', 'Hazel Maple Cedar Ash 924 Avenue', 'Ahmedabad', 'India', '+918116008221', '1982-04-27', 'Other'),
-- ('Jakob', 'Hansen', 'jakob.hansen@live.com', 'Linden Holly 875 Road', 'Kristiansand', 'Norway', '+477958924026', '1949-10-18', 'Female'),
-- ('Jiho', 'Kim', 'jiho.kim@gmx.com', 'Holly Spruce Elm Birch 1110 Avenue', 'Busan', 'South Korea', '+821232307621', '1953-04-07', 'Male'),
-- ('Diya', 'Kumar', 'diya.kumar@outlook.com', 'Linden Maple Cherry Elm 216 Road', 'Delhi', 'India', '+917725317715', '1945-02-17', 'Other'),
-- ('Liam', 'Martin', 'liam.martin@yandex.com', 'Beech Oak Holly Birch 446 Street', 'Montreal', 'Canada', '+18345221203', '1929-11-01', 'Other'),
-- ('Ivan', 'Popov', 'ivan.popov@gmail.com', 'Cedar Maple 714 Street', 'Rostov-on-Don', 'Russia', '+73903695562', '1954-01-17', 'Other'),
-- ('Jade', 'Thomas', 'jade.thomas@yahoo.com', 'Cedar Willow Ivy 1193 Drive', 'Strasbourg', 'France', '+331872149545', '1952-12-12', 'Female'),
-- ('Santiago', 'Fernndez', 'santiago.fernndez@gmail.com', 'Maple Beech Cedar 1061 Avenue', 'Córdoba', 'Argentina', '+545532396779', '1958-09-16', 'Male'),
-- ('Fang', 'Wang', 'fang.wang@msn.com', 'Hazel Ash Cherry 447 Road', 'Beijing', 'China', '+869114552575', '1957-04-22', 'Female'),
-- ('Pedro', 'Rodrigues', 'pedro.rodrigues@msn.com', 'Ivy Beech 1185 Avenue', 'Brasília', 'Brazil', '+559090184393', '1933-12-19', 'Female'),
-- ('Pablo', 'Lpez', 'pablo.lpez@fastmail.com', 'Cedar Holly Maple 521 Avenue', 'Seville', 'Spain', '+348511737503', '1937-08-18', 'Other'),
-- ('Jennifer', 'Brown', 'jennifer.brown@outlook.com', 'Cherry Beech 604 Road', 'San Jose', 'USA', '+16100359013', '1944-07-09', 'Female'),
-- ('Oliver', 'Larsson', 'oliver.larsson@fastmail.com', 'Pine Birch 264 Avenue', 'Stockholm', 'Sweden', '+467047800763', '1952-09-09', 'Other'),
-- ('Mateo', 'Prez', 'mateo.prez@icloud.com', 'Ash Ivy 437 Avenue', 'Maldonado', 'Uruguay', '+5988637855161', '1954-07-31', 'Male'),
-- ('Emilia', 'Prez', 'emilia.prez@aol.com', 'Spruce Cedar Linden 464 Avenue', 'Salto', 'Uruguay', '+5983168881051', '1946-07-28', 'Male'),
-- ('Emma', 'Gonzlez', 'emma.gonzlez@hushmail.com', 'Linden Oak Ash 923 Drive', 'Tucumán', 'Argentina', '+542085016019', '1956-12-14', 'Female'),
-- ('Mateo', 'Gonzlez', 'mateo.gonzlez@tutanota.com', 'Cherry Birch 661 Road', 'Rosario', 'Argentina', '+546340635216', '1953-01-28', 'Female'),
-- ('Rodrigo', 'Fernndez', 'rodrigo.fernndez@live.com', 'Linden Maple Beech Ash 539 Avenue', 'Melo', 'Uruguay', '+5987574943170', '1930-11-14', 'Male'),
-- ('Leon', 'Mller', 'leon.mller@protonmail.com', 'Cedar Willow 906 Street', 'Frankfurt', 'Germany', '+491257380309', '1955-11-15', 'Other'),
-- ('Jiwoo', 'Jung', 'jiwoo.jung@hushmail.com', 'Ivy Hazel Beech Oak 452 Drive', 'Daejeon', 'South Korea', '+828470555129', '1958-09-04', 'Female'),
-- ('Lucas', 'Larsen', 'lucas.larsen@yahoo.com', 'Holly Ivy Beech 1100 Avenue', 'Stavanger', 'Norway', '+472238263145', '1950-01-01', 'Other'),
-- ('Noah', 'Hansen', 'noah.hansen@outlook.com', 'Maple Beech Cedar 1061 Avenue', 'Horsens', 'Denmark', '+456295722215', '1936-02-05', 'Male'),
-- ('Martina', 'Prez', 'martina.prez@fastmail.com', 'Beech Oak Holly Birch 446 Street', 'Paysandú', 'Uruguay', '+5983383742542', '1931-07-30', 'Other'),
-- ('Isabella', 'Gonzlez', 'isabella.gonzlez@proton.me', 'Hazel Ash Cherry 447 Road', 'Arica', 'Chile', '+564844846908', '1940-03-12', 'Male'),
-- ('Vicente', 'Rojas', 'vicente.rojas@tutanota.com', 'Hazel Ash Holly Elm 1184 Drive', 'Concepción', 'Chile', '+567258856392', '1957-01-03', 'Female'),
-- ('Matteo', 'Esposito', 'matteo.esposito@tutanota.com', 'Linden Maple Cherry Elm 216 Road', 'Bari', 'Italy', '+399948331937', '1929-04-12', 'Other');

-- select * from v_population;
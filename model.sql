DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS buildings CASCADE;
DROP TABLE IF EXISTS service_type CASCADE;
DROP TABLE IF EXISTS type_of_guest CASCADE;
DROP TABLE IF EXISTS room_types CASCADE;
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS complaints CASCADE;
DROP TABLE IF EXISTS reservations CASCADE;
DROP TABLE IF EXISTS room_reservations CASCADE;
DROP TABLE IF EXISTS services CASCADE;
DROP TABLE IF EXISTS services_used CASCADE;
DROP TABLE IF EXISTS service_in_building CASCADE;



-- might need postgresql superuser rights to set requested format of date
DO
$$
    BEGIN
        EXECUTE format('ALTER DATABASE %I SET DATESTYLE TO German', current_database());
    END;
$$;

CREATE TABLE IF NOT EXISTS bd_hotel.clients
(
    client_id   BIGINT PRIMARY KEY,
    first_name  VARCHAR(128) NOT NULL,
    second_name VARCHAR(128) NOT NULL,
    phone       VARCHAR,
    duty        numeric DEFAULT 0
--     CONSTRAINT ck_pi_phone CHECK (phone ~ '^\+7[0-9]{10}$')
);

CREATE TABLE IF NOT EXISTS bd_hotel.buildings
(
    number         BIGINT PRIMARY KEY,
    rate           SMALLINT,
    floors         SMALLINT,
    rooms_quantity BIGINT NOT NULL,
    rooms_on_floor BIGINT NOT NULL,
    CHECK (rooms_quantity > 0 AND rate > 0 AND rate < 6),
    CHECK (floors > 0 AND rooms_on_floor > 0)
);

CREATE TABLE IF NOT EXISTS bd_hotel.service_type
(
    type_id BIGINT PRIMARY KEY,
    name    VARCHAR(128) NOT NULL
);

CREATE TABLE IF NOT EXISTS bd_hotel.type_of_guest
(
    guest_id BIGINT PRIMARY KEY,
    name     VARCHAR NOT NULL,
    discount NUMERIC,
    CHECK (discount >= 0 AND discount < 100)
);

CREATE TABLE IF NOT EXISTS bd_hotel.room_types
(
    room_type_id    BIGINT PRIMARY KEY ,
    room_area       SMALLINT NOT NULL,
    building_num    BIGINT,
    price_per_night NUMERIC  NOT NULL,
    FOREIGN KEY (building_num) REFERENCES bd_hotel.buildings,
    CHECK (room_area > 0 AND price_per_night > 0)
);

CREATE TABLE IF NOT EXISTS bd_hotel.rooms
(
    room_id      BIGINT PRIMARY KEY,
    number       BIGINT   NOT NULL,
    room_type_id BIGINT,
    floor        SMALLINT NOT NULL,
    FOREIGN KEY (room_type_id) REFERENCES bd_hotel.room_types,
    CHECK (floor > 0 AND number > 0)
);

CREATE TABLE IF NOT EXISTS bd_hotel.complaints
(
    complaint_id BIGINT PRIMARY KEY,
    person_id    BIGINT DEFAULT 1,
    info         VARCHAR(1024),
    FOREIGN KEY (person_id) REFERENCES bd_hotel.clients ON DELETE SET DEFAULT
);

CREATE TABLE IF NOT EXISTS bd_hotel.reservations
(
    reserve_id   BIGINT PRIMARY KEY,
    room_type_id BIGINT,
    floor        SMALLINT NOT NULL,
    FOREIGN KEY (room_type_id) REFERENCES bd_hotel.room_types,
    CHECK (floor > 0)
);

CREATE TABLE IF NOT EXISTS bd_hotel.room_reservations
(
    id             BIGINT PRIMARY KEY,
    person_id      BIGINT DEFAULT 1,
    reservation_id BIGINT,
    room_id        BIGINT,
    FOREIGN KEY (person_id) REFERENCES bd_hotel.clients ON DELETE SET DEFAULT,
    FOREIGN KEY (reservation_id) REFERENCES bd_hotel.reservations ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES bd_hotel.rooms
);




CREATE TABLE IF NOT EXISTS bd_hotel.services
(
    service_id BIGINT PRIMARY KEY,
    type_id    BIGINT DEFAULT 1,
    name       VARCHAR(128) NOT NULL,
    price      NUMERIC      NOT NULL,
    CHECK (price > 0),
    FOREIGN KEY (type_id) REFERENCES bd_hotel.service_type ON DELETE SET DEFAULT
);


CREATE TABLE IF NOT EXISTS bd_hotel.services_used
(
    id         BIGINT PRIMARY KEY,
    person_id  BIGINT,
    service_id BIGINT,
    FOREIGN KEY (person_id) REFERENCES bd_hotel.clients,
    FOREIGN KEY (service_id) REFERENCES bd_hotel.services ON DELETE SET DEFAULT
);


CREATE TABLE IF NOT EXISTS bd_hotel.service_in_building
(
    service_id      bigint,
    building_number bigint,
    FOREIGN KEY (service_id) REFERENCES bd_hotel.services ON DELETE CASCADE,
    FOREIGN KEY (building_number) REFERENCES bd_hotel.buildings ON DELETE CASCADE
);





-- imports

CREATE OR REPLACE PROCEDURE import_csv(table_name VARCHAR, pth VARCHAR, delim VARCHAR) AS
$$
BEGIN
    EXECUTE format('TRUNCATE TABLE bd_hotel.%I CASCADE', table_name);
    EXECUTE format('COPY bd_hotel.%I FROM %L DELIMITER %L CSV HEADER', table_name, pth, delim);
END;
$$ LANGUAGE plpgsql;

-- exports

CREATE OR REPLACE PROCEDURE export_csv(table_name VARCHAR, pth VARCHAR, delim VARCHAR) AS
$$
BEGIN
    EXECUTE format('COPY %I TO %L DELIMITER %L CSV HEADER', table_name, pth, delim);
END;
$$ LANGUAGE plpgsql;

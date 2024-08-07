-- Building Info Table
CREATE TABLE building_information (
    building_id INT PRIMARY KEY,
    building_name VARCHAR(100),
    state VARCHAR(20),
    address VARCHAR(255),
    zipcode VARCHAR(10),
    leasing_office VARCHAR(100)
);

-- Owner Table
CREATE TABLE owner_information (
    building_id INT,
    owner_name VARCHAR(100),
    owner_contact VARCHAR(100),
    PRIMARY KEY (building_id),
    FOREIGN KEY (building_id) REFERENCES building_information(building_id)
);

-- Listing Table
CREATE TABLE listing_information (
    listing_id INT PRIMARY KEY,
    building_id INT,
    room_number INT,
    bedroom INT,
    bathroom INT,
    availability VARCHAR(50),
    price DECIMAL(10, 2),
    sqft INT,
    FOREIGN KEY (building_id) REFERENCES building_information(building_id)
);


-- House History Table
CREATE TABLE house_history (
    listing_id INT,
    customer_id INT,
    start_date DATE,
    end_date DATE,
    price DECIMAL(10, 2),
    PRIMARY KEY (listing_id, customer_id),
    FOREIGN KEY (listing_id) REFERENCES listing_information(listing_id)
);

-- Open House Event Table
CREATE TABLE open_house_event (
    event_id SERIAL PRIMARY KEY,
    building_id INT,
    event_type VARCHAR(100),
    event_date DATE,
    event_time VARCHAR(10),
    capacity INT,
    FOREIGN KEY (building_id) REFERENCES building_information(building_id)
);

-- Amenities Table
CREATE TABLE amenities (
    building_id INT,
    amenity_fee DECIMAL(10, 2),
    gym BOOLEAN,
    swimming_pool BOOLEAN,
    basketball_court BOOLEAN,
    parking BOOLEAN,
    lounge BOOLEAN,
    PRIMARY KEY (building_id),
    FOREIGN KEY (building_id) REFERENCES building_information(building_id)
);

-- Neighborhood Table
CREATE TABLE neighborhood (
    building_id INT,
    school INT,
    grocery_store INT,
    pharmacy INT,
    park INT,
    restaurant INT,
    bar INT,
    PRIMARY KEY (building_id),
    FOREIGN KEY (building_id) REFERENCES building_information(building_id)
);

-- School Table
CREATE TABLE school (
    building_id INT,
    school_id INT PRIMARY KEY,
    school_name VARCHAR(255),
    school_rating DECIMAL(3, 1),
    school_type VARCHAR(50),
    FOREIGN KEY (building_id) REFERENCES building_information(building_id)
);

-- Demographic Table
CREATE TABLE demographic (
    building_id INT,
    state VARCHAR(50),
    area VARCHAR(100),
    income_level DECIMAL(3, 1),
    criminal_rate_level DECIMAL(3, 1),
    PRIMARY KEY (building_id),
    FOREIGN KEY (building_id) REFERENCES building_information(building_id)
);

-- Customer Info Table
CREATE TABLE customer_information (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    contact VARCHAR(15),
    email VARCHAR(100),
    employee_id INT
);

-- Transaction Table
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    customer_id INT,
    building_id INT,
    transaction_date DATE,
    transaction_type VARCHAR(50),
    transaction_amount DECIMAL(10, 2),
    status VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customer_information(customer_id),
    FOREIGN KEY (building_id) REFERENCES building_information(building_id)
);

-- Employee Table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    position VARCHAR(100),
    contact_info VARCHAR(15),
    office_id INT
);

-- Agent Customer Table
CREATE TABLE agent_customer (
    employee_id INT,
    customer_id INT,
    interested_listing_id INT,
    PRIMARY KEY (employee_id, customer_id, interested_listing_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (customer_id) REFERENCES customer_information(customer_id),
    FOREIGN KEY (interested_listing_id) REFERENCES listing_information(listing_id)
);

-- Office Table
CREATE TABLE offices (
    office_id INT PRIMARY KEY,
    state VARCHAR(50),
    address VARCHAR(255)
);

-- Operational Cost Table
CREATE TABLE operational_cost (
    cost_id INT PRIMARY KEY,
    office_id INT,
    cost_type VARCHAR(50),
    cost_amount DECIMAL(10, 2),
    transaction_date DATE,
    employee_id INT,
    FOREIGN KEY (office_id) REFERENCES offices(office_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);




